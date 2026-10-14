import SwiftUI

@main
struct LiveActivityDemoApp: App {
    @State private var controller = LiveActivityDemoController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            DemoRootView(controller: controller)
                .task {
                    await controller.restoreSession()
                }
                .onOpenURL { url in
                    controller.handle(url: url)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await controller.reconcileForeground() }
                    }
                }
        }
    }
}
