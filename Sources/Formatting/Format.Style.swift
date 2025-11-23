//
//  Format.Style.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 23/11/2025.
//

extension Format {
    /// A type that can format values into representations.
    ///
    /// This is an alias to the `Formatting` protocol, providing a namespaced
    /// way to refer to format styles under the `Format` namespace.
    ///
    /// Both of these are equivalent:
    /// ```swift
    /// struct MyFormatter: Formatting { ... }
    /// struct MyFormatter: Format.Style { ... }
    /// ```
    ///
    /// This aligns with Foundation's `FormatStyle` pattern while maintaining
    /// backward compatibility with the `Formatting` protocol.
    public protocol Style: Sendable {
        /// The type of value to be formatted.
        associatedtype FormatInput

        /// The type of the formatted representation.
        associatedtype FormatOutput

        /// Formats the given value into the output representation.
        ///
        /// - Parameter value: The value to format.
        /// - Returns: The formatted representation of the value.
        func format(_ value: FormatInput) -> FormatOutput
    }
}


extension Format.Style {
    /// Formats the given value into the output representation.
    ///
    /// This method provides function call syntax for formatting:
    ///
    /// ```swift
    /// let formatter = UppercaseFormat()
    /// let result = formatter("hello")  // "HELLO"
    /// ```
    ///
    /// - Parameter value: The value to format.
    /// - Returns: The formatted representation of the value.
    public func callAsFunction(_ value: FormatInput) -> FormatOutput {
        format(value)
    }
}
