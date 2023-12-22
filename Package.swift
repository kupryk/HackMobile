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
            targets: ["HackDevice"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(name: "HackDevice", dependencies: ["libimobiledevice.c"]),
        .binaryTarget(name: "libimobiledevice.c", path: "Resources/Automation/libimobiledevice.xcframework"),
    ]
)

