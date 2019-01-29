// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Swidux",
    products: [
        .library(name: "Swidux", targets: ["Swidux"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Swidux", dependencies: []),
        .testTarget(name: "SwiduxTests", dependencies: ["Swidux"]),
    ]
)
