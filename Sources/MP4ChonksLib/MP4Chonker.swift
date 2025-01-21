import DataScanner
import Foundation

public class MP4Chonker {
	public let moov: MOOV

	private var _videoTrack: TRAK?
	public var videoTrack: TRAK? {
		if let existing = _videoTrack {
			return existing
		}
		guard
			let videoTrack = moov.trak.first(where: { $0.mdia.hdlr.handlerType == .video })
		else { return nil }
		self._videoTrack = videoTrack
		return videoTrack
	}

	public init(mp4File: URL) throws {
		var scanner = try DataScanner(url: mp4File)
		scanner.defaultEndianness = .big

		var moov: MOOV?

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case MOOV.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				try moov.setValueOnce(MOOV(decoding: boxContent.data)) 
			case "ftyp":
				scanner.skipBoxContent(header: nextBoxHeader)
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
			}
		}

		guard let moov else {
			throw ChonkError.missingValue(type: Self.self, value: "Missing moov")
		}

		self.moov = moov
	}

	public func getVideoTimescale() -> UInt32? {
		guard
			let videoTrack = moov.trak.first(where: { $0.mdia.hdlr.handlerType == .video })
		else { return nil }

		return videoTrack.mdia.mdhd.timescale
	}

	public func info(fromM4SFile m4sFile: URL) throws -> MOOF {
		var scanner = try DataScanner(url: m4sFile)
		scanner.defaultEndianness = .big

		var moof: MOOF?

		while scanner.isAtEnd == false {
			let nextBoxHeader = try scanner.scanNextBoxHeader()

			switch nextBoxHeader.magic {
			case MOOF.magic:
				let boxContent = try scanner.scanBoxContent(header: nextBoxHeader)
				try moof.setValueOnce(MOOF(decoding: boxContent.data))
			case "styp", "sidx", "mdat":
				scanner.skipBoxContent(header: nextBoxHeader)
			default:
				try ChonkError.debugThrow(
					ChonkError.unexpectedValue(
						type: Self.self,
						value: "Unexpected child box: \(nextBoxHeader.magic)"))
			}
		}

		guard let moof else { throw ChonkError.missingValue(type: MOOF.self, value: "No moof in this file") }

		return moof
	}

	public func duration(forM4SFile m4sFile: URL) throws -> (numerator: UInt32, denominator: UInt32) {
		let info = try info(fromM4SFile: m4sFile)

		guard let videoTrack else { throw ChonkError.missingValue(type: TRAK.self, value: "Init file missing video TRAK") }

		let vTrackID = videoTrack.tkhd.trackID
		guard
			let infoTraf = info.traf.first(where: { $0.tfhd.trackID == vTrackID })
		else { throw ChonkError.missingValue(type: TRAF.self, value: "No video TRAF in m4s segment") }

		let samples = infoTraf.trun.flatMap(\.samples)

		let samplesDuration = samples.compactMap { $0.sampleDuration ?? infoTraf.tfhd.defaultSampleDuration }.reduce(0, +)

		return (samplesDuration, videoTrack.mdia.mdhd.timescale)
	}
}
