// Geometry+CoordinateArithmetic.swift
// Cross-type arithmetic between coordinates (X, Y) and dimensions (Width, Height)
// All operators are generic over Space to support different coordinate systems.

// MARK: - Y and Height Arithmetic

/// Y coordinate + Height → Y coordinate
/// Adding a height to a Y-coordinate moves the point up/down
@inlinable
public func + <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Y,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Y {
    Geometry<Scalar, Space>.Y(lhs.value + rhs.value)
}

/// Height + Y coordinate → Y coordinate
@inlinable
public func + <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Y
) -> Geometry<Scalar, Space>.Y {
    Geometry<Scalar, Space>.Y(lhs.value + rhs.value)
}

/// Y coordinate - Height → Y coordinate
/// Subtracting a height from a Y-coordinate moves the point down/up
@inlinable
public func - <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Y,
    rhs: Geometry<Scalar, Space>.Height
) -> Geometry<Scalar, Space>.Y {
    Geometry<Scalar, Space>.Y(lhs.value - rhs.value)
}

/// Height - Y coordinate → Y coordinate
/// Useful for coordinate system conversions (e.g., pageHeight - y)
@inlinable
public func - <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Height,
    rhs: Geometry<Scalar, Space>.Y
) -> Geometry<Scalar, Space>.Y {
    Geometry<Scalar, Space>.Y(lhs.value - rhs.value)
}

// MARK: - X and Width Arithmetic

/// X coordinate + Width → X coordinate
/// Adding a width to an X-coordinate moves the point right
@inlinable
public func + <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.X,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.X {
    Geometry<Scalar, Space>.X(lhs.value + rhs.value)
}

/// Width + X coordinate → X coordinate
@inlinable
public func + <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.X
) -> Geometry<Scalar, Space>.X {
    Geometry<Scalar, Space>.X(lhs.value + rhs.value)
}

/// X coordinate - Width → X coordinate
/// Subtracting a width from an X-coordinate moves the point left
@inlinable
public func - <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.X,
    rhs: Geometry<Scalar, Space>.Width
) -> Geometry<Scalar, Space>.X {
    Geometry<Scalar, Space>.X(lhs.value - rhs.value)
}

/// Width - X coordinate → X coordinate
@inlinable
public func - <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Width,
    rhs: Geometry<Scalar, Space>.X
) -> Geometry<Scalar, Space>.X {
    Geometry<Scalar, Space>.X(lhs.value - rhs.value)
}

// MARK: - Y and Y → Height (difference of coordinates)

/// Y coordinate - Y coordinate → Height (distance)
/// The difference of two Y-coordinates is a height/distance
@inlinable
public func - <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.Y,
    rhs: Geometry<Scalar, Space>.Y
) -> Geometry<Scalar, Space>.Height {
    Geometry<Scalar, Space>.Height(lhs.value - rhs.value)
}

// MARK: - X and X → Width (difference of coordinates)

/// X coordinate - X coordinate → Width (distance)
/// The difference of two X-coordinates is a width/distance
@inlinable
public func - <Space, Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar, Space>.X,
    rhs: Geometry<Scalar, Space>.X
) -> Geometry<Scalar, Space>.Width {
    Geometry<Scalar, Space>.Width(lhs.value - rhs.value)
}
