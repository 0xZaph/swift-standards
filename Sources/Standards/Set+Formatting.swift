import Formatting

extension Set where Element == String {
    /// Formats this set using the specified set format.
    ///
    /// Use this method with static format properties:
    ///
    /// ```swift
    /// let result = Set(["a", "b", "c"]).formatted(.list)
    /// ```
    ///
    /// - Parameter format: The set format to use.
    /// - Returns: The formatted representation of this set.
    public func formatted(_ format: Format) -> String {
        format.format(self)
    }

    /// Formats this set using a custom format style.
    ///
    /// Use this method to format a set with a custom format style:
    ///
    /// ```swift
    /// let result = Set(["a", "b", "c"]).formatted(MyCustomStyle())
    /// ```
    ///
    /// - Parameter style: The format style to use for formatting.
    /// - Returns: The formatted representation of this set.
    public func formatted<S: Formatting>(_ style: S) -> S.FormatOutput where S.FormatInput == Set<String> {
        style.format(self)
    }

    /// Formats this set using the default set format.
    ///
    /// - Returns: A set format that can be configured.
    public func formatted() -> Format {
        Format()
    }
}

// MARK: - String Set Format

extension Set where Element == String {
    /// A format for formatting string sets.
    ///
    /// Use static properties to access predefined formats:
    ///
    /// ```swift
    /// Set(["a", "b", "c"]).formatted(.list)  // "a, b, c" (sorted)
    /// ```
    ///
    /// Chain methods to configure the format:
    ///
    /// ```swift
    /// Set(["a", "b", "c"]).formatted(.list.separator("; "))  // "a; b; c"
    /// Set(["a", "b", "c"]).formatted(.bullets.prefix("→ "))  // "→ a\n→ b\n→ c"
    /// ```
    public struct Format: Formatting {
        public let style: Style
        public let customSeparator: String?
        public let customPrefix: String?

        public init(
            style: Style = .list,
            customSeparator: String? = nil,
            customPrefix: String? = nil
        ) {
            self.style = style
            self.customSeparator = customSeparator
            self.customPrefix = customPrefix
        }
    }
}

// MARK: - Set<String>.Format.Style

extension Set<String>.Format {
    public struct Style: Sendable {
        let apply: @Sendable (Set<String>, _ customSeparator: String?, _ customPrefix: String?) -> String

        public init(apply: @escaping @Sendable (_ value: Set<String>, _ customSeparator: String?, _ customPrefix: String?) -> String) {
            self.apply = apply
        }
    }
}

// MARK: - Set<String>.Format.Style Static Properties

extension Set<String>.Format.Style {
    /// Formats the set as a comma-separated list (sorted).
    public static var list: Self {
        .init { value, customSeparator, _ in
            let separator = customSeparator ?? ", "
            return value.sorted().joined(separator: separator)
        }
    }

    /// Formats the set as a bulleted list (sorted).
    public static var bullets: Self {
        .init { value, _, customPrefix in
            let prefix = customPrefix ?? "• "
            return value
                .sorted()
                .map { prefix + $0 }
                .joined(separator: "\n")
        }
    }
}

// MARK: - Set<String>.Format Methods

extension Set<String>.Format {
    public func format(_ value: Set<String>) -> String {
        style.apply(value, customSeparator, customPrefix)
    }
}

// MARK: - Set<String>.Format Static Properties

extension Set<String>.Format {
    /// Formats the set as a comma-separated list.
    public static var list: Self {
        .init(style: .list)
    }

    /// Formats the set as a bulleted list.
    public static var bullets: Self {
        .init(style: .bullets)
    }
}

// MARK: - Set<String>.Format Chaining Methods

extension Set<String>.Format {
    /// Sets a custom separator for list formatting.
    ///
    /// ```swift
    /// Set(["a", "b", "c"]).formatted(.list.separator("; "))  // "a; b; c"
    /// Set(["a", "b", "c"]).formatted(.list.separator(" | "))  // "a | b | c"
    /// ```
    public func separator(_ separator: String) -> Self {
        .init(style: style, customSeparator: separator, customPrefix: customPrefix)
    }

    /// Sets a custom prefix for bullet formatting.
    ///
    /// ```swift
    /// Set(["a", "b", "c"]).formatted(.bullets.prefix("→ "))  // "→ a\n→ b\n→ c"
    /// Set(["a", "b", "c"]).formatted(.bullets.prefix("- "))  // "- a\n- b\n- c"
    /// ```
    public func prefix(_ prefix: String) -> Self {
        .init(style: style, customSeparator: customSeparator, customPrefix: prefix)
    }
}

// MARK: - Generic Set Extension

extension Set {
    /// Formats this set using the specified format style.
    ///
    /// Use this method to format a set with a custom format style.
    ///
    /// - Parameter style: The format style to use for formatting.
    /// - Returns: The formatted representation of this set.
    public func formatted<S: Formatting>(_ style: S) -> S.FormatOutput where S.FormatInput == Set<Element> {
        style.format(self)
    }
}
