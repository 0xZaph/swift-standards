// Dimension.swift
// Type-safe dimensional measurements.

extension Geometry {
    /// A generic linear measurement parameterized by unit type.
    ///
    /// This is the base type for specific dimensional types like `Width`, `Height`, and `Length`.
    public struct Dimension<Unit: Geometry.Unit>: Sendable, Hashable {
        /// The measurement value
        public let value: Unit

        /// Create a dimension with the given value
        public init(_ value: Unit) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Dimension: Codable where Unit: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Dimension: AdditiveArithmetic where Unit: AdditiveArithmetic {
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

extension Geometry.Dimension: Comparable where Unit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}
