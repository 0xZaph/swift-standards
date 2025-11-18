import Formatting

extension Dictionary where Key == String, Value == String {
    /// Formats this dictionary using the specified dictionary format.
    ///
    /// Use this method with static format properties:
    ///
    /// ```swift
    /// let result = ["key": "value"].formatted(.pairs)
    /// ```
    ///
    /// - Parameter format: The dictionary format to use.
    /// - Returns: The formatted representation of this dictionary.
    public func formatted(_ format: Format) -> String {
        format.format(self)
    }

    /// Formats this dictionary using a custom format style.
    ///
    /// Use this method to format a dictionary with a custom format style:
    ///
    /// ```swift
    /// let result = ["key": "value"].formatted(MyCustomStyle())
    /// ```
    ///
    /// - Parameter style: The format style to use for formatting.
    /// - Returns: The formatted representation of this dictionary.
    public func formatted<S: Formatting>(_ style: S) -> S.FormatOutput where S.FormatInput == [String: String] {
        style.format(self)
    }

    /// Formats this dictionary using the default dictionary format.
    ///
    /// - Returns: A dictionary format that can be configured.
    public func formatted() -> Format {
        Format()
    }
}

// MARK: - String Dictionary Format

extension Dictionary where Key == String, Value == String {
    /// A format for formatting string dictionaries.
    ///
    /// Use static properties to access predefined formats:
    ///
    /// ```swift
    /// ["key": "value"].formatted(.pairs)  // "key: value"
    /// ```
    ///
    /// Chain methods to configure the format:
    ///
    /// ```swift
    /// ["a": "1", "b": "2"].formatted(.pairs.separator(" | "))  // "a: 1 | b: 2"
    /// ["a": "1", "b": "2"].formatted(.lines)                   // "a: 1\nb: 2"
    /// ```
    public struct Format: Formatting {
        public let style: Style
        public let customSeparator: String?
        public let customPairSeparator: String?

        public init(
            style: Style = .pairs,
            customSeparator: String? = nil,
            customPairSeparator: String? = nil
        ) {
            self.style = style
            self.customSeparator = customSeparator
            self.customPairSeparator = customPairSeparator
        }
    }
}

// MARK: - Dictionary<String, String>.Format.Style

extension Dictionary<String, String>.Format {
    public struct Style: Sendable {
        let apply: @Sendable ([String: String], _ customSeparator: String?, _ customPairSeparator: String?) -> String

        public init(apply: @escaping @Sendable (_ value: [String: String], _ customSeparator: String?, _ customPairSeparator: String?) -> String) {
            self.apply = apply
        }
    }
}

// MARK: - Dictionary<String, String>.Format.Style Static Properties

extension Dictionary<String, String>.Format.Style {
    /// Formats the dictionary as comma-separated key-value pairs.
    public static var pairs: Self {
        .init { value, customSeparator, customPairSeparator in
            let separator = customSeparator ?? ", "
            let pairSeparator = customPairSeparator ?? ": "
            return value
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key)\(pairSeparator)\($0.value)" }
                .joined(separator: separator)
        }
    }

    /// Formats the dictionary as newline-separated key-value pairs.
    public static var lines: Self {
        .init { value, _, customPairSeparator in
            let pairSeparator = customPairSeparator ?? ": "
            return value
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key)\(pairSeparator)\($0.value)" }
                .joined(separator: "\n")
        }
    }
}

// MARK: - Dictionary<String, String>.Format Methods

extension Dictionary<String, String>.Format {
    public func format(_ value: [String: String]) -> String {
        style.apply(value, customSeparator, customPairSeparator)
    }
}

// MARK: - Dictionary<String, String>.Format Static Properties

extension Dictionary<String, String>.Format {
    /// Formats the dictionary as comma-separated key-value pairs.
    public static var pairs: Self {
        .init(style: .pairs)
    }

    /// Formats the dictionary as newline-separated key-value pairs.
    public static var lines: Self {
        .init(style: .lines)
    }
}

// MARK: - Dictionary<String, String>.Format Chaining Methods

extension Dictionary<String, String>.Format {
    /// Sets a custom separator between pairs.
    ///
    /// ```swift
    /// ["a": "1", "b": "2"].formatted(.pairs.separator(" | "))  // "a: 1 | b: 2"
    /// ```
    public func separator(_ separator: String) -> Self {
        .init(style: style, customSeparator: separator, customPairSeparator: customPairSeparator)
    }

    /// Sets a custom separator between key and value.
    ///
    /// ```swift
    /// ["a": "1", "b": "2"].formatted(.pairs.pairSeparator(" = "))  // "a = 1, b = 2"
    /// ```
    public func pairSeparator(_ separator: String) -> Self {
        .init(style: style, customSeparator: customSeparator, customPairSeparator: separator)
    }
}

// MARK: - Generic Dictionary Extension

extension Dictionary {
    /// Formats this dictionary using the specified format style.
    ///
    /// Use this method to format a dictionary with a custom format style.
    ///
    /// - Parameter style: The format style to use for formatting.
    /// - Returns: The formatted representation of this dictionary.
    public func formatted<S: Formatting>(_ style: S) -> S.FormatOutput where S.FormatInput == [Key: Value] {
        style.format(self)
    }
}
