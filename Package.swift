// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OpenShelf",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "OpenShelf",
            dependencies: [.product(name: "Sparkle", package: "Sparkle")],
            path: "Sources/OpenShelf",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "OpenShelfTests",
            dependencies: ["OpenShelf"],
            path: "Tests/OpenShelfTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
