import DataScanner
import Foundation
import SwiftPizzaSnips

public struct MVHD: ChonkProtocol {
	public let creationTime: UInt
	public let modificationTime: UInt
	public let timescale: UInt32
	public let duration: UInt

	public let rate: Int32
	public let volume: Int16
	public let matrix: [Int32]
	public let nextTrackID: UInt32

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		let (version, _): (UInt8, NullFlags) = try scanner.scanVersionAndFlags()

		var accum: [String: AccumulatorType] = [:]
		if version == 1 {
			let creationTime: UInt = try scanner.scan()
			let modTime: UInt = try scanner.scan()
			let timescale: UInt32 = try scanner.scan()
			let duration: UInt = try scanner.scan()
			accum["CreationTime"] = .uint(creationTime)
			accum["ModTime"] = .uint(modTime)
			accum["Timescale"] = .uint32(timescale)
			accum["Duration"] = .uint(duration)
		} else {
			let creationTime: UInt32 = try scanner.scan()
			let modTime: UInt32 = try scanner.scan()
			let timescale: UInt32 = try scanner.scan()
			let duration: UInt32 = try scanner.scan()
			accum["CreationTime"] = .uint32(creationTime)
			accum["ModTime"] = .uint32(modTime)
			accum["Timescale"] = .uint32(timescale)
			accum["Duration"] = .uint32(duration)
		}

		let rate: Int32 = try scanner.scan(endianness: .big)
		let volume: Int16 = try scanner.scan(endianness: .big)
		// skip reserved
		scanner.currentOffset += 10

		var matrixValues: [Int32] = []
		for _ in 0..<9 {
			matrixValues.append(try scanner.scan())
		}

		// skip predefined
		scanner.currentOffset += 24

		let nextTrackID: UInt32 = try scanner.scan(endianness: .big)

		guard let creationTime = accum["CreationTime"] else {
			throw ChonkError.missingValue(type: Self.self, value: "CreationTime")
		}
		switch creationTime {
		case .uint(let value):
			self.creationTime = value
		case .uint32(let value):
			self.creationTime = UInt(value)
		default:
			throw ChonkError.corruptedValue(type: Self.self, value: "CreationTime")
		}

		guard let modificationTime = accum["ModTime"] else {
			throw ChonkError.missingValue(type: Self.self, value: "ModTime")
		}
		switch modificationTime {
		case .uint(let value):
			self.modificationTime = value
		case .uint32(let value):
			self.modificationTime = UInt(value)
		default:
			throw ChonkError.corruptedValue(type: Self.self, value: "ModTime")
		}

		guard let timescale = accum["Timescale"] else {
			throw ChonkError.missingValue(type: Self.self, value: "Timescale")
		}
		guard case .uint32(let tsValue) = timescale else {
			throw ChonkError.corruptedValue(type: Self.self, value: "Timescale")
		}
		self.timescale = tsValue

		guard let duration = accum["Duration"] else {
			throw ChonkError.missingValue(type: Self.self, value: "Duration")
		}
		switch duration {
		case .uint(let value):
			self.duration = value
		case .uint32(let value):
			self.duration = UInt(value)
		default:
			throw ChonkError.corruptedValue(type: Self.self, value: "Duration")
		}

		self.rate = rate
		self.volume = volume
		self.matrix = matrixValues
		self.nextTrackID = nextTrackID
	}
}
