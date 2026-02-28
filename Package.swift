// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ads",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ads", targets: ["ads"]),
        .library(name: "GoogleDocsLib", targets: ["GoogleDocsLib"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
    ],
    targets: [
        .executableTarget(
            name: "ads",
            dependencies: ["GoogleDocsLib"]
        ),
        .target(
            name: "GoogleDocsLib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "GoogleDocsLibTests",
            dependencies: ["GoogleDocsLib"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
