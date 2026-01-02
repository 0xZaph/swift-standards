//
//  Int64+Parser.swift
//  swift-standards
//
//  ParserPrinter for Int64 binary serialization.
//

extension Int64 {
    /// A parser that reads eight bytes as an `Int64`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0x00]
    /// let parser = Int64.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == -2, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = Int64
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> Int64 {
            let size = MemoryLayout<Int64>.size
            guard input.count >= size else {
                throw .unexpected(expected: "\(size) bytes for Int64")
            }
            var bytes: [UInt8] = []
            bytes.reserveCapacity(size)
            for _ in 0..<size {
                bytes.append(input.removeFirst())
            }
            return Int64(bytes: bytes, endianness: endianness)!
        }

        @inlinable
        public func print(_ output: Int64, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
