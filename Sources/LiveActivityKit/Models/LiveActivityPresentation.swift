import SwiftUI

/// A lifecycle hint that apps can use to style or interpret an activity state.
public enum LiveActivityPhase: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case preparing
    case active
    case attention
    case completed
    case failed

    public var id: String { rawValue }
}

/// The built-in accent choices supported by the package views.
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
