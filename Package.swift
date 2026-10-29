// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Ovation",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "Ovation",
            targets: ["Ovation"]
        ),
    ],
    targets: [
        .target(
            name: "Ovation",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "OvationTests",
            dependencies: ["Ovation"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
