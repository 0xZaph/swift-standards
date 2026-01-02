//
//  Parsing.Parsers.Map.swift
//  swift-standards
//
//  Map combinator - transforms parser output.
//

extension Parsing.Parsers {
    /// Namespace for map parsers.
    public enum Map {}
}

// MARK: - Map.Transform

extension Parsing.Parsers.Map {
    /// A parser that transforms the output of another parser.
    ///
    /// This is the functor `map` operation for parsers. It applies a pure
    /// transformation to successful parsing results.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let intParser = Digits().map { Int($0)! }
    /// ```
    ///
    /// Created via `parser.map(_:)`.
    public struct Transform<Upstream: Parsing.Parser, Output>: Parsing.Parser, Sendable
    where Upstream: Sendable {
        public typealias Input = Upstream.Input

        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: @Sendable (Upstream.Output) -> Output

        /// Creates a map parser.
        ///
        /// - Parameters:
        ///   - upstream: The parser to transform.
        ///   - transform: The transformation to apply.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping @Sendable (Upstream.Output) -> Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            transform(try upstream.parse(&input))
        }
    }
}

// MARK: - Map.Throwing

extension Parsing.Parsers.Map {
    /// A parser that transforms output using a throwing function.
    ///
    /// If the transformation throws, parsing fails with that error.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let positiveInt = Digits().tryMap { str in
    ///     guard let n = Int(str), n > 0 else {
    ///         throw Parsing.Error("Expected positive integer")
    ///     }
    ///     return n
    /// }
    /// ```
    ///
    /// Created via `parser.tryMap(_:)`.
    public struct Throwing<Upstream: Parsing.Parser, Output>: Parsing.Parser, Sendable
    where Upstream: Sendable {
        public typealias Input = Upstream.Input

        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: @Sendable (Upstream.Output) throws(Parsing.Error) -> Output

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping @Sendable (Upstream.Output) throws(Parsing.Error) -> Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            try transform(try upstream.parse(&input))
        }
    }
}
