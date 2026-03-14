import SwiftUI

struct PlaylistPanelView: View {
    @ObservedObject var viewModel: WinampViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("WINAMP PLAYLIST")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundStyle(WinampTheme.neon)
                Spacer()
                Button(viewModel.playlistExpanded ? "СВЕРНУТЬ" : "РАЗВЕРНУТЬ") {
                    withAnimation(.snappy) {
                        viewModel.playlistExpanded.toggle()
                    }
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }

            List(selection: $viewModel.selectedTrackID) {
                ForEach(viewModel.tracks, id: \.id) { track in
                    Button {
                        viewModel.selectedTrackID = track.id
                        Task { await viewModel.play(track: track) }
                    } label: {
                        HStack {
                            Text(track.displayTitle)
                                .foregroundStyle(WinampTheme.neon)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                            Spacer()
                            Text(track.durationText)
                                .foregroundStyle(.white)
                                .font(.system(size: 12, design: .monospaced))
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.86))
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    viewModel.selectedTrackID = viewModel.tracks[index].id
                    viewModel.removeSelectedTrack()
                }
            }
            .scrollContentBackground(.hidden)
            .frame(minHeight: 180)

            if let message = viewModel.importError {
                Text(message)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.red.opacity(0.9))
                    .lineLimit(2)
            }
        }
        .winampPanel()
    }
}
