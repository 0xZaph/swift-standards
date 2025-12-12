// Geometry.Ball.swift
// N-dimensional ball (hypersphere) defined by center and radius.

public import Affine
public import Algebra_Linear
public import Angle
public import Dimension

extension Geometry {
    /// N-dimensional ball (hypersphere) — all points within radius of center.
    ///
    /// A ball is the set of points whose distance from a center point is at most
    /// the radius. In 2D this is a disk (circle), in 3D a sphere.
    ///
    /// - `Ball<2>` = Circle (disk)
    /// - `Ball<3>` = Sphere (3-ball)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let circle = Geometry<Double, Void>.Ball<2>(
    ///     center: .init(x: .init(100), y: .init(100)),
    ///     radius: .init(50)
    /// )
    /// print(circle.area)           // Area measure
    /// print(circle.circumference)  // Perimeter
    /// ```
    public struct Ball<let N: Int> {
        /// Center point.
        public var center: Point<N>

        /// Radius (distance from center to boundary).
        public var radius: Radius

        /// Creates a ball with the given center and radius.
        @inlinable
        public init(center: consuming Point<N>, radius: consuming Radius) {
            self.center = center
            self.radius = radius
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// 2-dimensional ball (disk/circle).
    public typealias Circle = Ball<2>

    /// 3-dimensional ball (sphere).
    public typealias Sphere = Ball<3>
}

// MARK: - Conformances

extension Geometry.Ball: Sendable where Scalar: Sendable {}
extension Geometry.Ball: Equatable where Scalar: Equatable {}
extension Geometry.Ball: Hashable where Scalar: Hashable {}

#if Codable
extension Geometry.Ball: Codable where Scalar: Codable {}
#endif

// MARK: - Convenience Initializers

extension Geometry.Ball where Scalar: AdditiveArithmetic {
    /// Creates a ball centered at origin with given radius.
    @inlinable
    public init(radius: Geometry.Radius) {
        self.init(center: .zero, radius: radius)
    }
}

// MARK: - Static Properties

extension Geometry.Ball where Scalar: ExpressibleByIntegerLiteral & AdditiveArithmetic {
    /// Unit ball centered at origin with radius 1.
    @inlinable
    public static var unit: Self {
        Self(center: .zero, radius: .init(1))
    }
}

// MARK: - Common Properties (All Dimensions)

extension Geometry.Ball where Scalar: FloatingPoint {
    /// Diameter (2 × radius) with projections to Width/Height.
    @inlinable
    public var diameter: Geometry.Magnitude {
        Geometry.Magnitude(radius * 2)
    }
}

// MARK: - 2D Properties (Circle)

extension Geometry.Ball where N == 2, Scalar: FloatingPoint {
    /// Circumference (2π × radius).
    @inlinable
    public var circumference: Geometry.Circumference {
        radius * (2 * Scalar.pi)
    }

    /// Area (π × radius²).
    @inlinable
    public var area: Geometry.Area { Geometry.area(of: self) }

    /// Axis-aligned bounding rectangle.
    @inlinable
    public var boundingBox: Geometry.Rectangle { Geometry.boundingBox(of: self) }
}

// MARK: - 3D Properties (Sphere)

extension Geometry.Ball where N == 3, Scalar: FloatingPoint {
    /// Surface area (4π × radius²).
    @inlinable
    public var surfaceArea: Scalar {
        4 * Scalar.pi * (radius * radius)
    }

    /// Volume (4/3 × π × radius³).
    @inlinable
    public var volume: Scalar {
        (4 / 3) * Scalar.pi * (radius * radius) * radius.rawValue
    }
}

// MARK: - 2D Circle from Ellipse

extension Geometry.Ball where N == 2, Scalar: FloatingPoint {
    /// Creates a circle from an ellipse if the ellipse is circular.
    ///
    /// - Parameter ellipse: The ellipse to convert.
    /// - Returns: A circle if the ellipse has equal semi-major and semi-minor axes, `nil` otherwise.
    @inlinable
    public init?(_ ellipse: Geometry.Ellipse) {
        let diff: Scalar = ellipse.semiMajor.rawValue - ellipse.semiMinor.rawValue
        guard abs(diff) < Scalar.ulpOfOne else { return nil }
        self.init(center: ellipse.center, radius: ellipse.semiMajor)
    }
}

// MARK: - 2D Containment

extension Geometry.Ball where N == 2, Scalar: FloatingPoint {
    /// Checks if point is inside or on the circle boundary.
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        Geometry.contains(self, point: point)
    }

