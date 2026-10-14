import ActivityKit
import Foundation
import LiveActivityKit
import Observation
import Testing
@testable import LiveActivityDemo

@Suite("Controller interleavings", .serialized)
@MainActor
struct LiveActivityControllerTests {
    @Test("Browsing another recipe never updates an active session")
    func browseKeepsIdentity() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        controller.select(.sports)
        await settle()
        #expect(controller.selectedScenario == .sports)
        #expect(controller.currentModel.id == "sports-1")
        #expect(adapter.requests.first?.attributes.scenario == .delivery)
        #expect(adapter.updates.isEmpty)
    }

    @Test("End during suspended update is retained exactly once and blocks later updates")
    func terminalEndWins() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        adapter.suspendUpdates = true
        let update = Task { await controller.updateActivity() }
        await settle()
        #expect(adapter.updates.count == 1)
        await controller.endActivity()
        await controller.endActivity()
        controller.nextState()
        await settle()
        adapter.releaseUpdate()
        await update.value
        await settle()
        #expect(adapter.endings.count == 1)
        #expect(adapter.updates.count == 1)
        #expect(controller.lifecycle == .ended)
        #expect(!controller.canEndActivity)
    }

    @Test("Start availability notifies its view after a terminal event precedes End completion")
    func startAvailabilityAfterEarlyTerminalEvent() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        adapter.suspendEnd = true
        let ending = Task { await controller.endActivity() }
        await settle()
        #expect(adapter.endings.count == 1)
        adapter.emit(.ended)
        await settle()
        #expect(controller.lifecycle == .ended)
        #expect(controller.activeSession == nil)
        #expect(!controller.canStartActivity)

        // Track only after terminal mutations, so they cannot satisfy this assertion.
        let changes = AsyncStream<Void>.makeStream()
        withObservationTracking {
            _ = controller.canStartActivity
        } onChange: {
            changes.continuation.yield(())
        }
        adapter.releaseEnd()
        await ending.value
        changes.continuation.finish()
        var changeCount = 0
        for await _ in changes.stream { changeCount += 1 }
        #expect(changeCount == 1)
        #expect(controller.canStartActivity)
        await controller.startActivity()
        #expect(adapter.requests.count == 2)
    }

    @Test("Invalid ongoing content never reports successful restoration")
    func invalidRestore() async {
        let adapter = FakeLiveActivityAdapter()
        var model = LiveActivityRecipes.state(for: .sports, index: 1)
        model.id = "legacy-unknown-state"
        adapter.sessions = [DemoActivitySession(
            id: "legacy", attributes: LiveActivityAttributes(scenario: .delivery, activityID: "delivery-1"),
            content: ActivityContent(state: .init(model: model), staleDate: nil), state: .active
        )]
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.restoreSession()
        #expect(controller.selectedScenario == .delivery)
        #expect(controller.selectedStateIndex == 0)
        #expect(controller.statusMessage.style == .warning)
    }

    @Test("System terminal event overrides a prior running success message")
    func terminalStatus() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        await settle()
        adapter.emit(.dismissed)
        await settle()
        #expect(controller.lifecycle == .ended)
        #expect(!controller.statusMessage.title.lowercased().contains("running"))
        #expect(!controller.canEndActivity)
    }

    @Test("End sends explicit nil staleDate with session content")
    func endHasNoStaleDate() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        controller.select(.sports)
        await settle()
        await controller.endActivity()
        #expect(adapter.endings.first?.1.staleDate == nil)
        #expect(adapter.endings.first?.1.state.model.id == "delivery-1")
    }

    @Test("Authorization enabling after restore restores available Start")
    func permissionRecovery() async {
        let adapter = FakeLiveActivityAdapter()
        adapter.areActivitiesEnabled = false
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.restoreSession()
        await settle()
        #expect(!controller.canStartActivity)
        adapter.setEnabled(true)
        await settle()
        #expect(controller.canStartActivity)
    }

    private func settle() async {
        // Yield executor turns, not wall-clock sleeps. Adapter operations remain deterministic.
        for _ in 0..<20 { await Task.yield() }
    }

    @Test("Controller lifetime cancels both owned observation streams")
    func observerLifetime() async {
        let adapter = FakeLiveActivityAdapter()
        var controller: LiveActivityDemoController? = LiveActivityDemoController(adapter: adapter)
        weak var weakController = controller
        await controller?.startActivity()
        await settle()
        controller = nil
        await settle()
        #expect(weakController == nil)
        #expect(adapter.stateTerminations["session-1"] == 1)
        #expect(adapter.authorizationTerminations == 1)
    }

    @Test("Route rejection has separate feedback without replacing running or terminal status")
    func rejectedRouteFeedback() async throws {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        controller.select(.sports)
        let invalid = try #require(URL(string: "liveactivitydemo://scenario/ride/extra?state=ride-2"))
        #expect(!controller.handle(url: invalid))
        #expect(controller.routeFeedback?.style == .warning)
        #expect(controller.statusMessage.title.contains("Delivery"))
        #expect(controller.navigationPath == [.sports])
        await controller.endActivity()
        #expect(!controller.handle(url: invalid))
        #expect(controller.routeFeedback?.style == .warning)
        #expect(controller.lifecycle == .ended)
    }

    @Test("Failed suspended update still honors terminal End")
    func updateFailureWithEnd() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        adapter.suspendUpdates = true
        adapter.updateError = .payloadTooLarge(bytes: 5000)
        let update = Task { await controller.updateActivity() }
        await settle()
        await controller.endActivity()
        adapter.releaseUpdate()
        await update.value
        #expect(adapter.endings.count == 1)
        #expect(controller.lifecycle == .ended)
    }

    @Test("Failed End retains the session for an explicit retry")
    func endFailureRetry() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        adapter.endError = .missingSession
        await controller.endActivity()
        #expect(controller.activeSession?.id == "session-1")
        #expect(controller.canEndActivity)
        #expect(controller.statusMessage.style == .warning)
        adapter.endError = nil
        await controller.endActivity()
        #expect(adapter.endings.count == 1)
        #expect(controller.lifecycle == .ended)
    }

    @Test("A URL cannot change an update intent already chosen by a state action")
    func queuedStateBeforeURL() async throws {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        controller.selectState(at: 1)
        controller.handle(url: try #require(URL(string: "liveactivitydemo://scenario/delivery?state=delivery-4")))
        await settle()
        #expect(controller.currentModel.id == "delivery-4")
        #expect(adapter.updates.last?.1.state.model.id == "delivery-2")
    }

    @Test("Foreground restore refreshes system content until the user explicitly selects a preview")
    func refreshedRestoredContent() async {
        let adapter = FakeLiveActivityAdapter()
        adapter.sessions = [DemoActivitySession(
            id: "restored", attributes: LiveActivityAttributes(scenario: .sports, activityID: "sports-1"),
            content: ActivityContent(state: .init(model: LiveActivityRecipes.sports.states[1]), staleDate: nil), state: .active
        )]
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.restoreSession()
        adapter.sessions[0].content = ActivityContent(state: .init(model: LiveActivityRecipes.sports.states[2]), staleDate: nil)
        await controller.reconcileForeground()
        #expect(controller.currentModel.id == "sports-3")
        #expect(controller.selectedStateIndex == 2)
        await controller.endActivity()
        #expect(adapter.endings.last?.1.state.model.id == "sports-3")
    }

}

