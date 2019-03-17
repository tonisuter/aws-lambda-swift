// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AWSLambdaSwift",
    products: [
        .library(
            name: "AWSLambdaSwift",
            targets: ["AWSLambdaSwift"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AWSLambdaSwift",
            dependencies: []
        ),
    ]
)
