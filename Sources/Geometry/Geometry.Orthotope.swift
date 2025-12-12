// Geometry.Orthotope.swift
// N-dimensional orthotope (axis-aligned box with independent side lengths).

public import Affine
public import Algebra_Linear
public import Dimension

extension Geometry {
    /// N-dimensional orthotope — axis-aligned box with independent side lengths.
    ///
    /// An orthotope (also called a hyperrectangle) has potentially different extents
    /// in each dimension. In 2D this is a rectangle, in 3D a cuboid (rectangular box).
    ///
    /// - `Orthotope<2>` = Rectangle
    /// - `Orthotope<3>` = Cuboid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let rect = Geometry<Double, Void>.Rectangle(
    ///     llx: .init(0), lly: .init(0),
    ///     urx: .init(612), ury: .init(792)
    /// )
    /// print(rect.width)   // 612
    /// print(rect.height)  // 792
    /// ```
    public struct Orthotope<let N: Int> {
        /// Center point.
        public var center: Point<N>

        /// Half-extents (distance from center to each face).
        public var halfExtents: Size<N>

        /// Creates an orthotope with the given center and half-extents.
        @inlinable
        public init(center: consuming Point<N>, halfExtents: consuming Size<N>) {
            self.center = center
            self.halfExtents = halfExtents
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// 2-dimensional orthotope (rectangle).
    public typealias Rectangle = Orthotope<2>

    /// 3-dimensional orthotope (cuboid/rectangular box).
    public typealias Cuboid = Orthotope<3>
}

// MARK: - Conformances

extension Geometry.Orthotope: Sendable where Scalar: Sendable {}
extension Geometry.Orthotope: Equatable where Scalar: Equatable {}
extension Geometry.Orthotope: Hashable where Scalar: Hashable {}

#if Codable
extension Geometry.Orthotope: Codable where Scalar: Codable {}
#endif

// MARK: - Convenience Initializers

extension Geometry.Orthotope where Scalar: AdditiveArithmetic {
    /// Creates an orthotope centered at origin with given half-extents.
    @inlinable
    public init(halfExtents: Geometry.Size<N>) {
        self.init(center: .zero, halfExtents: halfExtents)
    }
}

// MARK: - Static Properties

extension Geometry.Orthotope where Scalar: ExpressibleByIntegerLiteral & AdditiveArithmetic {
    /// Unit orthotope centered at origin with all side lengths 1.
    @inlinable
    public static var unit: Self {
        Self(center: .zero, halfExtents: Geometry.Size(InlineArray(repeating: 1)))
    }
}

// MARK: - 2D Properties (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Lower-left x coordinate.
    @inlinable
    public var llx: Geometry.X {
        get { center.x - halfExtents.width }
        set {
            let oldUrx = center.x + halfExtents.width
            let newWidth: Geometry.Width = (oldUrx - newValue) / 2
            center = Geometry.Point(
                x: newValue + newWidth,
                y: center.y
            )
            halfExtents.width = newWidth
        }
    }

    /// Lower-left y coordinate.
    @inlinable
    public var lly: Geometry.Y {
        get { center.y - halfExtents.height }
        set {
            let oldUry = center.y + halfExtents.height
            let newHeight: Geometry.Height = (oldUry - newValue) / 2
            center = Geometry.Point(
                x: center.x,
                y: newValue + newHeight
            )
            halfExtents.height = newHeight
        }
    }

    /// Upper-right x coordinate.
    @inlinable
    public var urx: Geometry.X {
        get { center.x + halfExtents.width }
        set {
            let oldLlx = center.x - halfExtents.width
            let newWidth: Geometry.Width = (newValue - oldLlx) / 2
            center = Geometry.Point(
                x: oldLlx + newWidth,
                y: center.y
            )
            halfExtents.width = newWidth
        }
    }

    /// Upper-right y coordinate.
    @inlinable
    public var ury: Geometry.Y {
        get { center.y + halfExtents.height }
        set {
            let oldLly = center.y - halfExtents.height
            let newHeight: Geometry.Height = (newValue - oldLly) / 2
            center = Geometry.Point(
                x: center.x,
                y: oldLly + newHeight
            )
            halfExtents.height = newHeight
        }
    }

    /// Width of the orthotope.
    @inlinable
    public var width: Geometry.Width {
        get { halfExtents.width * 2 }
        set { halfExtents.width = newValue / 2 }
    }

