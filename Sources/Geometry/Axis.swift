// Axis.swift
// Axis direction conventions for coordinate systems.

/// Axis direction conventions for coordinate systems.
///
/// This is a dimensionless type (not parameterized by scalar) because
/// axis direction is independent of the coordinate unit type.
///
/// ## Structure
///
/// - `Axis.Vertical`: Y-axis direction (`.upward` or `.downward`)
/// - `Axis.Horizontal`: X-axis direction (`.rightward` or `.leftward`)
///
/// ## Usage
///
/// ```swift
/// let rect = rect.inset(by: insets, y: .upward)
/// ```
public enum Axis {}
