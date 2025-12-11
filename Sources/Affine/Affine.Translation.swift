// Affine.Translation.swift
// A 2D translation (displacement) in an affine space.

public import Algebra
public import Algebra_Linear
public import Dimension

extension Affine {
    /// A 2D translation (displacement) in an affine space.
    ///
    /// Translation is parameterized by the scalar type because it represents
    /// an actual displacement in the coordinate system - unlike rotation or
    /// scale which are dimensionless.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let offset: Affine<Double>.Translation = .init(dx: 72, dy: 144)
    /// ```
    public struct Translation {
        /// Horizontal displacement
        public var dx: Linear<Scalar>.Dx

        /// Vertical displacement
        public var dy: Linear<Scalar>.Dy

        /// Create a translation with typed displacement components
        @inlinable
        public init(dx: Linear<Scalar>.Dx, dy: Linear<Scalar>.Dy) {
            self.dx = dx
            self.dy = dy
        }
    }
}

extension Affine.Translation: Sendable where Scalar: Sendable {}
extension Affine.Translation: Equatable where Scalar: Equatable {}
extension Affine.Translation: Hashable where Scalar: Hashable {}
extension Affine.Translation: Codable where Scalar: Codable {}

// MARK: - Convenience Initializers

extension Affine.Translation {
    /// Create a translation from raw scalar values
    @inlinable
    public init(dx: Scalar, dy: Scalar) {
        self.dx = Linear<Scalar>.Dx(dx)
        self.dy = Linear<Scalar>.Dy(dy)
    }

    /// Create a translation from a vector
    @inlinable
    public init(_ vector: Linear<Scalar>.Vector<2>) {
        self.dx = vector.dx
        self.dy = vector.dy
    }
}

// MARK: - Zero

extension Affine.Translation where Scalar: AdditiveArithmetic {
    /// Zero translation (no displacement)
    @inlinable
    public static var zero: Self {
        Self(dx: .zero, dy: .zero)
    }
}

// MARK: - AdditiveArithmetic

extension Affine.Translation: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
}

// MARK: - Negation

extension Affine.Translation where Scalar: SignedNumeric {
    /// Negate the translation
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(dx: -value.dx, dy: -value.dy)
    }
}

// MARK: - Conversion to Vector

extension Affine.Translation {
    /// Convert to a 2D vector
    @inlinable
    public var vector: Linear<Scalar>.Vector<2> {
        Linear<Scalar>.Vector(dx: dx, dy: dy)
    }
}
