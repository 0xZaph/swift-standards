// Tagged.swift
// A phantom-type wrapper for type-safe value distinction.

/// A value distinguished by a phantom type tag.
///
/// `Tagged` wraps a raw value with a phantom type parameter that exists
/// only at compile-time. This allows the type system to distinguish
/// otherwise identical types without runtime overhead.
///
/// ## Examples
///
/// ```swift
/// // Define phantom types for different ID domains
/// enum UserIDTag {}
/// enum OrderIDTag {}
///
/// typealias UserID = Tagged<UserIDTag, Int>
/// typealias OrderID = Tagged<OrderIDTag, Int>
///
/// let userId: UserID = Tagged(42)
/// let orderId: OrderID = Tagged(42)
///
/// // These are different types despite both wrapping Int:
/// // userId == orderId  // Compile error: cannot compare UserID with OrderID
/// ```
///
/// ## Use Cases
///
/// - **Type-safe identifiers**: Prevent mixing user IDs with order IDs
/// - **Units**: Distinguish meters from feet at the type level
/// - **Domain boundaries**: Mark validated vs unvalidated strings
///
/// ## Note
///
/// Unlike `Pair<Tag, Value>` which stores both components, `Tagged`
/// only stores the raw value. The tag is purely a compile-time marker
/// with zero runtime cost.
///
public struct Tagged<Tag, RawValue> {
    /// The underlying value.
    public var rawValue: RawValue

    /// Creates a tagged value.
    @inlinable
    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    /// Creates a tagged value.
    @inlinable
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// MARK: - Conditional Conformances

extension Tagged: Sendable where RawValue: Sendable {}
extension Tagged: Equatable where RawValue: Equatable {}
extension Tagged: Hashable where RawValue: Hashable {}
extension Tagged: Codable where RawValue: Codable {}
extension Tagged: Comparable where RawValue: Comparable {
    @inlinable
    public static func < (lhs: Tagged, rhs: Tagged) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Functor

extension Tagged {
    /// Transform the raw value while preserving the tag.
    ///
    /// This is the functorial map for `Tagged<Tag, _>`.
    @inlinable
    public func map<NewRawValue>(
        _ transform: (RawValue) throws -> NewRawValue
    ) rethrows -> Tagged<Tag, NewRawValue> {
        Tagged<Tag, NewRawValue>(try transform(rawValue))
    }

    /// Change the tag type while preserving the raw value.
    ///
    /// This is a zero-cost type conversion since the tag is phantom.
    @inlinable
    public func retag<NewTag>(_: NewTag.Type = NewTag.self) -> Tagged<NewTag, RawValue> {
        Tagged<NewTag, RawValue>(rawValue)
    }
}

// MARK: - ExpressibleBy Literals

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: RawValue.IntegerLiteralType) {
        self.rawValue = RawValue(integerLiteral: value)
    }
}

extension Tagged: ExpressibleByFloatLiteral where RawValue: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: RawValue.FloatLiteralType) {
        self.rawValue = RawValue(floatLiteral: value)
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
    @inlinable
    public init(unicodeScalarLiteral value: RawValue.UnicodeScalarLiteralType) {
        self.rawValue = RawValue(unicodeScalarLiteral: value)
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable
    public init(extendedGraphemeClusterLiteral value: RawValue.ExtendedGraphemeClusterLiteralType) {
        self.rawValue = RawValue(extendedGraphemeClusterLiteral: value)
    }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: RawValue.StringLiteralType) {
        self.rawValue = RawValue(stringLiteral: value)
    }
}

extension Tagged: ExpressibleByBooleanLiteral where RawValue: ExpressibleByBooleanLiteral {
    @inlinable
    public init(booleanLiteral value: RawValue.BooleanLiteralType) {
        self.rawValue = RawValue(booleanLiteral: value)
    }
}
