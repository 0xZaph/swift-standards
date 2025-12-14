//
//  File.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 14/12/2025.
//
public import Algebra
public import Dimension

// MARK: - Vector × Scale (Uniform Scaling)

/// Scales a vector uniformly by a dimensionless scale factor.
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Linear<Scalar, Space>.Vector<N>,
    rhs: Scale<1, Scalar>
) -> Linear<Scalar, Space>.Vector<N> {
    var result = lhs.components
    for i in 0..<N {
        result[i] = lhs.components[i] * rhs.value
    }
    return Linear<Scalar, Space>.Vector<N>(result)
}

/// Scales a vector uniformly by a dimensionless scale factor (commutative).
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Scale<1, Scalar>,
    rhs: Linear<Scalar, Space>.Vector<N>
) -> Linear<Scalar, Space>.Vector<N> {
    var result = rhs.components
    for i in 0..<N {
        result[i] = lhs.value * rhs.components[i]
    }
    return Linear<Scalar, Space>.Vector<N>(result)
}

/// Divides a vector uniformly by a dimensionless scale factor.
@inlinable
public func / <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Linear<Scalar, Space>.Vector<N>,
    rhs: Scale<1, Scalar>
) -> Linear<Scalar, Space>.Vector<N> {
    var result = lhs.components
    for i in 0..<N {
        result[i] = lhs.components[i] / rhs.value
    }
    return Linear<Scalar, Space>.Vector<N>(result)
}
