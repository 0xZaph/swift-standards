// LineSegment.swift
// A line segment between two points.

extension Geometry {
    /// A line segment between two points.
    ///
    /// Useful for hit testing, intersections, and clipping operations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let segment = Geometry.LineSegment(
    ///     start: Point(x: 0, y: 0),
    ///     end: Point(x: 100, y: 100)
    /// )
    /// print(segment.length)  // 141.42...
    /// ```
    public struct LineSegment {
        /// The start point
        public var start: Point<2>

        /// The end point
        public var end: Point<2>

        /// Create a line segment between two points
        @inlinable
        public init(start: Point<2>, end: Point<2>) {
            self.start = start
            self.end = end
        }
    }
}

extension Geometry.LineSegment: Sendable where Unit: Sendable {}
extension Geometry.LineSegment: Hashable where Unit: Hashable {}
extension Geometry.LineSegment: Equatable where Unit: Equatable {}

// MARK: - Codable

extension Geometry.LineSegment: Codable where Unit: Codable {}

// MARK: - Reversed

extension Geometry.LineSegment {
    /// Return the segment with reversed direction
    @inlinable
    public var reversed: Self {
        Self(start: end, end: start)
    }
}

// MARK: - Double-based LineSegment Operations

extension Geometry.LineSegment where Unit == Double {
    /// The vector from start to end
    @inlinable
    public var vector: Geometry.Vector2 {
        Geometry.Vector2(dx: end.x - start.x, dy: end.y - start.y)
    }

    /// The squared length of the segment
    ///
    /// Use this when comparing lengths to avoid the sqrt computation.
    @inlinable
    public var lengthSquared: Double {
        vector.lengthSquared
    }

    /// The length of the segment
    @inlinable
    public var length: Double {
        vector.length
    }

    /// The midpoint of the segment
    @inlinable
    public var midpoint: Geometry.Point<2> {
        Geometry.Point(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2
        )
    }

    /// Get a point along the segment at parameter t
    ///
    /// - Parameter t: Parameter from 0 (start) to 1 (end)
    /// - Returns: The interpolated point
    @inlinable
    public func point(at t: Double) -> Geometry.Point<2> {
        let x = start.x + t * (end.x - start.x)
        let y = start.y + t * (end.y - start.y)
        return Geometry.Point(x: x, y: y)
    }
}
