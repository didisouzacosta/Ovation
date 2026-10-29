import Foundation
import Testing

@Suite("README example")
struct ReadmeExampleTests {

    // MARK: - Private Properties

    private static let regions = [
        ("configuration", "Demo/Sources/Core/Review/OvationConfiguration+Levels.swift"),
        ("view", "Demo/Sources/Features/Levels/LevelsView.swift"),
    ]

    // MARK: - Tests

    @Test("each README code block is the compiled Demo code", arguments: regions)
    func readmeMatchesDemo(region: String, demoFile: String) throws {
        let readme = try OvationSourceFiles.file("README.md")
        let demo = try OvationSourceFiles.file(demoFile)
        let block = try #require(readmeBlock(named: region, in: readme), "README has no \(region) block")
        let code = try #require(demoRegion(named: region, in: demo), "\(demoFile) has no \(region) region")

        #expect(block == code)
    }

    @Test("the README example uses only the public API")
    func readmeUsesPublicAPI() throws {
        let readme = try OvationSourceFiles.file("README.md")

        #expect(readme.contains("@testable") == false)
        #expect(readme.contains("import Ovation"))
        #expect(readme.contains(".ovationReview(.levels, trigger: wonLevels)"))
    }

    @Test("the README shows the package icon above the name")
    func readmeTitle() throws {
        let readme = try OvationSourceFiles.file("README.md")

        #expect(
            readme.hasPrefix(
                """
                <h1 align="center">
                  <img alt="Ovation icon" src="Docs/Images/app-icon.png" width="160"><br>
                  Ovation
                </h1>
                """
            )
        )
        #expect(FileManager.default
            .fileExists(atPath: OvationSourceFiles.packageRoot.appendingPathComponent("Docs/Images/app-icon.png").path))
    }

    @Test("the README no longer uses the old copy")
    func readmeCopy() throws {
        let readme = try OvationSourceFiles.file("README.md")

        #expect(readme.contains("5 stars to") == false)
        #expect(readme.contains("with 5 stars") == false)
        #expect(readme.contains("Not happy") == false)
        #expect(readme.contains("Continue") == false)
        #expect(readme.contains("StoreKit") == false)
        #expect(readme.localizedCaseInsensitiveContains("marquee") == false)
    }

    // MARK: - Private Methods

    /// The fenced block right after `<!-- README:<name> -->`.
    private func readmeBlock(named name: String, in readme: String) -> String? {
        guard let marker = readme.range(of: "<!-- README:\(name) -->") else {
            return nil
        }

        let rest = readme[marker.upperBound...]

        guard
            let open = rest.range(of: "```swift\n"),
            let close = rest[open.upperBound...].range(of: "\n```")
        else {
            return nil
        }

        return trimmed(String(rest[open.upperBound..<close.lowerBound]))
    }

    /// The lines between `// README:<name>:begin` and `// README:<name>:end`.
    private func demoRegion(named name: String, in source: String) -> String? {
        guard
            let begin = source.range(of: "// README:\(name):begin\n"),
            let end = source.range(of: "// README:\(name):end")
        else {
            return nil
        }

        return trimmed(String(source[begin.upperBound..<end.lowerBound]))
    }

    private func trimmed(_ code: String) -> String {
        code.trimmingCharacters(in: .newlines)
    }
}
