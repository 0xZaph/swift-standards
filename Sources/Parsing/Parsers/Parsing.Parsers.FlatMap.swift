//
//  Parsing.Parsers.FlatMap.swift
//  swift-standards
//
//  FlatMap combinator - chains dependent parsers.
//

extension Parsing.Parsers {
    /// A parser that chains two parsers where the second depends on the first's output.
    ///
    /// This is the monad `flatMap` (or `bind`) operation for parsers.
    /// It enables context-dependent parsing where the choice of next parser
    /// depends on what was previously parsed.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Parse a length-prefixed string
    /// let lengthPrefixed = UInt8Parser().flatMap { length in
    ///     Take(Int(length))
    /// }
    /// ```
    ///
    /// Created via `parser.flatMap(_:)`.
    public struct FlatMap<Upstream: Parsing.Parser, Downstream: Parsing.Parser>: Parsing.Parser, Sendable
    where Upstream: Sendable, Downstream: Sendable, Upstream.Input == Downstream.Input {
        public typealias Input = Upstream.Input
        public typealias Output = Downstream.Output

        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: @Sendable (Upstream.Output) -> Downstream

        /// Creates a flatMap parser.
        ///
        /// - Parameters:
        ///   - upstream: The first parser.
        ///   - transform: A function that produces the second parser from the first's output.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping @Sendable (Upstream.Output) -> Downstream
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let upstreamOutput = try upstream.parse(&input)
            let downstream = transform(upstreamOutput)
            return try downstream.parse(&input)
        }
    }
}
