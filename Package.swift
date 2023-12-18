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
            url: "https://api.github.com/repos/kupryk/HackMobile/releases/assets/141257999.zip",
            checksum: "872cd4989573e4c56d0134e625055f813314a7ff2fbbf26bd9a64d967e0562d0"
        ),
    ]
)

