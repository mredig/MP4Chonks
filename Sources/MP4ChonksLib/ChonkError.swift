public enum ChonkError: Error {
	case missingValue(type: Any.Type, value: String)
	case corruptedValue(type: Any.Type, value: String)
	case unexpectedValue(type: Any.Type, value: String)

	static func debugThrow(_ error: ChonkError) throws {
		#if DEBUG
		throw error
		#endif
	}
}
