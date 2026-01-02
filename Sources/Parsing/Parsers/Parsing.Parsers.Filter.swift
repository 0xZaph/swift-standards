//
//  Parsing.Parsers.Filter.swift
//  swift-standards
//
//  Filter combinator - validates parser output.
//

extension Parsing.Parsers {
    /// A parser that filters output using a predicate.
    ///
    /// If the upstream parser succeeds but the predicate returns false,
    /// parsing fails. This enables validation constraints on parsed values.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let positiveInt = IntParser().filter { $0 > 0 }
    /// ```
    ///
    /// Created via `parser.filter(_:)`.
    public struct Filter<Upstream: Parsing.Parser>: Parsing.Parser, Sendable
    where Upstream: Sendable {
        public typealias Input = Upstream.Input
        public typealias Output = Upstream.Output

        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let predicate: @Sendable (Output) -> Bool

        /// Creates a filter parser.
        ///
        /// - Parameters:
        ///   - upstream: The parser to filter.
        ///   - predicate: The predicate that must return true for success.
        @inlinable
        public init(
            upstream: Upstream,
            predicate: @escaping @Sendable (Output) -> Bool
        ) {
            self.upstream = upstream
            self.predicate = predicate
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let output = try upstream.parse(&input)
            guard predicate(output) else {
                throw Parsing.Error("Filter predicate failed for: \(output)")
            }
            return output
        }
    }
}
