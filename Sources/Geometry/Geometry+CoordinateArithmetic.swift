// Geometry+CoordinateArithmetic.swift
// Cross-type arithmetic between coordinates (X, Y) and dimensions (Width, Height)

// MARK: - Y and Height Arithmetic

/// Y coordinate + Height → Y coordinate
/// Adding a height to a Y-coordinate moves the point up/down
@inlinable
public func + <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Y,
    rhs: Geometry<Scalar>.Height
) -> Geometry<Scalar>.Y {
    Geometry<Scalar>.Y(lhs.value + rhs.value)
}

/// Height + Y coordinate → Y coordinate
@inlinable
public func + <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Height,
    rhs: Geometry<Scalar>.Y
) -> Geometry<Scalar>.Y {
    Geometry<Scalar>.Y(lhs.value + rhs.value)
}

/// Y coordinate - Height → Y coordinate
/// Subtracting a height from a Y-coordinate moves the point down/up
@inlinable
public func - <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Y,
    rhs: Geometry<Scalar>.Height
) -> Geometry<Scalar>.Y {
    Geometry<Scalar>.Y(lhs.value - rhs.value)
}

/// Height - Y coordinate → Y coordinate
/// Useful for coordinate system conversions (e.g., pageHeight - y)
@inlinable
public func - <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Height,
    rhs: Geometry<Scalar>.Y
) -> Geometry<Scalar>.Y {
    Geometry<Scalar>.Y(lhs.value - rhs.value)
}

// MARK: - X and Width Arithmetic

/// X coordinate + Width → X coordinate
/// Adding a width to an X-coordinate moves the point right
@inlinable
public func + <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.X,
    rhs: Geometry<Scalar>.Width
) -> Geometry<Scalar>.X {
    Geometry<Scalar>.X(lhs.value + rhs.value)
}

/// Width + X coordinate → X coordinate
@inlinable
public func + <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Width,
    rhs: Geometry<Scalar>.X
) -> Geometry<Scalar>.X {
    Geometry<Scalar>.X(lhs.value + rhs.value)
}

/// X coordinate - Width → X coordinate
/// Subtracting a width from an X-coordinate moves the point left
@inlinable
public func - <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.X,
    rhs: Geometry<Scalar>.Width
) -> Geometry<Scalar>.X {
    Geometry<Scalar>.X(lhs.value - rhs.value)
}

/// Width - X coordinate → X coordinate
@inlinable
public func - <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Width,
    rhs: Geometry<Scalar>.X
) -> Geometry<Scalar>.X {
    Geometry<Scalar>.X(lhs.value - rhs.value)
}

// MARK: - Y and Y → Height (difference of coordinates)

/// Y coordinate - Y coordinate → Height (distance)
/// The difference of two Y-coordinates is a height/distance
@inlinable
public func - <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.Y,
    rhs: Geometry<Scalar>.Y
) -> Geometry<Scalar>.Height {
    Geometry<Scalar>.Height(lhs.value - rhs.value)
}

// MARK: - X and X → Width (difference of coordinates)

/// X coordinate - X coordinate → Width (distance)
/// The difference of two X-coordinates is a width/distance
@inlinable
public func - <Scalar: AdditiveArithmetic>(
    lhs: Geometry<Scalar>.X,
    rhs: Geometry<Scalar>.X
) -> Geometry<Scalar>.Width {
    Geometry<Scalar>.Width(lhs.value - rhs.value)
}
