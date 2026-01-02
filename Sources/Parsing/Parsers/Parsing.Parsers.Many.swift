//
//  Parsing.Parsers.Many.swift
//  swift-standards
//
//  Many combinator - repeats a parser zero or more times.
//

extension Parsing.Parsers {
    /// Namespace for repetition parsers.
    public enum Many {}
}

// MARK: - Many.Separated

extension Parsing.Parsers.Many {
    /// A parser that applies another parser repeatedly with separators.
    ///
    /// `Separated` collects results into an array. It always succeeds (possibly with
    /// an empty array) unless a minimum count is specified.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // With separator
    /// let csv = Many.Separated { Field() } separator: { "," }
    /// ```
    public struct Separated<Element: Parsing.Parser, Separator: Parsing.Parser>: Parsing.Parser, Sendable
    where Element: Sendable, Separator: Sendable, Element.Input == Separator.Input {
        public typealias Input = Element.Input
        public typealias Output = [Element.Output]

        @usableFromInline
        let element: Element

        @usableFromInline
        let separator: Separator

        @usableFromInline
        let minimum: Int

        @usableFromInline
        let maximum: Int?

        /// Creates a Many parser.
        ///
        /// - Parameters:
        ///   - minimum: Minimum number of elements (default 0).
        ///   - maximum: Maximum number of elements (default unlimited).
        ///   - element: Parser for each element.
        ///   - separator: Parser for separators between elements.
        @inlinable
        public init(
            atLeast minimum: Int = 0,
            atMost maximum: Int? = nil,
            @Parsing.Build.Sequence<Input> element: () -> Element,
            @Parsing.Build.Sequence<Input> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = minimum
            self.maximum = maximum
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            var results: [Element.Output] = []

            // Parse first element
            do {
                let first = try element.parse(&input)
                results.append(first)
            } catch {
                if minimum > 0 {
                    throw error
                }
                return results
            }

            // Parse remaining elements (with separator)
            while maximum.map({ results.count < $0 }) ?? true {
                let saved = input

                // Try separator
                do {
                    _ = try separator.parse(&input)
                } catch {
                    input = saved
                    break
                }

                // Try next element
                do {
                    let next = try element.parse(&input)
                    results.append(next)
                } catch {
                    input = saved
                    break
                }
            }

            // Check minimum
            if results.count < minimum {
                throw Parsing.Error("Expected at least \(minimum) elements, got \(results.count)")
            }

            return results
        }
    }
}

// MARK: - Many.Simple

extension Parsing.Parsers.Many {
    /// A parser that applies another parser repeatedly (no separator).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Zero or more digits
    /// let digits = Many.Simple { Digit() }
    ///
    /// // One or more digits
    /// let digits1 = Many.Simple(atLeast: 1) { Digit() }
    ///
    /// // Exactly 4 digits
    /// let pin = Many.Simple(exactly: 4) { Digit() }
    /// ```
    public struct Simple<Element: Parsing.Parser>: Parsing.Parser, Sendable
    where Element: Sendable {
        public typealias Input = Element.Input
        public typealias Output = [Element.Output]

        @usableFromInline
        let element: Element

        @usableFromInline
        let minimum: Int

        @usableFromInline
        let maximum: Int?

        @inlinable
        public init(
            atLeast minimum: Int = 0,
            atMost maximum: Int? = nil,
            @Parsing.Build.Sequence<Input> element: () -> Element
        ) {
            self.element = element()
            self.minimum = minimum
            self.maximum = maximum
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Parsing.Error) -> Output {
            var results: [Element.Output] = []

            while maximum.map({ results.count < $0 }) ?? true {
                let saved = input

                do {
                    let next = try element.parse(&input)
                    results.append(next)
                } catch {
                    input = saved
                    break
                }
            }

            if results.count < minimum {
                throw Parsing.Error("Expected at least \(minimum) elements, got \(results.count)")
            }

            return results
        }
    }
}

// MARK: - Convenience Functions

extension Parsing {
    /// Parses zero or more occurrences of an element.
    @inlinable
    public static func many<Element: Parser>(
        atLeast minimum: Int = 0,
        atMost maximum: Int? = nil,
        @Build.Sequence<Element.Input> element: () -> Element
    ) -> Parsers.Many.Simple<Element> {
        Parsers.Many.Simple(atLeast: minimum, atMost: maximum, element: element)
    }

    /// Parses zero or more occurrences with a separator.
    @inlinable
    public static func many<Element: Parser, Separator: Parser>(
        atLeast minimum: Int = 0,
        atMost maximum: Int? = nil,
        @Build.Sequence<Element.Input> element: () -> Element,
        @Build.Sequence<Element.Input> separator: () -> Separator
    ) -> Parsers.Many.Separated<Element, Separator>
    where Element.Input == Separator.Input {
        Parsers.Many.Separated(atLeast: minimum, atMost: maximum, element: element, separator: separator)
    }
}
