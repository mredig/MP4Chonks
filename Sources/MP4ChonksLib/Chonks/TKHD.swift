import DataScanner
import Foundation
import SwiftPizzaSnips

public struct TKHD: ChonkProtocol {
	public let flags: TKHDFlags
	public let creationTime: UInt
	public let modificationTime: UInt
	public let trackID: UInt32
	public let duration: UInt
	public let layer: Int16
	public let volume: Int16
	public let matrix: [Int32]
	public let width: Int32
	public let height: Int32

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		let (version, flags): (UInt8, TKHDFlags) = try scanner.scanVersionAndFlags()

		self.flags = flags

		if version == 1 {
			self.creationTime = try scanner.scan()
			self.modificationTime = try scanner.scan()
			self.trackID = try scanner.scan()
			scanner.currentOffset += 4 // skip reserved
			self.duration = try scanner.scan()
		} else {
			let c: UInt32 = try scanner.scan()
			let m: UInt32 = try scanner.scan()
			let t: UInt32 = try scanner.scan()
			scanner.currentOffset += 4 // skip reserved
			let d: UInt32 = try scanner.scan()
			self.creationTime = UInt(c)
			self.modificationTime = UInt(m)
			self.trackID = t
			self.duration = UInt(d)
		}
		scanner.currentOffset += 8 // skip reserved

		self.layer = try scanner.scan()
		scanner.currentOffset += 2 // skip alt group
		self.volume = try scanner.scan()
		var matrix: [Int32] = []
		for _ in 0..<9 {
			matrix.append(try scanner.scan())
		}
		self.matrix = matrix
		self.width = try scanner.scan()
		self.height = try scanner.scan()
	}
}
