// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ExampleLambda",
    dependencies: [
        .package(path: "../AWSLambdaSwift")
    ],
    targets: [
        .target(
            name: "ExampleLambda",
            dependencies: ["AWSLambdaSwift"]),
    ]
)
