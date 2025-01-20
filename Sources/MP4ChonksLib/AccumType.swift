
typealias AccumType = AccumulatorType
enum AccumulatorType: Sendable, Hashable {
	case int(Int)
	case uint(UInt)
	case int16(Int16)
	case uint16(UInt16)
	case int32(Int32)
	case uint32(UInt32)
	case uint8(UInt8)
}
