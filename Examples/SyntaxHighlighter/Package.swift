// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyntaxHighlighter",
    dependencies: [
        .package(path: "../../"),
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.1.4"),
    ],
    targets: [
        .target(
            name: "SyntaxHighlighter",
            dependencies: ["AWSLambdaSwift", "Splash"]
        ),
    ]
)
