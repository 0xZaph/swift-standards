// Geometry
//
// Universal geometric primitives parameterized by unit type.
//
// This module provides type-safe geometry primitives that can be
// specialized for different coordinate systems and measurement units.
//
// ## Types
//
// - `Point<Unit>`: A 2D coordinate (x, y)
// - `Size<Unit>`: Dimensions (width, height)
// - `Rectangle<Unit>`: A bounding box defined by corners
// - `Width<Unit>`: A horizontal measurement
// - `Height<Unit>`: A vertical measurement
// - `Length<Unit>`: A general linear measurement
//
// ## Usage
//
// Specialize these types with your unit type:
//
// ```swift
// struct Points: AdditiveArithmetic { ... }
//
// typealias Coordinate = Point<Points>
// typealias PageSize = Size<Points>
// typealias BoundingBox = Rectangle<Points>
// ```

/// The Geometry namespace for geometric primitives.
///
/// Supports both copyable and non-copyable unit types.
/// Types are conditionally `Copyable` when `Unit` is `Copyable`.
public enum Geometry<Unit: ~Copyable>: ~Copyable {}

extension Geometry: Copyable where Unit: Copyable {}
extension Geometry: Sendable where Unit: Sendable {}
