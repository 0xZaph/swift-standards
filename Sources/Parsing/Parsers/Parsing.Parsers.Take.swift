//
//  Parsing.Parsers.Take.swift
//  swift-standards
//
//  Sequential composition parsers that collect outputs.
//

extension Parsing.Parsers {
    /// Namespace for sequential "take" parsers that collect multiple outputs.
    public enum Take {}

    /// Namespace for sequential "skip" parsers that discard Void outputs.
    public enum Skip {}
}

// MARK: - Take.Builder

extension Parsing.Parsers.Take {
    /// A result builder for composing parsers sequentially.
    ///
    /// `Take.Builder` enables declarative parser composition using Swift's
    /// result builder syntax. Parsers are combined sequentially, with their
    /// outputs collected into tuples.
    ///
    /// ## Sequential Composition
    ///
    /// Multiple parsers run in sequence. Outputs are combined into tuples:
    ///
    /// ```swift
    /// Parse.Sequence {
    ///     IntParser()      // Output: Int
    ///     ","              // Output: Void (discarded)
    ///     IntParser()      // Output: Int
    /// }
    /// // Result: (Int, Int)
    /// ```
    ///
    /// ## Void Skipping
    ///
    /// Parsers with `Void` output are automatically skipped in the result tuple.
    /// This is useful for delimiters and whitespace.
    ///
    /// ## Conditionals
    ///
    /// Use `if` statements for optional parsing:
    ///
    /// ```swift
    /// Parse.Sequence {
    ///     Header()
    ///     if hasBody {
    ///         Body()
    ///     }
    /// }
    /// ```
    @resultBuilder
    public struct Builder<Input> {
        // MARK: - Empty Block

        /// Builds an empty parser that consumes nothing and returns Void.
        @inlinable
        public static func buildBlock() -> Parsing.Parsers.Always<Input, Void> {
            Parsing.Parsers.Always(())
        }

        // MARK: - Single Parser

        /// Builds a single parser unchanged.
        @inlinable
        public static func buildBlock<P: Parsing.Parser>(
            _ parser: P
        ) -> P where P.Input == Input {
            parser
        }

        // MARK: - Two Parsers

        /// Combines two parsers sequentially.
        @inlinable
        public static func buildBlock<P0: Parsing.Parser, P1: Parsing.Parser>(
            _ p0: P0,
            _ p1: P1
        ) -> Parsing.Parsers.Take.Two<P0, P1>
        where P0.Input == Input, P1.Input == Input {
            Parsing.Parsers.Take.Two(p0, p1)
        }

        // MARK: - Skip First (P0 output is Void)

        /// Combines parsers, skipping Void output from first.
        @inlinable
        public static func buildBlock<P0: Parsing.Parser, P1: Parsing.Parser>(
            _ p0: P0,
            _ p1: P1
        ) -> Parsing.Parsers.Skip.First<P0, P1>
        where P0.Input == Input, P1.Input == Input, P0.Output == Void {
            Parsing.Parsers.Skip.First(p0, p1)
        }

        // MARK: - Skip Second (P1 output is Void)

        /// Combines parsers, skipping Void output from second.
        @inlinable
        public static func buildBlock<P0: Parsing.Parser, P1: Parsing.Parser>(
            _ p0: P0,
            _ p1: P1
        ) -> Parsing.Parsers.Skip.Second<P0, P1>
        where P0.Input == Input, P1.Input == Input, P1.Output == Void {
            Parsing.Parsers.Skip.Second(p0, p1)
        }

        // MARK: - Three Parsers

        /// Combines three parsers sequentially.
        @inlinable
        public static func buildBlock<P0: Parsing.Parser, P1: Parsing.Parser, P2: Parsing.Parser>(
            _ p0: P0,
            _ p1: P1,
            _ p2: P2
        ) -> Parsing.Parsers.Take.Three<P0, P1, P2>
        where P0.Input == Input, P1.Input == Input, P2.Input == Input {
            Parsing.Parsers.Take.Three(p0, p1, p2)
        }

        // MARK: - Partial Block Building (For Longer Chains)

        /// Starts building a partial block.
        @inlinable
        public static func buildPartialBlock<P: Parsing.Parser>(
            first: P
        ) -> P where P.Input == Input {
            first
        }

        /// Accumulates into partial block (general case).
        @inlinable
        public static func buildPartialBlock<Accumulated: Parsing.Parser, Next: Parsing.Parser>(
            accumulated: Accumulated,
            next: Next
        ) -> Parsing.Parsers.Take.Two<Accumulated, Next>
        where Accumulated.Input == Input, Next.Input == Input {
            Parsing.Parsers.Take.Two(accumulated, next)
        }

        /// Accumulates with Void skipping (accumulated is Void).
        @inlinable
        public static func buildPartialBlock<Accumulated: Parsing.Parser, Next: Parsing.Parser>(
            accumulated: Accumulated,
            next: Next
        ) -> Parsing.Parsers.Skip.First<Accumulated, Next>
        where Accumulated.Input == Input, Next.Input == Input, Accumulated.Output == Void {
            Parsing.Parsers.Skip.First(accumulated, next)
        }

