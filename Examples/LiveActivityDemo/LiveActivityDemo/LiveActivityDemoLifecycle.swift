import Foundation

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
