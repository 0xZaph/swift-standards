//
//  Parsing.Parse.swift
//  swift-standards
//
//  Parse entry point for building parsers.
//

extension Parsing {
    /// Namespace for parse entry points.
    public enum Parse {}
}

// MARK: - Parse.Sequence

extension Parsing.Parse {
    /// Entry point for building parsers with result builder syntax.
    ///
    /// `Sequence` provides a convenient way to compose parsers using Swift's
    /// result builder syntax. The resulting parser type is inferred from
    /// the builder contents.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// let keyValue = Parse.Sequence {
    ///     Prefix.While { $0 != UInt8(ascii: "=") }  // key
    ///     "="                                        // delimiter (discarded)
    ///     Rest()                                     // value
    /// }
    /// // Type: Parser with Output = (Substring, Substring) or similar
    /// ```
    ///
    /// ## With Output Type
    ///
    /// ```swift
    /// let point = Parse.Transform(Point.init) {
    ///     IntParser()
    ///     ","
    ///     IntParser()
    /// }
    /// ```
    ///
    /// ## Input Type Inference
    ///
    /// The input type is inferred from the parsers in the builder.
    /// All parsers must have the same input type.
    public struct Sequence<Input, Output, Body: Parsing.Parser>: Parsing.Parser, Sendable
    where Body: Sendable, Body.Input == Input, Body.Output == Output {
        @usableFromInline
        let body: Body

        /// Creates a parser from a builder.
        ///
        /// - Parameter build: A builder that produces a parser.
        @inlinable
        public init(
            @Parsing.Parsers.Take.Builder<Input> _ build: () -> Body
        ) {
            self.body = build()
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            try body.parse(&input)
        }
    }
}

// MARK: - Parse.Transform

extension Parsing.Parse {
    /// A parser that transforms its body's output.
    ///
    /// Enables constructing domain types from parsed tuples:
    ///
    /// ```swift
    /// let point = Parse.Transform(Point.init) {
    ///     IntParser()
    ///     ","
    ///     IntParser()
    /// }
    /// ```
    public struct Transform<Input, BodyOutput, Output, Body: Parsing.Parser>: Parsing.Parser, Sendable
    where Body: Sendable, Body.Input == Input, Body.Output == BodyOutput {
        @usableFromInline
        let body: Body

        @usableFromInline
        let transform: @Sendable (BodyOutput) -> Output

        @inlinable
        public init(
            _ transform: @escaping @Sendable (BodyOutput) -> Output,
            @Parsing.Parsers.Take.Builder<Input> _ build: () -> Body
        ) {
            self.body = build()
            self.transform = transform
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            transform(try body.parse(&input))
        }
    }
}

// MARK: - Parse.OneOf

extension Parsing.Parse {
    /// Entry point for building alternative parsers.
    ///
    /// `OneOf` tries each parser in order until one succeeds.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let boolean = Parse.OneOf {
    ///     "true".map { true }
    ///     "false".map { false }
    /// }
    /// ```
    public struct OneOf<Input, Output, Body: Parsing.Parser>: Parsing.Parser, Sendable
    where Body: Sendable, Body.Input == Input, Body.Output == Output {
        @usableFromInline
        let body: Body

        @inlinable
        public init(
            @Parsing.Parsers.OneOf.Builder<Input, Output> _ build: () -> Body
        ) {
            self.body = build()
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            try body.parse(&input)
        }
    }
}
