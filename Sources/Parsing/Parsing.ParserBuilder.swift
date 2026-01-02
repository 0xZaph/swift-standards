//
//  Parsing.ParserBuilder.swift
//  swift-standards
//
//  Result builder for declarative parser composition.
//

extension Parsing {
    /// Namespace for result builders.
    public enum Build {}
}

extension Parsing.Build {
    /// A result builder for composing parsers sequentially.
    ///
    /// `Build.Sequence` enables declarative parser composition using Swift's
    /// result builder syntax. Parsers are combined sequentially, with their
    /// outputs collected into tuples.
    ///
    /// ## Sequential Composition
    ///
    /// Multiple parsers run in sequence. Outputs are combined into tuples:
    ///
    /// ```swift
    /// Parse {
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
    /// Parse {
    ///     Header()
    ///     if hasBody {
    ///         Body()
    ///     }
    /// }
    /// ```
    @resultBuilder
    public struct Sequence<Input> {
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

// MARK: - OneOf Builder

extension Parsing.Build {
    /// A result builder for alternative parsers.
    ///
    /// `Build.OneOf` combines parsers as alternatives - the first one that
    /// succeeds wins.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// OneOf {
    ///     "true".map { true }
    ///     "false".map { false }
    /// }
    /// ```
    @resultBuilder
    public struct OneOf<Input, Output> {
        /// Builds a single alternative.
        @inlinable
        public static func buildBlock<P: Parsing.Parser>(
            _ parser: P
        ) -> P where P.Input == Input, P.Output == Output {
            parser
        }

        /// Combines two alternatives.
        @inlinable
        public static func buildBlock<P0: Parsing.Parser, P1: Parsing.Parser>(
            _ p0: P0,
            _ p1: P1
        ) -> Parsing.Parsers.OneOf.Two<P0, P1>
        where P0.Input == Input, P1.Input == Input,
              P0.Output == Output, P1.Output == Output {
            Parsing.Parsers.OneOf.Two(p0, p1)
        }

        /// Combines three alternatives.
        @inlinable
        public static func buildBlock<P0: Parsing.Parser, P1: Parsing.Parser, P2: Parsing.Parser>(
            _ p0: P0,
            _ p1: P1,
            _ p2: P2
        ) -> Parsing.Parsers.OneOf.Three<P0, P1, P2>
        where P0.Input == Input, P1.Input == Input, P2.Input == Input,
              P0.Output == Output, P1.Output == Output, P2.Output == Output {
            Parsing.Parsers.OneOf.Three(p0, p1, p2)
        }

        /// Starts partial block.
        @inlinable
        public static func buildPartialBlock<P: Parsing.Parser>(
            first: P
        ) -> P where P.Input == Input, P.Output == Output {
            first
        }

        /// Accumulates alternatives.
        @inlinable
        public static func buildPartialBlock<Accumulated: Parsing.Parser, Next: Parsing.Parser>(
            accumulated: Accumulated,
            next: Next
        ) -> Parsing.Parsers.OneOf.Two<Accumulated, Next>
        where Accumulated.Input == Input, Next.Input == Input,
              Accumulated.Output == Output, Next.Output == Output {
            Parsing.Parsers.OneOf.Two(accumulated, next)
        }
    }
}
