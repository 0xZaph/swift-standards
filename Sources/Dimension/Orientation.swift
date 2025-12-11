// Orientation.swift
// The abstract theory of binary orientation.

/// A type with exactly two values that are opposites of each other.
///
/// `Orientation` captures the abstract structure shared by all binary
/// orientation types: `Direction`, `Horizontal`, `Vertical`, `Depth`,
/// and `Temporal`. Mathematically, any `Orientation` is isomorphic to:
/// - `Bool` (true/false)
/// - Z/2Z (integers mod 2)
/// - The multiplicative group {-1, +1}
/// - The finite set 2 = {0, 1}
///
/// ## The Theory
///
/// An orientation type has exactly two inhabitants that are each other's
/// opposite. This gives us:
/// - `opposite`: The other value
/// - `!`: Prefix negation operator (alias for opposite)
/// - Involution law: `x.opposite.opposite == x`
///
/// ## Relationship to Direction
///
/// `Direction` is the **canonical** orientation - it represents pure
/// polarity without domain-specific interpretation. Other orientations
/// interpret Direction in specific contexts:
/// - `Horizontal`: positive → rightward, negative → leftward
/// - `Vertical`: positive → upward, negative → downward
/// - `Depth`: positive → forward, negative → backward
/// - `Temporal`: positive → future, negative → past
///
/// All orientations can convert to/from `Direction`, making the
/// isomorphism explicit.
///
/// ## Category Theory
///
/// This protocol defines a **theory** (in the sense of categorical
/// semantics). Conforming types are **models** of this theory.
/// `Direction` is the **initial model** (free algebra), while the
/// struct-based orientations are models with additional semantic meaning.
///
public protocol Orientation: Sendable, Hashable, CaseIterable where AllCases == [Self] {
    /// The opposite orientation.
    ///
    /// This is an involution: `x.opposite.opposite == x`
    var opposite: Self { get }

    /// The underlying canonical direction.
    ///
    /// This makes the isomorphism `Self ≅ Direction` explicit.
    var direction: Direction { get }

    /// Creates an orientation from a canonical direction.
    ///
    /// This is the inverse of `direction`, completing the isomorphism.
    init(direction: Direction)
}

// MARK: - Default Implementations

extension Orientation {
    /// Returns the opposite orientation.
    ///
    /// Uses the `!` prefix operator, mirroring `Bool` negation.
    @inlinable
    public static prefix func ! (value: Self) -> Self {
        value.opposite
    }

    /// All cases, derived from Direction's cases.
    @inlinable
    public static var allCases: [Self] {
        Direction.allCases.map { Self(direction: $0) }
    }
}

// MARK: - Generic Operations

extension Orientation {
    /// Returns `positive` if the condition is true, `negative` otherwise.
    ///
    /// This is the isomorphism `Bool → Orientation`.
    @inlinable
    public init(_ condition: Bool) {
        self.init(direction: condition ? Direction.positive : Direction.negative)
    }

    /// Whether this is the "positive" orientation.
    @inlinable
    public var isPositive: Bool {
        direction == Direction.positive
    }

    /// Whether this is the "negative" orientation.
    @inlinable
    public var isNegative: Bool {
        direction == Direction.negative
    }
}

/// A value paired with an orientation.
///
/// `Oriented` is a specialization of `Pair` for orientation types.
/// Access the orientation via `.0` and the scalar via `.1`.
///
/// ## Usage
///
/// ```swift
/// let velocity: Oriented<Vertical, Double> = Product(.upward, 9.8)
/// print(velocity.0)  // .upward
/// print(velocity.1)  // 9.8
/// ```
///
public typealias Oriented<O: Orientation, Scalar> = Pair<O, Scalar>

extension Orientation {
    public typealias Value<Scalar> = Oriented<Self, Scalar>
}
