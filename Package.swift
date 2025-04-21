// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toasty",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Toasty",
            targets: ["Toasty"])
    ],
    targets: [
        .target(
            name: "Toasty",
            dependencies: []),
        .testTarget(
            name: "ToastyTests",
            dependencies: ["Toasty"]),
    ]
)
