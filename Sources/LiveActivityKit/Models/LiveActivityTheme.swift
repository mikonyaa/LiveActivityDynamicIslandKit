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

    /// The built-in dark palette used by ``LiveActivityAppearance/porcelain(accent:)``.
    public static func porcelainDark(accent: LiveActivityAccent) -> LiveActivityPalette {
        LiveActivityPalette(
            background: Color(red: 0.09, green: 0.09, blue: 0.10),
            elevatedBackground: Color(red: 0.14, green: 0.14, blue: 0.15),
            primaryText: .white,
            secondaryText: Color.white.opacity(0.68),
            separator: Color.white.opacity(0.16),
            accent: accent.color
        )
    }
}

/// A pair of app-defined palettes for adaptive Lock Screen and preview surfaces.
///
/// Use this value when the built-in porcelain theme does not match your brand.
/// Dynamic Island views continue to respect the system's dark presentation.
public struct LiveActivityAppearance: Hashable, Sendable {
    public var light: LiveActivityPalette
    public var dark: LiveActivityPalette

    public init(light: LiveActivityPalette, dark: LiveActivityPalette) {
        self.light = light
        self.dark = dark
    }

    /// Returns the palette appropriate for the current SwiftUI color scheme.
    public func palette(for colorScheme: ColorScheme) -> LiveActivityPalette {
        colorScheme == .dark ? dark : light
    }

    /// The package's adaptive porcelain appearance with an app-selected accent.
    public static func porcelain(accent: LiveActivityAccent) -> LiveActivityAppearance {
        LiveActivityAppearance(
            light: .porcelain(accent: accent),
            dark: .porcelainDark(accent: accent)
        )
    }
}

public enum LiveActivityTheme: String, CaseIterable, Identifiable, Sendable {
    case porcelain

    public var id: String { rawValue }

    public var title: String {
        "Porcelain"
    }

    public func palette(for accent: LiveActivityAccent, colorScheme: ColorScheme) -> LiveActivityPalette {
        LiveActivityAppearance.porcelain(accent: accent).palette(for: colorScheme)
    }
}
