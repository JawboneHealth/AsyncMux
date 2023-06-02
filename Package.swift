// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "AsyncMux",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "AsyncMux",
            targets: ["AsyncMux"]),
    ],
    dependencies: [
      .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        .target(
            name: "AsyncMux",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources"
        ),
    ]
)
