extension LiveActivityDemoController {
    var statusMessage: DemoMessage {
        if !liveActivitiesEnabled {
            return DemoMessage(
                title: "Live Activities unavailable",
                detail: "Enable Live Activities in Settings, then return. You can still end an existing session.",
                style: .warning
            )
        }
        switch lifecycle {
        case .unavailable:
            return DemoMessage(title: "Live Activities unavailable", detail: "Return from Settings to refresh authorization.", style: .warning)
        case .ended:
            return DemoMessage(
                title: "Live Activity ended",
                detail: "The system may keep the final state briefly or dismiss it independently of the app.", style: .neutral
            )
        case .stale:
            return DemoMessage(title: "Live Activity stale", detail: "The current content has expired. Update or end this session.", style: .warning)
        case .failed(let detail):
            return DemoMessage(title: "ActivityKit error", detail: detail, style: .warning)
        case .starting, .updating, .ending:
            return DemoMessage(title: "Applying lifecycle change", detail: "ActivityKit is updating the system presentation.", style: .neutral)
        case .active:
            if let activeSession, activeSession.attributes.scenario != selectedScenario {
                return DemoMessage(
                    title: "\(activeSession.attributes.scenario.title) Live Activity running",
                    detail: "Browsing this recipe does not update it. End \(activeSession.attributes.scenario.title) before pressing Start here.",
                    style: .neutral
                )
            }
            return message ?? DemoMessage(
                title: "Live Activity running", detail: "State actions update this session; links only navigate to their snapshot.", style: .success
            )
        case .idle:
            return message ?? DemoMessage(
                title: "Ready for local preview", detail: "Choose a recipe and press Start to see the system surfaces.", style: .neutral
            )
        }
    }
}
