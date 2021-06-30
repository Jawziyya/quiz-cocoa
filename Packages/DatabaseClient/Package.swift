// swift-tools-version:5.3

import PackageDescription

let packageName = "DatabaseClient"

let package = Package(
    name: packageName,
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: packageName, targets: [packageName]),
    ],
    dependencies: [
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "5.0.0")),
        .package(name: "swift-composable-architecture", url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.16.0")),
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: [
                .product(name: "GRDB", package: "GRDB"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .testTarget(
            name: "DatabaseClientTests",
            dependencies: [
                .byName(name: packageName)
            ]),
    ]
)
