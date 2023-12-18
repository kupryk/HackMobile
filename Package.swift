// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "HackMobileCore",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "HackMobileCore",
            targets: ["HackMobileCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(name: "HackMobileCore", dependencies: [
            "libimobiledevice.c",
            "AnyCodable",
        ]),
        .target(name: "AnyCodable"),
        .binaryTarget(
            name: "libimobiledevice.c",
            path: "Resources/Automation/libimobiledevice.xcframework"
        ),
    ]
)

