import DataScanner
import Foundation

public struct MOOV: ChonkProtocol {

	public let mvhd: MVHD
	public let trak: [TRAK] // one or more
//	public let mvex: [MVEX] // zero or more
//	public let udta: UDTA? // zero or one

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		var mvhd: MVHD?
		var trak: [TRAK] = []

		while scanner.isAtEnd == false {
			let nextBox = try scanner.scanNextBox()

			switch nextBox.magic {
			case MVHD.magic:
				mvhd = try MVHD(decoding: nextBox.data)
			case TRAK.magic:
				trak.append(try TRAK(decoding: nextBox.data))
			case "mvex", "udta": break
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBox.magic)"))
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
