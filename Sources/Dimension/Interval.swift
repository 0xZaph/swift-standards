// Interval.swift
// Namespace for bounded continuous intervals.

/// Namespace for type-safe bounded intervals.
///
/// Intervals represent continuous values constrained to specific ranges.
/// Unlike discrete types like `Ordinal<N>`, intervals contain uncountably
/// many values within their bounds.
///
/// ## Types
///
/// - ``Unit``: The closed unit interval [0, 1]
///
/// ## Example
///
/// ```swift
/// let opacity: Interval<Double>.Unit = .half
/// let faded = opacity * opacity  // Closed under multiplication
/// print(faded.complement)        // 1 - faded
/// ```
///
/// ## Type Aliases
///
/// For convenience, common intervals have top-level type aliases:
/// - `Opacity<Scalar>` = `Interval<Scalar>.Unit`
/// - `Alpha<Scalar>` = `Opacity<Scalar>`
public enum Interval<Scalar: ~Copyable>: ~Copyable {}

extension Interval: Copyable where Scalar: Copyable {}
extension Interval: Sendable where Scalar: Sendable {}
