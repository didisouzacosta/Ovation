import Ovation
import SwiftUI

struct DemoHomeView: View {

    // MARK: - Private Properties

    @State private var viewModel = DemoHomeViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            LevelsView()
                .navigationTitle("Ovation")
                .safeAreaInset(edge: .bottom) {
                    debugTools
                }
        }
        .ovationReview(isPresented: $viewModel.isSheetPreviewPresented, configuration: .levels)
    }

    // MARK: - Subviews

    private var debugTools: some View {
        VStack(spacing: 12) {
            Button("Preview the sheet", action: viewModel.previewSheet)
                .buttonStyle(.borderedProminent)

            Button("Reset saved state", role: .destructive, action: viewModel.resetSavedState)

            Text(
                viewModel.didResetSavedState
                    ? "Saved state cleared. Relaunch the app for a new session."
                    : "Relaunch the app to start a new session."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.bar)
    }
}

#Preview("Home") {
    DemoHomeView()
}
