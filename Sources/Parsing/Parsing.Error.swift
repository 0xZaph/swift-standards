//
//  Parsing.Error.swift
//  swift-standards
//
//  Error types for parsing failures.
//

extension Parsing {
    /// An error that occurred during parsing.
    ///
    /// `Parsing.Error` captures information about parsing failures including:
    /// - A human-readable message describing what went wrong
    /// - The context where parsing failed (optional)
    /// - Underlying errors from nested parsers
    ///
    /// ## Error Aggregation
    ///
    /// When using `OneOf` or other branching combinators, multiple parsing attempts
    /// may fail. The error aggregates all failure information for comprehensive
    /// diagnostics.
    ///
    /// ## Example
    ///
    /// ```swift
    /// throw Parsing.Error("Expected digit", at: input)
    /// throw Parsing.Error("Invalid UTF-8 sequence", underlying: utf8Error)
    /// ```
    public struct Error: Swift.Error, Sendable, Equatable {
        /// A description of what went wrong.
        public let message: String

        /// Context information about where parsing failed.
        public let context: Context?

        /// Underlying errors from nested parsers.
        public let underlying: [Error]

        /// Creates an error with a message.
        ///
        /// - Parameter message: A description of the failure.
        @inlinable
        public init(_ message: String) {
            self.message = message
            self.context = nil
            self.underlying = []
        }

        /// Creates an error with a message and context.
        ///
        /// - Parameters:
        ///   - message: A description of the failure.
        ///   - context: Information about where parsing failed.
        @inlinable
        public init(_ message: String, context: Context) {
            self.message = message
            self.context = context
            self.underlying = []
        }

        /// Creates an error with a message and remaining input.
        ///
        /// - Parameters:
        ///   - message: A description of the failure.
        ///   - at: The input at the point of failure.
        @inlinable
        public init<Input>(_ message: String, at input: Input) {
            self.message = message
            self.context = Context(remainingCount: nil, debugDescription: String(describing: input))
            self.underlying = []
        }

        /// Creates an error with a message and remaining input count.
        ///
        /// - Parameters:
        ///   - message: A description of the failure.
        ///   - at: The input at the point of failure (Collection).
        @inlinable
        public init<Input: Collection>(_ message: String, at input: Input) {
            self.message = message
            self.context = Context(remainingCount: input.count, debugDescription: nil)
            self.underlying = []
        }

        /// Creates an error wrapping underlying errors.
        ///
        /// - Parameters:
        ///   - message: A description of the failure.
        ///   - underlying: Errors from nested parsing attempts.
        @inlinable
        public init(_ message: String, underlying: [Error]) {
            self.message = message
            self.context = nil
            self.underlying = underlying
        }

        /// Creates an error with all components.
        ///
        /// - Parameters:
        ///   - message: A description of the failure.
        ///   - context: Information about where parsing failed.
        ///   - underlying: Errors from nested parsing attempts.
        @inlinable
        public init(_ message: String, context: Context?, underlying: [Error]) {
            self.message = message
            self.context = context
            self.underlying = underlying
        }
    }
}

// MARK: - Error Context

extension Parsing.Error {
    /// Context information about a parsing failure.
    public struct Context: Sendable, Equatable {
        /// The number of bytes/elements remaining when parsing failed.
        public let remainingCount: Int?

        /// A debug description of the input state.
        public let debugDescription: String?

        /// Creates context with remaining count.
        @inlinable
        public init(remainingCount: Int?, debugDescription: String?) {
            self.remainingCount = remainingCount
            self.debugDescription = debugDescription
        }
    }
}

// MARK: - CustomStringConvertible

extension Parsing.Error: CustomStringConvertible {
    public var description: String {
        var result = message

        if let context = context {
            if let count = context.remainingCount {
                result += " (at \(count) bytes remaining)"
            }
            if let debug = context.debugDescription {
                result += " [\(debug)]"
            }
        }

        if !underlying.isEmpty {
            result += "\n  Underlying errors:"
            for error in underlying {
                let indented = error.description
                    .split(separator: "\n")
                    .map { "    " + $0 }
                    .joined(separator: "\n")
                result += "\n" + indented
            }
        }

        return result
    }
}

// MARK: - Common Error Factories

extension Parsing.Error {
    /// Creates an error for unexpected end of input.
    ///
    /// - Parameter expected: What was expected but not found.
    /// - Returns: An appropriate error.
    @inlinable
    public static func unexpectedEnd(expected: String) -> Self {
        Self("Unexpected end of input: expected \(expected)")
    }

    /// Creates an error for unexpected input.
    ///
    /// - Parameters:
    ///   - got: What was found.
    ///   - expected: What was expected.
    /// - Returns: An appropriate error.
    @inlinable
    public static func unexpected<T>(_ got: T, expected: String) -> Self {
        Self("Unexpected \(got): expected \(expected)")
    }

    /// Creates an error for no matching alternative.
    ///
    /// - Parameter errors: Errors from each attempted alternative.
    /// - Returns: An error aggregating all failures.
    @inlinable
    public static func noMatch(tried errors: [Parsing.Error]) -> Self {
        Self("No matching alternative", underlying: errors)
    }
}
