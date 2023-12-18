// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "HackMobile",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "HackMobile",
            targets: ["HackMobile"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(name: "HackMobile", dependencies: [
            "libimobiledevice.c",
            "AnyCodable",
        ]),
        .target(name: "AnyCodable"),
        .binaryTarget(
            name: "libimobiledevice.c",
            url: "",
            checksum: ""
        ),
    ]
)

