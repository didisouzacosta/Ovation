import SwiftUI

/// The decorative laurels and five stars above the title. Hidden from VoiceOver. It grows with
/// Dynamic Type but shrinks to fit the available width, so it never widens the sheet.
struct OvationHeader: View {

    // MARK: - Private Properties

    @ScaledMetric(relativeTo: .largeTitle) private var spacing = OvationSheetLayout.headerSpacing
    @ScaledMetric(relativeTo: .largeTitle) private var laurelWidth = OvationSheetLayout.laurelWidth
    @ScaledMetric(relativeTo: .largeTitle) private var laurelHeight = OvationSheetLayout.laurelHeight
    @ScaledMetric(relativeTo: .largeTitle) private var starSize = OvationSheetLayout.headerStarSize
    @ScaledMetric(relativeTo: .largeTitle) private var starSpacing = OvationSheetLayout.headerStarSpacing

    // MARK: - Public Properties

    let tint: Color

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            laurel("laurel.leading")

            HStack(spacing: starSpacing) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: starSize, maxHeight: starSize)
                }
            }

            laurel("laurel.trailing")
        }
        .foregroundStyle(tint)
        .accessibilityHidden(true)
    }

    // MARK: - Private Methods

    private func laurel(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: laurelWidth, maxHeight: laurelHeight)
    }
}

#if DEBUG
    #Preview("Cabeçalho") {
        OvationHeader(tint: .white)
            .padding()
            .background(.black)
    }

    #Preview("Cabeçalho dourado") {
        OvationHeader(tint: .yellow)
            .padding()
            .background(.indigo)
    }
#endif
