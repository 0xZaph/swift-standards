// AffineTransform+Real.swift
// Rotation extensions using angles for Real types.

public import RealModule

extension Geometry.AffineTransform where Unit: Real {
    /// Create a rotation transform from an angle in radians
    @inlinable
    public static func rotation(_ angle: Geometry.Radian) -> Self {
        rotation(cos: angle.cos, sin: angle.sin)
    }

    /// Create a rotation transform from an angle in degrees
    @inlinable
    public static func rotation(_ angle: Geometry.Degree) -> Self {
        rotation(angle.radians)
    }

    /// Return a new transform with rotation applied
    @inlinable
    public func rotated(by angle: Geometry.Radian) -> Self {
        rotated(cos: angle.cos, sin: angle.sin)
    }

    /// Return a new transform with rotation applied
    @inlinable
    public func rotated(by angle: Geometry.Degree) -> Self {
        rotated(by: angle.radians)
    }
}