    /// Height of the orthotope.
    @inlinable
    public var height: Geometry.Height {
        get { halfExtents.height * 2 }
        set { halfExtents.height = newValue / 2 }
    }
}

// MARK: - 2D Initializers (Rectangle API) - FloatingPoint

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Creates a rectangle from corner coordinates.
    ///
    /// - Parameters:
    ///   - llx: Lower-left x coordinate
    ///   - lly: Lower-left y coordinate
    ///   - urx: Upper-right x coordinate
    ///   - ury: Upper-right y coordinate
    @inlinable
    public init(
        llx: Geometry.X,
        lly: Geometry.Y,
        urx: Geometry.X,
        ury: Geometry.Y
    ) {
        let cx = (llx.value + urx.value) / 2
        let cy = (lly.value + ury.value) / 2
        let hw = (urx.value - llx.value) / 2
        let hh = (ury.value - lly.value) / 2
        self.init(
            center: Geometry.Point(
                x: Affine<Scalar, Space>.X(cx),
                y: Affine<Scalar, Space>.Y(cy)
            ),
            halfExtents: Geometry.Size(width: Geometry.Width(hw), height: Geometry.Height(hh))
        )
    }

    /// Creates a rectangle from origin and size.
    ///
    /// - Parameters:
    ///   - x: Lower-left x coordinate
    ///   - y: Lower-left y coordinate
    ///   - width: Width of the rectangle
    ///   - height: Height of the rectangle
    @inlinable
    public init(
        x: Geometry.X,
        y: Geometry.Y,
        width: Geometry.Width,
        height: Geometry.Height
    ) {
        self.init(
            llx: x,
            lly: y,
            urx: x + width,
            ury: y + height
        )
    }
}

// MARK: - 2D Initializers (Rectangle API) - BinaryInteger

extension Geometry.Orthotope where N == 2, Scalar: BinaryInteger {
    /// Creates a rectangle from corner coordinates.
    ///
    /// - Parameters:
    ///   - llx: Lower-left x coordinate
    ///   - lly: Lower-left y coordinate
    ///   - urx: Upper-right x coordinate
    ///   - ury: Upper-right y coordinate
    @inlinable
    public init(
        llx: Geometry.X,
        lly: Geometry.Y,
        urx: Geometry.X,
        ury: Geometry.Y
    ) {
        let cx = (llx.value + urx.value) / 2
        let cy = (lly.value + ury.value) / 2
        let hw = (urx.value - llx.value) / 2
        let hh = (ury.value - lly.value) / 2
        self.init(
            center: Geometry.Point(
                x: Affine<Scalar, Space>.X(cx),
                y: Affine<Scalar, Space>.Y(cy)
            ),
            halfExtents: Geometry.Size(width: Geometry.Width(hw), height: Geometry.Height(hh))
        )
    }

    /// Creates a rectangle from origin and size.
    ///
    /// - Parameters:
    ///   - x: Lower-left x coordinate
    ///   - y: Lower-left y coordinate
    ///   - width: Width of the rectangle
    ///   - height: Height of the rectangle
    @inlinable
    public init(
        x: Geometry.X,
        y: Geometry.Y,
        width: Geometry.Width,
        height: Geometry.Height
    ) {
        self.init(
            llx: x,
            lly: y,
            urx: x + width,
            ury: y + height
        )
    }
}

// MARK: - 2D Computed Properties (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Center x coordinate.
    @inlinable
    public var midX: Geometry.X { center.x }

    /// Center y coordinate.
    @inlinable
    public var midY: Geometry.Y { center.y }

    /// Minimum x coordinate.
    @inlinable
    public var minX: Geometry.X { llx }

    /// Maximum x coordinate.
    @inlinable
    public var maxX: Geometry.X { urx }

    /// Minimum y coordinate.
    @inlinable
    public var minY: Geometry.Y { lly }

    /// Maximum y coordinate.
    @inlinable
    public var maxY: Geometry.Y { ury }

    /// Area of the rectangle.
    @inlinable
    public var area: Geometry.Area { Geometry.area(of: self) }

    /// Perimeter of the rectangle.
    @inlinable
    public var perimeter: Geometry.Perimeter { Geometry.perimeter(of: self) }

    /// Diagonal length.
    @inlinable
    public var diagonal: Geometry.Magnitude {
        let w = width.value
        let h = height.value
        return Geometry.Magnitude(Linear<Scalar, Space>.Magnitude((w * w + h * h).squareRoot()))
    }
}

// MARK: - 2D Containment (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Check if the rectangle has zero or negative area.
    @inlinable
    public var isEmpty: Bool {
        halfExtents.width.value <= 0 || halfExtents.height.value <= 0
    }

    /// Check if the rectangle contains a point.
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        Geometry.contains(self, point: point)
    }

    /// Check if this rectangle contains another rectangle.
    @inlinable
    public func contains(_ other: Self) -> Bool {
        Geometry.contains(self, other)
    }

    /// Check if this rectangle intersects another.
    @inlinable
    public func intersects(_ other: Self) -> Bool {
        Geometry.intersects(self, other)
    }
}

