import DataScanner
import Foundation

extension DataScanner {
	mutating func scanMagic() throws -> String {
		var magic = ""
		try magic.append(scanUTF8Character())
		try magic.append(scanUTF8Character())
		try magic.append(scanUTF8Character())
		try magic.append(scanUTF8Character())
		return magic
	}
}

extension DataScanner {
	struct Box: Sendable {
		let magic: String
		let data: Data
	}

	struct BoxHeader: Sendable {
		let magic: String
		let count: Int
	}

	mutating func scanNextBoxHeader() throws -> BoxHeader {
		let boxSize: UInt32 = try scan(endianness: .big)
		let boxMagic: String = try scanMagic()

		return BoxHeader(magic: boxMagic, count: Int(boxSize) - 8)
	}

	mutating func scanBoxContent(header: BoxHeader) throws -> Box {
		let bytes = try scanBytes(header.count)
		return Box(magic: header.magic, data: bytes)
	}

	mutating func skipBoxContent(header: BoxHeader) {
		currentOffset += header.count
	}

	@available(*, deprecated)
	mutating func scanNextBox() throws -> Box {
		let boxSize: UInt32 = try scan(endianness: .big)
		let boxMagic: String = try scanMagic()

		let box = try scanBytes(Int(boxSize) - 8)
		return Box(magic: boxMagic, data: box)
	}
}

extension DataScanner {
	mutating func scanVersionAndFlags<Flags: OptionSet>() throws -> (UInt8, Flags) where Flags.RawValue == UInt32 {
		let version = try peekByte()

		let flagMask: UInt32 = {
			let maxA = UInt32(UInt8.max)
			let maxB = maxA << 8
			let maxC = maxB << 8

			return maxA | maxB | maxC
		}()
		let rawFlags: UInt32 = try scan(endianness: .big) & flagMask

		return (version, Flags(rawValue: rawFlags))
	}
}
