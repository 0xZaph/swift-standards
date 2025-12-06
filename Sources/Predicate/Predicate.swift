// Predicate.swift
// A composable boolean test on values of type T.

/// A predicate that tests whether values of type `T` satisfy a condition.
///
/// Predicates are composable boolean functions. They can be combined using
/// logical operators to build complex conditions from simple ones.
///
/// ## Creating Predicates
///
/// ```swift
/// let isEven = Predicate<Int> { $0 % 2 == 0 }
/// let isPositive = Predicate<Int> { $0 > 0 }
/// ```
///
/// ## Evaluating Predicates
///
/// Predicates are callable, so you can use them like functions:
///
/// ```swift
/// isEven(4)      // true
/// isEven(3)      // false
/// ```
///
/// ## Composing Predicates
///
/// Use logical operators or fluent methods:
///
/// ```swift
/// // Operators
/// let isEvenAndPositive = isEven && isPositive
/// let isEvenOrPositive = isEven || isPositive
/// let isOdd = !isEven
///
/// // Fluent methods
/// let isEvenAndPositive = isEven.and(isPositive)
/// let isOdd = isEven.negated
/// ```
///
/// ## Use Cases
///
/// - **Filtering**: `array.filter(isEven.and(isPositive).evaluate)`
/// - **Validation**: `let isValid = isNotEmpty.and(isValidEmail)`
/// - **Access control**: `let canEdit = isOwner.or(isAdmin)`
/// - **Search**: `let matches = query.and(inDateRange)`
///
/// ## Mathematical Properties
///
/// Predicates form a Boolean algebra under `and`, `or`, and `negated`:
///
/// - **Identity**: `p.and(.always) ≡ p`, `p.or(.never) ≡ p`
/// - **Annihilation**: `p.and(.never) ≡ .never`, `p.or(.always) ≡ .always`
/// - **Idempotence**: `p.and(p) ≡ p`, `p.or(p) ≡ p`
/// - **Complement**: `p.and(p.negated) ≡ .never`, `p.or(p.negated) ≡ .always`
/// - **Double negation**: `p.negated.negated ≡ p`
/// - **De Morgan**: `!(p && q) ≡ !p || !q`, `!(p || q) ≡ !p && !q`
/// - **Distributivity**: `p && (q || r) ≡ (p && q) || (p && r)`
public struct Predicate<T>: @unchecked Sendable {
    /// The underlying evaluation function.
    public var evaluate: (T) -> Bool

    /// Creates a predicate from an evaluation closure.
    ///
    /// - Parameter evaluate: A closure that returns `true` if the value satisfies the condition.
    @inlinable
    public init(_ evaluate: @escaping (T) -> Bool) {
        self.evaluate = evaluate
    }
}

// MARK: - Call as Function

extension Predicate {
    /// Evaluates the predicate on a value.
    ///
    /// This allows predicates to be used like functions:
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// isEven(4)  // true
    /// ```
    @inlinable
    public func callAsFunction(_ value: T) -> Bool {
        evaluate(value)
    }
}

// MARK: - Constants

extension Predicate {
    /// A predicate that always returns `true`.
    ///
    /// This is the identity element for `and`:
    /// ```swift
    /// p.and(.always) ≡ p
    /// ```
    @inlinable
    public static var always: Predicate {
        Predicate { _ in true }
    }

    /// A predicate that always returns `false`.
    ///
    /// This is the identity element for `or`:
    /// ```swift
    /// p.or(.never) ≡ p
    /// ```
    @inlinable
    public static var never: Predicate {
        Predicate { _ in false }
    }
}

// MARK: - Negation

extension Predicate {
    /// The negation of this predicate.
    ///
    /// Returns a predicate that returns `true` when this predicate returns `false`,
    /// and vice versa.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isOdd = isEven.negated
    /// isOdd(3)  // true
    /// ```
    @inlinable
    public var negated: Predicate {
        Predicate { self.evaluate($0) == false }
    }

    /// Returns the negation of the predicate.
    @inlinable
    public static prefix func ! (predicate: Predicate) -> Predicate {
        predicate.negated
    }
}

