// swift-tools-version: 6.2
// Package manifest for the AtomicBot macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "AtomicBot",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "AtomicBotIPC", targets: ["AtomicBotIPC"]),
        .library(name: "AtomicBotDiscovery", targets: ["AtomicBotDiscovery"]),
        .executable(name: "AtomicBot", targets: ["AtomicBot"]),
        .executable(name: "atomicbot-mac", targets: ["AtomicBotMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/AtomicBotKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "AtomicBotIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "AtomicBotDiscovery",
            dependencies: [
                .product(name: "AtomicBotKit", package: "AtomicBotKit"),
            ],
            path: "Sources/AtomicBotDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "AtomicBot",
            dependencies: [
                "AtomicBotIPC",
                "AtomicBotDiscovery",
                .product(name: "AtomicBotKit", package: "AtomicBotKit"),
                .product(name: "AtomicBotChatUI", package: "AtomicBotKit"),
                .product(name: "AtomicBotProtocol", package: "AtomicBotKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/AtomicBot.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "AtomicBotMacCLI",
            dependencies: [
                "AtomicBotDiscovery",
                .product(name: "AtomicBotKit", package: "AtomicBotKit"),
                .product(name: "AtomicBotProtocol", package: "AtomicBotKit"),
            ],
            path: "Sources/AtomicBotMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "AtomicBotIPCTests",
            dependencies: [
                "AtomicBotIPC",
                "AtomicBot",
                "AtomicBotDiscovery",
                .product(name: "AtomicBotProtocol", package: "AtomicBotKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
