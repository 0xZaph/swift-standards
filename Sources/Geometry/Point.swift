// Point.swift
// A fixed-size coordinate with compile-time known dimensions.

extension Geometry {
    /// A fixed-size coordinate/position with compile-time known dimensions.
    ///
    /// `Point` represents a position in N-dimensional space, as opposed to `Vector`
    /// which represents a displacement. This distinction enables clearer semantics:
    /// - Points can be translated by vectors
    /// - The difference of two points is a vector
    ///
    /// Uses Swift 6.2 integer generic parameters (SE-0452) for type-safe
    /// dimension checking at compile time.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let origin: Geometry.Point<2, Double> = .zero
    /// let position = Geometry.Point(x: 72.0, y: 144.0)
    /// let position3D = Geometry.Point(x: 1.0, y: 2.0, z: 3.0)
    /// ```
    public struct Point<let N: Int, Unit: Geometry.Unit>: Sendable {
        /// The point coordinates stored inline
        public var coordinates: InlineArray<N, Unit>

        /// Create a point from an inline array of coordinates
        @inlinable
        public init(_ coordinates: InlineArray<N, Unit>) {
            self.coordinates = coordinates
        }
    }
}

// MARK: - Equatable

extension Geometry.Point: Equatable where Unit: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<N {
            if lhs.coordinates[i] != rhs.coordinates[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Hashable

extension Geometry.Point: Hashable where Unit: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(coordinates[i])
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// A 2D point
    public typealias Point2<Unit: Geometry.Unit> = Point<2, Unit>

    /// A 3D point
    public typealias Point3<Unit: Geometry.Unit> = Point<3, Unit>

    /// A 4D point
    public typealias Point4<Unit: Geometry.Unit> = Point<4, Unit>
}

// MARK: - Codable

extension Geometry.Point: Codable where Unit: Codable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var coordinates = InlineArray<N, Unit>(repeating: try container.decode(Unit.self))
        for i in 1..<N {
            coordinates[i] = try container.decode(Unit.self)
        }
        self.coordinates = coordinates
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<N {
            try container.encode(coordinates[i])
        }
    }
}

// MARK: - Subscript

extension Geometry.Point {
    /// Access coordinate by index
    @inlinable
    public subscript(index: Int) -> Unit {
        get { coordinates[index] }
        set { coordinates[index] = newValue }
    }
}

// MARK: - Zero

extension Geometry.Point where Unit: AdditiveArithmetic {
    /// The origin point (all coordinates zero)
    @inlinable
    public static var zero: Self {
        Self(InlineArray(repeating: .zero))
    }
}

// MARK: - Arithmetic

extension Geometry.Point where Unit: AdditiveArithmetic {
    /// Add two points
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs.coordinates
        for i in 0..<N {
            result[i] = lhs.coordinates[i] + rhs.coordinates[i]
        }
        return Self(result)
    }

    /// Subtract two points
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = lhs.coordinates
        for i in 0..<N {
            result[i] = lhs.coordinates[i] - rhs.coordinates[i]
        }
        return Self(result)
    }
}

// MARK: - 2D Convenience

extension Geometry.Point where N == 2 {
    /// The x coordinate
    @inlinable
    public var x: Unit {
        get { coordinates[0] }
        set { coordinates[0] = newValue }
    }

    /// The y coordinate
    @inlinable
    public var y: Unit {
        get { coordinates[1] }
        set { coordinates[1] = newValue }
    }

    /// Create a 2D point with the given coordinates
    @inlinable
    public init(x: Unit, y: Unit) {
        self.init([x, y])
    }
}

// MARK: - 3D Convenience

extension Geometry.Point where N == 3 {
    /// The x coordinate
    @inlinable
    public var x: Unit {
        get { coordinates[0] }
        set { coordinates[0] = newValue }
    }

    /// The y coordinate
    @inlinable
    public var y: Unit {
        get { coordinates[1] }
        set { coordinates[1] = newValue }
    }

    /// The z coordinate
    @inlinable
    public var z: Unit {
        get { coordinates[2] }
        set { coordinates[2] = newValue }
    }

