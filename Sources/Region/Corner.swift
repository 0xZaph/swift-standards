// Corner.swift
// Rectangle corners as product of Horizontal × Vertical.

public import Algebra
public import Dimension

extension Region {
    /// Four corners of a rectangle defined by horizontal and vertical positions.
    ///
    /// Corner represents the Cartesian product of horizontal (left/right) and vertical (top/bottom) positions, forming four named corners. Use it for corner-specific styling, layout constraints, or geometric operations. Forms the product group Z₂ × Z₂.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let corner = Region.Corner.topLeft
    /// let opposite = !corner  // .bottomRight
    ///
    /// // Component access
    /// corner.horizontal  // .leftward
    /// corner.vertical    // .upward
    ///
    /// // Adjacent corners
    /// corner.horizontalAdjacent  // .topRight (shares vertical edge)
    /// corner.verticalAdjacent    // .bottomLeft (shares horizontal edge)
    /// ```
    ///
    /// ## Note
    ///
    /// Uses absolute directions (left/right, top/bottom), not layout-relative terms (leading/trailing).
    public struct Corner: Sendable, Hashable, Codable {
        /// Horizontal position (leftward or rightward).
        public var horizontal: Horizontal

        /// Vertical position (upward or downward).
        public var vertical: Vertical

        /// Creates a corner from horizontal and vertical positions.
        @inlinable
        public init(horizontal: Horizontal, vertical: Vertical) {
            self.horizontal = horizontal
            self.vertical = vertical
        }
    }
}

// MARK: - Named Corners

extension Region.Corner {
    /// Top-left corner.
    public static let topLeft = Region.Corner(horizontal: .leftward, vertical: .upward)

    /// Top-right corner.
    public static let topRight = Region.Corner(horizontal: .rightward, vertical: .upward)

    /// Bottom-left corner.
    public static let bottomLeft = Region.Corner(horizontal: .leftward, vertical: .downward)

    /// Bottom-right corner.
    public static let bottomRight = Region.Corner(horizontal: .rightward, vertical: .downward)
}

// MARK: - CaseIterable

extension Region.Corner: CaseIterable {
    public static let allCases: [Region.Corner] = [
        .topLeft, .topRight, .bottomLeft, .bottomRight,
    ]
}

// MARK: - Opposite

extension Region.Corner {
    /// Diagonally opposite corner (flips both horizontal and vertical).
    @inlinable
    public static func opposite(of corner: Region.Corner) -> Region.Corner {
        Region.Corner(horizontal: corner.horizontal.opposite, vertical: corner.vertical.opposite)
    }

    /// Diagonally opposite corner (flips both horizontal and vertical).
    @inlinable
    public var opposite: Region.Corner {
        Region.Corner.opposite(of: self)
    }

    /// Returns the diagonally opposite corner (diagonal reflection).
    @inlinable
    public static prefix func ! (value: Region.Corner) -> Region.Corner {
        Region.Corner.opposite(of: value)
    }
}

// MARK: - Properties

extension Region.Corner {
    /// Whether this is a top corner (upward vertical position).
    @inlinable
    public static func isTop(_ corner: Region.Corner) -> Bool { corner.vertical == .upward }

    /// Whether this is a top corner (upward vertical position).
    @inlinable
    public var isTop: Bool { Region.Corner.isTop(self) }

    /// Whether this is a bottom corner (downward vertical position).
    @inlinable
    public static func isBottom(_ corner: Region.Corner) -> Bool { corner.vertical == .downward }

    /// Whether this is a bottom corner (downward vertical position).
    @inlinable
    public var isBottom: Bool { Region.Corner.isBottom(self) }

    /// Whether this is a left corner (leftward horizontal position).
    @inlinable
    public static func isLeft(_ corner: Region.Corner) -> Bool { corner.horizontal == .leftward }

    /// Whether this is a left corner (leftward horizontal position).
    @inlinable
    public var isLeft: Bool { Region.Corner.isLeft(self) }

    /// Whether this is a right corner (rightward horizontal position).
    @inlinable
    public static func isRight(_ corner: Region.Corner) -> Bool { corner.horizontal == .rightward }

    /// Whether this is a right corner (rightward horizontal position).
    @inlinable
    public var isRight: Bool { Region.Corner.isRight(self) }
}

// MARK: - Adjacent Corners

extension Region.Corner {
    /// Corner horizontally adjacent to this one (flips horizontal, keeps vertical).
    @inlinable
    public static func horizontalAdjacent(of corner: Region.Corner) -> Region.Corner {
        Region.Corner(horizontal: corner.horizontal.opposite, vertical: corner.vertical)
    }

    /// Corner horizontally adjacent to this one (flips horizontal, keeps vertical).
    @inlinable
    public var horizontalAdjacent: Region.Corner {
        Region.Corner.horizontalAdjacent(of: self)
    }

    /// Corner vertically adjacent to this one (keeps horizontal, flips vertical).
    @inlinable
    public static func verticalAdjacent(of corner: Region.Corner) -> Region.Corner {
        Region.Corner(horizontal: corner.horizontal, vertical: corner.vertical.opposite)
    }

    /// Corner vertically adjacent to this one (keeps horizontal, flips vertical).
    @inlinable
    public var verticalAdjacent: Region.Corner {
        Region.Corner.verticalAdjacent(of: self)
    }
}

// MARK: - Paired Value

extension Region.Corner {
    /// A value paired with its corner.
    public typealias Value<Payload> = Pair<Region.Corner, Payload>
}
