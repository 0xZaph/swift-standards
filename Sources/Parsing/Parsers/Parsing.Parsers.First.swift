//
//  Parsing.Parsers.First.swift
//  swift-standards
//
//  Single element and rest-of-input parsers.
//

extension Parsing.Parsers {
    /// Namespace for first-element parsers.
    public enum First {}
}

// MARK: - First.Element

extension Parsing.Parsers.First {
    /// A parser that consumes and returns the first element.
    ///
    /// Fails if the input is empty.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let anyByte = First.Element<ArraySlice<UInt8>>()
    /// ```
    public struct Element<Input: Parsing.Input>: Parsing.Parser, Sendable
    where Input: Sendable {
        public typealias Output = Input.Element

        @inlinable
        public init() {}

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            guard !input.isEmpty else {
                throw Parsing.Error.unexpectedEnd(expected: "any element")
            }
            return input.removeFirst()
        }
    }
}

// MARK: - First.Where

extension Parsing.Parsers.First {
    /// A parser that consumes the first element if it matches a predicate.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let digit = First.Where<ArraySlice<UInt8>> { $0 >= 0x30 && $0 <= 0x39 }
    /// ```
    public struct Where<Input: Parsing.Input>: Parsing.Parser, Sendable
    where Input: Sendable {
        public typealias Output = Input.Element

        @usableFromInline
        let predicate: @Sendable (Input.Element) -> Bool

        @usableFromInline
        let expected: String

        @inlinable
        public init(
            expected: String = "matching element",
            _ predicate: @escaping @Sendable (Input.Element) -> Bool
        ) {
            self.predicate = predicate
            self.expected = expected
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            guard let element = input.first else {
                throw Parsing.Error.unexpectedEnd(expected: expected)
            }
            guard predicate(element) else {
                throw Parsing.Error.unexpected(element, expected: expected)
            }
            return input.removeFirst()
        }
    }
}

// MARK: - Rest

extension Parsing.Parsers {
    /// A parser that consumes and returns all remaining input.
    ///
    /// Always succeeds, possibly with empty output.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Parse {
    ///     Header()
    ///     Rest()  // Everything after header
    /// }
    /// ```
    public struct Rest<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable, Input.SubSequence == Input {
        public typealias Output = Input

        @inlinable
        public init() {}

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let result = input
            input = input[input.endIndex...]  // Empty the input
            return result
        }
    }
}

// MARK: - Consume Namespace

extension Parsing.Parsers {
    /// Namespace for element-consuming parsers.
    public enum Consume {}
}

// MARK: - Consume.Exactly

extension Parsing.Parsers.Consume {
    /// A parser that consumes exactly N elements.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let fourBytes = Consume.Exactly<ArraySlice<UInt8>>(4)
    /// ```
    public struct Exactly<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable, Input.SubSequence == Input {
        public typealias Output = Input

        @usableFromInline
        let count: Int

        @inlinable
        public init(_ count: Int) {
            self.count = count
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let endIndex = input.index(input.startIndex, offsetBy: count, limitedBy: input.endIndex)
                ?? input.endIndex

            let actualCount = input.distance(from: input.startIndex, to: endIndex)
            guard actualCount == count else {
                throw Parsing.Error("Expected \(count) elements, got \(actualCount)")
            }

            let result = input[input.startIndex..<endIndex]
            input = input[endIndex...]
            return result
        }
    }
}

// MARK: - Discard Namespace

extension Parsing.Parsers {
    /// Namespace for element-discarding parsers.
    public enum Discard {}
}

// MARK: - Discard.Exactly

extension Parsing.Parsers.Discard {
    /// A parser that skips N elements without returning them.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Parse {
    ///     Discard.Exactly<ArraySlice<UInt8>>(4)  // Skip 4-byte header
    ///     Rest()
    /// }
    /// ```
    public struct Exactly<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable, Input.SubSequence == Input {
        public typealias Output = Void

        @usableFromInline
        let count: Int

        @inlinable
        public init(_ count: Int) {
            self.count = count
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Void {
            let endIndex = input.index(input.startIndex, offsetBy: count, limitedBy: input.endIndex)
                ?? input.endIndex

            let actualCount = input.distance(from: input.startIndex, to: endIndex)
            guard actualCount == count else {
                throw Parsing.Error("Expected to skip \(count) elements, only \(actualCount) available")
            }

            input = input[endIndex...]
        }
    }
}

// MARK: - End

extension Parsing.Parsers {
    /// A parser that succeeds only at end of input.
    ///
    /// Consumes nothing and produces Void. Fails if input remains.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Parse {
    ///     Content()
    ///     End()  // Ensure nothing follows
    /// }
    /// ```
    public struct End<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable {
        public typealias Output = Void

        @inlinable
        public init() {}

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Void {
            guard input.isEmpty else {
                throw Parsing.Error("Expected end of input", at: input)
            }
        }
    }
}
