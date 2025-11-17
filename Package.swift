// swift-tools-version: 6.1

import PackageDescription

// Swift Embedded compatible:
// - No Foundation dependencies
// - No existential types (any Protocol)
// - No reflection or runtime features
// - Pure Swift value types only

let package = Package(
    name: "swift-standards",
    platforms: [
        .macOS(.v15),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Standards",
            targets: ["Standards"]
        ),
        .library(
            name: "StandardsTestSupport",
            targets: ["StandardsTestSupport"]
        )
    ],
    targets: [
        .target(
            name: "Standards"
        ),
        .target(
            name: "StandardsTestSupport",
            dependencies: ["Standards"]
        ),
        .testTarget(
            name: "Standards Tests",
            dependencies: [
                "Standards",
                "StandardsTestSupport"
            ]
        )
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(
        .enableUpcomingFeature("MemberImportVisibility")
    )
    target.swiftSettings = settings
}

