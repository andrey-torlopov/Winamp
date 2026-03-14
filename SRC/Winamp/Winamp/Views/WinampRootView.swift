import SwiftUI

struct WinampRootView: View {
    @StateObject private var viewModel: WinampViewModel

    init(viewModel: @autoclosure @escaping () -> WinampViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let isLandscape = proxy.size.width > proxy.size.height

                Group {
                    if isLandscape {
                        LandscapeContent(viewModel: viewModel)
                    } else {
                        PortraitContent(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(WinampTheme.background.ignoresSafeArea())
            }
            .navigationDestination(isPresented: $viewModel.showEqualizerWindow) {
                EqualizerWindowView(playbackService: viewModel.playbackService)
            }
        }
        .fileImporter(
            isPresented: $viewModel.showImporter,
            allowedContentTypes: viewModel.supportedTypes,
            allowsMultipleSelection: true,
            onCompletion: viewModel.importFiles
        )
        .onAppear {
            viewModel.reloadTracks()
        }
    }
}

private struct LandscapeContent: View {
    @ObservedObject var viewModel: WinampViewModel

    var body: some View {
        HStack(spacing: 12) {
            PlayerPanelView(viewModel: viewModel, compactControls: false)
            PlaylistPanelView(viewModel: viewModel)
                .frame(maxWidth: 380)
        }
        .padding()
    }
}

private struct PortraitContent: View {
    @ObservedObject var viewModel: WinampViewModel

    var body: some View {
        VStack(spacing: 10) {
            if !viewModel.playlistExpanded {
                PlayerPanelView(viewModel: viewModel, compactControls: false)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                PlayerPanelView(viewModel: viewModel, compactControls: true)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            PlaylistPanelView(viewModel: viewModel)
                .frame(maxHeight: .infinity)
        }
        .padding()
    }
}
