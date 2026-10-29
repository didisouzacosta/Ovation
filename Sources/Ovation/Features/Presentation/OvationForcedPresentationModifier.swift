import SwiftUI

/// Presents the review sheet whenever `isPresented` is true, for debugging and previews. It
/// ignores every rule and leaves no trace: nothing is read or written and no event is sent.
struct OvationForcedPresentationModifier: ViewModifier {

    // MARK: - Public Properties

    @Binding var isPresented: Bool

    let configuration: OvationConfiguration

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(configuration: configuration),
                    theme: configuration.theme,
                    onFinish: finish
                )
            }
    }

    // MARK: - Private Methods

    private func finish(_: OvationOutcome) {
        isPresented = false
    }
}
