// swift-tools-version:4.2

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