    /// Checks if point is strictly inside (not on boundary).
    @inlinable
    public func containsInterior(_ point: Geometry.Point<2>) -> Bool {
        center.distanceSquared(to: point) < radius * radius
    }

    /// Checks if another circle is entirely contained within this circle.
    @inlinable
    public func contains(_ other: Self) -> Bool {
        Geometry.contains(self, other)
    }
}

// MARK: - 2D Point on Circle

extension Geometry.Ball where N == 2, Scalar: BinaryFloatingPoint {
    /// Returns point on circle at given angle from positive x-axis.
    @inlinable
    public func point(at angle: Radian) -> Geometry.Point<2> {
        let c = Scalar(angle.cos)
        let s = Scalar(angle.sin)
        let r = radius.rawValue
        return Geometry.Point(
            x: Affine<Scalar, Space>.X(center.x.rawValue + r * c),
            y: Affine<Scalar, Space>.Y(center.y.rawValue + r * s)
        )
    }

    /// Returns unit tangent vector at given angle (perpendicular to radius, counter-clockwise).
    @inlinable
    public func tangent(at angle: Radian) -> Geometry.Vector<2> {
        let c = Scalar(angle.cos)
        let s = Scalar(angle.sin)
        return Geometry.Vector(
            dx: Linear<Scalar, Space>.Dx(-s),
            dy: Linear<Scalar, Space>.Dy(c)
        )
    }

    /// Returns closest point on circle boundary to given point.
    @inlinable
    public func closestPoint(to point: Geometry.Point<2>) -> Geometry.Point<2> {
        let vx = point.x.rawValue - center.x.rawValue
        let vy = point.y.rawValue - center.y.rawValue
        let len = (vx * vx + vy * vy).squareRoot()
        let r = radius.rawValue
        guard len > 0 else {
            return Geometry.Point(
                x: Affine<Scalar, Space>.X(center.x.rawValue + r),
                y: center.y
            )
        }
        let scale = r / len
        return Geometry.Point(
            x: Affine<Scalar, Space>.X(center.x.rawValue + vx * scale),
            y: Affine<Scalar, Space>.Y(center.y.rawValue + vy * scale)
        )
    }
}

// MARK: - 2D Intersection

extension Geometry.Ball where N == 2, Scalar: FloatingPoint {
    /// Checks if circles intersect or touch.
    @inlinable
    public func intersects(_ other: Self) -> Bool {
        Geometry.intersects(self, other)
    }

    /// Finds intersection points with a line.
    ///
    /// - Returns: Array of 0, 1, or 2 points where line crosses circle.
    @inlinable
    public func intersection(with line: Geometry.Line) -> [Geometry.Point<2>] {
        Geometry.intersection(self, line)
    }

    /// Finds intersection points with another circle.
    ///
    /// - Returns: Array of 0, 1, or 2 points where circles intersect.
    @inlinable
    public func intersection(with other: Self) -> [Geometry.Point<2>] {
        Geometry.intersection(self, other)
    }
}

// MARK: - Static Implementations

extension Geometry where Scalar: FloatingPoint {
    /// Calculate the area of a circle.
    @inlinable
    public static func area(of circle: Ball<2>) -> Area {
        Area(Scalar.pi * (circle.radius * circle.radius))
    }

    /// Calculate the axis-aligned bounding rectangle of a circle.
    @inlinable
    public static func boundingBox(of circle: Ball<2>) -> Rectangle {
        Rectangle(
            llx: circle.center.x - circle.radius,
            lly: circle.center.y - circle.radius,
            urx: circle.center.x + circle.radius,
            ury: circle.center.y + circle.radius
        )
    }

