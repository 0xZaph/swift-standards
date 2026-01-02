//
//  Int16+Parser.swift
//  swift-standards
//
//  ParserPrinter for Int16 binary serialization.
//

extension Int16 {
    /// A parser that reads two bytes as an `Int16`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0xFF, 0xFE, 0x00]
    /// let parser = Int16.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == -2, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = Int16
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> Int16 {
            let size = MemoryLayout<Int16>.size
            guard input.count >= size else {
                throw .unexpected(expected: "\(size) bytes for Int16")
            }
            var bytes: [UInt8] = []
            bytes.reserveCapacity(size)
            for _ in 0..<size {
                bytes.append(input.removeFirst())
            }
            return Int16(bytes: bytes, endianness: endianness)!
        }

        @inlinable
        public func print(_ output: Int16, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
