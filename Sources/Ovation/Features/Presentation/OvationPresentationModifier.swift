import SwiftUI

/// Evaluates each change of `trigger` and presents the review sheet when Ovation's checks and
/// the app's rule allow it. `.presented` is sent when the sheet is really on screen; a sheet that
/// does not appear (another modal is up, or the view left) is released, with its session
/// reservation, after `OvationReview.appearanceTimeout`.
struct OvationPresentationModifier<Trigger: Equatable>: ViewModifier {

    // MARK: - Public Properties

    let configuration: OvationConfiguration
    let trigger: Trigger
    let onEvent: @MainActor (OvationEvent) -> Void

    // MARK: - Private Properties

    @State private var viewModel: OvationPresentationViewModel

    /// Any dismissal, including the swipe, ends the presentation through the view model.
    private var activePresentation: Binding<OvationPresentation?> {
        Binding {
            viewModel.activePresentation
        } set: { presentation in
            guard presentation == nil else {
                return
            }

            finish(.dismissed)
        }
    }

    // MARK: - Initializer

    init(
        configuration: OvationConfiguration,
        trigger: Trigger,
        onEvent: @escaping @MainActor (OvationEvent) -> Void
    ) {
        self.configuration = configuration
        self.trigger = trigger
        self.onEvent = onEvent
        _viewModel = State(
            initialValue: OvationPresentationViewModel(
                storage: UserDefaultsOvationStorage(namespace: configuration.resolvedNamespace)
            )
        )
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) {
                handleTrigger()
            }
            .sheet(item: activePresentation) { presentation in
                OvationSheet(
                    viewModel: OvationSheetViewModel(configuration: presentation.configuration),
                    theme: presentation.configuration.theme,
                    onFinish: finish
                )
                .onAppear(perform: sheetAppeared)
            }
            .task(id: viewModel.awaitingPresentationID) {
                await releaseIfNotShown()
            }
    }

    // MARK: - Private Methods

    private func handleTrigger() {
        viewModel.handleTrigger(configuration)
    }

    private func sheetAppeared() {
        guard let event = viewModel.sheetAppeared() else {
            return
        }

        onEvent(event)
    }

    private func releaseIfNotShown() async {
        guard viewModel.awaitingPresentationID != nil else {
            return
        }

        try? await Task.sleep(for: OvationReview.appearanceTimeout)

        // Also on cancellation: after an appearance or a release this does nothing, and a view
        // that leaves while its sheet is coming must not keep the session reserved.
        viewModel.presentationDidNotAppear()
    }

    private func finish(_ outcome: OvationOutcome) {
        guard let event = viewModel.finish(outcome) else {
            return
        }

        onEvent(event)
    }
}
