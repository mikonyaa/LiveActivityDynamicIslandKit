import Foundation

struct LiveActivityDemoRoute: Equatable, Sendable {
    static let scheme = "liveactivitydemo"

    var scenario: LiveActivityScenario
    var stateID: String

    init(scenario: LiveActivityScenario, stateID: String) {
        self.scenario = scenario
        self.stateID = stateID
    }

    init?(url: URL) {
        guard url.scheme?.lowercased() == Self.scheme,
              url.host?.lowercased() == "scenario",
              url.pathComponents.count == 2,
              let scenario = LiveActivityScenario(rawValue: url.pathComponents[1]),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let stateID = components.queryItems?
                .first(where: { $0.name == "state" })?
                .value?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !stateID.isEmpty
        else { return nil }

        self.init(scenario: scenario, stateID: stateID)
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = "scenario"
        components.path = "/\(scenario.rawValue)"
        components.queryItems = [URLQueryItem(name: "state", value: stateID)]
        return components.url
    }
}
