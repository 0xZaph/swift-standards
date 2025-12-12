// Line.swift
// An infinite line and its bounded segment in 2D space.

public import Affine
public import Algebra
public import Algebra_Linear

extension Geometry {
    /// An infinite line in 2D space.
    ///
    /// A line extends infinitely in both directions and can be defined by:
    /// - A point and a direction vector
    /// - Two distinct points
    ///
    /// For a bounded portion of a line, see `Line.Segment`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Line through origin with direction (1, 1)
    /// let diagonal = Geometry<Double, Void>.Line(
    ///     point: .init(x: 0, y: 0),
    ///     direction: .init(dx: 1, dy: 1)
    /// )
    ///
    /// // Line through two points
    /// let line = Geometry<Double, Void>.Line(
    ///     from: .init(x: 0, y: 0),
    ///     to: .init(x: 10, y: 10)
    /// )
    /// ```
    public struct Line {
        /// A point on the line
        public var point: Point<2>

        /// The direction vector of the line (not necessarily normalized)
        public var direction: Vector<2>

        /// Create a line from a point and direction vector
        @inlinable
        public init(point: consuming Point<2>, direction: consuming Vector<2>) {
            self.point = point
            self.direction = direction
        }
    }
}

extension Geometry.Line: Sendable where Scalar: Sendable {}
extension Geometry.Line: Equatable where Scalar: Equatable {}
extension Geometry.Line: Hashable where Scalar: Hashable {}

// MARK: - Codable
#if Codable
    extension Geometry.Line: Codable where Scalar: Codable {}
#endif
// MARK: - Factory Methods (AdditiveArithmetic)

extension Geometry.Line where Scalar: AdditiveArithmetic {
    /// Create a line through two points
    ///
    /// - Parameters:
    ///   - from: First point on the line
    ///   - to: Second point on the line
    @inlinable
    public init(from: Geometry.Point<2>, to: Geometry.Point<2>) {
        self.point = from
        self.direction = Geometry.Vector(dx: to.x - from.x, dy: to.y - from.y)
    }
}

// MARK: - FloatingPoint Operations

extension Geometry.Line where Scalar: FloatingPoint {
    /// A normalized direction vector (unit length)
    @inlinable
    public var normalizedDirection: Geometry.Vector<2> {
        direction.normalized
    }

    /// Get a point on the line at parameter t
    ///
    /// - Parameter t: The parameter (0 = base point, 1 = base point + direction)
    /// - Returns: The point at parameter t
    @inlinable
    public func point(at t: Scalar) -> Geometry.Point<2> {
        Geometry.Point(
            x: point.x + t * direction.dx,
            y: point.y + t * direction.dy
        )
    }

    /// The perpendicular distance from a point to this line.
    ///
    /// - Returns: The perpendicular distance, or `nil` if the line has zero-length direction vector.
    @inlinable
    public func distance(to other: Geometry.Point<2>) -> Geometry.Distance? {
        Geometry.distance(from: self, to: other)
    }

    /// Find the intersection point with another line.
    ///
    /// - Parameter other: Another line to intersect with
    /// - Returns: The intersection point, or `nil` if lines are parallel or coincident
    @inlinable
    public func intersection(with other: Self) -> Geometry.Point<2>? {
        Geometry.intersection(self, other)
    }

    /// Project a point onto this line.
    ///
    /// - Parameter point: The point to project
    /// - Returns: The closest point on the line, or `nil` if line has zero-length direction
    @inlinable
    public func projection(of other: Geometry.Point<2>) -> Geometry.Point<2>? {
        Geometry.projection(of: other, onto: self)
    }

    /// Reflect a point across this line.
    ///
    /// - Parameter point: The point to reflect
    /// - Returns: The reflected point, or `nil` if line has zero-length direction
    @inlinable
    public func reflection(of other: Geometry.Point<2>) -> Geometry.Point<2>? {
        guard let projected = projection(of: other) else { return nil }

        // Reflection = 2 * projection - original point
        return Geometry.Point(
            x: Geometry.X(2 * projected.x.value - other.x.value),
            y: Geometry.Y(2 * projected.y.value - other.y.value)
        )
    }

    /// Find intersection points with an N-gon.
    ///
    /// - Parameter ngon: The polygon to intersect with
    /// - Returns: Array of intersection points where the line crosses polygon edges
    @inlinable
    public func intersections<let N: Int>(with ngon: Geometry.Ngon<N>) -> [Geometry.Point<2>]
    where Scalar: FloatingPoint {
        var result: [Geometry.Point<2>] = []
        let edges = ngon.edges
        for i in 0..<N {
            // Intersect this line with the segment's line, then check if on segment
            let seg = edges[i]
            let segLine = seg.line
            guard let pt = intersection(with: segLine) else { continue }

            // Check if pt is within segment bounds (parameter t in [0, 1])
            let lenSq = seg.vector.dx * seg.vector.dx + seg.vector.dy * seg.vector.dy
            guard lenSq > .ulpOfOne else { continue }
            let v = Geometry.Vector(dx: pt.x - seg.start.x, dy: pt.y - seg.start.y)
            let t = (seg.vector.dx * v.dx + seg.vector.dy * v.dy) / lenSq
            if t >= 0 && t <= 1 {
                result.append(pt)
            }
        }
        return result
    }
}

