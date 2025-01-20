import DataScanner
import Foundation
import SwiftPizzaSnips

public struct MDHD: ChonkProtocol {
	public let creationTime: UInt
	public let modificationTime: UInt
	public let timescale: UInt32
	public let duration: UInt
	public let languageCode: [UInt8]

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data)
		scanner.defaultEndianness = .big

		let (version, _): (UInt8, NullFlags) = try scanner.scanVersionAndFlags()

		if version == 1 {
			self.creationTime = try scanner.scan()
			self.modificationTime = try scanner.scan()
			self.timescale = try scanner.scan()
			self.duration = try scanner.scan()
		} else {
			let creationTime: UInt32 = try scanner.scan()
			let modificationTime: UInt32 = try scanner.scan()
			let timescale: UInt32 = try scanner.scan()
			let duration: UInt32 = try scanner.scan()
			self.creationTime = UInt(creationTime)
			self.modificationTime = UInt(modificationTime)
			self.timescale = timescale
			self.duration = UInt(duration)
		}

		let langRaw: UInt16 = try scanner.scan()

		func fiveBitter(fiveBitOffset: Int) -> UInt8 {
			let base: UInt16 = 0b11_111
			let cut = (langRaw >> (fiveBitOffset * 8)) & base
			return UInt8(truncatingIfNeeded: cut)
		}

		let byteA = fiveBitter(fiveBitOffset: 2)
		let byteB = fiveBitter(fiveBitOffset: 1)
		let byteC = fiveBitter(fiveBitOffset: 0)
		let langCode = [byteA, byteB, byteC]

		self.languageCode = langCode
	}
}
