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

// MARK: - Take.Two

extension Parsing.Parsers.Take {
    /// A parser that runs two parsers in sequence and collects both outputs.
    ///
    /// The outputs are combined into a tuple `(P0.Output, P1.Output)`.
    /// Created by `Build.Sequence` when combining two non-Void parsers.
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
