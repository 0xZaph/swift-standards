//
//  UInt64+Parser.swift
//  swift-standards
//
//  ParserPrinter for UInt64 binary serialization.
//

extension UInt64 {
    /// A parser that reads eight bytes as a `UInt64`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0, 0x00]
    /// let parser = UInt64.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == 0x123456789ABCDEF0, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = UInt64
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> UInt64 {
            let size = MemoryLayout<UInt64>.size
            guard input.count >= size else {
                throw .unexpected(expected: "\(size) bytes for UInt64")
            }
            var bytes: [UInt8] = []
            bytes.reserveCapacity(size)
            for _ in 0..<size {
                bytes.append(input.removeFirst())
            }
            return UInt64(bytes: bytes, endianness: endianness)!
        }

        @inlinable
        public func print(_ output: UInt64, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
