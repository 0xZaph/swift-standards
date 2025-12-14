//
//  File.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 14/12/2025.
//

// MARK: - Affine Arithmetic

extension Affine.Point where Scalar: AdditiveArithmetic {
    /// Computes displacement vector from `rhs` to `lhs`.
    ///
    /// Returns the vector representing the displacement needed to move from point `rhs` to point `lhs`.
    /// This fundamental affine operation converts position difference into directional displacement.
    ///
    /// ## Note
    ///
    /// Adding two points (`Point + Point`) is intentionally unsupported as it lacks geometric meaning.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let p = Affine<Double>.Point(x: 10, y: 20)
    /// let q = Affine<Double>.Point(x: 4, y: 8)
    /// let v = p - q  // Vector(dx: 6, dy: 12) — displacement from q to p
    /// ```
    @inlinable
    @_disfavoredOverload
    public static func - (
        lhs: borrowing Self,
        rhs: borrowing Self
    ) -> Linear<Scalar, Space>.Vector<N> {
        var result = InlineArray<N, Scalar>(repeating: lhs.coordinates[0] - rhs.coordinates[0])
        for i in 1..<N {
            result[i] = lhs.coordinates[i] - rhs.coordinates[i]
        }
        return Linear<Scalar, Space>.Vector(result)
    }

    /// Translates point by adding displacement vector.
    ///
    /// Fundamental affine operation moving a position by a directional displacement.
    @inlinable
    @_disfavoredOverload
    public static func + (
        lhs: borrowing Self,
        rhs: borrowing Linear<Scalar, Space>.Vector<N>
    ) -> Self {
        var result = lhs.coordinates
        for i in 0..<N {
            result[i] = lhs.coordinates[i] + rhs.components[i]
        }
        return Self(result)
    }

    /// Translates point by subtracting displacement vector.
    @inlinable
    @_disfavoredOverload
    public static func - (
        lhs: borrowing Self,
        rhs: borrowing Linear<Scalar, Space>.Vector<N>
    ) -> Self {
        var result = lhs.coordinates
        for i in 0..<N {
            result[i] = lhs.coordinates[i] - rhs.components[i]
        }
        return Self(result)
    }
}
