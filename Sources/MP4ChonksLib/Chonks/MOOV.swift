import DataScanner
import Foundation

public struct MOOV: ChonkProtocol {

	public let mvhd: MVHD
	public let trak: [TRAK] // one or more
//	public let mvex: [MVEX] // zero or more
//	public let udta: UDTA? // zero or one

	public var description: String {
		let traks = trak
			.map { $0.description.prefixingLines(with: "\($0.tkhd.trackID) ") }
			.joined(separator: "\n")

		return """
			MOOV:
			\(mvhd.description.prefixingLines(with: "\t"))
			\(traks.description.prefixingLines(with: "\t"))
			"""
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		var mvhd: MVHD?
		var trak: [TRAK] = []

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case MVHD.magic:
				let nextBox = try scanner.scanBoxContent(header: nextBoxHeader)
				mvhd = try MVHD(decoding: nextBox.data)
			case TRAK.magic:
				let nextBox = try scanner.scanBoxContent(header: nextBoxHeader)
				trak.append(try TRAK(decoding: nextBox.data))
			case "mvex", "udta":
				scanner.skipBoxContent(header: nextBoxHeader)
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
			}
		}

		guard let mvhd else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing mvhd")
		}
		guard trak.isOccupied else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing trak")
		}

		self.mvhd = mvhd
		self.trak = trak
	}
}
