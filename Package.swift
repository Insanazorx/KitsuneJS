// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift",
    products: [
        .executable(name: "swift", targets: ["swift"]),
        .executable(name: "swift-backend-smoke", targets: ["swift-backend-smoke"]),
        .library(name: "BackendBridge", targets: ["BackendBridge"]),
    ],
    targets: [
        .executableTarget(
            name: "swift",
            dependencies: ["BackendBridge"],
            path: "Sources/Frontend",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "BackendBridge",
            path: "Sources/Bridge/Swift"
        ),
        .executableTarget(
            name: "swift-backend-smoke",
            dependencies: ["BackendBridge"],
            path: "Sources/Bridge/SwiftSmoke"
        ),
    ]
)
