//
//  UInt32+Parser.swift
//  swift-standards
//
//  ParserPrinter for UInt32 binary serialization.
//

extension UInt32 {
    /// A parser that reads four bytes as a `UInt32`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78, 0x00]
    /// let parser = UInt32.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == 0x12345678, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = UInt32
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> UInt32 {
            let size = MemoryLayout<UInt32>.size
            guard input.count >= size else {
                throw .unexpected(expected: "\(size) bytes for UInt32")
            }
            var bytes: [UInt8] = []
            bytes.reserveCapacity(size)
            for _ in 0..<size {
                bytes.append(input.removeFirst())
            }
            return UInt32(bytes: bytes, endianness: endianness)!
        }

        @inlinable
        public func print(_ output: UInt32, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
