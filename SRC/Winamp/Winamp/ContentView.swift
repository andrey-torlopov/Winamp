import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WinampViewModel?

    var body: some View {
        Group {
            if let viewModel {
                WinampRootView(viewModel: viewModel)
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(WinampTheme.background.ignoresSafeArea())
            }
        }
        .task {
            guard viewModel == nil else { return }
            viewModel = WinampViewModel(context: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TrackItem.self, inMemory: true)
}
