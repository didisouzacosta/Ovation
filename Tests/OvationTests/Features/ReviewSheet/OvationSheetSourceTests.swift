import Foundation
import Testing

@Suite("Review sheet source")
struct OvationSheetSourceTests {

    // MARK: - Tests

    @Test("the sheet is a large sheet without grabber, dark, with the close button on the leading side")
    func sheetPresentation() throws {
        let sheet = try OvationSourceFiles.source("Features/ReviewSheet/OvationSheet.swift")

        #expect(sheet.contains(".presentationDetents([.large])"))
        #expect(sheet.contains(".presentationDragIndicator(.hidden)"))
        #expect(sheet.contains(".presentationBackground(theme.background)"))
        #expect(sheet.contains(".preferredColorScheme(.dark)"))
        #expect(sheet.contains("ToolbarItem(placement: .topBarLeading)"))
        #expect(sheet.contains("Button(role: .close, action: close)"))
        #expect(sheet.contains(".toolbarBackgroundVisibility(.hidden, for: .navigationBar)"))
        #expect(sheet.contains("fullScreenCover") == false)
        #expect(sheet.contains(".navigationTitle") == false)
    }

    @Test("the sheet never calls the native review prompt; that is up to the app")
    func noNativePrompt() throws {
        for (path, source) in try OvationSourceFiles.allSources() {
            #expect(source.contains("StoreKit") == false, "\(path)")
            #expect(source.contains("requestReview") == false, "\(path)")
        }
    }

    @Test("the body centers when it fits and scrolls only as a safeguard, clipped above the footer")
    func sheetLayout() throws {
        let sheet = try OvationSourceFiles.source("Features/ReviewSheet/OvationSheet.swift")

        #expect(sheet.contains(".scrollBounceBehavior(.basedOnSize)"))
        #expect(sheet.contains(".onGeometryChange(for: CGFloat.self, of: OvationSheetLayout.visibleHeight)"))
        #expect(sheet.contains("onScrollGeometryChange") == false)
        #expect(sheet.contains(".frame(maxWidth: .infinity, minHeight: visibleHeight)"))
        #expect(sheet.contains("VStack(spacing: 0) {\n                ScrollView {"))
        #expect(sheet.contains("safeAreaInset") == false)
        #expect(sheet.contains(".dynamicTypeSize(...DynamicTypeSize.accessibility2)"))
        #expect(sheet.contains("if viewModel.showsCarousel"))
    }

    @Test("no custom Liquid Glass and no blurred card backgrounds")
    func noCustomGlassOrBlur() throws {
        for (path, source) in try OvationSourceFiles.allSources() {
            #expect(source.contains("glassEffect") == false, "\(path)")
            #expect(source.contains("GlassEffectContainer") == false, "\(path)")
            #expect(source.contains("Material") == false, "\(path)")
            #expect(source.contains(".blur(") == false, "\(path)")
        }
    }

    @Test("texts truncate at their line limits instead of growing the layout")
    func lineLimits() throws {
        let layout = try OvationSourceFiles.source("Features/ReviewSheet/OvationSheetLayout.swift")
        let intro = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationIntro.swift")
        let card = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationCardView.swift")
        let footer = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationFooter.swift")
        let button = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationPrimaryButtonStyle.swift")

        #expect(layout.contains("static let titleLineLimit = 2"))
        #expect(layout.contains("static let messageLineLimit = 3"))
        #expect(layout.contains("static let cardTitleLineLimit = 1"))
        #expect(layout.contains("static let cardTextLineLimit = 4"))
        #expect(layout.contains("static let cardHeight: CGFloat = 192"))
        #expect(intro.contains(".lineLimit(OvationSheetLayout.titleLineLimit)"))
        #expect(intro.contains(".lineLimit(OvationSheetLayout.messageLineLimit)"))
        #expect(card.contains(".lineLimit(OvationSheetLayout.cardTitleLineLimit)"))
        #expect(card.contains(".lineLimit(OvationSheetLayout.cardTextLineLimit)"))
        #expect(card.contains("reservesSpace") == false)
        #expect(occurrences(of: ".lineLimit(1)", in: card) == 2)
        #expect(footer.contains(".lineLimit(1)"))
        #expect(button.contains(".lineLimit(1)"))

        for source in [intro, card, footer, button] {
            #expect(occurrences(of: ".truncationMode(.tail)", in: source) == occurrences(of: ".lineLimit(", in: source))
            #expect(source.contains("fixedSize") == false)
        }
    }

    @Test("cards follow the model flags, have a fixed height with content from the top, and center the footer")
    func cardsFollowTheModel() throws {
        let card = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationCardView.swift")

        #expect(card.contains("if let rating = card.rating"))
        #expect(card.contains("if card.showsFooter"))
        #expect(card.contains("if card.showsAuthorSymbol {"))
        #expect(occurrences(of: "person.fill", in: card) == 1)
        #expect(card.contains("source.displayName"))
        #expect(occurrences(of: "HStack(alignment: .center", in: card) == 2)
        #expect(card.contains("firstTextBaseline") == false)
        #expect(card.contains("@ScaledMetric(relativeTo: .body) private var height = OvationSheetLayout.cardHeight"))
        #expect(card.contains(".frame(width: width, height: height, alignment: .topLeading)"))
        #expect(card.contains("maxHeight") == false)
        #expect(card.contains("Spacer()") == false)
        #expect(occurrences(of: ".layoutPriority(1)", in: card) == 4)
        #expect(card.contains("let height") == false)
    }

