// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "MP4Chonks",
	platforms: [
		.macOS(.v13),
	],
	products: [
		.library(
			name: "MP4ChonksLib",
			targets: ["MP4ChonksLib"]),
		.executable(
			name: "MP4Chonks",
			targets: ["MP4Chonks"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
		.package(url: "https://github.com/mredig/SwiftPizzaSnips.git", .upToNextMajor(from: "0.4.0")),
		.package(url: "https://github.com/mredig/DataScanner.git", .upToNextMajor(from: "0.4.2")),
//		.package(url: "https://github.com/mredig/DataScanner.git", branch: "0.4.2a"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "MP4ChonksLib",
			dependencies: [
				"SwiftPizzaSnips",
				"DataScanner",
			]
		),
		.executableTarget(
			name: "MP4Chonks",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				"MP4ChonksLib",
			]
		),
	]
)
