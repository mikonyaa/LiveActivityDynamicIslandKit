import SwiftUI

@main
struct LiveActivityDemoApp: App {
    @State private var controller = LiveActivityDemoController()

    var body: some Scene {
        WindowGroup {
            DemoRootView(controller: controller)
                .task {
                    await controller.restoreSession()
                }
                .onOpenURL { url in
                    controller.handle(url: url)
                }
        }
    }
}
