// Scale+Linear.swift
// Linear matrix conversion for Scale.

public import Algebra_Linear
public import Dimension

// MARK: - Conversion to Linear

extension Scale where N == 2, Scalar: ExpressibleByIntegerLiteral {
    /// Converts to a 2D linear transformation matrix.
    @inlinable
    public func linear<Space>() -> Linear<Scalar, Space>.Matrix<2, 2> {
        .init(a: x, b: 0, c: 0, d: y)
    }
}
