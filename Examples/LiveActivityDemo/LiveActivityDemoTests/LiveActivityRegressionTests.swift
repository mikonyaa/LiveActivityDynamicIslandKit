import Foundation
import Testing
@testable import LiveActivityDemo

@Suite("Routing regressions")
struct LiveActivityRoutingRegressionTests {
    @Test("Ambiguous URL state parameters are rejected")
    func rejectsAmbiguousState() throws {
        let url = try #require(URL(string: "liveactivitydemo://scenario/delivery?state=delivery-1&state=sports-2"))
        #expect(LiveActivityDemoRoute(url: url) == nil)
    }
}
