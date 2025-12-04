// swift-tools-version: 6.2

import PackageDescription

// Swift Embedded compatible:
// - No Foundation dependencies
// - No existential types (any Protocol)
// - No reflection or runtime features
// - Pure Swift value types only

let package = Package(
    name: "swift-standards",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Standards",
            targets: ["Standards"]
        ),
        .library(
            name: "Formatting",
            targets: ["Formatting"]
        ),
        .library(
            name: "StandardTime",
            targets: ["StandardTime"]
        ),
        .library(
            name: "Locale",
            targets: ["Locale"]
        ),
        .library(
            name: "Geometry",
            targets: ["Geometry"]
        ),
        .library(
            name: "StandardsTestSupport",
            targets: ["StandardsTestSupport"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-testing-performance", from: "0.1.1")
    ],
    targets: [
        .target(
            name: "Standards"
        ),
        .target(
            name: "Formatting"
        ),
        .target(
            name: "StandardTime",
            dependencies: [
                "Standards"
            ]
        ),
        .target(
            name: "Locale",
            dependencies: [
                "Standards"
            ]
        ),
        .target(
            name: "Geometry"
        ),
        .target(
            name: "StandardsTestSupport",
            dependencies: [
                "Standards",
                .product(name: "TestingPerformance", package: "swift-testing-performance"),
            ]
        ),
        .testTarget(
            name: "Standards".tests,
            dependencies: [
                "Standards",
                "StandardsTestSupport",
            ]
        ),
        .testTarget(
            name: "Formatting".tests,
            dependencies: [
                "Formatting",
                "StandardsTestSupport",
            ]
        ),
        .testTarget(
            name: "StandardTime".tests,
            dependencies: [
                "StandardTime",
                "StandardsTestSupport",
            ]
        ),
        .testTarget(
            name: "Locale".tests,
            dependencies: [
                "Locale",
                "StandardsTestSupport",
            ]
        ),
        .testTarget(
            name: "Geometry".tests,
            dependencies: [
                "Geometry",
                "StandardsTestSupport",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings =
        existing + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
        ]
}