// MARK: - 2D Set Operations (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// The union of this rectangle with another.
    @inlinable
    public func union(_ other: Self) -> Self {
        Geometry.union(self, other)
    }

    /// The intersection of this rectangle with another, if they intersect.
    @inlinable
    public func intersection(_ other: Self) -> Self? {
        Geometry.intersection(self, other)
    }
}

// MARK: - 2D Corner Access (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Get a corner coordinate.
    @inlinable
    public func corner(_ corner: Region.Corner) -> Geometry.Point<2> {
        switch corner {
        case .bottomLeft:
            return Geometry.Point(x: llx, y: lly)
        case .bottomRight:
            return Geometry.Point(x: urx, y: lly)
        case .topLeft:
            return Geometry.Point(x: llx, y: ury)
        case .topRight:
            return Geometry.Point(x: urx, y: ury)
        default:
            fatalError("Invalid corner")
        }
    }
}

// MARK: - 2D Functional Updates (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Create a new rectangle with a modified lower-left x.
    @inlinable
    public func with(llx newLlx: Geometry.X) -> Self {
        var copy = self
        copy.llx = newLlx
        return copy
    }

    /// Create a new rectangle with a modified lower-left y.
    @inlinable
    public func with(lly newLly: Geometry.Y) -> Self {
        var copy = self
        copy.lly = newLly
        return copy
    }

    /// Create a new rectangle with a modified upper-right x.
    @inlinable
    public func with(urx newUrx: Geometry.X) -> Self {
        var copy = self
        copy.urx = newUrx
        return copy
    }

    /// Create a new rectangle with a modified upper-right y.
    @inlinable
    public func with(ury newUry: Geometry.Y) -> Self {
        var copy = self
        copy.ury = newUry
        return copy
    }
}

// MARK: - 2D Transformation (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Translate the rectangle by the given displacements.
    @inlinable
    public func translated(dx: Geometry.Width, dy: Geometry.Height) -> Self {
        Self(
            center: Geometry.Point(x: center.x + dx, y: center.y + dy),
            halfExtents: halfExtents
        )
    }

    /// Translate the rectangle by a vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(center: center + vector, halfExtents: halfExtents)
    }

    /// Return a rectangle inset by the given amounts.
    @inlinable
    public func insetBy(dx: Geometry.Width, dy: Geometry.Height) -> Self {
        Self(
            center: center,
            halfExtents: Geometry.Size(
                width: halfExtents.width - dx,
                height: halfExtents.height - dy
            )
        )
    }

    /// Return a rectangle inset by uniform padding on all sides.
    @inlinable
    public func inset(by padding: Geometry.Size<1>) -> Self {
        insetBy(dx: padding.width, dy: padding.height)
    }

    /// Return a rectangle inset by edge insets.
    @inlinable
    public func inset(by insets: Geometry.EdgeInsets) -> Self {
        Self(
            llx: llx + insets.leading,
            lly: lly + insets.bottom,
            urx: urx - insets.trailing,
            ury: ury - insets.top
        )
    }

    /// Scale the rectangle uniformly about its center.
    @inlinable
    public func scaled(by factor: Scalar) -> Self {
        Self(
            center: center,
            halfExtents: Geometry.Size(
                width: halfExtents.width * factor,
                height: halfExtents.height * factor
            )
        )
    }
}

// MARK: - 2D Dimension Clamping (Rectangle)

extension Geometry.Orthotope where N == 2, Scalar: FloatingPoint {
    /// Returns a rectangle with width clamped to at most the given maximum.
    @inlinable
    public func clamped(maxWidth: Geometry.Width) -> Self {
        guard width.value > maxWidth.value else { return self }
        var copy = self
        copy.width = maxWidth
        return copy
    }

    /// Returns a rectangle with height clamped to at most the given maximum.
    @inlinable
    public func clamped(maxHeight: Geometry.Height) -> Self {
        guard height.value > maxHeight.value else { return self }
        var copy = self
        copy.height = maxHeight
        return copy
    }
}

// MARK: - 3D Properties (Cuboid)

extension Geometry.Orthotope where N == 3, Scalar: FloatingPoint {
    /// Width (x-extent).
    @inlinable
    public var width: Geometry.Width {
        get { halfExtents.width * 2 }
        set { halfExtents.width = newValue / 2 }
    }

    /// Height (y-extent).
    @inlinable
    public var height: Geometry.Height {
        get { halfExtents.height * 2 }
        set { halfExtents.height = newValue / 2 }
    }