    /// Check if a circle contains a point.
    @inlinable
    public static func contains(_ circle: Ball<2>, point: Point<2>) -> Bool {
        circle.center.distanceSquared(to: point) <= circle.radius * circle.radius
    }

    /// Check if a circle contains another circle.
    @inlinable
    public static func contains(_ circle: Ball<2>, _ other: Ball<2>) -> Bool {
        circle.center.distance(to: other.center) + other.radius <= circle.radius
    }

    /// Check if two circles intersect or touch.
    @inlinable
    public static func intersects(_ circle1: Ball<2>, _ circle2: Ball<2>) -> Bool {
        let dist = circle1.center.distance(to: circle2.center)
        let sumRadii = circle1.radius + circle2.radius
        let diffRadii = circle1.radius >= circle2.radius ? circle1.radius - circle2.radius : circle2.radius - circle1.radius
        return dist <= sumRadii && dist >= diffRadii
    }

    /// Find intersection points between a circle and a line.
    @inlinable
    public static func intersection(_ circle: Ball<2>, _ line: Line) -> [Point<2>] {
        let fx = line.point.x.rawValue - circle.center.x.rawValue
        let fy = line.point.y.rawValue - circle.center.y.rawValue
        let dx = line.direction.dx.rawValue
        let dy = line.direction.dy.rawValue
        let r = circle.radius.rawValue

        let a = dx * dx + dy * dy
        let b = 2 * (fx * dx + fy * dy)
        let c = fx * fx + fy * fy - r * r

        let discriminant = b * b - 4 * a * c

        guard discriminant >= 0 else { return [] }

        if discriminant == 0 {
            let t = -b / (2 * a)
            return [line.point(at: t)]
        }

        let sqrtDisc = discriminant.squareRoot()
        let t1 = (-b - sqrtDisc) / (2 * a)
        let t2 = (-b + sqrtDisc) / (2 * a)
        return [line.point(at: t1), line.point(at: t2)]
    }

    /// Find intersection points between two circles.
    @inlinable
    public static func intersection(_ circle1: Ball<2>, _ circle2: Ball<2>) -> [Point<2>] {
        let dist = circle1.center.distance(to: circle2.center)
        let sumRadii = circle1.radius + circle2.radius
        let diffRadii = circle1.radius >= circle2.radius ? circle1.radius - circle2.radius : circle2.radius - circle1.radius

        guard dist <= sumRadii && dist >= diffRadii && dist.rawValue > 0 else {
            return []
        }

        let d = dist.rawValue
        let r1 = circle1.radius.rawValue
        let r2 = circle2.radius.rawValue

        let a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
        let hSq = r1 * r1 - a * a

        guard hSq >= 0 else { return [] }
        let h = hSq.squareRoot()

        let cx = circle1.center.x.rawValue
        let cy = circle1.center.y.rawValue
        let ocx = circle2.center.x.rawValue
        let ocy = circle2.center.y.rawValue
        let dirX = (ocx - cx) / d
        let dirY = (ocy - cy) / d
        let px = cx + a * dirX
        let py = cy + a * dirY

        if h == 0 {
            return [Point(x: Affine<Scalar, Space>.X(px), y: Affine<Scalar, Space>.Y(py))]
        }

        return [
            Point(
                x: Affine<Scalar, Space>.X(px + h * dirY),
                y: Affine<Scalar, Space>.Y(py - h * dirX)
            ),
            Point(
                x: Affine<Scalar, Space>.X(px - h * dirY),
                y: Affine<Scalar, Space>.Y(py + h * dirX)
            ),
        ]
    }
}

// MARK: - 2D Transformation

extension Geometry.Ball where N == 2, Scalar: FloatingPoint {
    /// Returns circle translated by vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(center: center + vector, radius: radius)
    }

    /// Returns circle scaled uniformly about its center.
    @inlinable
    public func scaled(by factor: Scalar) -> Self {
        Self(center: center, radius: radius * factor)
    }

