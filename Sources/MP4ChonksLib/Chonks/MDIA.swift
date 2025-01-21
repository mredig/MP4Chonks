import DataScanner
import Foundation
import SwiftPizzaSnips

public struct MDIA: ChonkProtocol {
	public let mdhd: MDHD
//	public let minf: MINF
	public let hdlr: HDLR

	public var description: String {
		"""
		MDIA:
		\(mdhd.description.prefixingLines(with: "\t"))
		\(hdlr.description.prefixingLines(with: "\t"))
		"""
	}


	public init(decoding data: Data) throws {
		var scanner = DataScanner(data)
		scanner.defaultEndianness = .big

		var mdhd: MDHD?
		var hdlr: HDLR?

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case MDHD.magic:
				let nextBox = try scanner.scanBoxContent(header: nextBoxHeader)
				mdhd = try MDHD(decoding: nextBox.data)
			case HDLR.magic:
				let nextBox = try scanner.scanBoxContent(header: nextBoxHeader)
				hdlr = try HDLR(decoding: nextBox.data)
			case "minf":
				scanner.skipBoxContent(header: nextBoxHeader)
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
			}
		}

		guard let mdhd else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing mdhd")
		}
		guard let hdlr else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing hdlr")
		}
		self.mdhd = mdhd
		self.hdlr = hdlr
	}
}
