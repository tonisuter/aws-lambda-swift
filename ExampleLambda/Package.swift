// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ExampleLambda",
    dependencies: [
        .package(path: "../AWSLambdaSwift"),
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.1.4")
    ],
    targets: [
        .target(
            name: "ExampleLambda",
            dependencies: ["AWSLambdaSwift", "Splash"]),
    ]
)
