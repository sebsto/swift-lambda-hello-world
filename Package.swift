// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "swift-demo",
    platforms: [.macOS(.v11)],
    products: [
        .executable(
            name: "swift-demo",
            targets: ["swift-demo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from: "0.4.0")),
        .package(name: "soto", url: "https://github.com/soto-project/soto.git", .upToNextMajor(from: "5.4.0"))

    ],
    targets: [
        .target(
            name: "swift-demo",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoCognitoIdentity", package: "soto")
            ]),
        .testTarget(
            name: "swift-demoTests",
            dependencies: ["swift-demo"]),
    ]
)
