// Linear.swift
// Linear algebra namespace for vector spaces and linear maps.
//
// This module provides type-safe linear algebra primitives.
// Types are parameterized by their scalar type (the field).
//
// ## Category Theory Perspective
//
// This module represents the category **Vect** of vector spaces:
// - Objects: Vector spaces (represented by `Vector<N>`)
// - Morphisms: Linear maps (represented by `Matrix<M, N>`)
//
// ## Types
//
// - `Vector<N>`: An N-dimensional vector (element of vector space)
// - `Matrix<M, N>`: An M×N matrix (linear map from N-dim to M-dim space)
// - `Dx`, `Dy`, `Dz`: Type-safe displacement components
//
// ## Usage
//
// ```swift
// typealias Vec3 = Linear<Double>.Vector<3>
// typealias Mat4 = Linear<Double>.Matrix4x4
//
// let v: Vec3 = .init(dx: 1, dy: 2, dz: 3)
// let m: Mat4 = .identity
// ```

public import Algebra
public import Dimension

/// The Linear namespace for vector space primitives.
///
/// Parameterized by the scalar type (field) used for coordinates.
/// Supports both copyable and non-copyable scalar types.
public enum Linear<Scalar: ~Copyable>: ~Copyable {}

extension Linear: Copyable where Scalar: Copyable {}
extension Linear: Sendable where Scalar: Sendable {}

// MARK: - Displacement Type Aliases

extension Linear {
    /// A type-safe horizontal displacement (vector X-component).
    ///
    /// Displacements are vector components, distinct from coordinates.
    /// Use for widths, horizontal changes, or vector X-components.
    public typealias Dx = Tagged<Index.X.Displacement, Scalar>

    /// A type-safe vertical displacement (vector Y-component).
    ///
    /// Displacements are vector components, distinct from coordinates.
    /// Use for heights, vertical changes, or vector Y-components.
    public typealias Dy = Tagged<Index.Y.Displacement, Scalar>

    /// A type-safe depth displacement (vector Z-component).
    ///
    /// Displacements are vector components, distinct from coordinates.
    /// Use for depths, Z-axis changes, or vector Z-components.
    public typealias Dz = Tagged<Index.Z.Displacement, Scalar>

    /// A type-safe homogeneous displacement (vector W-component).
    ///
    /// Displacements are vector components, distinct from coordinates.
    public typealias Dw = Tagged<Index.W.Displacement, Scalar>
}
