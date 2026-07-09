#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import Foundation

@available(iOS 16.1, *)
public struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var model: LiveActivityContentModel

        public init(model: LiveActivityContentModel) {
            self.model = model
        }
    }

    public var scenario: LiveActivityScenario
    public var activityID: String

    public init(
        scenario: LiveActivityScenario,
        activityID: String
    ) {
        self.scenario = scenario
        self.activityID = activityID
    }
}
#endif
