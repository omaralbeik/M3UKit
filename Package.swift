// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "M3UKit",
    products: [
        .library(
            name: "M3UKit",
            targets: ["M3UKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "M3UKit",
            dependencies: []
        ),
        .testTarget(
            name: "M3UKitTests",
            dependencies: ["M3UKit"],
            resources: [.process("Resources")]
        )
    ]
)
