import DataScanner
import Foundation

public struct MOOF: ChonkProtocol {
	public let mfhd: MFHD
	public let traf: [TRAF] // zero or more

	public var description: String {
		let trafs = traf
			.map { $0.description.prefixingLines(with: "\($0.tfhd.trackID) ") }
			.joined(separator: "\n")

		return """
			MOOF:
			\(mfhd.description.prefixingLines(with: "\t"))
			\(trafs.description.prefixingLines(with: "\t"))
			"""
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		var mfhd: MFHD?
		var traf: [TRAF] = []

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case MFHD.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				try mfhd.setValueOnce(MFHD(decoding: boxContent.data))
			case TRAF.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				traf.append(try TRAF(decoding: boxContent.data))
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
			}
		}

		guard let mfhd else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing mfhd")
		}
		guard traf.isOccupied else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing traf")
		}

		self.mfhd = mfhd
		self.traf = traf
	}
}
