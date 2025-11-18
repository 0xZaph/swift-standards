import Formatting

extension UInt {
    /// Formats this unsigned integer using the specified unsigned integer format.
    ///
    /// Use this method with static format properties:
    ///
    /// ```swift
    /// let result = UInt(42).formatted(.number)
    /// ```
    ///
    /// - Parameter format: The unsigned integer format to use.
    /// - Returns: The formatted representation of this unsigned integer.
    public func formatted(_ format: Format) -> String {
        format.format(self)
    }

    /// Formats this unsigned integer using a custom format style.
    ///
    /// Use this method to format an unsigned integer with a custom format style:
    ///
    /// ```swift
    /// let result = UInt(42).formatted(MyCustomStyle())
    /// ```
    ///
    /// - Parameter style: The format style to use for formatting.
    /// - Returns: The formatted representation of this unsigned integer.
    public func formatted<S: Formatting>(_ style: S) -> S.FormatOutput where S.FormatInput == UInt {
        style.format(self)
    }

    /// Formats this unsigned integer using the default unsigned integer format.
    ///
    /// - Returns: An unsigned integer format that can be configured.
    public func formatted() -> Format {
        Format()
    }
}

// MARK: - UInt Format

extension UInt {
    /// A format for formatting unsigned integers.
    ///
    /// Use static properties to access predefined formats:
    ///
    /// ```swift
    /// UInt(42).formatted(.number)  // "42"
    /// UInt(255).formatted(.hex)    // "0xff"
    /// ```
    ///
    /// Chain methods to configure the format:
    ///
    /// ```swift
    /// UInt(255).formatted(.hex.uppercase())  // "0xFF"
    /// UInt(42).formatted(.binary)            // "0b101010"
    /// ```
    public struct Format: Formatting {
        public let style: Style
        public let isUppercase: Bool

        public init(
            style: Style = .number,
            isUppercase: Bool = false
        ) {
            self.style = style
            self.isUppercase = isUppercase
        }
    }
}

// MARK: - UInt.Format.Style

extension UInt.Format {
    public struct Style: Sendable {
        let apply: @Sendable (_ value: UInt, _ isUppercase: Bool) -> String

        public init(apply: @escaping @Sendable (_ value: UInt, _ isUppercase: Bool) -> String) {
            self.apply = apply
        }
    }
}

// MARK: - UInt.Format.Style Static Properties

extension UInt.Format.Style {
    /// Formats the unsigned integer as a decimal number.
    public static var number: Self {
        .init { value, _ in "\(value)" }
    }

    /// Formats the unsigned integer as hexadecimal.
    public static var hex: Self {
        .init { value, isUppercase in
            let hexDigits = String(value, radix: 16)
            return "0x" + (isUppercase ? hexDigits.uppercased() : hexDigits)
        }
    }

    /// Formats the unsigned integer as binary.
    public static var binary: Self {
        .init { value, _ in "0b\(String(value, radix: 2))" }
    }
}

// MARK: - UInt.Format Methods

extension UInt.Format {
    public func format(_ value: UInt) -> String {
        style.apply(value, isUppercase)
    }
}

// MARK: - UInt.Format Static Properties

extension UInt.Format {
    /// Formats the unsigned integer as a decimal number.
    public static var number: Self {
        .init(style: .number)
    }

    /// Formats the unsigned integer as hexadecimal.
    public static var hex: Self {
        .init(style: .hex)
    }

    /// Formats the unsigned integer as binary.
    public static var binary: Self {
        .init(style: .binary)
    }
}

// MARK: - UInt.Format Chaining Methods

extension UInt.Format {
    /// Formats hex letters as uppercase.
    ///
    /// ```swift
    /// UInt(255).formatted(.hex.uppercase())  // "0xFF"
    /// ```
    public func uppercase() -> Self {
        .init(style: style, isUppercase: true)
    }
}
