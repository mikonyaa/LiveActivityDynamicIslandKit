import Foundation
import LiveActivityKit

// The compact fixture rows are intentionally optimized for side-by-side state comparison.
// swiftlint:disable line_length function_parameter_count

extension LiveActivityRecipes {
    static var delivery: LiveActivityRecipe {
        LiveActivityRecipe(
            scenario: .delivery,
            states: [
                model(.delivery, "delivery-1", .preparing, "Order confirmed", "Studio supplies are being packed", "8:40", "Preparing", "Courier assigned", 0.18, "18%", "Kitchen", "Door", .blue, 34, "34 min"),
                model(.delivery, "delivery-2", .active, "On the way", "Courier is moving through the city", "8:22", "En route", "3 stops before you", 0.54, "54%", "Pickup", "Home", .blue, 22, "22 min"),
                model(.delivery, "delivery-3", .attention, "Nearby", "Meet the courier at the entrance", "4 min", "Arriving", "Keep your phone nearby", 0.86, "86%", "Block B", "Lobby", .blue, 4, "4 min"),
                model(.delivery, "delivery-4", .completed, "Delivered", "Package left with reception", "Done", "Complete", "Proof of delivery saved", 1, "100%", "Courier", "Reception", .blue, 0, "now")
            ]
        )
    }

    static var ride: LiveActivityRecipe {
        LiveActivityRecipe(
            scenario: .ride,
            states: [
                model(.ride, "ride-1", .preparing, "Finding a driver", "Checking nearby premium rides", "1 min", "Matching", "No surge applied", 0.12, "12%", "You", "Driver", .teal, 12, "12 min"),
                model(.ride, "ride-2", .active, "Driver arriving", "Ayan is coming in a black sedan", "5 min", "KZ 204", "Meet at the north entrance", 0.46, "46%", "Pickup", "North", .teal, 5, "5 min"),
                model(.ride, "ride-3", .active, "In ride", "Heading to the workspace", "14 min", "On trip", "Fastest route selected", 0.64, "64%", "Current", "Studio", .teal, 14, "14 min"),
                model(.ride, "ride-4", .completed, "Arrived", "Trip completed safely", "Done", "Complete", "Receipt is ready", 1, "100%", "Ride", "Arrived", .teal, 0, "now")
            ]
        )
    }

    static var timer: LiveActivityRecipe {
        LiveActivityRecipe(
            scenario: .timer,
            states: [
                model(.timer, "timer-1", .active, "Focus timer", "Deep work session is running", "24:00", "Running", "Design pass", 0.2, "20%", "Start", "Focus", .indigo, 24, "24 min"),
                model(.timer, "timer-2", .active, "Focus timer", "Keep the session steady", "12:30", "Halfway", "No interruption logged", 0.5, "50%", "Focus", "Break", .indigo, 12.5, "12 min"),
                model(.timer, "timer-3", .attention, "Almost done", "Prepare to wrap the task", "02:00", "Final", "Save notes before break", 0.92, "92%", "Wrap", "Break", .indigo, 2, "2 min"),
                model(.timer, "timer-4", .completed, "Session complete", "Focus block finished", "Done", "Complete", "Take a short break", 1, "100%", "Focus", "Break", .indigo, 0, "now")
            ]
        )
    }

    static var sports: LiveActivityRecipe {
        LiveActivityRecipe(
            scenario: .sports,
            states: [
                model(.sports, "sports-1", .preparing, "Astana vs Almaty", "Tip-off is approaching", "19:30", "Pregame", "Lineups confirmed", 0.05, "Ready", "AST", "ALM", .green, 40, "40 min"),
                model(.sports, "sports-2", .active, "Astana leads", "Second quarter", "42–38", "Q2 04:18", "Possession: Astana", 0.42, "Q2", "AST", "ALM", .green, 24, "24 min"),
                model(.sports, "sports-3", .attention, "One-point game", "Final possession", "81–80", "Q4 00:18", "Timeout on the floor", 0.96, "Clutch", "AST", "ALM", .green, 1, "18 sec"),
                model(.sports, "sports-4", .completed, "Final", "Astana wins at home", "84–82", "Final", "Game stats available", 1, "Final", "AST", "ALM", .green, 0, "final")
            ]
        )
    }

    static var download: LiveActivityRecipe {
        LiveActivityRecipe(
            scenario: .download,
            states: [
                model(.download, "download-1", .preparing, "Preparing export", "Collecting design assets", "0%", "Queued", "Archive will start soon", 0, "Queued", "Source", "Cloud", .blue, 18, "18 min"),
                model(.download, "download-2", .active, "Exporting library", "Uploading components and assets", "48%", "Transferring", "Stable connection", 0.48, "48%", "Local", "Cloud", .blue, 9, "9 min"),
                model(.download, "download-3", .attention, "Verifying files", "Checking archive integrity", "92%", "Verifying", "Do not close the app", 0.92, "92%", "Hash", "Ready", .blue, 2, "2 min"),
                model(.download, "download-4", .completed, "Export complete", "Archive is ready to share", "Done", "Complete", "Link copied to clipboard", 1, "100%", "Archive", "Ready", .blue, 0, "now")
            ]
        )
    }

    static var trip: LiveActivityRecipe {
        LiveActivityRecipe(
            scenario: .trip,
            states: [
                model(.trip, "trip-1", .preparing, "Boarding soon", "Gate opens for the studio trip", "Gate 4", "Boarding", "Seat 12A", 0.16, "16%", "Gate", "Seat", .amber, 42, "42 min"),
                model(.trip, "trip-2", .active, "En route", "Next stop is Central Station", "18 min", "On time", "Transfer remains protected", 0.44, "44%", "Line A", "Central", .amber, 18, "18 min"),
                model(.trip, "trip-3", .attention, "Transfer", "Walk to platform 2", "6 min", "Change", "Follow the yellow signs", 0.72, "72%", "P1", "P2", .amber, 6, "6 min"),
                model(.trip, "trip-4", .completed, "Arriving", "Destination is next", "2 min", "Arriving", "Prepare to exit", 0.94, "94%", "Train", "Exit", .amber, 2, "2 min")
            ]
        )
    }

    private static func model(
        _ scenario: LiveActivityScenario,
        _ id: String,
        _ phase: LiveActivityPhase,
        _ title: String,
        _ subtitle: String,
        _ primaryValue: String,
        _ secondaryValue: String,
        _ footnote: String,
        _ fraction: Double,
        _ progressLabel: String,
        _ leadingLabel: String,
        _ trailingLabel: String,
        _ accent: LiveActivityAccent,
        _ minutes: TimeInterval,
        _ remaining: String
    ) -> LiveActivityContentModel {
        LiveActivityContentModel(
            id: id,
            symbolName: scenario.systemImage,
            accessibilityTitle: scenario.title,
            phase: phase,
            title: title,
            subtitle: subtitle,
            primaryValue: primaryValue,
            secondaryValue: secondaryValue,
            footnote: footnote,
            progress: LiveActivityProgress(fraction: fraction, label: progressLabel),
            timeline: timeline(minutes: minutes, remaining: remaining),
            leadingLabel: leadingLabel,
            trailingLabel: trailingLabel,
            accent: accent
        )
    }
}

// swiftlint:enable line_length function_parameter_count
