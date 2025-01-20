import DataScanner
import Foundation
import SwiftPizzaSnips

public struct TRAK: ChonkProtocol {
	public let tkhd: TKHD
	// public let tref: TREF?
	 public let mdia: MDIA
	// public let edts: EDTS?

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data)
		scanner.defaultEndianness = .big

		var tkhd: TKHD?
		var mdia: MDIA?

		while scanner.isAtEnd == false {
			let nextBox = try scanner.scanNextBox()

			switch nextBox.magic {
			case TKHD.magic:
				tkhd = try TKHD(decoding: nextBox.data)
			case MDIA.magic:
				mdia = try MDIA(decoding: nextBox.data)
			case "tref", "edts": break
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBox.magic)"))
			}
		}

		guard let tkhd else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing tkhd")
		}
		guard let mdia else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing mdia")
		}

		self.tkhd = tkhd
		self.mdia = mdia
	}
}
