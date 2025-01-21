import DataScanner
import Foundation

public struct TRUN: ChonkProtocol {
	public let flags: TRUNFlags
	public let sampleCount: UInt32
	public let dataOffset: Int32?
	public let firstSampleFlags: TRUNFlags?

	public let samples: [Sample]

	public var description: String {
		let samplesss = samples
			.enumerated()
			.map { $0.element.description.prefixingLines(with: "\($0.offset) ")}
			.joined(separator: "\n")

		return """
			TRUN:
			flags: \(flags)
			sampleCount: \(sampleCount)
			dataOffset: \(dataOffset as Any)
			firstSampleFlags: \(firstSampleFlags as Any)
			\(samplesss.prefixingLines(with: "\t"))
			"""
	}

	init(flags: TRUNFlags, sampleCount: UInt32, dataOffset: Int32?, firstSampleFlags: TRUNFlags?, samples: [Sample]) {
		self.flags = flags
		self.sampleCount = sampleCount
		self.dataOffset = dataOffset
		self.firstSampleFlags = firstSampleFlags
		self.samples = samples
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		let (_, flags): (UInt8, TRUNFlags) = try scanner.scanVersionAndFlags()

		let sampleCount: UInt32 = try scanner.scan()
		let dataOffset: Int32? = try scanner.scanOptional { flags.contains(.dataOffsetPresent) }
		let firstSampleFlagsRaw: UInt32? = try scanner.scanOptional { flags.contains(.firstSampleFlagsPresent) }
		let firstSampleFlags = firstSampleFlagsRaw.map { TRUNFlags(rawValue: $0) }

		var samples: [Sample] = []
		var sampleStartIndex: UInt32 = 0
		if let firstSampleFlags {
			let sampleDuration: UInt32? = try scanner.scanOptional { firstSampleFlags.contains(.sampleDurationPresent) }
			let sampleSize: UInt32? = try scanner.scanOptional { firstSampleFlags.contains(.sampleSizePresent) }
			let sampleFlags: UInt32? = try scanner.scanOptional { firstSampleFlags.contains(.sampleFlagsPresent) }
			let sampleCompositionTimeOffset: UInt32? = try scanner.scanOptional { firstSampleFlags.contains(.sampleCompTimeOffsetsPresent) }

			samples.append(
				Sample(
					sampleDuration: sampleDuration,
					sampleSize: sampleSize,
					sampleFlags: sampleFlags,
					sampleCompositionTimeOffset: sampleCompositionTimeOffset))
			sampleStartIndex = 1
		}

		for _ in sampleStartIndex..<sampleCount {
			let sampleDuration: UInt32? = try scanner.scanOptional { flags.contains(.sampleDurationPresent) }
			let sampleSize: UInt32? = try scanner.scanOptional { flags.contains(.sampleSizePresent) }
			let sampleFlags: UInt32? = try scanner.scanOptional { flags.contains(.sampleFlagsPresent) }
			let sampleCompositionTimeOffset: UInt32? = try scanner.scanOptional { flags.contains(.sampleCompTimeOffsetsPresent) }

			samples.append(
				Sample(
					sampleDuration: sampleDuration,
					sampleSize: sampleSize,
					sampleFlags: sampleFlags,
					sampleCompositionTimeOffset: sampleCompositionTimeOffset))
		}

		self.init(
			flags: flags,
			sampleCount: sampleCount,
			dataOffset: dataOffset,
			firstSampleFlags: firstSampleFlags,
			samples: samples)
	}

	public struct Sample: Sendable, Hashable, CustomStringConvertible {
		public let sampleDuration: UInt32?
		public let sampleSize: UInt32?
		public let sampleFlags: UInt32?
		public let sampleCompositionTimeOffset: UInt32?

		public var description: String {
			let components: [String] = [
				("sampleDuration", sampleDuration),
				("sampleSize", sampleSize),
				("sampleFlags", sampleFlags),
				("sampleCompositionTimeOffset", sampleCompositionTimeOffset),
			]
				.compactMap {
					guard let value = $0.1 else { return nil }
					return "\($0.0): \(value)"
				}

			return "Sample:\n\(components.joined(separator: "\n"))"
		}
	}
}
