import DataScanner
import Foundation

public struct TRAF: ChonkProtocol {
	public let tfhd: TFHD
	public let trun: [TRUN] // zero or more

	public var description: String {
		let truns = trun
			.map { $0.description }
			.joined(separator: "\n")

		return """
			TRAF:
			\(tfhd.description.prefixingLines(with: "\t"))
			\(truns.description.prefixingLines(with: "\t"))
			"""
	}

	public init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		var tfhd: TFHD?
		var trun: [TRUN] = []

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case TFHD.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				try tfhd.setValueOnce(TFHD(decoding: boxContent.data))
			case TRUN.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				try trun.append(TRUN(decoding: boxContent.data))
			case "tfdt":
				scanner.skipBoxContent(header: nextBoxHeader)
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
			}
		}

		guard let tfhd else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing tfhd")
		}
		self.tfhd = tfhd
		self.trun = trun
	}
}
