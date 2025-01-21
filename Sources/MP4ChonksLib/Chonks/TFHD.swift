import DataScanner
import Foundation

public struct TFHD: ChonkProtocol {
	public let flags: TFHDFlags
	public let trackID: UInt32
	public let baseDataOffset: UInt?
	public let sampleDescriptionIndex: UInt32?
	public let defaultSampleDuration: UInt32?
	public let defaultSampleSize: UInt32?
	public let defaultSampleFlags: UInt32?

	public var description: String {
		"""
		TFHD:
		flags: \(flags)
		trackID: \(trackID)
		baseDataOffset: \(baseDataOffset as Any)
		sampleDescriptionIndex: \(sampleDescriptionIndex as Any)
		defaultSampleDuration: \(defaultSampleDuration as Any)
		defaultSampleSize: \(defaultSampleSize as Any)
		defaultSampleFlags: \(defaultSampleFlags as Any)
		"""
	}

	init(
		flags: TFHDFlags,
		trackID: UInt32,
		baseDataOffset: UInt?,
		sampleDescriptionIndex: UInt32?,
		defaultSampleDuration: UInt32?,
		defaultSampleSize: UInt32?,
		defaultSampleFlags: UInt32?
	) {
		self.flags = flags
		self.trackID = trackID
		self.baseDataOffset = baseDataOffset
		self.sampleDescriptionIndex = sampleDescriptionIndex
		self.defaultSampleDuration = defaultSampleDuration
		self.defaultSampleSize = defaultSampleSize
		self.defaultSampleFlags = defaultSampleFlags
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		let (_, flags): (UInt8, TFHDFlags) = try scanner.scanVersionAndFlags()

		let trackID: UInt32 = try scanner.scan()

		let baseDataOffset: UInt? = try scanner.scanOptional { flags.contains(.dataOffsetPresent) }
		let sampleDescIndex: UInt32? = try scanner.scanOptional { flags.contains(.sampleDescIndexPresent) }
		let defaultSampleDuration: UInt32? = try scanner.scanOptional { flags.contains(.defaultSampleDurationPresent) }
		let defaultSampleSize: UInt32? = try scanner.scanOptional { flags.contains(.defaultSampleSizePresent) }
		let defaultSampleFlags: UInt32? = try scanner.scanOptional { flags.contains(.defaultSampleFlagsPresent) }

		self.init(
			flags: flags,
			trackID: trackID,
			baseDataOffset: baseDataOffset,
			sampleDescriptionIndex: sampleDescIndex,
			defaultSampleDuration: defaultSampleDuration,
			defaultSampleSize: defaultSampleSize,
			defaultSampleFlags: defaultSampleFlags)
	}
}
