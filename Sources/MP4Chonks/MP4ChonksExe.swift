// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import MP4ChonksLib
import Foundation

@main
struct MP4ChonksExe: ParsableCommand {
	@Option(
		name: [.customShort("m"), .customLong("mp4")],
		help: "Path to initalizing mp4 file.",
		completion: .file(extensions: ["mp4"]),
		transform: {
			URL(filePath: $0)
		})
	var mp4File: URL

	@Argument(
		help: "Path to m4s file(s)",
		completion: .file(extensions: ["m4s"]),
		transform: {
			URL(filePath: $0)
		})
	var m4sFiles: [URL]

    mutating func run() throws {
		let mp4 = try MP4Chonker(mp4File: mp4File)

		for m4sFile in m4sFiles {
			let rationalDuration = try mp4.duration(forM4SFile: m4sFile)
			let floatDuration = Double(rationalDuration.numerator) / Double(rationalDuration.denominator)
			print("\(m4sFile.lastPathComponent): \(floatDuration)s")
		}
    }
}
