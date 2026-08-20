// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-time-to-live",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Time To Live",
            targets: ["Time To Live"]
        ),
        .library(
            name: "Time To Live Store",
            targets: ["Time To Live Store"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-cache-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-time-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(name: "Time To Live"),
        .target(
            name: "Time To Live Store",
            dependencies: [
                "Time To Live",
                .product(name: "Cache Primitives", package: "swift-cache-primitives"),
            ]
        ),
        .testTarget(
            name: "Time To Live Tests",
            dependencies: [
                "Time To Live",
                .product(name: "Time Primitive", package: "swift-time-primitives"),
            ]
        ),
        .testTarget(
            name: "Time To Live Store Tests",
            dependencies: [
                "Time To Live Store",
                .product(name: "Time Primitive", package: "swift-time-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
