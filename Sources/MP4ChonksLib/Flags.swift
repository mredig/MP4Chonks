
public struct TFHDFlags: OptionSet, Sendable {
	public var rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public static let dataOffsetPresent = TFHDFlags(rawValue: 0x1)
	public static let sampleDescIndexPresent = TFHDFlags(rawValue: 0x2)
	public static let defaultSampleDurationPresent = TFHDFlags(rawValue: 0x8)
	public static let defaultSampleSizePresent = TFHDFlags(rawValue: 0x10)
	public static let defaultSampleFlagsPresent = TFHDFlags(rawValue: 0x20)
	public static let durationIsEmpty = TFHDFlags(rawValue: 0x010000)
}

public struct TRUNFlags: OptionSet, Sendable {
	public var rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public static let dataOffsetPresent = TRUNFlags(rawValue: 0x1)
	public static let firstSampleFlagsPresent = TRUNFlags(rawValue: 0x4)
	public static let sampleDurationPresent = TRUNFlags(rawValue: 0x100)
	public static let sampleSizePresent = TRUNFlags(rawValue: 0x200)
	public static let sampleFlagsPresent = TRUNFlags(rawValue: 0x400)
	public static let sampleCompTimeOffsetsPresent = TRUNFlags(rawValue: 0x800)
}

public struct TKHDFlags: OptionSet, Sendable {
	public var rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	/// Whether track is enabled or not
	public static let trackEnabled = TKHDFlags(rawValue: 0x1)
	/// Whether track is used in presentation
	public static let trackInMovie = TKHDFlags(rawValue: 0x2)
	/// Whether track is used when previewing presentation
	public static let trackInPreview = TKHDFlags(rawValue: 0x4)
}

struct NullFlags: OptionSet, Sendable {
	var rawValue: UInt32
}
