//
//  Parsing.Parsers.Literal.swift
//  swift-standards
//
//  Literal matching parsers.
//

extension Parsing.Parsers {
    /// A parser that matches a specific byte sequence.
    ///
    /// `Literal` consumes exact bytes from the input. It succeeds with `Void`
    /// output, making it ideal for delimiters and keywords.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Match a keyword
    /// let httpKeyword = Literal([0x48, 0x54, 0x54, 0x50])  // "HTTP"
    ///
    /// // Via string literal (for ASCII)
    /// let comma: Literal<Span<UInt8>> = ","
    /// ```
    public struct Literal<Input: Parsing.Input>: Parsing.Parser, Sendable
    where Input: Sendable, Input.Element == UInt8 {
        public typealias Output = Void

        @usableFromInline
        let bytes: [UInt8]

        /// Creates a literal parser for the given bytes.
        @inlinable
        public init(_ bytes: [UInt8]) {
            self.bytes = bytes
        }

        /// Creates a literal parser from a static string.
        @inlinable
        public init(_ string: StaticString) {
            self.bytes = Array(string.utf8Start.withMemoryRebound(to: UInt8.self, capacity: string.utf8CodeUnitCount) {
                UnsafeBufferPointer(start: $0, count: string.utf8CodeUnitCount)
            })
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Void {
            for expected in bytes {
                guard let actual = input.first else {
                    throw Parsing.Error.unexpectedEnd(expected: "byte \(expected)")
                }
                guard actual == expected else {
                    throw Parsing.Error.unexpected(actual, expected: "byte \(expected)")
                }
                _ = input.removeFirst()
            }
        }
    }
}

// MARK: - Single Byte Literal

extension Parsing.Parsers {
    /// A parser that matches a single byte.
    ///
    /// More efficient than `Literal` for single bytes.
    public struct Byte<Input: Parsing.Input>: Parsing.Parser, Sendable
    where Input: Sendable, Input.Element == UInt8 {
        public typealias Output = Void

        @usableFromInline
        let expected: UInt8

        @inlinable
        public init(_ expected: UInt8) {
            self.expected = expected
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Void {
            guard let actual = input.first else {
                throw Parsing.Error.unexpectedEnd(expected: "byte \(expected)")
            }
            guard actual == expected else {
                throw Parsing.Error.unexpected(actual, expected: "byte \(expected)")
            }
            _ = input.removeFirst()
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension Parsing.Parsers.Literal: ExpressibleByStringLiteral {
    /// Creates a literal parser from a string literal.
    ///
    /// The string is converted to UTF-8 bytes.
    @inlinable
    public init(stringLiteral value: String) {
        self.bytes = Array(value.utf8)
    }
}

extension Parsing.Parsers.Literal: ExpressibleByUnicodeScalarLiteral {
    @inlinable
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        self.bytes = Array(String(value).utf8)
    }
}

extension Parsing.Parsers.Literal: ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.bytes = Array(String(value).utf8)
    }
}
