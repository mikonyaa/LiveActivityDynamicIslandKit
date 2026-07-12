import Foundation
import LiveActivityKit

enum LiveActivityScenario: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case delivery
    case ride
    case timer
    case sports
    case download
    case trip

    var id: String { rawValue }

    var title: String {
        switch self {
        case .delivery:
            "Delivery"
        case .ride:
            "Ride"
        case .timer:
            "Timer"
        case .sports:
            "Sports"
        case .download:
            "Transfer"
        case .trip:
            "Trip"
        }
    }

    var subtitle: String {
        switch self {
        case .delivery:
            "Package and courier progress"
        case .ride:
            "Driver, pickup, and arrival"
        case .timer:
            "Countdown and focus windows"
        case .sports:
            "Score, period, and game clock"
        case .download:
            "Sync, import, and export progress"
        case .trip:
            "Boarding, transfer, and arrival"
        }
    }

    var systemImage: String {
        switch self {
        case .delivery:
            "shippingbox.fill"
        case .ride:
            "car.fill"
        case .timer:
            "timer"
        case .sports:
            "sportscourt.fill"
        case .download:
            "arrow.down.circle.fill"
        case .trip:
            "tram.fill"
        }
    }

    var accent: LiveActivityAccent {
        switch self {
        case .delivery, .download:
            .blue
        case .ride:
            .teal
        case .timer:
            .indigo
        case .sports:
            .green
        case .trip:
            .amber
        }
    }
}
