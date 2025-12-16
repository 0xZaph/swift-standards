// Edge.swift
// Rectangle edges.

import Algebra
public import Dimension

extension Region {
    /// Four edges of a rectangle with absolute directional naming.
    ///
    /// Edge represents the four sides of a rectangle using absolute directions (top, left, bottom, right). Use it for edge-specific insets, borders, or geometric constraints. Each edge has an opposite edge and an orientation (horizontal or vertical).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let edge = Region.Edge.top
    /// let opposite = !edge         // .bottom
    /// let isHoriz = edge.isHorizontal  // true
    ///
    /// // Corner endpoints
    /// let (c1, c2) = edge.corners  // (.topLeft, .topRight)
    ///
    /// // Pair with values
    /// let inset: Region.Edge.Value<CGFloat> = .init(.left, 16)
    /// ```
    ///
    /// ## Note
    ///
    /// Uses absolute directions (left/right, top/bottom), not layout-relative terms (leading/trailing).
    public enum Edge: Sendable, Hashable, Codable, CaseIterable {
        /// Top edge.
        case top

        /// Left edge.
        case left

        /// Bottom edge.
        case bottom

        /// Right edge.
        case right
    }
}

// MARK: - Opposite

extension Region.Edge {
    /// Opposite edge (parallel edge across the rectangle).
    @inlinable
    public static func opposite(of edge: Region.Edge) -> Region.Edge {
        switch edge {
        case .top: return .bottom
        case .left: return .right
        case .bottom: return .top
        case .right: return .left
        }
    }

    /// Opposite edge (parallel edge across the rectangle).
    @inlinable
    public var opposite: Region.Edge {
        Region.Edge.opposite(of: self)
    }

    /// Returns the opposite edge (parallel reflection).
    @inlinable
    public static prefix func ! (value: Region.Edge) -> Region.Edge {
        Region.Edge.opposite(of: value)
    }
}

// MARK: - Orientation

extension Region.Edge {
    /// Whether this is a horizontal edge (top or bottom).
    @inlinable
    public static func isHorizontal(_ edge: Region.Edge) -> Bool {
        edge == .top || edge == .bottom
    }

    /// Whether this is a horizontal edge (top or bottom).
    @inlinable
    public var isHorizontal: Bool {
        Region.Edge.isHorizontal(self)
    }

    /// Whether this is a vertical edge (left or right).
    @inlinable
    public static func isVertical(_ edge: Region.Edge) -> Bool {
        edge == .left || edge == .right
    }

    /// Whether this is a vertical edge (left or right).
    @inlinable
    public var isVertical: Bool {
        Region.Edge.isVertical(self)
    }
}

// MARK: - Adjacent Corners

extension Region.Edge {
    /// Two corners that bound this edge as endpoints.
    @inlinable
    public static func corners(of edge: Region.Edge) -> (Region.Corner, Region.Corner) {
        switch edge {
        case .top: return (.topLeft, .topRight)
        case .left: return (.topLeft, .bottomLeft)
        case .bottom: return (.bottomLeft, .bottomRight)
        case .right: return (.topRight, .bottomRight)
        }
    }

    /// Two corners that bound this edge as endpoints.
    @inlinable
    public var corners: (Region.Corner, Region.Corner) {
        Region.Edge.corners(of: self)
    }
}

// MARK: - Paired Value

extension Region.Edge {
    /// A value paired with its edge.
    public typealias Value<Payload> = Pair<Region.Edge, Payload>
}
