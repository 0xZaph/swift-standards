// Dimension.swift
// Phantom types for coordinate dimensions and their semantic roles.
//
// This module provides type-safe phantom types for distinguishing:
// - Dimensions (X, Y, Z, W)
// - Roles (Coordinate vs Displacement)
//
// ## Mathematical Foundation
//
// In affine geometry:
// - **Coordinates** are components of points (positions in affine space)
// - **Displacements** are components of vectors (elements of vector space)
//
// These are fundamentally different: you can add displacements,
// but adding coordinates is meaningless.
//
// ## Usage
//
// Use with `Tagged` to create type-safe scalar wrappers:
//
// ```swift
// typealias XCoordinate = Tagged<Index.X.Coordinate, Double>
// typealias Width = Tagged<Index.X.Displacement, Double>
// ```

/// Phantom types for coordinate dimension indices and their semantic roles.
///
/// `Index` provides phantom types for the X, Y, Z, W dimensions, each with
/// `Coordinate` and `Displacement` subtypes to distinguish positions from vectors.
public enum Index {

    /// Phantom types for the X (horizontal) dimension.
    public enum X {
        /// Tag for X coordinates (horizontal position).
        public enum Coordinate {}
        /// Tag for X displacements (horizontal extent/change).
        public enum Displacement {}
    }

    /// Phantom types for the Y (vertical) dimension.
    public enum Y {
        /// Tag for Y coordinates (vertical position).
        public enum Coordinate {}
        /// Tag for Y displacements (vertical extent/change).
        public enum Displacement {}
    }

    /// Phantom types for the Z (depth) dimension.
    public enum Z {
        /// Tag for Z coordinates (depth position).
        public enum Coordinate {}
        /// Tag for Z displacements (depth extent/change).
        public enum Displacement {}
    }

    /// Phantom types for the W (homogeneous) dimension.
    public enum W {
        /// Tag for W coordinates.
        public enum Coordinate {}
        /// Tag for W displacements.
        public enum Displacement {}
    }

    /// Phantom type for scalar magnitudes (lengths, distances, radii).
    ///
    /// Unlike coordinates (positions) and displacements (directed extents),
    /// magnitudes are non-directional scalar quantities representing the
    /// "size" of something: vector norms, distances between points, radii, etc.
    public enum Magnitude {}
}
