import DataScanner
import Foundation
import SwiftPizzaSnips

public struct HDLR: ChonkProtocol {
	public struct HandlerType: RawRepresentable, Sendable, Hashable, MagicNumber {
		public var rawValue: UInt32

		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}

		public static let video = HandlerType(stringValue: String("vide".reversed()))!
		public static let sound = HandlerType(stringValue: String("soun".reversed()))!
		public static let hint = HandlerType(stringValue: String("hint".reversed()))!
	}

	public let handlerType: HandlerType
	public let name: String

	public var description: String {
		"""
		HDLR:
		HandlerType: \(handlerType.stringValue ?? "\(handlerType.rawValue)")
		Name: \(name)
		"""
	}

	init(decoding data: Data) throws {
		var scanner = DataScanner(data: data)
		scanner.defaultEndianness = .big

		let _: (UInt8, NullFlags) = try scanner.scanVersionAndFlags()

		scanner.currentOffset += 4 // skip pre defined
		let rawHandler: UInt32 = try scanner.scan()
		self.handlerType = HandlerType(rawValue: rawHandler)
		scanner.currentOffset += 12 // skip reserved
		self.name = try scanner.scanStringUntilNullTerminated()
	}
}
