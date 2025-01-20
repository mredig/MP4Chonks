import DataScanner
import Foundation

public class MP4Chonker {
	public let moov: MOOV

	public init(mp4File: URL) throws {
		var scanner = try DataScanner(url: mp4File)
		scanner.defaultEndianness = .big

		var moov: MOOV?

		while scanner.isAtEnd == false {
			let nextBox = try scanner.scanNextBox()

			switch nextBox.magic {
			case MOOV.magic:
				moov = try MOOV(decoding: nextBox.data)
				break
			case "ftyp": break
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBox.magic)"))
			}
		}

		guard let moov else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing moov")
		}

		self.moov = moov
	}
}
