// Affine.Point+Real.swift
// Polar coordinates and rotation for 2D points with Real scalar types.

import Algebra_Linear
public import Angle
public import Dimension
public import RealModule

// MARK: - Polar Coordinates

extension Affine.Point where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// Creates point at polar coordinates relative to origin.
    ///
    /// Converts polar coordinates `(r, θ)` to Cartesian coordinates `(x, y)`.
    @inlinable
    public static func polar(radius: Affine.Distance, angle: Radian) -> Self {
        let r = radius.value
        return Self(
            x: Affine.X(r * Scalar(angle.cos)),
            y: Affine.Y(r * Scalar(angle.sin))
        )
    }

    /// Angular direction from origin to this point in radians.
    @inlinable
    public var angle: Radian {
        .atan2(y: Double(y.value), x: Double(x.value))
    }

    /// Distance from origin to this point.
    @inlinable
    public var radius: Affine.Distance {
        .init(Scalar.sqrt(x.value * x.value + y.value * y.value))
    }
}

// MARK: - Rotation

extension Affine.Point where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// Rotates point counterclockwise around origin by specified angle.
    @inlinable
    public static func rotated(_ point: Self, by angle: Radian) -> Self {
        let c = Scalar(angle.cos)
        let s = Scalar(angle.sin)
        let px = point.x.value
        let py = point.y.value
        return Self(
            x: Affine.X(px * c - py * s),
            y: Affine.Y(px * s + py * c)
        )
    }

    /// Rotates point counterclockwise around origin by specified angle.
    @inlinable
    public func rotated(by angle: Radian) -> Self {
        Self.rotated(self, by: angle)
    }

    /// Rotates point counterclockwise around specified center by angle.
    @inlinable
    public static func rotated(_ point: Self, by angle: Radian, around center: Self) -> Self {
        let translated = Self(
            x: Affine.X(point.x.value - center.x.value),
            y: Affine.Y(point.y.value - center.y.value)
        )
        let rotated = Self.rotated(translated, by: angle)
        return Self(
            x: Affine.X(rotated.x.value + center.x.value),
            y: Affine.Y(rotated.y.value + center.y.value)
        )
    }

    /// Rotates point counterclockwise around specified center by angle.
    @inlinable
    public func rotated(by angle: Radian, around center: Self) -> Self {
        Self.rotated(self, by: angle, around: center)
    }

    /// Rotates point counterclockwise around origin by angle in degrees.
    @inlinable
    public static func rotated(_ point: Self, by angle: Degree) -> Self {
        rotated(point, by: angle.radians)
    }

    /// Rotates point counterclockwise around origin by angle in degrees.
    @inlinable
    public func rotated(by angle: Degree) -> Self {
        Self.rotated(self, by: angle)
    }

    /// Rotates point counterclockwise around specified center by angle in degrees.
    @inlinable
    public static func rotated(_ point: Self, by angle: Degree, around center: Self) -> Self {
        rotated(point, by: angle.radians, around: center)
    }

    /// Rotates point counterclockwise around specified center by angle in degrees.
    @inlinable
    public func rotated(by angle: Degree, around center: Self) -> Self {
        Self.rotated(self, by: angle, around: center)
    }
}
