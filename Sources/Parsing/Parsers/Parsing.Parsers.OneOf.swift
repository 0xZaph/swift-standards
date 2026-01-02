//
//  Parsing.Parsers.OneOf.swift
//  swift-standards
//
//  OneOf combinator - tries alternatives until one succeeds.
//

extension Parsing.Parsers {
    /// Namespace for alternative parsers.
    public enum OneOf {}
}

// MARK: - Type-Erased OneOf

extension Parsing.Parsers.OneOf {
    /// A parser that tries multiple alternatives in order.
    ///
    /// `Any` attempts each parser in sequence. The first parser that succeeds
    /// determines the result. If all parsers fail, it fails with an error
    /// aggregating all the individual failures.
    ///
    /// ## Backtracking
    ///
    /// By default, saves and restores input state between attempts.
    /// This enables clean backtracking when an alternative fails partway through.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let boolParser = OneOf {
    ///     "true".map { true }
    ///     "false".map { false }
    /// }
    /// ```
    ///
    /// Created via result builder or ``OneOf.Any([parsers])``.
    public struct `Any`<Input, Output>: Parsing.Parser, Sendable {
        @usableFromInline
        let parsers: [@Sendable (inout Input) throws(Parsing.Error) -> Output]

        /// Creates a OneOf parser from an array of parser closures.
        @inlinable
        public init(_ parsers: [@Sendable (inout Input) throws(Parsing.Error) -> Output]) {
            self.parsers = parsers
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            var errors: [Parsing.Error] = []
            let saved = input

            for parser in parsers {
                do {
                    return try parser(&input)
                } catch {
                    errors.append(error)
                    input = saved  // Restore for next attempt
                }
            }

            throw Parsing.Error.noMatch(tried: errors)
        }
    }
}

// MARK: - Two-Parser OneOf

extension Parsing.Parsers.OneOf {
    /// A parser that tries two alternatives.
    ///
    /// Type-safe variant for exactly two parsers. Used by result builders.
    public struct Two<P0: Parsing.Parser, P1: Parsing.Parser>: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P0.Input == P1.Input, P0.Output == P1.Output {
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
            let saved = input

            do {
                return try p0.parse(&input)
            } catch let error0 {
                input = saved
                do {
                    return try p1.parse(&input)
                } catch let error1 {
                    throw Parsing.Error.noMatch(tried: [error0, error1])
                }
            }
        }
    }
}

// MARK: - Three-Parser OneOf

extension Parsing.Parsers.OneOf {
    /// A parser that tries three alternatives.
    public struct Three<P0: Parsing.Parser, P1: Parsing.Parser, P2: Parsing.Parser>: Parsing.Parser, Sendable
    where P0: Sendable, P1: Sendable, P2: Sendable,
          P0.Input == P1.Input, P1.Input == P2.Input,
          P0.Output == P1.Output, P1.Output == P2.Output {
        public typealias Input = P0.Input
        public typealias Output = P0.Output

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
            let saved = input
            var errors: [Parsing.Error] = []

            do { return try p0.parse(&input) }
            catch { errors.append(error); input = saved }

            do { return try p1.parse(&input) }
            catch { errors.append(error); input = saved }

            do { return try p2.parse(&input) }
            catch { errors.append(error) }

            throw Parsing.Error.noMatch(tried: errors)
        }
    }
}
