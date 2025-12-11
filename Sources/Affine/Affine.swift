// Affine.swift
// Affine geometry namespace for affine spaces and transformations.
//
// This module provides type-safe affine geometry primitives.
// Types are parameterized by their scalar type (the field).
//
// ## Category Theory Perspective
//
// This module represents the category **Aff** of affine spaces:
// - Objects: Affine spaces (vector space + forgotten origin)
// - Morphisms: Affine maps (linear map + translation)
//
// Key distinction from Vect:
// - Vector spaces have a distinguished origin
// - Affine spaces have no canonical origin
// - Points in affine space can be translated by vectors
// - The difference of two points is a vector
//
// ## Types
//
// - `Point<N>`: A position in N-dimensional affine space
// - `X`, `Y`, `Z`: Type-safe coordinate functions (projections)
// - `Translation`: A displacement in affine space
// - `Transform`: An affine transformation (linear + translation)
//
// ## Usage
//
// ```swift
// typealias Point2D = Affine<Double>.Point<2>
//
// let p: Point2D = .init(x: 1, y: 2)
// let q: Point2D = .init(x: 4, y: 6)
// let v = q - p  // Linear<Double>.Vector<2>
// ```

public import Algebra
public import Dimension

/// The Affine namespace for affine space primitives.
///
/// Parameterized by the scalar type (field) used for coordinates.
/// Supports both copyable and non-copyable scalar types.
public enum Affine<Scalar: ~Copyable>: ~Copyable {}

extension Affine: Copyable where Scalar: Copyable {}
extension Affine: Sendable where Scalar: Sendable {}

// MARK: - Coordinate Type Aliases

extension Affine {
    /// A type-safe horizontal coordinate (x-position).
    ///
    /// Coordinates are point components, distinct from displacements.
    /// Use for horizontal positions or point X-components.
    public typealias X = Tagged<Index.X.Coordinate, Scalar>

    /// A type-safe vertical coordinate (y-position).
    ///
    /// Coordinates are point components, distinct from displacements.
    /// Use for vertical positions or point Y-components.
    public typealias Y = Tagged<Index.Y.Coordinate, Scalar>

    /// A type-safe depth coordinate (z-position).
    ///
    /// Coordinates are point components, distinct from displacements.
    /// Use for depth positions or point Z-components.
    public typealias Z = Tagged<Index.Z.Coordinate, Scalar>

    /// A type-safe homogeneous coordinate (w-position).
    ///
    /// Coordinates are point components, distinct from displacements.
    public typealias W = Tagged<Index.W.Coordinate, Scalar>
}
