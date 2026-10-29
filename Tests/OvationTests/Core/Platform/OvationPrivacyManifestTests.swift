import Foundation
import Testing
@testable import Ovation

@Suite("Privacy manifest")
struct OvationPrivacyManifestTests {

    // MARK: - Tests

    @Test("the bundle declares UserDefaults with reason CA92.1, no tracking and no collected data")
    func privacyManifest() throws {
        let url = try #require(Bundle.module.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let data = try Data(contentsOf: url)
        let manifest = try #require(
            PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        )
        let accessedTypes = try #require(manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]])

        #expect(manifest["NSPrivacyTracking"] as? Bool == false)
        #expect((manifest["NSPrivacyTrackingDomains"] as? [Any])?.isEmpty == true)
        #expect((manifest["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true)
        #expect(accessedTypes.count == 1)
        #expect(accessedTypes
            .first?["NSPrivacyAccessedAPIType"] as? String == "NSPrivacyAccessedAPICategoryUserDefaults")
        #expect(accessedTypes.first?["NSPrivacyAccessedAPITypeReasons"] as? [String] == ["CA92.1"])
    }
}
