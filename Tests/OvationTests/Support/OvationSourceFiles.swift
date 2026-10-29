import Foundation

/// Reads the package's files as text, for tests that check the source.
enum OvationSourceFiles {

    // MARK: - Public Properties

    static let packageRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    // MARK: - Public Methods

    static func file(_ relativePath: String) throws -> String {
        try String(contentsOf: packageRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    static func source(_ relativePath: String) throws -> String {
        try file("Sources/Ovation/\(relativePath)")
    }

    /// Every Swift file under `Sources/Ovation`, by path relative to it.
    static func allSources() throws -> [String: String] {
        let root = packageRoot.appendingPathComponent("Sources/Ovation")
        let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)

        var sources: [String: String] = [:]

        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else {
                continue
            }

            let relativePath = String(url.path.dropFirst(root.path.count + 1))

            sources[relativePath] = try String(contentsOf: url, encoding: .utf8)
        }

        return sources
    }
}
