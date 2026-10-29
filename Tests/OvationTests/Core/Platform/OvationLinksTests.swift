import Foundation
import Testing
@testable import Ovation

@Suite("Ovation links")
struct OvationLinksTests {

    // MARK: - Tests

    @Test("the write review URL is the official App Store link")
    func writeReviewURLIsOfficial() {
        let url = OvationLinks.writeReviewURL(appStoreID: "6819261640")

        #expect(url?.absoluteString == "https://apps.apple.com/app/id6819261640?action=write-review")
    }

    @Test("App Store IDs are trimmed")
    func appStoreIDsAreTrimmed() {
        #expect(OvationLinks.normalizedAppStoreID(" 123 \n") == "123")
        #expect(
            OvationLinks.writeReviewURL(appStoreID: " 123")?.absoluteString
                == "https://apps.apple.com/app/id123?action=write-review"
        )
    }

    @Test("App Store IDs must be ASCII digits only", arguments: ["", "  ", "abc", "12a", "id123", "1 2", "١٢٣"])
    func invalidAppStoreIDs(_ appStoreID: String) {
        #expect(OvationLinks.normalizedAppStoreID(appStoreID) == nil)
        #expect(OvationLinks.writeReviewURL(appStoreID: appStoreID) == nil)
    }

    @Test("the feedback URL is a mailto link with an encoded subject")
    func feedbackURLEncodesTheSubject() {
        let url = OvationLinks.feedbackURL(email: "suporte@example.com", subject: "Feedback sobre o Poção & Cia")

        #expect(
            url?.absoluteString
                == "mailto:suporte@example.com?subject=Feedback%20sobre%20o%20Po%C3%A7%C3%A3o%20%26%20Cia"
        )
    }

    @Test("support emails are trimmed and need an at sign")
    func supportEmailsAreValidated() {
        #expect(OvationLinks.normalizedEmail(" a+b@example.com ") == "a+b@example.com")
        #expect(OvationLinks.normalizedEmail("") == nil)
        #expect(OvationLinks.normalizedEmail("support") == nil)
        #expect(OvationLinks.feedbackURL(email: "support", subject: "Hi") == nil)
    }
}