    /// Create a 3D point with the given coordinates
    @inlinable
    public init(x: Unit, y: Unit, z: Unit) {
        self.init([x, y, z])
    }
}

// MARK: - 4D Convenience

extension Geometry.Point where N == 4 {
    /// The x coordinate
    @inlinable
    public var x: Unit {
        get { coordinates[0] }
        set { coordinates[0] = newValue }
    }

    /// The y coordinate
    @inlinable
    public var y: Unit {
        get { coordinates[1] }
        set { coordinates[1] = newValue }
    }

    /// The z coordinate
    @inlinable
    public var z: Unit {
        get { coordinates[2] }
        set { coordinates[2] = newValue }
    }

    /// The w coordinate
    @inlinable
    public var w: Unit {
        get { coordinates[3] }
        set { coordinates[3] = newValue }
    }

    /// Create a 4D point with the given coordinates
    @inlinable
    public init(x: Unit, y: Unit, z: Unit, w: Unit) {
        self.init([x, y, z, w])
    }
}

// MARK: - Double-based 2D Point Operations

extension Geometry.Point where N == 2, Unit == Double {
    /// Translate point by delta values
    @inlinable
    public func translated(dx: Double, dy: Double) -> Self {
        Self(x: x + dx, y: y + dy)
    }

    /// Translate point by a vector
    @inlinable
    public func translated(by vector: Geometry.Vector<2, Unit>) -> Self {
        Self(x: x + vector.dx, y: y + vector.dy)
    }

    /// The squared distance to another point
    @inlinable
    public func distanceSquared(to other: Self) -> Double {
        let dx = other.x - x
        let dy = other.y - y
        return dx * dx + dy * dy
    }

    /// The distance to another point
    @inlinable
    public func distance(to other: Self) -> Double {
        distanceSquared(to: other).squareRoot()
    }

    /// The vector from this point to another
    @inlinable
    public func vector(to other: Self) -> Geometry.Vector<2, Unit> {
        Geometry.Vector(dx: other.x - x, dy: other.y - y)
    }
}

// MARK: - Point + Vector Operations (2D Double)

extension Geometry.Point where N == 2, Unit == Double {
    /// Add a vector to a point
    @inlinable
    public static func + (lhs: Self, rhs: Geometry.Vector<2, Unit>) -> Self {
        Self(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }

    /// Subtract a vector from a point
    @inlinable
    public static func - (lhs: Self, rhs: Geometry.Vector<2, Unit>) -> Self {
        Self(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
    }
}

// MARK: - Double-based 3D Point Operations

extension Geometry.Point where N == 3, Unit == Double {
    /// Translate point by delta values
    @inlinable
    public func translated(dx: Double, dy: Double, dz: Double) -> Self {
        Self(x: x + dx, y: y + dy, z: z + dz)
    }

    /// Translate point by a vector
    @inlinable
    public func translated(by vector: Geometry.Vector<3, Unit>) -> Self {
        Self(x: x + vector.dx, y: y + vector.dy, z: z + vector.dz)
    }

    /// The squared distance to another point
    @inlinable
    public func distanceSquared(to other: Self) -> Double {
        let dx = other.x - x
        let dy = other.y - y
        let dz = other.z - z
        return dx * dx + dy * dy + dz * dz
    }

    /// The distance to another point
    @inlinable
    public func distance(to other: Self) -> Double {
        distanceSquared(to: other).squareRoot()
    }

    /// The vector from this point to another
    @inlinable
    public func vector(to other: Self) -> Geometry.Vector<3, Unit> {
        Geometry.Vector(dx: other.x - x, dy: other.y - y, dz: other.z - z)
    }
}

// MARK: - Point + Vector Operations (3D Double)

extension Geometry.Point where N == 3, Unit == Double {
    /// Add a vector to a point
    @inlinable
    public static func + (lhs: Self, rhs: Geometry.Vector<3, Unit>) -> Self {
        Self(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy, z: lhs.z + rhs.dz)
    }

    /// Subtract a vector from a point
    @inlinable
    public static func - (lhs: Self, rhs: Geometry.Vector<3, Unit>) -> Self {
        Self(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy, z: lhs.z - rhs.dz)
    }
}
