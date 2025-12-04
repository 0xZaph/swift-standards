// Degree+Trigonometry.swift
// Trigonometric extensions for Degree using swift-numerics Real protocol.

public import RealModule

// MARK: - Degree → Radian Conversion

extension Geometry.Degree where Unit: Real {
    /// Convert degrees to radians
    @inlinable
    public var radians: Geometry<Unit>.Radian {
        Geometry<Unit>.Radian(value * Unit.pi / 180)
    }

    /// Sine of the angle
    @inlinable
    public var sin: Unit { radians.sin }

    /// Cosine of the angle
    @inlinable
    public var cos: Unit { radians.cos }

    /// Tangent of the angle
    @inlinable
    public var tan: Unit { radians.tan }
}

// MARK: - Constants

extension Geometry.Degree where Unit: Real {
    /// 90 degrees (right angle)
    @inlinable
    public static var rightAngle: Self { Self(90) }

    /// 180 degrees (straight angle)
    @inlinable
    public static var straight: Self { Self(180) }

    /// 360 degrees (full circle)
    @inlinable
    public static var fullCircle: Self { Self(360) }

    /// 45 degrees
    @inlinable
    public static var fortyFive: Self { Self(45) }

    /// 60 degrees
    @inlinable
    public static var sixty: Self { Self(60) }

    /// 30 degrees
    @inlinable
    public static var thirty: Self { Self(30) }
}