    @Test("the carousel pages with snapping and advances in a structured task")
    func carouselPaging() throws {
        let carousel = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationCarousel.swift")

        #expect(carousel.contains(".scrollTargetLayout()"))
        #expect(carousel.contains(".scrollTargetBehavior(.viewAligned)"))
        #expect(carousel.contains(".scrollPosition(id: $position)"))
        #expect(carousel.contains(".contentMargins(.horizontal, contentMargin, for: .scrollContent)"))
        #expect(carousel.contains(".scrollIndicators(.hidden)"))
        #expect(carousel.contains(".task(id: tick)"))
        #expect(carousel.contains("Task.sleep(for: OvationCarouselPaging.interval)"))
        #expect(carousel.contains("Timer") == false)
        #expect(carousel.contains("Task {") == false)
        #expect(occurrences(of: "ForEach(", in: carousel) == 1)
        #expect(carousel.contains("HStack(alignment: .top, spacing: OvationSheetLayout.cardSpacing)"))
        #expect(carousel.contains("fixedSize") == false)
        #expect(carousel.contains("cardHeight") == false)
        #expect(carousel.contains("HeightTemplate") == false)
    }

    @Test("accessibility: decorative header hidden, header trait, one element per card, star labels")
    func accessibility() throws {
        let header = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationHeader.swift")
        let intro = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationIntro.swift")
        let card = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationCardView.swift")
        let glow = try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationGlow.swift")

        #expect(header.contains(".accessibilityHidden(true)"))
        #expect(header.contains(".frame(maxWidth: starSize, maxHeight: starSize)"))
        #expect(header.contains(".frame(maxWidth: laurelWidth, maxHeight: laurelHeight)"))
        #expect(glow.contains(".accessibilityHidden(true)"))
        #expect(intro.contains(".accessibilityAddTraits(.isHeader)"))
        #expect(card.contains(".accessibilityElement(children: .combine)"))
        #expect(card.contains(".accessibilityLabel(OvationLocalized.cardRating(rating))"))
    }

    @Test("sizes follow Dynamic Type and secondary texts follow Increase Contrast")
    func dynamicTypeAndContrast() throws {
        let layout = try OvationSourceFiles.source("Features/ReviewSheet/OvationSheetLayout.swift")

        for component in [
            "OvationHeader",
            "OvationIntro",
            "OvationCardView",
            "OvationFooter",
            "OvationPrimaryButtonStyle",
        ] {
            let source = try OvationSourceFiles.source("Features/ReviewSheet/Components/\(component).swift")

            #expect(source.contains("@ScaledMetric"), "\(component)")
        }

        #expect(layout.contains("static let increasedContrastOpacity = 0.85"))
        #expect(try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationIntro.swift")
            .contains("contrast: contrast"))
        #expect(try OvationSourceFiles.source("Features/ReviewSheet/Components/OvationCardView.swift")
            .contains("contrast: contrast"))
    }

    @Test("the forced presentation touches no storage, no session and no events")
    func forcedPresentationLeavesNoTrace() throws {
        let forced = try OvationSourceFiles.source("Features/Presentation/OvationForcedPresentationModifier.swift")

        #expect(forced.contains("Storage") == false)
        #expect(forced.contains("session") == false)
        #expect(forced.contains("Session") == false)
        #expect(forced.contains("onEvent") == false)
        #expect(forced.contains(".sheet(isPresented: $isPresented)"))
    }

    @Test("the automatic presentation uses the shared session and the namespaced storage")
    func automaticPresentation() throws {
        let modifier = try OvationSourceFiles.source("Features/Presentation/OvationPresentationModifier.swift")
        let viewModel = try OvationSourceFiles.source("Features/Presentation/OvationPresentationViewModel.swift")

        #expect(modifier.contains("UserDefaultsOvationStorage(namespace: configuration.resolvedNamespace)"))
        #expect(modifier.contains(".onChange(of: trigger)"))
        #expect(modifier.contains("initial: true") == false)
        #expect(modifier.contains(".sheet(item: activePresentation)"))
        #expect(modifier.contains(".onAppear(perform: sheetAppeared)"))
        #expect(modifier.contains(".task(id: viewModel.awaitingPresentationID)"))
        #expect(modifier.contains("Task.sleep(for: OvationReview.appearanceTimeout)"))
        #expect(modifier.contains("guard !Task.isCancelled") == false)
        #expect(viewModel.contains("session: OvationSession = .shared"))
    }

    @Test("every view file has previews")
    func everyViewHasPreviews() throws {
        for (path, source) in try OvationSourceFiles.allSources() where source.contains(": View {") {
            #expect(source.contains("#Preview("), "\(path)")
        }
    }

    // MARK: - Private Methods

    private func occurrences(of needle: String, in source: String) -> Int {
        source.components(separatedBy: needle).count - 1
    }
}
