import DataScanner
import Foundation

protocol ChonkProtocol {
	static var magic: String { get }

	init(decoding data: Data) throws

//	func handleMagic(_ boxMagic: String, _ box: Data) throws -> ChonkProtocol
}

extension ChonkProtocol {
	static var magic: String { "\(Self.self)".lowercased() }

//	func scanMagicBox(_ data: Data) throws -> [String: [ChonkProtocol]] {
//		var boxScanner = DataScanner(data: data)
//
//		var accumulator: [String: [ChonkProtocol]] = [:]
//		while boxScanner.isAtEnd == false {
//			let boxSize: UInt32 = try boxScanner.scan(endianness: .big)
//
//			let boxMagic = try boxScanner.scanMagic()
//			let box = try boxScanner.scanBytes(Int(boxSize) - 8)
//			accumulator[boxMagic, default: []].append(try handleMagic(boxMagic, box))
//		}
//		return accumulator
//	}
}
