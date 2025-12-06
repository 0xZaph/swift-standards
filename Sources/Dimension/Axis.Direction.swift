// Axis.Direction.swift
// Direction along an axis.

extension Axis {
    /// Direction along an axis (positive or negative).
    ///
    /// Represents the two possible directions along any axis,
    /// independent of coordinate system conventions and dimension count.
    /// This is the abstract notion of "which way" along an axis.
    ///
    /// ## Mathematical Background
    ///
    /// In a coordinate system, each axis has two directions:
    /// positive (increasing values) and negative (decreasing values).
    /// The semantic meaning of "positive" depends on the axis orientation
    /// convention (see `Axis.Vertical` and `Axis.Horizontal`).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let direction: Axis<2>.Direction = .positive
    /// let reversed = direction.opposite  // .negative
    /// ```
    public enum Direction: Sendable, Hashable, Codable, CaseIterable {
        /// Positive direction (increasing coordinate values).
        case positive

        /// Negative direction (decreasing coordinate values).
        case negative

        /// The opposite direction.
        @inlinable
        public var opposite: Direction {
            switch self {
            case .positive: return .negative
            case .negative: return .positive
            }
        }

        /// The sign multiplier for this direction.
        ///
        /// - `.positive` returns `1`
        /// - `.negative` returns `-1`
        @inlinable
        public var sign: Int {
            switch self {
            case .positive: return 1
            case .negative: return -1
            }
        }

        /// The sign multiplier as a Double.
        @inlinable
        public var signDouble: Double {
            switch self {
            case .positive: return 1.0
            case .negative: return -1.0
            }
        }
    }
}