    /// Depth (z-extent).
    @inlinable
    public var depth: Scalar {
        get { halfExtents.depth * 2 }
        set { halfExtents.dimensions[2] = newValue / 2 }
    }

    /// Volume (width × height × depth).
    @inlinable
    public var volume: Scalar {
        let w = halfExtents.width.value * 2
        let h = halfExtents.height.value * 2
        let d = halfExtents.depth * 2
        return w * h * d
    }

    /// Surface area (2 × (wh + wd + hd)).
    @inlinable
    public var surfaceArea: Scalar {
        let w = halfExtents.width.value * 2
        let h = halfExtents.height.value * 2
        let d = halfExtents.depth * 2
        return 2 * (w * h + w * d + h * d)
    }

    /// Space diagonal.
    @inlinable
    public var diagonal: Geometry.Magnitude {
        let w = halfExtents.width.value * 2
        let h = halfExtents.height.value * 2
        let d = halfExtents.depth * 2
        return Geometry.Magnitude(Linear<Scalar, Space>.Magnitude((w * w + h * h + d * d).squareRoot()))
    }
}

// MARK: - Functorial Map

extension Geometry.Orthotope {
    /// Transforms coordinates using the given closure.
    @inlinable
    public func map<Result>(
        _ transform: (Scalar) throws -> Result
    ) rethrows -> Geometry<Result, Space>.Orthotope<N> {
        Geometry<Result, Space>.Orthotope(
            center: try center.map(transform),
            halfExtents: try halfExtents.map(transform)
        )
    }
}

// MARK: - Static Implementations

extension Geometry where Scalar: FloatingPoint {
    /// Calculate the area of a rectangle.
    @inlinable
    public static func area(of rectangle: Orthotope<2>) -> Area {
        Area(rectangle.width.value * rectangle.height.value)
    }

    /// Calculate the perimeter of a rectangle.
    @inlinable
    public static func perimeter(of rectangle: Orthotope<2>) -> Perimeter {
        Perimeter((rectangle.width.value + rectangle.height.value) * 2)
    }

    /// Check if a rectangle contains a point.
    @inlinable
    public static func contains(_ rectangle: Orthotope<2>, point: Point<2>) -> Bool {
        let dx = point.x.rawValue - rectangle.center.x.rawValue
        let dy = point.y.rawValue - rectangle.center.y.rawValue
        let hw = rectangle.halfExtents.width.value
        let hh = rectangle.halfExtents.height.value
        return dx >= -hw && dx <= hw && dy >= -hh && dy <= hh
    }

    /// Check if a rectangle contains another rectangle.
    @inlinable
    public static func contains(_ rectangle: Orthotope<2>, _ other: Orthotope<2>) -> Bool {
        other.llx.value >= rectangle.llx.value &&
        other.urx.value <= rectangle.urx.value &&
        other.lly.value >= rectangle.lly.value &&
        other.ury.value <= rectangle.ury.value
    }

    /// Check if two rectangles intersect.
    @inlinable
    public static func intersects(_ rectangle1: Orthotope<2>, _ rectangle2: Orthotope<2>) -> Bool {
        rectangle1.llx.value <= rectangle2.urx.value &&
        rectangle1.urx.value >= rectangle2.llx.value &&
        rectangle1.lly.value <= rectangle2.ury.value &&
        rectangle1.ury.value >= rectangle2.lly.value
    }

    /// Calculate the union of two rectangles.
    @inlinable
    public static func union(_ rectangle1: Orthotope<2>, _ rectangle2: Orthotope<2>) -> Orthotope<2> {
        Orthotope<2>(
            llx: X(Swift.min(rectangle1.llx.value, rectangle2.llx.value)),
            lly: Y(Swift.min(rectangle1.lly.value, rectangle2.lly.value)),
            urx: X(Swift.max(rectangle1.urx.value, rectangle2.urx.value)),
            ury: Y(Swift.max(rectangle1.ury.value, rectangle2.ury.value))
        )
    }

    /// Calculate the intersection of two rectangles.
    @inlinable
    public static func intersection(_ rectangle1: Orthotope<2>, _ rectangle2: Orthotope<2>) -> Orthotope<2>? {
        guard intersects(rectangle1, rectangle2) else { return nil }
        return Orthotope<2>(
            llx: X(Swift.max(rectangle1.llx.value, rectangle2.llx.value)),
            lly: Y(Swift.max(rectangle1.lly.value, rectangle2.lly.value)),
            urx: X(Swift.min(rectangle1.urx.value, rectangle2.urx.value)),
            ury: Y(Swift.min(rectangle1.ury.value, rectangle2.ury.value))
        )
    }
}
