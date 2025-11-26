// swift-tools-version: 6.0
// MetalForge - A Shader Puzzle Game & Creative Tool

import PackageDescription

let package = Package(
    name: "MetalForge",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MetalForge", targets: ["MetalForge"])
    ],
    targets: [
        .executableTarget(
            name: "MetalForge",
            dependencies: [],
            path: "MetalForge",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "MetalForgeTests",
            dependencies: ["MetalForge"],
            path: "MetalForgeTests"
        )
    ]
)
