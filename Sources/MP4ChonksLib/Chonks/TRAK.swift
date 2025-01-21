import DataScanner
import Foundation
import SwiftPizzaSnips

public struct TRAK: ChonkProtocol {
	public let tkhd: TKHD
	// public let tref: TREF?
	 public let mdia: MDIA
	// public let edts: EDTS?

	public var description: String {
		"""
		TRAK:
		\(tkhd.description.prefixingLines(with: "\t"))
		\(mdia.description.prefixingLines(with: "\t"))
		"""
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data)
		scanner.defaultEndianness = .big

		var tkhd: TKHD?
		var mdia: MDIA?

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case TKHD.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				tkhd = try TKHD(decoding: boxContent.data)
			case MDIA.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				mdia = try MDIA(decoding: boxContent.data)
			case "tref", "edts":
				scanner.skipBoxContent(header: nextBoxHeader)
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
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
