import Testing
@testable import Ovation

@Suite("Ovation app info")
struct OvationAppInfoTests {

    // MARK: - Tests

    @Test("the localized display name comes first")
    func localizedDisplayNameComesFirst() {
        let name = OvationAppInfo.displayName(
            info: ["CFBundleDisplayName": "Potion", "CFBundleName": "PotionPals"],
            localizedInfo: ["CFBundleDisplayName": "Poção"]
        )

        #expect(name == "Poção")
    }

    @Test("the display name comes before the bundle name")
    func displayNameComesBeforeBundleName() {
        let name = OvationAppInfo.displayName(
            info: ["CFBundleDisplayName": "PotionPals", "CFBundleName": "Potion"],
            localizedInfo: nil
        )

        #expect(name == "PotionPals")
    }

    @Test("blank names fall back to the bundle name")
    func blankNamesFallBack() {
        let name = OvationAppInfo.displayName(
            info: ["CFBundleDisplayName": "  ", "CFBundleName": "PotionPals"],
            localizedInfo: ["CFBundleDisplayName": ""]
        )

        #expect(name == "PotionPals")
    }

    @Test("no names means no display name")
    func noNamesMeansNil() {
        #expect(OvationAppInfo.displayName(info: [:], localizedInfo: nil) == nil)
    }
}
