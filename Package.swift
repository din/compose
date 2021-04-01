// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Compose",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
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
