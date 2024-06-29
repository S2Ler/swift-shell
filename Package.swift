// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "swift-shell",
  platforms: [
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "Shell",
      targets: ["Shell"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Shell",
      dependencies: []
    ),
    .testTarget(
      name: "ShellTests",
      dependencies: ["Shell"]
    ),
  ]
)
