import Foundation
import SwiftUI

enum LiveActivityDemoLifecycle: Equatable, Sendable {
    case unavailable
    case idle
    case starting
    case active
    case updating
    case ending
    case ended
    case failed(String)

    var isBusy: Bool {
        switch self {
        case .starting, .updating, .ending:
            true
        default:
            false
        }
    }

    var canStart: Bool {
        switch self {
        case .idle, .ended, .failed:
            true
        default:
            false
        }
    }

    var canUpdate: Bool {
        self == .active
    }

    var canEnd: Bool {
        switch self {
        case .active, .updating:
            true
        default:
            false
        }
    }
}

struct DemoMessage: Identifiable, Equatable {
    enum Style {
        case neutral
        case success
        case warning

        var symbolName: String {
            switch self {
            case .neutral:
                "sparkles"
            case .success:
                "checkmark.circle.fill"
            case .warning:
                "exclamationmark.triangle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .neutral:
                .blue
            case .success:
                .green
            case .warning:
                .orange
            }
        }
    }

    let id = UUID()
    var title: String
    var detail: String
    var style: Style
}
