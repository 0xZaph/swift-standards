// Scalar.swift
// A generic scalar value parameterized by unit type.

extension Geometry {
    /// A generic scalar value parameterized by unit type.
    ///
    /// `Scalar` wraps a `Double` value with a phantom unit type parameter,
    /// providing type safety for measurements in different coordinate systems.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Points: Geometry.Unit {}
    /// struct Pixels: Geometry.Unit {}
    ///
    /// let pointValue: Geometry.Scalar<Points> = 72.0
    /// let pixelValue: Geometry.Scalar<Pixels> = 96.0
    ///
    /// // Compile error: cannot mix units
    /// // let sum = pointValue + pixelValue
    /// ```
    public struct Scalar: Sendable, Hashable {
        /// The underlying value
        public var value: Double

        /// Create a scalar with the given value
        @inlinable
        public init(_ value: Double) {
            self.value = value
        }
    }
}

// MARK: - Codable

extension Geometry.Scalar: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Scalar: AdditiveArithmetic {
    @inlinable
    public static var zero: Self { Self(0) }

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.value + rhs.value)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.value - rhs.value)
    }
}

// MARK: - Numeric Operations

extension Geometry.Scalar {
    /// Multiply by a scalar
    @inlinable
    public static func * (lhs: Self, rhs: Double) -> Self {
        Self(lhs.value * rhs)
    }

    /// Multiply scalar by value
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

extension Geometry.Scalar: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Scalar: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Scalar: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}
