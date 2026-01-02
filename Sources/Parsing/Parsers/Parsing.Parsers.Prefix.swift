//
//  Parsing.Parsers.Prefix.swift
//  swift-standards
//
//  Prefix-based parsers.
//

extension Parsing.Parsers {
    /// Namespace for prefix-based parsers.
    public enum Prefix {}
}

// MARK: - Prefix.While

extension Parsing.Parsers.Prefix {
    /// A parser that consumes elements while a predicate holds.
    ///
    /// `While` is fundamental for tokenization. It greedily consumes elements
    /// until the predicate returns false or input is exhausted.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Parse digits
    /// let digits = Prefix.While { $0 >= 0x30 && $0 <= 0x39 }
    ///
    /// // Parse until delimiter
    /// let field = Prefix.While { $0 != UInt8(ascii: ",") }
    /// ```
    ///
    /// ## Output
    ///
    /// Returns the consumed portion as a slice of the input type.
    public struct While<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable, Input.SubSequence == Input {
        public typealias Output = Input

        @usableFromInline
        let minLength: Int

        @usableFromInline
        let maxLength: Int?

        @usableFromInline
        let predicate: @Sendable (Input.Element) -> Bool

        /// Creates a prefix parser.
        ///
        /// - Parameters:
        ///   - minLength: Minimum elements to consume (default 0).
        ///   - maxLength: Maximum elements to consume (default unlimited).
        ///   - predicate: Returns true for elements to consume.
        @inlinable
        public init(
            minLength: Int = 0,
            maxLength: Int? = nil,
            _ predicate: @escaping @Sendable (Input.Element) -> Bool
        ) {
            self.minLength = minLength
            self.maxLength = maxLength
            self.predicate = predicate
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            var count = 0
            var endIndex = input.startIndex

            while endIndex < input.endIndex {
                if let max = maxLength, count >= max {
                    break
                }
                guard predicate(input[endIndex]) else {
                    break
                }
                input.formIndex(after: &endIndex)
                count += 1
            }

            guard count >= minLength else {
                throw Parsing.Error("Expected at least \(minLength) elements, got \(count)")
            }

            let result = input[input.startIndex..<endIndex]
            input = input[endIndex...]  // Consume from input
            return result
        }
    }
}

// MARK: - Prefix.UpTo

extension Parsing.Parsers.Prefix {
    /// A parser that consumes up to (but not including) a delimiter sequence.
    ///
    /// Unlike `While`, this looks for a specific delimiter sequence rather
    /// than testing each element.
    public struct UpTo<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable, Input.Element: Equatable & Sendable, Input.SubSequence == Input {
        public typealias Output = Input

        @usableFromInline
        let delimiter: [Input.Element]

        /// Creates a prefix-up-to parser.
        ///
        /// - Parameter delimiter: The sequence to stop before.
        @inlinable
        public init(_ delimiter: [Input.Element]) {
            self.delimiter = delimiter
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            var endIndex = input.startIndex

            outer: while endIndex < input.endIndex {
                // Check if delimiter starts here
                var checkIndex = endIndex
                for element in delimiter {
                    guard checkIndex < input.endIndex else {
                        break outer
                    }
                    guard input[checkIndex] == element else {
                        // No match, advance and continue
                        input.formIndex(after: &endIndex)
                        continue outer
                    }
                    input.formIndex(after: &checkIndex)
                }
                // Found delimiter
                break
            }

            let result = input[input.startIndex..<endIndex]
            input = input[endIndex...]
            return result
        }
    }
}

// MARK: - Prefix.Through

extension Parsing.Parsers.Prefix {
    /// A parser that consumes through (including) a delimiter sequence.
    ///
    /// Like `UpTo` but includes the delimiter in the consumed portion.
    public struct Through<Input: Collection>: Parsing.Parser, Sendable
    where Input: Sendable, Input.Element: Equatable & Sendable, Input.SubSequence == Input {
        public typealias Output = Input

        @usableFromInline
        let delimiter: [Input.Element]

        @inlinable
        public init(_ delimiter: [Input.Element]) {
            self.delimiter = delimiter
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            var endIndex = input.startIndex

            outer: while endIndex < input.endIndex {
                var checkIndex = endIndex
                for element in delimiter {
                    guard checkIndex < input.endIndex else {
                        break outer
                    }
                    guard input[checkIndex] == element else {
                        input.formIndex(after: &endIndex)
                        continue outer
                    }
                    input.formIndex(after: &checkIndex)
                }
                // Found delimiter - include it in result
                let result = input[input.startIndex..<checkIndex]
                input = input[checkIndex...]
                return result
            }

            throw Parsing.Error("Delimiter not found")
        }
    }
}