extension LiveActivityControllerTests {
    @Test("Burst updates coalesce to the latest matching recipe snapshot")
    func burstUpdates() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        adapter.suspendUpdates = true
        let first = Task { await controller.updateActivity() }
        await settle()
        controller.selectState(at: 1)
        await controller.updateActivity()
        controller.selectState(at: 2)
        await controller.updateActivity()
        controller.selectState(at: 3)
        await controller.updateActivity()
        await settle()
        adapter.releaseUpdate()
        await first.value
        #expect(adapter.updates.count == 2)
        #expect(adapter.updates.last?.1.state.model.id == "delivery-4")
        #expect(controller.lifecycle == .active)
    }

    @Test("System dismissal during await cannot be revived by update completion")
    func dismissalDuringUpdate() async {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        adapter.suspendUpdates = true
        let update = Task { await controller.updateActivity() }
        await settle()
        adapter.emit(.dismissed)
        await settle()
        adapter.releaseUpdate()
        await update.value
        #expect(controller.lifecycle == .ended)
        #expect(controller.activeSession == nil)
        #expect(adapter.endings.isEmpty)
    }

    @Test("Explicit end then start switches both attributes and widget identity")
    func explicitSwitchAndOldEvents() async throws {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        controller.select(.sports)
        #expect(!controller.canStartActivity)
        await controller.endActivity()
        await controller.startActivity()
        #expect(adapter.requests.count == 2)
        #expect(controller.activeSession?.attributes.scenario == .sports)
        #expect(controller.activeSession?.content.state.model.id == "sports-1")
        let session = try #require(controller.activeSession)
        let route = LiveActivityDemoRoute(scenario: session.attributes.scenario, stateID: session.content.state.model.id)
        #expect(route.url?.absoluteString == "liveactivitydemo://scenario/sports?state=sports-1")
        adapter.emit(.active, id: "session-1")
        adapter.emit(.dismissed, id: "session-1")
        await settle()
        #expect(controller.activeSession?.id == "session-2")
        #expect(controller.lifecycle == .active)
        #expect(adapter.stateTerminations["session-1"] == 1)
    }

    @Test("Every actual URL applies one matching destination without changing the session")
    func allRoutes() async throws {
        let adapter = FakeLiveActivityAdapter()
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.startActivity()
        for scenario in LiveActivityScenario.allCases {
            for index in 1...4 {
                let url = try #require(URL(string: "liveactivitydemo://scenario/\(scenario.rawValue)?state=\(scenario.rawValue)-\(index)"))
                #expect(controller.handle(url: url))
                #expect(controller.handle(url: url))
                #expect(controller.navigationPath == [scenario])
                #expect(controller.selectedScenario == scenario)
                #expect(controller.currentModel.id == "\(scenario.rawValue)-\(index)")
                #expect(controller.selectedStateIndex == index - 1)
                await controller.restoreSession()
                #expect(controller.currentModel.id == "\(scenario.rawValue)-\(index)")
                #expect(controller.navigationPath == [scenario])
            }
        }
        #expect(adapter.updates.isEmpty)
        #expect(controller.activeSession?.attributes.scenario == .delivery)
        #expect(!controller.handle(url: try #require(URL(string: "liveactivitydemo://scenario/ride?state=ride-99"))))
        #expect(controller.currentModel.id == "trip-4")
        #expect(controller.navigationPath == [.trip])
    }

    @Test("Restoration uses current validated system content and permission changes retain the handle")
    func validRestoreAndPermission() async {
        let adapter = FakeLiveActivityAdapter()
        let model = LiveActivityRecipes.sports.states[2]
        adapter.sessions = [DemoActivitySession(
            id: "restored", attributes: LiveActivityAttributes(scenario: .sports, activityID: "sports-1"),
            content: ActivityContent(state: .init(model: model), staleDate: nil), state: .stale
        )]
        let controller = LiveActivityDemoController(adapter: adapter)
        await controller.restoreSession()
        #expect(controller.currentModel.id == "sports-3")
        #expect(controller.navigationPath == [.sports])
        #expect(controller.lifecycle == .stale)
        #expect(controller.statusMessage.style == .warning)
        adapter.setEnabled(false)
        await settle()
        #expect(!controller.canUpdateActivity)
        #expect(controller.canEndActivity)
        #expect(controller.activeSession?.id == "restored")
        adapter.setEnabled(true)
        await controller.reconcileForeground()
        #expect(controller.canUpdateActivity)
        await controller.endActivity()
        #expect(adapter.endings.first?.0 == "restored")
        #expect(controller.lifecycle == .ended)
    }
}
