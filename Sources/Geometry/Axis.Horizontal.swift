// Axis.Horizontal.swift
// Horizontal (X) axis direction.

public import Dimension

extension Axis {
    /// Horizontal (X) axis orientation convention.
    ///
    /// Determines how "leading" and "trailing" map to x-coordinates:
    /// - `.rightward`: X increases rightward (standard convention)
    /// - `.leftward`: X increases leftward
    ///
    /// This is a coordinate system convention, independent of dimension count.
    public enum Horizontal: Sendable, Hashable, CaseIterable {
        /// X axis increases rightward (standard convention).
        case rightward

        /// X axis increases leftward.
        case leftward
    }
}
