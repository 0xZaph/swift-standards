//
//  File.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 14/12/2025.
//

import Algebra_Linear
public import Dimension

// MARK: - Size × Scale

/// Scales a size uniformly by a dimensionless scale factor.
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] * rhs.value
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}

/// Scales a size uniformly by a dimensionless scale factor (commutative).
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Scale<1, Scalar>,
    rhs: Geometry<Scalar, Space>.Size<N>
) -> Geometry<Scalar, Space>.Size<N> {
    rhs * lhs
}

/// Divides a size uniformly by a dimensionless scale factor.
@inlinable
public func / <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<1, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] / rhs.value
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}

/// Scales a size per-dimension by a matching scale factor.
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<N, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] * rhs.factors[i]
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}

/// Scales a size per-dimension by a matching scale factor (commutative).
@inlinable
public func * <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Scale<N, Scalar>,
    rhs: Geometry<Scalar, Space>.Size<N>
) -> Geometry<Scalar, Space>.Size<N> {
    rhs * lhs
}

/// Divides a size per-dimension by a matching scale factor.
@inlinable
public func / <Scalar: FloatingPoint, Space, let N: Int>(
    lhs: Geometry<Scalar, Space>.Size<N>,
    rhs: Scale<N, Scalar>
) -> Geometry<Scalar, Space>.Size<N> {
    var result = lhs.dimensions
    for i in 0..<N {
        result[i] = lhs.dimensions[i] / rhs.factors[i]
    }
    return Geometry<Scalar, Space>.Size<N>(result)
}
