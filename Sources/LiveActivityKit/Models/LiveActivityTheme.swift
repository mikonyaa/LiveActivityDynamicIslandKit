import SwiftUI

public struct LiveActivityPalette: Hashable, Sendable {
    public var background: Color
    public var elevatedBackground: Color
    public var primaryText: Color
    public var secondaryText: Color
    public var separator: Color
    public var accent: Color

    public init(
        background: Color,
        elevatedBackground: Color,
        primaryText: Color,
        secondaryText: Color,
        separator: Color,
        accent: Color
    ) {
        self.background = background
        self.elevatedBackground = elevatedBackground
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.separator = separator
        self.accent = accent
    }

    public static func porcelain(accent: LiveActivityAccent) -> LiveActivityPalette {
        LiveActivityPalette(
            background: Color(red: 0.965, green: 0.961, blue: 0.945),
            elevatedBackground: .white,
            primaryText: Color(red: 0.07, green: 0.075, blue: 0.085),
            secondaryText: Color(red: 0.35, green: 0.35, blue: 0.32),
            separator: Color(red: 0.84, green: 0.82, blue: 0.78),
            accent: accent.color
        )
    }
}

public enum LiveActivityTheme: String, CaseIterable, Identifiable, Sendable {
    case porcelain

    public var id: String { rawValue }

    public var title: String {
        "Porcelain"
    }

    public func palette(for accent: LiveActivityAccent, colorScheme _: ColorScheme) -> LiveActivityPalette {
        .porcelain(accent: accent)
    }
}
