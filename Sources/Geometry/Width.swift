// Width.swift
// A type-safe horizontal measurement.

extension Geometry {
    /// A horizontal measurement (width) parameterized by unit type.
    ///
    /// Use `Width` when you need type safety to distinguish horizontal
    /// measurements from vertical ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setDimensions(width: Geometry.Width<Points>, height: Geometry.Height<Points>) {
    ///     // Compiler prevents accidentally swapping width and height
    /// }
    /// ```
    public struct Width<Unit: Geometry.Unit>: Sendable, Hashable {
        /// The width value
        public let value: Unit

        /// Create a width with the given value
        public init(_ value: Unit) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Width: Codable where Unit: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Width: AdditiveArithmetic where Unit: AdditiveArithmetic {
    public static var zero: Self {
        Self(.zero)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.value + rhs.value)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.value - rhs.value)
    }
}

// MARK: - Comparable

extension Geometry.Width: Comparable where Unit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}
