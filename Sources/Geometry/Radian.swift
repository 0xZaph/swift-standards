// Radian.swift
// An angle measured in radians.

extension Geometry {
    /// An angle measured in radians.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let rightAngle = Geometry.Radian(.pi / 2)
    /// let fromDegrees = Geometry.Degree(90).radians
    /// ```
    public struct Radian: Sendable, Hashable {
        /// The value in radians
        public var value: Double

        /// Create a radian value
        @inlinable
        public init(_ value: Double) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Radian: Codable {}

// MARK: - Conversions

extension Geometry.Radian {
    /// Convert to degrees
    @inlinable
    public var degrees: Geometry.Degree {
        Geometry.Degree(value * 180.0 / .pi)
    }
}

// MARK: - Common Angles

extension Geometry.Radian {
    /// Zero angle
    public static var zero: Self { Self(0) }

    /// Create an angle as a fraction of a full turn (2π radians)
    ///
    /// - Parameter fraction: The fraction of a full turn (e.g., 0.25 for 90°, 0.5 for 180°)
    /// - Returns: The angle in radians
    ///
    /// ## Examples
    /// ```swift
    /// let quarterTurn = Geometry.Radian.turn(1/4)  // π/2 radians
    /// let halfTurn = Geometry.Radian.turn(1/2)     // π radians
    /// let fullTurn = Geometry.Radian.turn(1)       // 2π radians
    /// ```
    @inlinable
    public static func turn(_ fraction: Double) -> Self {
        Self(2 * .pi * fraction)
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.Radian: AdditiveArithmetic {
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.value + rhs.value)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.value - rhs.value)
    }
}

// MARK: - Scalar Operations

extension Geometry.Radian {
    /// Multiply by a scalar
    @inlinable
    public static func * (lhs: Self, rhs: Double) -> Self {
        Self(lhs.value * rhs)
    }

    /// Multiply scalar by radian
    @inlinable
    public static func * (lhs: Double, rhs: Self) -> Self {
        Self(lhs * rhs.value)
    }

    /// Divide by a scalar
    @inlinable
    public static func / (lhs: Self, rhs: Double) -> Self {
        Self(lhs.value / rhs)
    }

    /// Negate
    @inlinable
    public static prefix func - (value: Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Comparable

extension Geometry.Radian: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Radian: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Radian: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}
