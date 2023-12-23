// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "HackDevice",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "HackDevice",
            targets: ["RitchieDevice", "HackDevice"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/kupryk/HackLogger.git",
            from: "0.0.1"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "libimobiledevice.c",
            path: "Resources/Automation/libimobiledevice.xcframework"
        ),
        .target(
            name: "RitchieDevice",
            dependencies: ["HackLogger", "libimobiledevice.c"],
            path: "Sources/RitchieDevice"
        ),
        .target(
            name: "HackDevice",
            dependencies: ["RitchieDevice"],
            path: "Sources/HackDevice"
        ),
    ]
)

