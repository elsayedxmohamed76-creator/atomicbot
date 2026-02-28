// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AtomicBotKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "AtomicBotProtocol", targets: ["AtomicBotProtocol"]),
        .library(name: "AtomicBotKit", targets: ["AtomicBotKit"]),
        .library(name: "AtomicBotChatUI", targets: ["AtomicBotChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "AtomicBotProtocol",
            path: "Sources/AtomicBotProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "AtomicBotKit",
            dependencies: [
                "AtomicBotProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/AtomicBotKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "AtomicBotChatUI",
            dependencies: [
                "AtomicBotKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/AtomicBotChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "AtomicBotKitTests",
            dependencies: ["AtomicBotKit", "AtomicBotChatUI"],
            path: "Tests/AtomicBotKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
