// EdgeInsets.swift
// Insets from the edges of a rectangle.

extension Geometry {
    /// Insets from the edges of a rectangle, parameterized by unit type.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let margins: Geometry.EdgeInsets<Double> = .init(
    ///     top: 72, leading: 72, bottom: 72, trailing: 72
    /// )
    /// ```
    public struct EdgeInsets<Unit: Geometry.Unit>: Sendable, Hashable {
        /// Top inset
        public var top: Unit

        /// Leading (left in LTR) inset
        public var leading: Unit

        /// Bottom inset
        public var bottom: Unit

        /// Trailing (right in LTR) inset
        public var trailing: Unit

        /// Create edge insets
        ///
        /// - Parameters:
        ///   - top: Top inset
        ///   - leading: Leading inset
        ///   - bottom: Bottom inset
        ///   - trailing: Trailing inset
        public init(top: Unit, leading: Unit, bottom: Unit, trailing: Unit) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
        }
    }
}

// MARK: - Codable

extension Geometry.EdgeInsets: Codable where Unit: Codable {}

// MARK: - Convenience Initializers

extension Geometry.EdgeInsets {
    /// Create edge insets with the same value on all edges
    ///
    /// - Parameter all: The inset value for all edges
    public init(all: Unit) {
        self.top = all
        self.leading = all
        self.bottom = all
        self.trailing = all
    }

    /// Create edge insets with horizontal and vertical values
    ///
    /// - Parameters:
    ///   - horizontal: Inset for leading and trailing edges
    ///   - vertical: Inset for top and bottom edges
    public init(horizontal: Unit, vertical: Unit) {
        self.top = vertical
        self.leading = horizontal
        self.bottom = vertical
        self.trailing = horizontal
    }
}

// MARK: - Zero

extension Geometry.EdgeInsets where Unit: AdditiveArithmetic {
    /// Zero insets
    public static var zero: Self {
        Self(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
    }
}
