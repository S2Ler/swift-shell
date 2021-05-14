// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "swift-shell",
  platforms: [
    .macOS(.v10_13),
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
      dependencies: [],
      swiftSettings: [.unsafeFlags([
        "-Xfrontend", "-enable-experimental-concurrency",
        "-Xfrontend", "-disable-availability-checking",
      ])]
    ),
    .testTarget(
      name: "ShellTests",
      dependencies: ["Shell"],
      swiftSettings: [.unsafeFlags([
        "-Xfrontend", "-enable-experimental-concurrency",
        "-Xfrontend", "-disable-availability-checking",
      ])]
    ),
  ]
)
