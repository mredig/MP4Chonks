import DataScanner
import Foundation
import SwiftPizzaSnips

public struct MDIA: ChonkProtocol {
	public let mdhd: MDHD
//	public let minf: MINF
//	public let hdlr: HDLR

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data)
		scanner.defaultEndianness = .big

		var mdhd: MDHD?

		while scanner.isAtEnd == false {
			let nextBox = try scanner.scanNextBox()

			switch nextBox.magic {
			case MDHD.magic:
				mdhd = try MDHD(decoding: nextBox.data)
			case "minf", "hdlr":
				break
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBox.magic)"))
			}
		}

		guard let mdhd else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing MDHD")
		}
		self.mdhd = mdhd
	}
}
