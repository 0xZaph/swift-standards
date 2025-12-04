// Height.swift
// A type-safe vertical measurement.

extension Geometry {
    /// A vertical measurement (height) parameterized by unit type.
    ///
    /// Use `Height` when you need type safety to distinguish vertical
    /// measurements from horizontal ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setDimensions(width: Geometry.Width<Points>, height: Geometry.Height<Points>) {
    ///     // Compiler prevents accidentally swapping width and height
    /// }
    /// ```
    public struct Height {
        /// The height value
        public let value: Unit

        /// Create a height with the given value
        public init(_ value: Unit) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Height: Codable where Unit: Codable {}
extension Geometry.Height: Sendable where Unit: Sendable {}
extension Geometry.Height: Equatable where Unit: Equatable {}
extension Geometry.Height: Hashable where Unit: Hashable {}

// MARK: - AdditiveArithmetic

extension Geometry.Height: AdditiveArithmetic where Unit: AdditiveArithmetic {
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

extension Geometry.Height: Comparable where Unit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}
