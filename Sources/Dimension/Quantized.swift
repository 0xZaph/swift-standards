// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

/// A coordinate space that defines discrete precision through quantization.
///
/// Quantized spaces ensure that all coordinates snap to a discrete grid,
/// eliminating floating-point precision artifacts at boundaries. This is
/// essential for rendering systems where adjacent elements must share
/// exact boundary values.
///
/// ## Mathematical Properties
///
/// For a quantized space with quantum `q`:
/// - All coordinates are multiples of `q`
/// - `quantize(x) = round(x / q) × q`
/// - Adjacent boundaries align exactly: if `a` and `b` are quantized,
///   then `a + (b - a) = b` with no floating-point error
///
/// ## Example
///
/// ```swift
/// enum PDFUserSpace: Quantized {
///     typealias Scalar = Double
///     static var quantum: Double { 0.01 }  // 1/100 point precision
/// }
/// ```
public protocol Quantized {
    associatedtype Scalar: BinaryFloatingPoint

    /// The smallest representable difference in this space.
    ///
    /// All coordinates and displacements are rounded to multiples of this value.
    static var quantum: Scalar { get }
}

extension Quantized {
    /// Quantizes a value to the nearest grid point in this space.
    @inlinable
    public static func quantize(_ value: Scalar) -> Scalar {
        (value / quantum).rounded() * quantum
    }

    /// Returns the quantum converted to the specified floating-point type.
    ///
    /// This enables quantized operators to work with any BinaryFloatingPoint scalar
    /// without requiring a same-type constraint between the operator's Scalar and Space.Scalar.
    @inlinable
    public static func quantum<T: BinaryFloatingPoint>(as type: T.Type) -> T {
        T(quantum)
    }
}

// MARK: - Tagged Quantization

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Creates a tagged value quantized to the given quantum.
    @inlinable
    public init(quantized rawValue: RawValue, quantum: RawValue) {
        self.rawValue = (rawValue / quantum).rounded() * quantum
    }
}

// MARK: - Quantized Coordinate/Displacement Arithmetic

// These operators are defined as static extension methods on Tagged.
// Swift prefers static methods over free functions in overload resolution,
// so these will be selected when Space: Quantized.

// MARK: X Coordinate + X Displacement

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Adds a displacement to an X coordinate in a quantized space.
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.X.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.X.Displacement<Space>, RawValue>
    ) -> Tagged<Index.X.Coordinate<Space>, RawValue> where Tag == Index.X.Coordinate<Space> {
        Tagged<Index.X.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts two X coordinates in a quantized space, returning a displacement.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.X.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.X.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.X.Displacement<Space>, RawValue> where Tag == Index.X.Coordinate<Space> {
        Tagged<Index.X.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts a displacement from an X coordinate in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.X.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.X.Displacement<Space>, RawValue>
    ) -> Tagged<Index.X.Coordinate<Space>, RawValue> where Tag == Index.X.Coordinate<Space> {
        Tagged<Index.X.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }
}

// MARK: X Displacement + X Coordinate

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Adds an X coordinate to a displacement in a quantized space (commutative).
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.X.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.X.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.X.Coordinate<Space>, RawValue> where Tag == Index.X.Displacement<Space> {
        Tagged<Index.X.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts an X coordinate from a displacement in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.X.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.X.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.X.Coordinate<Space>, RawValue> where Tag == Index.X.Displacement<Space> {
        Tagged<Index.X.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Adds two X displacements in a quantized space.
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.X.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.X.Displacement<Space>, RawValue>
    ) -> Tagged<Index.X.Displacement<Space>, RawValue> where Tag == Index.X.Displacement<Space> {
        Tagged<Index.X.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts two X displacements in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.X.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.X.Displacement<Space>, RawValue>
    ) -> Tagged<Index.X.Displacement<Space>, RawValue> where Tag == Index.X.Displacement<Space> {
        Tagged<Index.X.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }
}

// MARK: Y Coordinate + Y Displacement

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Adds a displacement to a Y coordinate in a quantized space.
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.Y.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.Y.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Y.Coordinate<Space>, RawValue> where Tag == Index.Y.Coordinate<Space> {
        Tagged<Index.Y.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts two Y coordinates in a quantized space, returning a displacement.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Y.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.Y.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.Y.Displacement<Space>, RawValue> where Tag == Index.Y.Coordinate<Space> {
        Tagged<Index.Y.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts a displacement from a Y coordinate in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Y.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.Y.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Y.Coordinate<Space>, RawValue> where Tag == Index.Y.Coordinate<Space> {
        Tagged<Index.Y.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }
}

// MARK: Y Displacement + Y Coordinate

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Adds a Y coordinate to a displacement in a quantized space (commutative).
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.Y.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Y.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.Y.Coordinate<Space>, RawValue> where Tag == Index.Y.Displacement<Space> {
        Tagged<Index.Y.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts a Y coordinate from a displacement in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Y.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Y.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.Y.Coordinate<Space>, RawValue> where Tag == Index.Y.Displacement<Space> {
        Tagged<Index.Y.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Adds two Y displacements in a quantized space.
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.Y.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Y.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Y.Displacement<Space>, RawValue> where Tag == Index.Y.Displacement<Space> {
        Tagged<Index.Y.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts two Y displacements in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Y.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Y.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Y.Displacement<Space>, RawValue> where Tag == Index.Y.Displacement<Space> {
        Tagged<Index.Y.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }
}

// MARK: Z Coordinate + Z Displacement

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Adds a displacement to a Z coordinate in a quantized space.
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.Z.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.Z.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Z.Coordinate<Space>, RawValue> where Tag == Index.Z.Coordinate<Space> {
        Tagged<Index.Z.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts two Z coordinates in a quantized space, returning a displacement.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Z.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.Z.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.Z.Displacement<Space>, RawValue> where Tag == Index.Z.Coordinate<Space> {
        Tagged<Index.Z.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts a displacement from a Z coordinate in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Z.Coordinate<Space>, RawValue>,
        rhs: Tagged<Index.Z.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Z.Coordinate<Space>, RawValue> where Tag == Index.Z.Coordinate<Space> {
        Tagged<Index.Z.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }
}

// MARK: Z Displacement + Z Coordinate

extension Tagged where RawValue: BinaryFloatingPoint {
    /// Adds a Z coordinate to a displacement in a quantized space (commutative).
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.Z.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Z.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.Z.Coordinate<Space>, RawValue> where Tag == Index.Z.Displacement<Space> {
        Tagged<Index.Z.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts a Z coordinate from a displacement in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Z.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Z.Coordinate<Space>, RawValue>
    ) -> Tagged<Index.Z.Coordinate<Space>, RawValue> where Tag == Index.Z.Displacement<Space> {
        Tagged<Index.Z.Coordinate<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Adds two Z displacements in a quantized space.
    @inlinable
    public static func + <Space: Quantized>(
        lhs: Tagged<Index.Z.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Z.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Z.Displacement<Space>, RawValue> where Tag == Index.Z.Displacement<Space> {
        Tagged<Index.Z.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue + rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }

    /// Subtracts two Z displacements in a quantized space.
    @inlinable
    public static func - <Space: Quantized>(
        lhs: Tagged<Index.Z.Displacement<Space>, RawValue>,
        rhs: Tagged<Index.Z.Displacement<Space>, RawValue>
    ) -> Tagged<Index.Z.Displacement<Space>, RawValue> where Tag == Index.Z.Displacement<Space> {
        Tagged<Index.Z.Displacement<Space>, RawValue>(
            quantized: lhs.rawValue - rhs.rawValue,
            quantum: Space.quantum(as: RawValue.self)
        )
    }
}
