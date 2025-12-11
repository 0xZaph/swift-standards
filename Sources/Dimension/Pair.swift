// Pair.swift
// The binary cartesian product type.

/// A pair of two values.
///
/// `Pair` is the binary cartesian product `First × Second`. This is the
/// categorical product of two objects in the category of types.
///
/// ## Examples
///
/// ```swift
/// let point = Pair(3, 4)
/// print(point.first)   // 3
/// print(point.second)  // 4
///
/// // Transform the second component
/// let scaled = point.mapSecond { $0 * 2 }  // Pair(3, 8)
/// ```
///
/// ## Classifier Pattern
///
/// Many domain types pair a classifier with a value:
///
/// ```swift
/// // A parity paired with a value
/// typealias ParityValue<T> = Pair<Parity, T>
/// let even: ParityValue<Int> = Pair(.even, 42)
///
/// // A sign paired with a magnitude
/// typealias Signed<T> = Pair<Sign, T>
/// let negative: Signed<Double> = Pair(.negative, 3.14)
/// ```
///
/// ## Mathematical Background
///
/// In category theory, the product of two objects A and B is an object
/// A × B with projection morphisms π₁: A × B → A and π₂: A × B → B.
/// `Pair` is a bifunctor, covariant in both arguments.
///
public struct Pair<First, Second> {
    /// The first component.
    public var first: First

    /// The second component.
    public var second: Second

    /// Creates a pair from two values.
    @inlinable
    public init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }
}

// MARK: - Conditional Conformances

extension Pair: Sendable where First: Sendable, Second: Sendable {}
extension Pair: Equatable where First: Equatable, Second: Equatable {}
extension Pair: Hashable where First: Hashable, Second: Hashable {}
#if Codable
extension Pair: Codable where First: Codable, Second: Codable {}
#endif

// MARK: - Functor

extension Pair {
    /// Transform the second component while preserving the first.
    ///
    /// This is the functorial map for `Pair<First, _>`.
    @inlinable
    public func map<NewSecond>(
        _ transform: (Second) throws -> NewSecond
    ) rethrows -> Pair<First, NewSecond> {
        Pair<First, NewSecond>(first, try transform(second))
    }

    /// Transform the second component while preserving the first.
    ///
    /// Alias for `map(_:)` for clarity when both components might be transformed.
    @inlinable
    public func mapSecond<NewSecond>(
        _ transform: (Second) throws -> NewSecond
    ) rethrows -> Pair<First, NewSecond> {
        try map(transform)
    }

    /// Transform the first component while preserving the second.
    ///
    /// This is the functorial map for `Pair<_, Second>`.
    @inlinable
    public func mapFirst<NewFirst>(
        _ transform: (First) throws -> NewFirst
    ) rethrows -> Pair<NewFirst, Second> {
        Pair<NewFirst, Second>(try transform(first), second)
    }

    /// Transform both components.
    ///
    /// This is the bifunctorial map.
    @inlinable
    public func bimap<NewFirst, NewSecond>(
        first firstTransform: (First) throws -> NewFirst,
        second secondTransform: (Second) throws -> NewSecond
    ) rethrows -> Pair<NewFirst, NewSecond> {
        Pair<NewFirst, NewSecond>(
            try firstTransform(first),
            try secondTransform(second)
        )
    }
}

// MARK: - Swap

extension Pair {
    /// Returns the pair with components swapped.
    @inlinable
    public var swapped: Pair<Second, First> {
        Pair<Second, First>(second, first)
    }
}

// MARK: - Tuple Conversion

extension Pair {
    /// Creates a pair from a tuple.
    @inlinable
    public init(_ tuple: (First, Second)) {
        self.first = tuple.0
        self.second = tuple.1
    }

    /// The pair as a tuple.
    @inlinable
    public var tuple: (First, Second) {
        (first, second)
    }
}

// MARK: - Enumerable First Components

extension Pair where First: CaseIterable {
    /// All possible first components for this pair type.
    @inlinable
    public static var allFirsts: First.AllCases {
        First.allCases
    }
}