// MARK: - Conjunction (AND)

extension Predicate {
    /// Combines this predicate with another using logical AND.
    ///
    /// The resulting predicate returns `true` only if both predicates return `true`.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    /// let isEvenAndPositive = isEven.and(isPositive)
    /// isEvenAndPositive(4)   // true
    /// isEvenAndPositive(-4)  // false
    /// ```
    @inlinable
    public func and(_ other: Predicate) -> Predicate {
        Predicate { self.evaluate($0) && other.evaluate($0) }
    }

    /// Combines two predicates using logical AND.
    @inlinable
    public static func && (lhs: Predicate, rhs: Predicate) -> Predicate {
        lhs.and(rhs)
    }
}

// MARK: - Disjunction (OR)

extension Predicate {
    /// Combines this predicate with another using logical OR.
    ///
    /// The resulting predicate returns `true` if either predicate returns `true`.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isNegative = Predicate<Int> { $0 < 0 }
    /// let isEvenOrNegative = isEven.or(isNegative)
    /// isEvenOrNegative(4)   // true
    /// isEvenOrNegative(-3)  // true
    /// isEvenOrNegative(3)   // false
    /// ```
    @inlinable
    public func or(_ other: Predicate) -> Predicate {
        Predicate { self.evaluate($0) || other.evaluate($0) }
    }

    /// Combines two predicates using logical OR.
    @inlinable
    public static func || (lhs: Predicate, rhs: Predicate) -> Predicate {
        lhs.or(rhs)
    }
}

// MARK: - Exclusive Or (XOR)

extension Predicate {
    /// Combines this predicate with another using logical XOR.
    ///
    /// The resulting predicate returns `true` if exactly one predicate returns `true`.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    /// let isEvenXorPositive = isEven.xor(isPositive)
    /// isEvenXorPositive(4)   // false (both true)
    /// isEvenXorPositive(3)   // true (positive only)
    /// isEvenXorPositive(-4)  // true (even only)
    /// ```
    @inlinable
    public func xor(_ other: Predicate) -> Predicate {
        Predicate { self.evaluate($0) != other.evaluate($0) }
    }

    /// Combines two predicates using logical XOR.
    @inlinable
    public static func ^ (lhs: Predicate, rhs: Predicate) -> Predicate {
        lhs.xor(rhs)
    }
}

// MARK: - NAND / NOR

extension Predicate {
    /// Combines this predicate with another using logical NAND.
    ///
    /// Equivalent to `self.and(other).negated`.
    @inlinable
    public func nand(_ other: Predicate) -> Predicate {
        self.and(other).negated
    }

    /// Combines this predicate with another using logical NOR.
    ///
    /// Equivalent to `self.or(other).negated`.
    @inlinable
    public func nor(_ other: Predicate) -> Predicate {
        self.or(other).negated
    }
}

// MARK: - Implication

extension Predicate {
    /// Creates a predicate representing logical implication.
    ///
    /// `self.implies(other)` is equivalent to `!self || other`.
    /// Returns `true` unless `self` is `true` and `other` is `false`.
    ///
    /// ```swift
    /// let hasPermission = isAdmin.implies(canDelete)
    /// // If admin, must be able to delete; non-admins always pass
    /// ```
    @inlinable
    public func implies(_ other: Predicate) -> Predicate {
        self.negated.or(other)
    }

    /// Creates a predicate representing logical biconditional (if and only if).
    ///
    /// Returns `true` when both predicates have the same truth value.
    /// Equivalent to `!(self.xor(other))`.
    @inlinable
    public func iff(_ other: Predicate) -> Predicate {
        self.xor(other).negated
    }
}

// MARK: - Contravariant Mapping

