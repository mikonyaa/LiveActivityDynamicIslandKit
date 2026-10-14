import Foundation
import LiveActivityKit
import SwiftUI

/// The consuming app owns its domain model. No demo types or internal APIs are needed.
struct FileTransfer: Codable, Hashable, Sendable {
    var id: String
    var fileName: String
    var sentMegabytes: Double
    var totalMegabytes: Double
    var remainingSeconds: Int
    var source: String
    var destination: String
    var startedAt: Date

    var renderingModel: LiveActivityContentModel {
        let isIndeterminate = totalMegabytes <= 0
        let fraction = isIndeterminate ? 0 : sentMegabytes / totalMegabytes
        return LiveActivityContentModel(
            id: id,
            symbolName: "arrow.up.document.fill",
            accessibilityTitle: "File transfer",
            phase: .active,
            title: "Sending \(fileName)",
            subtitle: "Secure transfer",
            primaryValue: "\(Int(sentMegabytes)) MB",
            secondaryValue: isIndeterminate ? "Calculating size" : "of \(Int(totalMegabytes)) MB",
            footnote: "Keep the app open to continue",
            progress: LiveActivityProgress(
                fraction: fraction,
                label: isIndeterminate ? "Connecting" : "Uploading",
                isIndeterminate: isIndeterminate
            ),
            timeline: LiveActivityTimeline(
                startedAt: startedAt,
                estimatedEnd: startedAt.addingTimeInterval(TimeInterval(remainingSeconds)),
                remainingText: "\(remainingSeconds) seconds remaining"
            ),
            leadingLabel: source,
            trailingLabel: destination,
            accent: .indigo
        )
    }
}

/// Embedded SwiftUI composition compiles every public surface in an external module.
/// A macOS build of this view does not run an iPhone ActivityKit session.
struct FileTransferSurfaces: View {
    var transfer: FileTransfer

    var body: some View {
        let model = transfer.renderingModel
        VStack(spacing: 20) {
            LiveActivityLockScreenCard(model: model, theme: .porcelain)
            HStack {
                LiveActivityCompactLeadingView(model: model)
                Spacer()
                LiveActivityCompactTrailingView(model: model)
            }
            LiveActivityMinimalView(model: model)
                .frame(width: 24, height: 24)
            LiveActivityExpandedIslandView(model: model, theme: .porcelain)
        }
        .padding()
    }
}

private struct ConsumerEvidence: Encodable {
    let domain: String
    let importedProduct: String
    let surfaces: [String]
    let publicModelCodableRoundTrip: Bool
    let transferredMegabytes: Double
    let progressFraction: Double
    let remainingSeconds: Int
    let indeterminateProgress: Bool
    let accessibilitySummary: String
    let verificationLevel: String
}

@main
enum ConsumerProbe {
    @MainActor
    static func main() throws {
        let transfer = FileTransfer(
            id: "transfer-001",
            fileName: "Field recordings.zip",
            sentMegabytes: 12,
            totalMegabytes: 48,
            remainingSeconds: 90,
            source: "This Mac",
            destination: "Team archive",
            startedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let model = transfer.renderingModel
        let encoded = try JSONEncoder().encode(model)
        let decoded = try JSONDecoder().decode(LiveActivityContentModel.self, from: encoded)
        guard decoded == model, model.progress.fraction == 0.25 else {
            throw ConsumerError.publicModelContract
        }

        var connecting = transfer
        connecting.totalMegabytes = 0
        guard connecting.renderingModel.progress.isIndeterminate else {
            throw ConsumerError.publicModelContract
        }
        _ = FileTransferSurfaces(transfer: transfer).body
        _ = FileTransferSurfaces(transfer: connecting).body

        let evidence = ConsumerEvidence(
            domain: "File transfer",
            importedProduct: "LiveActivityKit",
            surfaces: ["lockScreen", "compactLeading", "compactTrailing", "minimal", "expanded"],
            publicModelCodableRoundTrip: true,
            transferredMegabytes: transfer.sentMegabytes,
            progressFraction: model.progress.fraction,
            remainingSeconds: transfer.remainingSeconds,
            indeterminateProgress: connecting.renderingModel.progress.isIndeterminate,
            accessibilitySummary: model.accessibilitySummary,
            verificationLevel: "macOS public API build and model execution; embedded views instantiated"
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let output = try encoder.encode(evidence)
        FileHandle.standardOutput.write(output)
        FileHandle.standardOutput.write(Data("\n".utf8))
    }
}

private enum ConsumerError: Error {
    case publicModelContract
}
