// Length.swift
// A type-safe general linear measurement.

extension Geometry {
    /// A general linear measurement (length) parameterized by unit type.
    ///
    /// Use `Length` for measurements that aren't specifically horizontal or vertical,
    /// such as distances, radii, or line thicknesses.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func drawCircle(center: Geometry.Point<Points>, radius: Geometry.Length<Points>) {
    ///     // ...
    /// }
    /// ```
    public struct Length<Unit: Geometry.Unit>: Sendable, Hashable {
        /// The length value
        public let value: Unit

        /// Create a length with the given value
        public init(_ value: Unit) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Length: Codable where Unit: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Length: AdditiveArithmetic where Unit: AdditiveArithmetic {
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

extension Geometry.Length: Comparable where Unit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}
