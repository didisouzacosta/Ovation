import Testing
@testable import Ovation

@Suite("Ovation configuration")
struct OvationConfigurationTests {

    // MARK: - Tests

    @Test("defaults leave the optional parts to the package")
    func defaults() {
        let configuration = OvationConfiguration(appStoreID: "123", supportEmail: "a@b.com")

        #expect(configuration.appName == nil)
        #expect(configuration.cards.isEmpty)
        #expect(configuration.texts == OvationTexts())
        #expect(configuration.theme.fontStyle == .standard)
        #expect(configuration.storageNamespace == nil)
    }

    @Test("the storage namespace defaults to the bundle identifier, then to Ovation")
    func namespaceDefaults() {
        let configuration = OvationConfiguration(appStoreID: "123", supportEmail: "a@b.com")
        let custom = OvationConfiguration(appStoreID: "123", supportEmail: "a@b.com", storageNamespace: "custom")
        let blank = OvationConfiguration(appStoreID: "123", supportEmail: "a@b.com", storageNamespace: " ")

        #expect(configuration.resolvedNamespace(bundleIdentifier: "com.example.app") == "com.example.app")
        #expect(configuration.resolvedNamespace(bundleIdentifier: nil) == "Ovation")
        #expect(custom.resolvedNamespace(bundleIdentifier: "com.example.app") == "custom")
        #expect(blank.resolvedNamespace(bundleIdentifier: "com.example.app") == "com.example.app")
    }

    @Test("only digit App Store IDs are valid")
    func validity() {
        #expect(OvationConfiguration(appStoreID: "6819261640", supportEmail: "").isValid)
        #expect(OvationConfiguration(appStoreID: "", supportEmail: "a@b.com").isValid == false)
        #expect(OvationConfiguration(appStoreID: "abc", supportEmail: "a@b.com").isValid == false)
    }

    @Test("the app name override wins over the bundle name")
    func appNameOverride() {
        let named = OvationConfiguration(appStoreID: "1", supportEmail: "", appName: "Potion")
        let blank = OvationConfiguration(appStoreID: "1", supportEmail: "", appName: " ")

        #expect(named.resolvedAppName(defaultName: "Bundle") == "Potion")
        #expect(blank.resolvedAppName(defaultName: "Bundle") == "Bundle")
    }
}
