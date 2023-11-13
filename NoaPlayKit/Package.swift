// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NoaPlayKit",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "DataGenerator", targets: ["DataGenerator"]),
        .library(name: "FormattersClient", targets: ["FormattersClient"]),
        .library(name: "MemoryCards", targets: ["MemoryCards"]),
        .library(name: "Models",targets: ["Models"]),
        .library(name: "Theme", targets: ["Theme"]),
        .library(name: "VisualComponents", targets: ["VisualComponents"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.3.0"),
        .package(url: "https://github.com/movingparts-io/Pow", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataGenerator",
            dependencies: [
                "Models",
                "Theme",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "DataGeneratorTests",
            dependencies: [
                "DataGenerator"
            ]
        ),
        .target(
            name: "FormattersClient",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "FormattersClientTests",
            dependencies: [
                "FormattersClient"
            ]
        ),
        .target(
            name: "MemoryCards",
            dependencies: [
                "Models",
                "Theme",
                "VisualComponents",
                "DataGenerator",
                "FormattersClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Pow", package: "Pow")
            ]
        ),
        .testTarget(
            name: "MemoryCardsTests",
            dependencies: [
                "MemoryCards"
            ]
        ),
        .target(name: "Models"),
        .target(
            name: "Theme",
            dependencies: ["Models"],
            resources: [
                .process("Assets.xcassets")
            ]
        ),
        .target(
            name: "VisualComponents",
            dependencies: [
                "Theme"
            ]
        )
    ]
)
