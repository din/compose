// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Compose",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14)],
    products: [
        .library(
            name: "Compose",
            targets: ["Compose"]),
        .library(
            name: "ComposeUI",
            targets: ["ComposeUI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Compose",
            dependencies: []),
        .target(
            name: "ComposeUI",
            dependencies: ["Compose"])
    ]
)