// MARK: - Line.Segment

extension Geometry.Line {
    /// A bounded segment of a line between two endpoints.
    ///
    /// A segment is the finite portion of a line between two points.
    /// Unlike a line which extends infinitely, a segment has definite
    /// start and end points.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let segment = Geometry<Double, Void>.Line.Segment(
    ///     start: .init(x: 0, y: 0),
    ///     end: .init(x: 100, y: 100)
    /// )
    /// print(segment.length)  // 141.42...
    /// ```
    public struct Segment {
        /// The start point
        public var start: Geometry.Point<2>

        /// The end point
        public var end: Geometry.Point<2>

        /// Create a line segment between two points
        @inlinable
        public init(start: consuming Geometry.Point<2>, end: consuming Geometry.Point<2>) {
            self.start = start
            self.end = end
        }
    }
}

extension Geometry.Line.Segment: Sendable where Scalar: Sendable {}
extension Geometry.Line.Segment: Equatable where Scalar: Equatable {}
extension Geometry.Line.Segment: Hashable where Scalar: Hashable {}

// MARK: - Segment Codable
#if Codable
    extension Geometry.Line.Segment: Codable where Scalar: Codable {}
#endif
// MARK: - Segment Reversed

extension Geometry.Line.Segment {
    /// Return the segment with reversed direction
    @inlinable
    public var reversed: Self {
        Self(start: end, end: start)
    }
}

// MARK: - Segment Vector (AdditiveArithmetic)

extension Geometry.Line.Segment where Scalar: AdditiveArithmetic {
    /// The vector from start to end
    @inlinable
    public var vector: Geometry.Vector<2> {
        Geometry.Vector(dx: end.x - start.x, dy: end.y - start.y)
    }

    /// The infinite line containing this segment
    @inlinable
    public var line: Geometry.Line {
        Geometry.Line(point: start, direction: vector)
    }
}

// MARK: - Segment FloatingPoint Operations

extension Geometry.Line.Segment where Scalar: FloatingPoint {
    /// The squared length of the segment
    ///
    /// Use this when comparing lengths to avoid the sqrt computation.
    @inlinable
    public var lengthSquared: Scalar {
        vector.lengthSquared
    }

    /// The length of the segment
    @inlinable
    public var length: Geometry.Length {
        Geometry.Length(vector.length)
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
    public func point(at t: Scalar) -> Geometry.Point<2> {
        let x = start.x + t * (end.x - start.x)
        let y = start.y + t * (end.y - start.y)
        return Geometry.Point(x: x, y: y)
    }

    /// Find the intersection point with another line segment.
    ///
    /// Uses parametric line intersection with bounds checking.
    ///
    /// - Parameter other: Another segment to intersect with
    /// - Returns: The intersection point if segments intersect, `nil` otherwise
    @inlinable
    public func intersection(with other: Self) -> Geometry.Point<2>? {
        Geometry.intersection(self, other)
    }

    /// Check if this segment intersects with another segment.
    ///
    /// - Parameter other: Another segment to check
    /// - Returns: `true` if segments intersect
    @inlinable
    public func intersects(with other: Self) -> Bool {
        intersection(with: other) != nil
    }

    /// The perpendicular distance from a point to this segment.
    ///
    /// Returns the distance to the closest point on the segment (including endpoints).
    ///
    /// - Parameter point: The point to measure from
    /// - Returns: The distance to the closest point on the segment
    @inlinable
    public func distance(to other: Geometry.Point<2>) -> Geometry.Distance {
        Geometry.distance(from: self, to: other)
    }

    /// Find intersection points with an N-gon.
    ///
    /// - Parameter ngon: The polygon to intersect with
    /// - Returns: Array of intersection points where the segment crosses polygon edges
    @inlinable
    public func intersections<let N: Int>(with ngon: Geometry.Ngon<N>) -> [Geometry.Point<2>]
    where Scalar: AdditiveArithmetic {
        var result: [Geometry.Point<2>] = []
        let edges = ngon.edges
        for i in 0..<N {
            if let point = intersection(with: edges[i]) {
                result.append(point)
            }
        }
        return result
    }
}

// MARK: - Backward Compatibility Typealias

extension Geometry {
    /// A line segment between two points.
    ///
    /// This is a typealias for `Line.Segment` for backward compatibility.
    /// Prefer using `Geometry.Line.Segment` for new code.
    public typealias LineSegment = Line.Segment
}

// MARK: - Functorial Map (Line)

extension Geometry.Line {
    /// Create a line by transforming the coordinates of another line
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U, Space>.Line,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            point: try Geometry.Point<2>(other.point, transform),
            direction: try Geometry.Vector<2>(other.direction, transform)
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result, Space>.Line {
        Geometry<Result, Space>.Line(
            point: try point.map(transform),
            direction: try direction.map(transform)
        )
    }
}

// MARK: - Line Static Implementations

extension Geometry where Scalar: FloatingPoint {
    /// Calculate the perpendicular distance from a point to a line.
    @inlinable
    public static func distance(from line: Line, to point: Point<2>) -> Distance? {
        let len = line.direction.length
        guard len != 0 else { return nil }
        let v = Vector(dx: point.x - line.point.x, dy: point.y - line.point.y)
        let cross = line.direction.dx * v.dy - line.direction.dy * v.dx
        return Distance(abs(cross) / len)
    }

