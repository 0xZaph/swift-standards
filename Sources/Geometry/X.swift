// X.swift
// A type-safe horizontal coordinate.

extension Geometry {
    /// A horizontal coordinate (x-position) parameterized by unit type.
    ///
    /// Use `X` when you need type safety to distinguish horizontal
    /// coordinates from vertical ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setPosition(x: Geometry.X<Points>, y: Geometry.Y<Points>) {
    ///     // Compiler prevents accidentally swapping x and y
    /// }
    /// ```
    public struct X<Unit: Geometry.Unit>: Sendable, Hashable {
        /// The x coordinate value
        public let value: Unit

        /// Create an x coordinate with the given value
        public init(_ value: Unit) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.X: Codable where Unit: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.X: AdditiveArithmetic where Unit: AdditiveArithmetic {
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

extension Geometry.X: Comparable where Unit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.X: ExpressibleByIntegerLiteral where Unit: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Unit.IntegerLiteralType) {
        self.value = Unit(integerLiteral: value)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.X: ExpressibleByFloatLiteral where Unit: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Unit.FloatLiteralType) {
        self.value = Unit(floatLiteral: value)
    }
}
