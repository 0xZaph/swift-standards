// Product.swift
// The n-ary cartesian product type.

/// The n-ary cartesian product of types.
///
/// `Product` represents the general cartesian product `A × B × C × ...`
/// using Swift's parameter packs. This is the categorical product in
/// the category of types.
///
/// ## Examples
///
/// ```swift
/// let pair = Product(1, "hello")           // Product<Int, String>
/// let triple = Product(1, "hello", true)   // Product<Int, String, Bool>
///
/// // Access values via the tuple
/// print(pair.values.0)    // 1
/// print(pair.values.1)    // "hello"
/// ```
///
/// ## Mathematical Background
///
/// In category theory, the product of objects A₁, A₂, ..., Aₙ is an
/// object P together with projection morphisms πᵢ: P → Aᵢ satisfying
/// the universal property: for any object X with morphisms fᵢ: X → Aᵢ,
/// there exists a unique morphism f: X → P such that πᵢ ∘ f = fᵢ.
///
/// For types, this is simply the tuple `(A₁, A₂, ..., Aₙ)`.
///
@dynamicMemberLookup
public struct Product<each Element> {
    /// The tuple of values.
    public var values: (repeat each Element)

    /// Creates a product from the given values.
    @inlinable
    public init(_ values: repeat each Element) {
        self.values = (repeat each values)
    }

    /// Provides direct access to tuple elements via key paths.
    ///
    /// This allows `product.0` instead of `product.values.0`.
    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<(repeat each Element), T>) -> T {
        values[keyPath: keyPath]
    }
}

// MARK: - Conditional Conformances

extension Product: Sendable where repeat each Element: Sendable {}

extension Product: Equatable where repeat each Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        func isEqual<T: Equatable>(_ l: T, _ r: T) -> Bool { l == r }

        for result in repeat isEqual(each lhs.values, each rhs.values) {
            if !result { return false }
        }
        return true
    }
}

extension Product: Hashable where repeat each Element: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        func hashElement<T: Hashable>(_ element: T, _ hasher: inout Hasher) {
            hasher.combine(element)
        }
        repeat hashElement(each values, &hasher)
    }
}

// Note: Codable conformance for parameter packs requires more complex handling
// and may not be directly expressible in current Swift.
