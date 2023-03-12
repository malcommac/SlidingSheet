// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlidingSheet",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "SlidingSheet",
            targets: ["SlidingSheet"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SlidingSheet",
            dependencies: []),
        .testTarget(
            name: "SlidingSheetTests",
            dependencies: ["SlidingSheet"]),
    ]
)
