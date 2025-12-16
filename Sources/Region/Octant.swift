// Octant.swift
// 3D space octants.

import Algebra
public import Dimension

extension Region {
    /// Eight regions of 3D Cartesian space separated by coordinate planes.
    ///
    /// Octant divides 3D space into eight regions defined by the signs of x, y, and z coordinates, analogous to quadrants in 2D. Use it for spatial partitioning in three dimensions, 3D collision detection, or coordinate sign analysis. Forms the group Z₂³ under axis reflections.
    ///
    /// ## Example
    ///
    /// ```swift
    /// //        +z     npp  |  ppp
    /// //         ↑     npn  |  ppn
    /// //         |  nnp     | pnp
    /// //         | nnn      |/ pnn
    /// //         +-----→ +x
    /// //        /
    /// //       +y
    ///
    /// let oct: Region.Octant = .ppp      // x > 0, y > 0, z > 0
    /// let reflected = !oct               // .nnn (origin reflection)
    ///
    /// // Check coordinate signs
    /// oct.hasPositiveX  // true
    /// oct.hasPositiveZ  // true
    /// ```
    public enum Octant: Sendable, Hashable, Codable, CaseIterable {
        /// Octant with x > 0, y > 0, z > 0.
        case ppp
        /// Octant with x > 0, y > 0, z < 0.
        case ppn
        /// Octant with x > 0, y < 0, z > 0.
        case pnp
        /// Octant with x > 0, y < 0, z < 0.
        case pnn
        /// Octant with x < 0, y > 0, z > 0.
        case npp
        /// Octant with x < 0, y > 0, z < 0.
        case npn
        /// Octant with x < 0, y < 0, z > 0.
        case nnp
        /// Octant with x < 0, y < 0, z < 0.
        case nnn
    }
}

// MARK: - Opposite

extension Region.Octant {
    /// Opposite octant (reflection through origin, flipping all axis signs).
    @inlinable
    public static func opposite(of octant: Region.Octant) -> Region.Octant {
        switch octant {
        case .ppp: return .nnn
        case .ppn: return .nnp
        case .pnp: return .npn
        case .pnn: return .npp
        case .npp: return .pnn
        case .npn: return .pnp
        case .nnp: return .ppn
        case .nnn: return .ppp
        }
    }

    /// Opposite octant (reflection through origin, flipping all axis signs).
    @inlinable
    public var opposite: Region.Octant {
        Region.Octant.opposite(of: self)
    }

    /// Returns the opposite octant (origin reflection).
    @inlinable
    public static prefix func ! (value: Region.Octant) -> Region.Octant {
        Region.Octant.opposite(of: value)
    }
}

// MARK: - Sign Properties

extension Region.Octant {
    /// Whether x is positive in this octant.
    @inlinable
    public static func hasPositiveX(_ octant: Region.Octant) -> Bool {
        switch octant {
        case .ppp, .ppn, .pnp, .pnn: return true
        case .npp, .npn, .nnp, .nnn: return false
        }
    }

    /// Whether x is positive in this octant.
    @inlinable
    public var hasPositiveX: Bool {
        Region.Octant.hasPositiveX(self)
    }

    /// Whether y is positive in this octant.
    @inlinable
    public static func hasPositiveY(_ octant: Region.Octant) -> Bool {
        switch octant {
        case .ppp, .ppn, .npp, .npn: return true
        case .pnp, .pnn, .nnp, .nnn: return false
        }
    }

    /// Whether y is positive in this octant.
    @inlinable
    public var hasPositiveY: Bool {
        Region.Octant.hasPositiveY(self)
    }

    /// Whether z is positive in this octant.
    @inlinable
    public static func hasPositiveZ(_ octant: Region.Octant) -> Bool {
        switch octant {
        case .ppp, .pnp, .npp, .nnp: return true
        case .ppn, .pnn, .npn, .nnn: return false
        }
    }

    /// Whether z is positive in this octant.
    @inlinable
    public var hasPositiveZ: Bool {
        Region.Octant.hasPositiveZ(self)
    }
}

// MARK: - Paired Value

extension Region.Octant {
    /// A value paired with its octant.
    public typealias Value<Payload> = Pair<Region.Octant, Payload>
}