extension Predicate {
    /// Transforms a predicate to work on a different input type.
    ///
    /// Given a function from `U` to `T`, creates a predicate on `U`
    /// by first applying the transformation.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let hasEvenLength = isEven.pullback(\.count)
    /// hasEvenLength("hi")    // true (count 2)
    /// hasEvenLength("hello") // false (count 5)
    /// ```
    ///
    /// - Parameter transform: A function that transforms `U` values to `T` values.
    /// - Returns: A predicate that tests `U` values.
    @inlinable
    public func pullback<U>(_ transform: @escaping (U) -> T) -> Predicate<U> {
        Predicate<U> { self.evaluate(transform($0)) }
    }

    /// Transforms a predicate using a key path.
    ///
    /// ```swift
    /// let isLong = Predicate<Int> { $0 > 10 }
    /// let hasLongName = isLong.pullback(\User.name.count)
    /// ```
    @inlinable
    public func pullback<U>(_ keyPath: KeyPath<U, T>) -> Predicate<U> {
        pullback { $0[keyPath: keyPath] }
    }
}

// MARK: - Convenience Factories

extension Predicate where T: Equatable {
    /// Creates a predicate that tests for equality with a value.
    ///
    /// ```swift
    /// let isZero = Predicate<Int>.equals(0)
    /// isZero(0)  // true
    /// isZero(1)  // false
    /// ```
    @inlinable
    public static func equals(_ value: T) -> Predicate {
        Predicate { $0 == value }
    }

    /// Creates a predicate that tests for inequality with a value.
    @inlinable
    public static func notEquals(_ value: T) -> Predicate {
        Predicate { $0 != value }
    }

    /// Creates a predicate that tests membership in a collection.
    ///
    /// ```swift
    /// let isVowel = Predicate<Character>.isIn("aeiou")
    /// isVowel("a")  // true
    /// isVowel("b")  // false
    /// ```
    @inlinable
    public static func isIn<C: Collection>(_ collection: C) -> Predicate where C.Element == T {
        Predicate { collection.contains($0) }
    }
}

extension Predicate where T: Comparable {
    /// Creates a predicate that tests if a value is less than a threshold.
    @inlinable
    public static func lessThan(_ value: T) -> Predicate {
        Predicate { $0 < value }
    }

    /// Creates a predicate that tests if a value is less than or equal to a threshold.
    @inlinable
    public static func lessThanOrEqual(_ value: T) -> Predicate {
        Predicate { $0 <= value }
    }

    /// Creates a predicate that tests if a value is greater than a threshold.
    @inlinable
    public static func greaterThan(_ value: T) -> Predicate {
        Predicate { $0 > value }
    }

    /// Creates a predicate that tests if a value is greater than or equal to a threshold.
    @inlinable
    public static func greaterThanOrEqual(_ value: T) -> Predicate {
        Predicate { $0 >= value }
    }

    /// Creates a predicate that tests if a value is within a range.
    ///
    /// ```swift
    /// let isTeenager = Predicate<Int>.inRange(13...19)
    /// isTeenager(15)  // true
    /// isTeenager(25)  // false
    /// ```
    @inlinable
    public static func inRange(_ range: ClosedRange<T>) -> Predicate {
        Predicate { range.contains($0) }
    }

    /// Creates a predicate that tests if a value is within a half-open range.
    @inlinable
    public static func inRange(_ range: Range<T>) -> Predicate {
        Predicate { range.contains($0) }
    }
}

extension Predicate where T: Collection {
    /// A predicate that tests if a collection is empty.
    @inlinable
    public static var isEmpty: Predicate {
        Predicate { $0.isEmpty }
    }

    /// A predicate that tests if a collection is not empty.
    @inlinable
    public static var isNotEmpty: Predicate {
        Predicate { !$0.isEmpty }
    }

    /// Creates a predicate that tests if a collection has a specific count.
    @inlinable
    public static func hasCount(_ count: Int) -> Predicate {
        Predicate { $0.count == count }
    }
}

extension Predicate where T: StringProtocol {
    /// Creates a predicate that tests if a string contains a substring.
    @inlinable
    public static func contains<S: StringProtocol>(_ substring: S) -> Predicate {
        Predicate { $0.contains(substring) }
    }

