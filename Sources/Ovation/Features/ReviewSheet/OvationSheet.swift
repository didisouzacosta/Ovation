import SwiftUI

/// The review sheet: the header and message, the carousel, the feedback link and the "Write a
/// review" button. It owns its actions and reports how it ended through `onFinish`. It never
/// calls the native review prompt: that is up to the integrating app.
struct OvationSheet: View {

    // MARK: - Private Properties

    @Environment(\.openURL) private var openURL

    @ScaledMetric(relativeTo: .body) private var contentSpacing = OvationSheetLayout.contentSpacing

    @State private var viewModel: OvationSheetViewModel
    @State private var visibleHeight: CGFloat = 0

    // MARK: - Public Properties

    let theme: OvationTheme
    let onFinish: (OvationOutcome) -> Void

    // MARK: - Initializer

    init(
        viewModel: OvationSheetViewModel,
        theme: OvationTheme,
        onFinish: @escaping (OvationOutcome) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.theme = theme
        self.onFinish = onFinish
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    content
                }
                .scrollBounceBehavior(.basedOnSize)
                .onGeometryChange(for: CGFloat.self, of: OvationSheetLayout.visibleHeight) { height in
                    visibleHeight = height
                }

                OvationFooter(
                    feedbackLink: viewModel.showsFeedbackLink ? viewModel.texts.feedbackLink : nil,
                    primaryTitle: viewModel.primaryButtonTitle,
                    theme: theme,
                    onFeedback: sendFeedback,
                    onPrimary: primaryAction
                )
            }
            .background(alignment: .bottom) {
                OvationGlow(inner: theme.glowInner, outer: theme.glowOuter)
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close, action: close)
                }
            }
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .alert(viewModel.mailUnavailableTitle, isPresented: $viewModel.isMailAlertPresented) {
                Button(viewModel.mailUnavailableCopyTitle, action: copyEmail)
                Button(viewModel.mailUnavailableDismissTitle, role: .cancel, action: {})
            } message: {
                Text(viewModel.mailUnavailableMessage)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(theme.background)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    // MARK: - Subviews

    /// Centered when it fits; scrolls only on short screens, clipped above the footer.
    private var content: some View {
        VStack(spacing: contentSpacing) {
            OvationIntro(title: viewModel.texts.title, message: viewModel.texts.message, theme: theme)

            if viewModel.showsCarousel {
                OvationCarousel(cards: viewModel.cards, starTint: theme.cardStarTint)
            }
        }
        .frame(maxWidth: .infinity, minHeight: visibleHeight)
    }

    // MARK: - Private Methods

    private func primaryAction() {
        switch viewModel.primaryAction() {
        case let .openReviewPage(url):
            openURL(url)
            onFinish(.reviewPageOpened)

        case .finish:
            onFinish(.dismissed)
        }
    }

    private func sendFeedback() {
        guard let url = viewModel.feedbackURL else {
            return
        }

        openURL(url) { accepted in
            mailOpened(accepted)
        }
    }

    private func mailOpened(_ accepted: Bool) {
        guard viewModel.mailOpened(accepted) else {
            return
        }

        onFinish(.feedbackOpened)
    }

    private func copyEmail() {
        viewModel.copyEmail()
    }

    private func close() {
        onFinish(.dismissed)
    }
}

#if DEBUG
    #Preview("Escrever uma avaliação") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(configuration: OvationPreviewFixtures.configuration()),
                    theme: OvationTheme(),
                    onFinish: { _ in }
                )
            }
    }

    #Preview("Sem cards") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(configuration: OvationPreviewFixtures.configuration(cards: [])),
                    theme: OvationTheme(),
                    onFinish: { _ in }
                )
            }
    }

    #Preview("Cards de destaque") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(
                        configuration: OvationPreviewFixtures
                            .configuration(cards: OvationPreviewFixtures.highlightCards)
                    ),
                    theme: OvationTheme(),
                    onFinish: { _ in }
                )
            }
    }

    #Preview("Tema arredondado") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(configuration: OvationPreviewFixtures.configuration()),
                    theme: OvationPreviewFixtures.roundedTheme,
                    onFinish: { _ in }
                )
            }
    }

    #Preview("Sem e-mail") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(configuration: OvationPreviewFixtures
                        .configuration(supportEmail: "")),
                    theme: OvationTheme(),
                    onFinish: { _ in }
                )
            }
    }

    #Preview("Textos longos") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(
                        configuration: OvationPreviewFixtures.configuration(
                            cards: [OvationPreviewFixtures.longCard, OvationPreviewFixtures.appStoreCard],
                            texts: OvationPreviewFixtures.longTexts
                        )
                    ),
                    theme: OvationTheme(),
                    onFinish: { _ in }
                )
            }
    }

    #Preview("Dynamic Type XXXL") {
        @Previewable @State var isPresented = true

        Color.black
            .sheet(isPresented: $isPresented) {
                OvationSheet(
                    viewModel: OvationSheetViewModel(
                        configuration: OvationPreviewFixtures.configuration(texts: OvationPreviewFixtures.longTexts)
                    ),
                    theme: OvationTheme(),
                    onFinish: { _ in }
                )
                .dynamicTypeSize(.xxxLarge)
            }
    }
#endif
