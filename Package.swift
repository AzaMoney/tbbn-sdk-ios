// swift-tools-version:5.9
// Status: WORKING (source only) — untested. No Swift toolchain exists in the environment this
// was written in, so this code has not been compiled or run. Written as a faithful translation
// of packages/sdk-js/src/client.ts's full method surface (all 27 resource groups, Phase 0-13).
// Review before shipping to production.

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
