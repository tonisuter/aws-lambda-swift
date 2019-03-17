// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "RESTCountries",
    dependencies: [
        .package(path: "../../"),
    ],
    targets: [
        .target(
            name: "RESTCountries",
            dependencies: ["AWSLambdaSwift"]
        ),
    ]
)
