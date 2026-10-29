import Foundation
import Testing

@Suite("Package and concurrency source")
struct OvationPackageSourceTests {

    // MARK: - Tests

    @Test("the manifest targets Swift 6.2 tools, Swift 6 mode and iOS 26, without dependencies")
    func manifest() throws {
        let manifest = try OvationSourceFiles.file("Package.swift")

        #expect(manifest.hasPrefix("// swift-tools-version: 6.2"))
        #expect(manifest.contains("swiftLanguageModes: [.v6]"))
        #expect(manifest.contains(".iOS(.v26)"))
        #expect(manifest.contains(".macOS") == false)
        #expect(manifest.contains(".package(") == false)
        #expect(manifest.contains("defaultIsolation") == false)
        #expect(manifest.contains("unsafeFlags") == false)
    }

    @Test("the package avoids unstructured tasks and unsafe concurrency escapes")
    func noUnsafeConcurrency() throws {
        for (path, source) in try OvationSourceFiles.allSources() {
            #expect(source.contains("Task {") == false, "\(path)")
            #expect(source.contains("Task.detached") == false, "\(path)")
            #expect(source.contains("@unchecked Sendable") == false, "\(path)")
            #expect(source.contains("nonisolated(unsafe)") == false, "\(path)")
            #expect(source.contains("DispatchQueue") == false, "\(path)")
        }
    }

    @Test("view models, storage and session are main actor isolated")
    func mainActorIsolation() throws {
        let files = [
            "Features/Presentation/OvationPresentationViewModel.swift",
            "Features/ReviewSheet/OvationSheetViewModel.swift",
            "Core/Persistence/OvationStorage.swift",
            "Core/Persistence/UserDefaultsOvationStorage.swift",
            "Core/Presentation/OvationSession.swift",
        ]

        for file in files {
            #expect(try OvationSourceFiles.source(file).contains("@MainActor"), "\(file)")
        }
    }

    @Test("the tests use Swift Testing only")
    func swiftTestingOnly() throws {
        let enumerator = FileManager.default.enumerator(
            at: OvationSourceFiles.packageRoot.appendingPathComponent("Tests"),
            includingPropertiesForKeys: nil
        )

        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else {
                continue
            }

            let source = try String(contentsOf: url, encoding: .utf8)

            #expect(source.contains("import XC" + "Test") == false, "\(url.lastPathComponent)")
            #expect(source.contains("XC" + "UIApplication") == false, "\(url.lastPathComponent)")
        }
    }
}