    /// Creates a predicate that tests if a string has a prefix.
    @inlinable
    public static func hasPrefix<S: StringProtocol>(_ prefix: S) -> Predicate {
        Predicate { $0.hasPrefix(prefix) }
    }

    /// Creates a predicate that tests if a string has a suffix.
    @inlinable
    public static func hasSuffix<S: StringProtocol>(_ suffix: S) -> Predicate {
        Predicate { $0.hasSuffix(suffix) }
    }
}

// MARK: - Optional Predicates

extension Predicate {
    /// Creates a predicate on optional values that returns `true` for `nil`.
    ///
    /// ```swift
    /// let isNil = Predicate<Int?>.isNil
    /// isNil(nil)  // true
    /// isNil(42)   // false
    /// ```
    @inlinable
    public static var isNil: Predicate<T?> {
        Predicate<T?> { $0 == nil }
    }

    /// Creates a predicate on optional values that returns `true` for non-`nil`.
    @inlinable
    public static var isNotNil: Predicate<T?> {
        Predicate<T?> { $0 != nil }
    }

    /// Lifts this predicate to work on optional values.
    ///
    /// Returns `false` for `nil`, otherwise evaluates the wrapped value.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isEvenOrNil = isEven.optional(default: false)
    /// isEvenOrNil(4)    // true
    /// isEvenOrNil(nil)  // false
    /// ```
    @inlinable
    public func optional(default defaultValue: Bool) -> Predicate<T?> {
        Predicate<T?> { value in
            guard let value else { return defaultValue }
            return self.evaluate(value)
        }
    }
}

// MARK: - Quantifiers

extension Predicate {
    // MARK: Array Convenience Properties

    /// Creates a predicate that tests if all elements in an array satisfy this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let allEven = isEven.all
    /// allEven([2, 4, 6])  // true
    /// allEven([2, 3, 4])  // false
    /// ```
    ///
    /// For other sequence types, use the generic `all()` method.
    @inlinable
    public var all: Predicate<[T]> {
        Predicate<[T]> { $0.allSatisfy(self.evaluate) }
    }

    /// Creates a predicate that tests if any element in an array satisfies this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let anyEven = isEven.any
    /// anyEven([1, 2, 3])  // true
    /// anyEven([1, 3, 5])  // false
    /// ```
    ///
    /// For other sequence types, use the generic `any()` method.
    @inlinable
    public var any: Predicate<[T]> {
        Predicate<[T]> { $0.contains(where: self.evaluate) }
    }

    /// Creates a predicate that tests if no elements in an array satisfy this predicate.
    ///
    /// For other sequence types, use the generic `none()` method.
    @inlinable
    public var none: Predicate<[T]> {
        Predicate<[T]> { !$0.contains(where: self.evaluate) }
    }

    // MARK: Generic Sequence Methods

    /// Creates a predicate that tests if all elements in a sequence satisfy this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    ///
    /// // Works with any Sequence type
    /// isEven.forAll()(Set([2, 4, 6]))   // true
    /// isEven.forAll()(1...10)            // false
    /// ```
    @inlinable
    public func forAll<S: Sequence>() -> Predicate<S> where S.Element == T {
        Predicate<S> { $0.allSatisfy(self.evaluate) }
    }

    /// Creates a predicate that tests if any element in a sequence satisfies this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    ///
    /// // Works with any Sequence type
    /// isEven.forAny()(Set([1, 2, 3]))   // true
    /// isEven.forAny()(1...10)            // true
    /// ```
    @inlinable
    public func forAny<S: Sequence>() -> Predicate<S> where S.Element == T {
        Predicate<S> { $0.contains(where: self.evaluate) }
    }

    /// Creates a predicate that tests if no elements in a sequence satisfy this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    ///
    /// // Works with any Sequence type
    /// isEven.forNone()(Set([1, 3, 5]))  // true
    /// isEven.forNone()(1...10)           // false
    /// ```
    @inlinable
    public func forNone<S: Sequence>() -> Predicate<S> where S.Element == T {
        Predicate<S> { !$0.contains(where: self.evaluate) }
    }
}