    /// Returns circle scaled uniformly about given point.
    @inlinable
    public func scaled(by factor: Scalar, about point: Geometry.Point<2>) -> Self {
        let px = point.x.rawValue
        let py = point.y.rawValue
        let cx = center.x.rawValue
        let cy = center.y.rawValue
        let newCenter = Geometry.Point(
            x: Affine<Scalar, Space>.X(px + factor * (cx - px)),
            y: Affine<Scalar, Space>.Y(py + factor * (cy - py))
        )
        return Self(center: newCenter, radius: radius * factor)
    }
}

// MARK: - Functorial Map

extension Geometry.Ball {
    /// Transforms coordinates using the given closure.
    @inlinable
    public func map<Result>(
        _ transform: (Scalar) throws -> Result
    ) rethrows -> Geometry<Result, Space>.Ball<N> {
        Geometry<Result, Space>.Ball(
            center: try center.map(transform),
            radius: try radius.map(transform)
        )
    }
}

// MARK: - 2D Bézier Approximation

extension Geometry.Ball where N == 2, Scalar: BinaryFloatingPoint {
    /// Cubic Bézier curve segment.
    public struct BezierSegment {
        /// Start point.
        public let start: Geometry.Point<2>
        /// First control point.
        public let control1: Geometry.Point<2>
        /// Second control point.
        public let control2: Geometry.Point<2>
        /// End point.
        public let end: Geometry.Point<2>

        /// Creates a Bézier segment with given control points.
        @inlinable
        public init(
            start: Geometry.Point<2>,
            control1: Geometry.Point<2>,
            control2: Geometry.Point<2>,
            end: Geometry.Point<2>
        ) {
            self.start = start
            self.control1 = control1
            self.control2 = control2
            self.end = end
        }
    }
}

extension Geometry.Ball.BezierSegment: Sendable where Scalar: Sendable {}

extension Geometry.Ball where N == 2, Scalar: BinaryFloatingPoint {
    /// Four cubic Bézier curves approximating this circle.
    ///
    /// Uses standard constant k = 0.5522847498 for excellent circle approximation.
    /// Curves start at 3 o'clock and proceed counter-clockwise through quadrants.
    @inlinable
    public var bezierCurves: [BezierSegment] {
        let k = Scalar(0.5522847498) * radius.rawValue
        let cx = center.x.rawValue
        let cy = center.y.rawValue
        let r = radius.rawValue

        let right = Geometry.Point<2>(x: .init(cx + r), y: .init(cy))
        let bottom = Geometry.Point<2>(x: .init(cx), y: .init(cy - r))
        let left = Geometry.Point<2>(x: .init(cx - r), y: .init(cy))
        let top = Geometry.Point<2>(x: .init(cx), y: .init(cy + r))

        return [
            BezierSegment(
                start: right,
                control1: Geometry.Point<2>(x: .init(cx + r), y: .init(cy - k)),
                control2: Geometry.Point<2>(x: .init(cx + k), y: .init(cy - r)),
                end: bottom
            ),
            BezierSegment(
                start: bottom,
                control1: Geometry.Point<2>(x: .init(cx - k), y: .init(cy - r)),
                control2: Geometry.Point<2>(x: .init(cx - r), y: .init(cy - k)),
                end: left
            ),
            BezierSegment(
                start: left,
                control1: Geometry.Point<2>(x: .init(cx - r), y: .init(cy + k)),
                control2: Geometry.Point<2>(x: .init(cx - k), y: .init(cy + r)),
                end: top
            ),
            BezierSegment(
                start: top,
                control1: Geometry.Point<2>(x: .init(cx + k), y: .init(cy + r)),
                control2: Geometry.Point<2>(x: .init(cx + r), y: .init(cy + k)),
                end: right
            ),
        ]
    }

    /// Starting point for Bézier curve rendering (3 o'clock position).
    @inlinable
    public var bezierStartPoint: Geometry.Point<2> {
        Geometry.Point<2>(x: .init(center.x.rawValue + radius.rawValue), y: center.y)
    }
}
