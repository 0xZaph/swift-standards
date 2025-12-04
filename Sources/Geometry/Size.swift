// Size.swift
// A fixed-size dimensions with compile-time known number of dimensions.

extension Geometry {
    /// A fixed-size dimensions with compile-time known number of dimensions.
    ///
    /// This generic structure represents N-dimensional sizes (width, height, depth, etc.)
    /// and can be specialized for different coordinate systems.
    ///
    /// Uses Swift 6.2 integer generic parameters (SE-0452) for type-safe
    /// dimension checking at compile time.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let pageSize: Geometry.Size<2> = .init(width: 612, height: 792)
    /// let boxSize: Geometry.Size<3, Double> = .init(width: 10, height: 20, depth: 30)
    /// ```
    public struct Size<let N: Int> {
        /// The size dimensions stored inline
        public var dimensions: InlineArray<N, Unit>

        /// Create a size from an inline array of dimensions
        @inlinable
        public init(_ dimensions: InlineArray<N, Unit>) {
            self.dimensions = dimensions
        }
    }
}

extension Geometry.Size: Sendable where Unit: Sendable {}

// MARK: - Equatable

extension Geometry.Size: Equatable where Unit: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<N {
            if lhs.dimensions[i] != rhs.dimensions[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Hashable

extension Geometry.Size: Hashable where Unit: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(dimensions[i])
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// A 2D size
    public typealias Size2 = Size<2>

    /// A 3D size
    public typealias Size3 = Size<3>
}

// MARK: - Codable

extension Geometry.Size: Codable where Unit: Codable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var dimensions = InlineArray<N, Unit>(repeating: try container.decode(Unit.self))
        for i in 1..<N {
            dimensions[i] = try container.decode(Unit.self)
        }
        self.dimensions = dimensions
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<N {
            try container.encode(dimensions[i])
        }
    }
}

// MARK: - Subscript

extension Geometry.Size {
    /// Access dimension by index
    @inlinable
    public subscript(index: Int) -> Unit {
        get { dimensions[index] }
        set { dimensions[index] = newValue }
    }
}

// MARK: - Zero

extension Geometry.Size where Unit: AdditiveArithmetic {
    /// Zero size (all dimensions zero)
    @inlinable
    public static var zero: Self {
        Self(InlineArray(repeating: .zero))
    }
}

// MARK: - 2D Convenience

extension Geometry.Size where N == 2 {
    /// Width (first dimension)
    @inlinable
    public var width: Unit {
        get { dimensions[0] }
        set { dimensions[0] = newValue }
    }

    /// Height (second dimension)
    @inlinable
    public var height: Unit {
        get { dimensions[1] }
        set { dimensions[1] = newValue }
    }

    /// Create a 2D size with the given dimensions
    @inlinable
    public init(width: Unit, height: Unit) {
        self.init([width, height])
    }
}

// MARK: - 3D Convenience

extension Geometry.Size where N == 3 {
    /// Width (first dimension)
    @inlinable
    public var width: Unit {
        get { dimensions[0] }
        set { dimensions[0] = newValue }
    }

    /// Height (second dimension)
    @inlinable
    public var height: Unit {
        get { dimensions[1] }
        set { dimensions[1] = newValue }
    }

    /// Depth (third dimension)
    @inlinable
    public var depth: Unit {
        get { dimensions[2] }
        set { dimensions[2] = newValue }
    }

    /// Create a 3D size with the given dimensions
    @inlinable
    public init(width: Unit, height: Unit, depth: Unit) {
        self.init([width, height, depth])
    }
}
