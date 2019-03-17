// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SquareNumber",
    dependencies: [
        .package(path: "../../"),
    ],
    targets: [
        .target(
            name: "SquareNumber",
            dependencies: ["AWSLambdaSwift"]
        ),
    ]
)
