// swift-tools-version:5.9
// TBBNSDK — Swift client for the TBBN Platform API.

import PackageDescription

let package = Package(
    name: "TBBNSDK",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "TBBNSDK", targets: ["TBBNSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "TBBNSDK", dependencies: [.product(name: "Crypto", package: "swift-crypto")], path: "Sources/TBBNSDK")
    ]
)
