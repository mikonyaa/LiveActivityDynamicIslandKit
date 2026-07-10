#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import Foundation
import LiveActivityKit

@available(iOS 16.1, *)
struct LiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable, Sendable {
        var model: LiveActivityContentModel
    }

    var scenario: LiveActivityScenario
    var activityID: String

}
#endif