        /// Accumulates with Void skipping (next is Void).
        @inlinable
        public static func buildPartialBlock<Accumulated: Parsing.Parser, Next: Parsing.Parser>(
            accumulated: Accumulated,
            next: Next
        ) -> Parsing.Parsers.Skip.Second<Accumulated, Next>
        where Accumulated.Input == Input, Next.Input == Input, Next.Output == Void {
            Parsing.Parsers.Skip.Second(accumulated, next)
        }

        // MARK: - Conditionals

        /// Builds an optional parser from an `if` statement.
        @inlinable
        public static func buildIf<P: Parsing.Parser>(
            _ parser: P?
        ) -> Parsing.Parsers.Optional<P> where P.Input == Input {
            .init(parser)
        }

        /// Builds the first branch of if-else.
        @inlinable
        public static func buildEither<First: Parsing.Parser, Second: Parsing.Parser>(
            first: First
        ) -> Parsing.Parsers.Conditional<First, Second>
        where First.Input == Input, Second.Input == Input, First.Output == Second.Output {
            Parsing.Parsers.Conditional.first(first)
        }

        /// Builds the second branch of if-else.
        @inlinable
        public static func buildEither<First: Parsing.Parser, Second: Parsing.Parser>(
            second: Second
        ) -> Parsing.Parsers.Conditional<First, Second>
        where First.Input == Input, Second.Input == Input, First.Output == Second.Output {
            Parsing.Parsers.Conditional.second(second)
        }

        // MARK: - Expressions

        /// Wraps an expression in the builder context.
        @inlinable
        public static func buildExpression<P: Parsing.Parser>(
            _ parser: P
        ) -> P where P.Input == Input {
            parser
        }
    }
}

// MARK: - Take.Two

extension Parsing.Parsers.Take {
    /// A parser that runs two parsers in sequence and collects both outputs.
    ///
    /// The outputs are combined into a tuple `(P0.Output, P1.Output)`.
    /// Created by `Take.Builder` when combining two non-Void parsers.
    public struct Two<P0: Parsing.Parser, P1: Parsing.Parser>: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P0.Input == P1.Input {
        public typealias Input = P0.Input
        public typealias Output = (P0.Output, P1.Output)

        @usableFromInline
        let p0: P0

        @usableFromInline
        let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let o0 = try p0.parse(&input)
            let o1 = try p1.parse(&input)
            return (o0, o1)
        }
    }
}

// MARK: - Take.Three

extension Parsing.Parsers.Take {
    /// A parser that runs three parsers in sequence and collects all outputs.
    public struct Three<P0: Parsing.Parser, P1: Parsing.Parser, P2: Parsing.Parser>: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P2: Sendable,
          P0.Input == P1.Input, P1.Input == P2.Input {
        public typealias Input = P0.Input
        public typealias Output = (P0.Output, P1.Output, P2.Output)

        @usableFromInline
        let p0: P0

        @usableFromInline
        let p1: P1

        @usableFromInline
        let p2: P2

        @inlinable
        public init(_ p0: P0, _ p1: P1, _ p2: P2) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let o0 = try p0.parse(&input)
            let o1 = try p1.parse(&input)
            let o2 = try p2.parse(&input)
            return (o0, o1, o2)
        }
    }
}

// MARK: - Take.Four

extension Parsing.Parsers.Take {
    /// A parser that runs four parsers in sequence and collects all outputs.
    public struct Four<
        P0: Parsing.Parser, P1: Parsing.Parser, P2: Parsing.Parser, P3: Parsing.Parser
    >: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P2: Sendable, P3: Sendable,
          P0.Input == P1.Input, P1.Input == P2.Input, P2.Input == P3.Input {
        public typealias Input = P0.Input
        public typealias Output = (P0.Output, P1.Output, P2.Output, P3.Output)

        @usableFromInline let p0: P0
        @usableFromInline let p1: P1
        @usableFromInline let p2: P2
        @usableFromInline let p3: P3

        @inlinable
        public init(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let o0 = try p0.parse(&input)
            let o1 = try p1.parse(&input)
            let o2 = try p2.parse(&input)
            let o3 = try p3.parse(&input)
            return (o0, o1, o2, o3)
        }
    }
}

// MARK: - Skip.First

extension Parsing.Parsers.Skip {
    /// A parser that runs two parsers but discards the first's output.
    ///
    /// Used when the first parser has `Void` output (like a delimiter).
    public struct First<P0: Parsing.Parser, P1: Parsing.Parser>: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P0.Input == P1.Input, P0.Output == Void {
        public typealias Input = P0.Input
        public typealias Output = P1.Output

        @usableFromInline
        let p0: P0

        @usableFromInline
        let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            _ = try p0.parse(&input)
            return try p1.parse(&input)
        }
    }
}

// MARK: - Skip.Second

extension Parsing.Parsers.Skip {
    /// A parser that runs two parsers but discards the second's output.
    ///
    /// Used when the second parser has `Void` output (like a delimiter).
    public struct Second<P0: Parsing.Parser, P1: Parsing.Parser>: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P0.Input == P1.Input, P1.Output == Void {
        public typealias Input = P0.Input
        public typealias Output = P0.Output

        @usableFromInline
        let p0: P0

        @usableFromInline
        let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let o0 = try p0.parse(&input)
            _ = try p1.parse(&input)
            return o0
        }
    }
}
