//
//  Parsing.Parsers.Always.swift
//  swift-standards
//
//  Always and Optional parsers.
//

extension Parsing.Parsers {
    /// A parser that always succeeds without consuming input.
    ///
    /// `Always` is useful as an identity element and for injecting values.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Always succeed with a default value
    /// let withDefault = parser.orElse(Always(defaultValue))
    /// ```
    public struct Always<Input, Output>: Parsing.Parser, Sendable where Output: Sendable {
        public let output: Output

        /// Creates an always-succeeding parser.
        ///
        /// - Parameter output: The value to always return.
        @inlinable
        public init(_ output: Output) {
            self.output = output
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            output
        }
    }
}

// MARK: - Never

extension Parsing.Parsers {
    /// A parser that always fails.
    ///
    /// `Fail` is useful as a fallback in error handling scenarios.
    public struct Fail<Input, Output>: Parsing.Parser, Sendable {
        @usableFromInline
        let error: Parsing.Error

        /// Creates a failing parser.
        ///
        /// - Parameter message: The error message.
        @inlinable
        public init(_ message: String) {
            self.error = Parsing.Error(message)
        }

        /// Creates a failing parser with a specific error.
        @inlinable
        public init(error: Parsing.Error) {
            self.error = error
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            throw error
        }
    }
}

// MARK: - Optional Parser

extension Parsing.Parsers {
    /// A parser that optionally parses if its wrapped parser is present.
    ///
    /// Used by `Build.Sequence` for `if` statements without `else`.
    public struct Optional<Wrapped: Parsing.Parser>: Parsing.Parser, Sendable
    where Wrapped: Sendable {
        public typealias Input = Wrapped.Input
        public typealias Output = Wrapped.Output?

        @usableFromInline
        let wrapped: Wrapped?

        @inlinable
        public init(_ wrapped: Wrapped?) {
            self.wrapped = wrapped
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            guard let wrapped = wrapped else {
                return nil
            }
            return try wrapped.parse(&input)
        }
    }
}

// MARK: - Conditional Parser

extension Parsing.Parsers {
    /// A parser that represents a conditional branch.
    ///
    /// Used by `ParserBuilder` for `if-else` statements.
    public enum Conditional<First: Parsing.Parser, Second: Parsing.Parser>: Parsing.Parser, Sendable
    where First: Sendable, Second: Sendable,
          First.Input == Second.Input, First.Output == Second.Output {
        public typealias Input = First.Input
        public typealias Output = First.Output

        case first(First)
        case second(Second)

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            switch self {
            case .first(let parser):
                return try parser.parse(&input)
            case .second(let parser):
                return try parser.parse(&input)
            }
        }
    }
}

// MARK: - Optionally Parser

extension Parsing.Parsers {
    /// A parser that tries to parse but succeeds with nil on failure.
    ///
    /// Unlike `Optional` (compile-time optional), this is runtime optional.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let optionalSign = Optionally { Sign() }
    /// ```
    public struct Optionally<Wrapped: Parsing.Parser>: Parsing.Parser, Sendable
    where Wrapped: Sendable {
        public typealias Input = Wrapped.Input
        public typealias Output = Wrapped.Output?

        @usableFromInline
        let wrapped: Wrapped

        @inlinable
        public init(@Parsing.Parsers.Take.Builder<Input> _ wrapped: () -> Wrapped) {
            self.wrapped = wrapped()
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            let saved = input
            do {
                return try wrapped.parse(&input)
            } catch {
                input = saved
                return nil
            }
        }
    }
}
