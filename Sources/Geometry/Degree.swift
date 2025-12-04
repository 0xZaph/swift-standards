// Degree.swift
// An angle measured in degrees.

extension Geometry {
    /// An angle measured in degrees.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let rightAngle = Geometry.Degree(90)
    /// let inRadians = rightAngle.radians  // Geometry.Radian
    /// ```
    public struct Degree: Sendable, Hashable {
        /// The value in degrees
        public var value: Double

        /// Create a degree value
        @inlinable
        public init(_ value: Double) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Degree: Codable {}

// MARK: - Conversions

extension Geometry.Degree {
    /// Convert to radians
    @inlinable
    public var radians: Geometry.Radian {
        Geometry.Radian(value * .pi / 180.0)
    }
}

// MARK: - Common Angles

extension Geometry.Degree {
    /// Zero angle
    public static let zero = Self(0)

    /// Create an angle as a fraction of a full turn (360 degrees)
    ///
    /// - Parameter fraction: The fraction of a full turn (e.g., 0.25 for 90°, 0.5 for 180°)
    /// - Returns: The angle in degrees
    ///
    /// ## Examples
    /// ```swift
    /// let quarterTurn = Geometry.Degree.turn(1/4)  // 90 degrees
    /// let halfTurn = Geometry.Degree.turn(1/2)     // 180 degrees
    /// let fullTurn = Geometry.Degree.turn(1)       // 360 degrees
    /// ```
    @inlinable
    public static func turn(_ fraction: Double) -> Self {
        Self(360 * fraction)
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.Degree: AdditiveArithmetic {
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

extension Geometry.Degree {
    /// Multiply by a scalar
    @inlinable
    public static func * (lhs: Self, rhs: Double) -> Self {
        Self(lhs.value * rhs)
    }

    /// Multiply scalar by degree
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

extension Geometry.Degree: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Degree: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Degree: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}
