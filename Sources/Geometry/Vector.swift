// Vector.swift
// A fixed-size displacement vector with compile-time known dimensions.

extension Geometry {
    /// A fixed-size displacement vector with compile-time known dimensions.
    ///
    /// `Vector` represents a displacement or direction, as opposed to `Point`
    /// which represents a position. This distinction enables clearer semantics:
    /// - Points can be translated by vectors
    /// - Vectors can be added to each other
    /// - The difference of two points is a vector
    ///
    /// Uses Swift 6.2 integer generic parameters (SE-0452) for type-safe
    /// dimension checking at compile time.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let velocity: Geometry.Vector<2, Units> = .init(dx: 10, dy: 5)
    /// let velocity3D: Geometry.Vector<3, Units> = .init(dx: 1, dy: 2, dz: 3)
    /// ```
    public struct Vector<let N: Int, Unit: Geometry.Unit>: Sendable {
        /// The vector components stored inline
        public var components: InlineArray<N, Double>

        /// Create a vector from an inline array of components
        @inlinable
        public init(_ components: InlineArray<N, Double>) {
            self.components = components
        }
    }
}

// MARK: - Equatable

extension Geometry.Vector: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<N {
            if lhs.components[i] != rhs.components[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Hashable

extension Geometry.Vector: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(components[i])
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// A 2D vector
    public typealias Vector2<Unit: Geometry.Unit> = Vector<2, Unit>

    /// A 3D vector
    public typealias Vector3<Unit: Geometry.Unit> = Vector<3, Unit>

    /// A 4D vector
    public typealias Vector4<Unit: Geometry.Unit> = Vector<4, Unit>
}

// MARK: - Codable

extension Geometry.Vector: Codable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var components = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            components[i] = try container.decode(Double.self)
        }
        self.components = components
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<N {
            try container.encode(components[i])
        }
    }
}

// MARK: - Subscript

extension Geometry.Vector {
    /// Access component by index
    @inlinable
    public subscript(index: Int) -> Double {
        get { components[index] }
        set { components[index] = newValue }
    }
}

// MARK: - Zero

extension Geometry.Vector {
    /// The zero vector
    @inlinable
    public static var zero: Self {
        Self(InlineArray(repeating: 0))
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.Vector: AdditiveArithmetic {
    /// Add two vectors
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            result[i] = lhs.components[i] + rhs.components[i]
        }
        return Self(result)
    }

    /// Subtract two vectors
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            result[i] = lhs.components[i] - rhs.components[i]
        }
        return Self(result)
    }
}

// MARK: - Scalar Operations

extension Geometry.Vector {
    /// Scale vector by a scalar
    @inlinable
    public static func * (lhs: Self, rhs: Double) -> Self {
        var result = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            result[i] = lhs.components[i] * rhs
        }
        return Self(result)
    }

    /// Scale vector by a scalar
    @inlinable
    public static func * (lhs: Double, rhs: Self) -> Self {
        var result = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            result[i] = lhs * rhs.components[i]
        }
        return Self(result)
    }

    /// Divide vector by a scalar
    @inlinable
    public static func / (lhs: Self, rhs: Double) -> Self {
        var result = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            result[i] = lhs.components[i] / rhs
        }
        return Self(result)
    }

    /// Negate vector
    @inlinable
    public static prefix func - (value: Self) -> Self {
        var result = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            result[i] = -value.components[i]
        }
        return Self(result)
    }
}

// MARK: - Properties

extension Geometry.Vector {
    /// The squared length of the vector
    ///
    /// Use this when comparing magnitudes to avoid the sqrt computation.
    @inlinable
    public var lengthSquared: Double {
        var sum = 0.0
        for i in 0..<N {
            sum += components[i] * components[i]
        }
        return sum
    }

    /// The length (magnitude) of the vector
    @inlinable
    public var length: Double {
        lengthSquared.squareRoot()
    }

    /// A unit vector in the same direction
    ///
    /// Returns zero vector if this vector has zero length.
    @inlinable
    public var normalized: Self {
        let len = length
        guard len > 0 else { return .zero }
        return self / len
    }
}

// MARK: - Operations

extension Geometry.Vector {
    /// Dot product of two vectors
    @inlinable
    public func dot(_ other: Self) -> Double {
        var sum = 0.0
        for i in 0..<N {
            sum += components[i] * other.components[i]
        }
        return sum
    }
}

// MARK: - 2D Convenience

extension Geometry.Vector where N == 2 {
    /// The x component (horizontal displacement)
    @inlinable
    public var dx: Double {
        get { components[0] }
        set { components[0] = newValue }
    }

    /// The y component (vertical displacement)
    @inlinable
    public var dy: Double {
        get { components[1] }
        set { components[1] = newValue }
    }

    /// Create a 2D vector with the given components
    @inlinable
    public init(dx: Double, dy: Double) {
        self.init([dx, dy])
    }

    /// 2D cross product (returns scalar z-component)
    ///
    /// This is the signed area of the parallelogram formed by the two vectors.
    /// Positive if `other` is counter-clockwise from `self`.
    @inlinable
    public func cross(_ other: Self) -> Double {
        dx * other.dy - dy * other.dx
    }
}

// MARK: - 3D Convenience

extension Geometry.Vector where N == 3 {
    /// The x component
    @inlinable
    public var dx: Double {
        get { components[0] }
        set { components[0] = newValue }
    }

    /// The y component
    @inlinable
    public var dy: Double {
        get { components[1] }
        set { components[1] = newValue }
    }

    /// The z component
    @inlinable
    public var dz: Double {
        get { components[2] }
        set { components[2] = newValue }
    }

    /// Create a 3D vector with the given components
    @inlinable
    public init(dx: Double, dy: Double, dz: Double) {
        self.init([dx, dy, dz])
    }

    /// 3D cross product
    @inlinable
    public func cross(_ other: Self) -> Self {
        Self(
            dx: dy * other.dz - dz * other.dy,
            dy: dz * other.dx - dx * other.dz,
            dz: dx * other.dy - dy * other.dx
        )
    }
}

// MARK: - 4D Convenience

extension Geometry.Vector where N == 4 {
    /// The x component
    @inlinable
    public var dx: Double {
        get { components[0] }
        set { components[0] = newValue }
    }

    /// The y component
    @inlinable
    public var dy: Double {
        get { components[1] }
        set { components[1] = newValue }
    }

    /// The z component
    @inlinable
    public var dz: Double {
        get { components[2] }
        set { components[2] = newValue }
    }

    /// The w component
    @inlinable
    public var dw: Double {
        get { components[3] }
        set { components[3] = newValue }
    }

    /// Create a 4D vector with the given components
    @inlinable
    public init(dx: Double, dy: Double, dz: Double, dw: Double) {
        self.init([dx, dy, dz, dw])
    }
}
