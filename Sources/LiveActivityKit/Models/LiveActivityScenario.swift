import Foundation
import SwiftUI

public enum LiveActivityScenario: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case delivery
    case ride
    case timer
    case sports
    case download
    case trip

    public var id: String { rawValue }

    public var title: String {
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

    public var subtitle: String {
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

    public var systemImage: String {
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

    public var accent: LiveActivityAccent {
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

public enum LiveActivityPhase: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case preparing
    case active
    case attention
    case completed
    case failed

    public var id: String { rawValue }
}

public enum LiveActivityAccent: String, CaseIterable, Codable, Hashable, Sendable {
    case blue
    case teal
    case indigo
    case green
    case amber

    public var color: Color {
        switch self {
        case .blue:
            Color(red: 0.04, green: 0.48, blue: 1.0)
        case .teal:
            Color(red: 0.0, green: 0.58, blue: 0.62)
        case .indigo:
            Color(red: 0.34, green: 0.34, blue: 0.86)
        case .green:
            Color(red: 0.22, green: 0.57, blue: 0.31)
        case .amber:
            Color(red: 0.86, green: 0.52, blue: 0.12)
        }
    }
}
