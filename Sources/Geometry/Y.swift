// Y.swift
// A type-safe vertical coordinate.

extension Geometry {
    /// A vertical coordinate (y-position) parameterized by unit type.
    ///
    /// Use `Y` when you need type safety to distinguish vertical
    /// coordinates from horizontal ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setPosition(x: Geometry.X<Points>, y: Geometry.Y<Points>) {
    ///     // Compiler prevents accidentally swapping x and y
    /// }
    /// ```
    public struct Y<Unit: Geometry.Unit>: Sendable, Hashable {
        /// The y coordinate value
        public let value: Unit

        /// Create a y coordinate with the given value
        public init(_ value: Unit) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Y: Codable where Unit: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Y: AdditiveArithmetic where Unit: AdditiveArithmetic {
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

extension Geometry.Y: Comparable where Unit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Y: ExpressibleByIntegerLiteral where Unit: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Unit.IntegerLiteralType) {
        self.value = Unit(integerLiteral: value)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Y: ExpressibleByFloatLiteral where Unit: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Unit.FloatLiteralType) {
        self.value = Unit(floatLiteral: value)
    }
}
