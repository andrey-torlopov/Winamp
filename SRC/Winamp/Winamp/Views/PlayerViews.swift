import SwiftUI

struct PlayerPanelView: View {
    @ObservedObject var viewModel: WinampViewModel
    let compactControls: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.nowPlayingTitle)
                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                .foregroundStyle(WinampTheme.neon)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.black.opacity(0.88))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TIME")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(timeText)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(WinampTheme.neon)
                }
                Spacer()
                Button("+ FILE") {
                    viewModel.showImporter = true
                }
                .buttonStyle(.borderedProminent)
                .tint(WinampTheme.amber)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            }

            TransportControlsView(
                isPlaying: viewModel.playbackService.isPlaying,
                compactMode: compactControls,
                onPrevious: viewModel.playPrevious,
                onTogglePlay: viewModel.togglePlayback,
                onNext: viewModel.playNext
            )

            if !compactControls {
                EqualizerCompactView(playbackService: viewModel.playbackService) {
                    viewModel.showEqualizerWindow = true
                }
            }
        }
        .winampPanel()
    }

    private var timeText: String {
        let current = formatted(seconds: viewModel.playbackService.currentTime)
        let total = formatted(seconds: viewModel.playbackService.duration)
        return "\(current) / \(total)"
    }

    private func formatted(seconds: TimeInterval) -> String {
        guard seconds.isFinite else { return "--:--" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "--:--"
    }
}

struct TransportControlsView: View {
    let isPlaying: Bool
    let compactMode: Bool
    let onPrevious: () -> Void
    let onTogglePlay: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ControlButton(symbol: "backward.end.fill", action: onPrevious)
            ControlButton(symbol: isPlaying ? "pause.fill" : "play.fill", action: onTogglePlay)
            ControlButton(symbol: "forward.end.fill", action: onNext)

            if !compactMode {
                Spacer()
            }
        }
    }
}

private struct ControlButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 52, height: 38)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(red: 0.78, green: 0.82, blue: 0.95))
        .foregroundStyle(Color(red: 0.12, green: 0.14, blue: 0.24))
    }
}