    /// Find the intersection point between two lines.
    @inlinable
    public static func intersection(_ line1: Line, _ line2: Line) -> Point<2>? {
        // Cross product of direction vectors
        let cross = line1.direction.dx * line2.direction.dy - line1.direction.dy * line2.direction.dx

        // If cross product is near zero, lines are parallel
        guard abs(cross) > .ulpOfOne else { return nil }

        // Vector from line1's point to line2's point
        let dp = Vector(
            dx: line2.point.x - line1.point.x,
            dy: line2.point.y - line1.point.y
        )

        // Parameter t for line1
        let t = (dp.dx * line2.direction.dy - dp.dy * line2.direction.dx) / cross

        return line1.point(at: t)
    }

    /// Project a point onto a line.
    @inlinable
    public static func projection(of point: Point<2>, onto line: Line) -> Point<2>? {
        let lenSq = line.direction.dx * line.direction.dx + line.direction.dy * line.direction.dy
        guard lenSq != 0 else { return nil }

        let v = Vector(dx: point.x - line.point.x, dy: point.y - line.point.y)
        let dot = line.direction.dx * v.dx + line.direction.dy * v.dy
        let t = dot / lenSq

        return line.point(at: t)
    }
}

// MARK: - Line.Segment Static Implementations

extension Geometry where Scalar: FloatingPoint {
    /// Find the intersection point between two line segments.
    @inlinable
    public static func intersection(_ segment1: Line.Segment, _ segment2: Line.Segment) -> Point<2>? {
        let d1 = segment1.vector
        let d2 = segment2.vector

        // Cross product of direction vectors
        let cross = d1.dx * d2.dy - d1.dy * d2.dx

        // If cross product is near zero, segments are parallel
        guard abs(cross) > .ulpOfOne else { return nil }

        // Vector from segment1's start to segment2's start
        let dp = Vector(
            dx: segment2.start.x - segment1.start.x,
            dy: segment2.start.y - segment1.start.y
        )

        // Parameters for both segments
        let t1 = (dp.dx * d2.dy - dp.dy * d2.dx) / cross
        let t2 = (dp.dx * d1.dy - dp.dy * d1.dx) / cross

        // Check if intersection is within both segments [0, 1]
        guard t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1 else { return nil }

        return segment1.point(at: t1)
    }

    /// Calculate the perpendicular distance from a point to a line segment.
    @inlinable
    public static func distance(from segment: Line.Segment, to point: Point<2>) -> Distance {
        let v = segment.vector
        let lenSq = v.dx * v.dx + v.dy * v.dy

        // Degenerate segment (point)
        if lenSq == 0 {
            let dx = point.x - segment.start.x
            let dy = point.y - segment.start.y
            return .init((dx * dx + dy * dy).squareRoot())
        }

        // Project point onto line, clamping to segment
        let w = Vector(dx: point.x - segment.start.x, dy: point.y - segment.start.y)
        let t = max(0, min(1, (v.dx * w.dx + v.dy * w.dy) / lenSq))

        let closest = segment.point(at: t)
        let dx = point.x - closest.x
        let dy = point.y - closest.y
        return .init((dx * dx + dy * dy).squareRoot())
    }
}

// MARK: - Functorial Map (Line.Segment)

extension Geometry.Line.Segment {
    /// Create a segment by transforming the coordinates of another segment
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U, Space>.Line.Segment,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            start: try Geometry.Point<2>(other.start, transform),
            end: try Geometry.Point<2>(other.end, transform)
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result, Space>.Line.Segment {
        Geometry<Result, Space>.Line.Segment(
            start: try start.map(transform),
            end: try end.map(transform)
        )
    }
}
