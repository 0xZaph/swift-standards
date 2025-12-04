// Radian+Degree.swift
// Conversion from Radian to Degree.

public import RealModule

extension Geometry.Radian where Unit: Real {
    /// Convert radians to degrees
    @inlinable
    public var degrees: Geometry<Unit>.Degree {
        Geometry<Unit>.Degree(value * 180 / Unit.pi)
    }
}
