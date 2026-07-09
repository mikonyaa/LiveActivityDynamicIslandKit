// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LiveActivityDynamicIslandKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "LiveActivityKit",
            targets: ["LiveActivityKit"]
        )
    ],
    targets: [
        .target(
            name: "LiveActivityKit"
        ),
        .testTarget(
            name: "LiveActivityKitTests",
            dependencies: ["LiveActivityKit"]
        )
    ]
)
