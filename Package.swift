// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Focnotes",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Focnotes", targets: ["Focnotes"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", exact: "0.6.0")
    ],
    targets: [
        .executableTarget(
            name: "Focnotes",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown")
            ],
            path: "Sources/Focnotes"
        )
    ]
)
