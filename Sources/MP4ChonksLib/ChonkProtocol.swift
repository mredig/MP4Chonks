import DataScanner
import Foundation

protocol ChonkProtocol: CustomStringConvertible {
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

extension Optional where Wrapped: ChonkProtocol {
	mutating func setValueOnce(_ newValue: Wrapped) throws(ChonkError) {
		guard case .none = self else {
			throw .duplicateValue(type: Wrapped.self, value: "Only a single \(Wrapped.self) value allowed in this container")
		}
		self = .some(newValue)
	}
}
