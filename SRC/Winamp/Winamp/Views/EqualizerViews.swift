import SwiftUI

struct VisualizerView: View {
    let values: [CGFloat]

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                RoundedRectangle(cornerRadius: 1)
                    .fill(
                        LinearGradient(
                            colors: [WinampTheme.neon, WinampTheme.amber],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 6, height: max(6, value * 56))
            }
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: 70, maxHeight: 70, alignment: .bottom)
        .background(Color.black.opacity(0.85))
        .overlay(Rectangle().stroke(WinampTheme.borderLight, lineWidth: 1))
    }
}

struct EqualizerCompactView: View {
    @ObservedObject var playbackService: AudioPlaybackService
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VisualizerView(values: playbackService.visualizer)
            HStack(spacing: 8) {
                Text("EQ")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(WinampTheme.neon)
                Text("PREAMP \(Int(playbackService.preamp)) dB")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                Spacer()
                Button("ОТКРЫТЬ") { onTap() }
                    .buttonStyle(.borderedProminent)
                    .tint(WinampTheme.amber)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            }
        }
        .winampPanel()
    }
}

struct EqualizerWindowView: View {
    @ObservedObject var playbackService: AudioPlaybackService

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("WINAMP EQUALIZER")
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundStyle(WinampTheme.neon)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("PREAMP")
                    .foregroundStyle(.white)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                Slider(value: Binding(
                    get: { Double(playbackService.preamp) },
                    set: { playbackService.preamp = Float($0) }
                ), in: -12...12)
                .tint(WinampTheme.amber)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(playbackService.bands.enumerated()), id: \.offset) { index, frequency in
                    VStack {
                        Slider(value: Binding(
                            get: { Double(playbackService.gains[index]) },
                            set: { playbackService.gains[index] = Float($0) }
                        ), in: -12...12)
                        .rotationEffect(.degrees(-90))
                        .frame(height: 110)
                        Text(label(for: frequency))
                            .foregroundStyle(.white)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                }
            }

            VisualizerView(values: playbackService.visualizer)
        }
        .padding()
        .background(WinampTheme.background)
    }

    private func label(for value: Float) -> String {
        if value >= 1000 {
            return "\(Int(value / 1000))k"
        }
        return "\(Int(value))"
    }
}
