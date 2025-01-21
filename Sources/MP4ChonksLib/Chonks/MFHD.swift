import DataScanner
import Foundation
import SwiftPizzaSnips

public struct MFHD: ChonkProtocol {
	/// Ordinal index of this fragment. Must be increased from the previous.
	public let sequenceNumber: UInt32

	public var description: String {
		"MFHD:\nsequenceNumber: \(sequenceNumber)"
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		let (_, _): (UInt8, NullFlags) = try scanner.scanVersionAndFlags()

		self.sequenceNumber = try scanner.scan()
	}
}
