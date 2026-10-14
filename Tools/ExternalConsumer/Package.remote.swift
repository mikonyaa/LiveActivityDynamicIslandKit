// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FileTransferConsumer",
    platforms: [.iOS(.v17), .macOS(.v14)],
    dependencies: [
        .package(
            url: "https://github.com/mikonyaa/LiveActivityDynamicIslandKit.git",
            exact: "0.1.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "ConsumerProbe",
            dependencies: [
                .product(name: "LiveActivityKit", package: "LiveActivityDynamicIslandKit")
            ]
        )
    ]
)
