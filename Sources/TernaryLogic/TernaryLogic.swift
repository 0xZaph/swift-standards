/// Namespace for ternary (three-valued) logic types and operations.
///
/// Ternary logic extends classical boolean logic with a third value representing "unknown" or "indeterminate". Use this to handle computations where truth values may not be fully determined, such as database null handling, partial evaluations, or SQL-like three-valued logic.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = true
/// let b: Bool? = nil  // unknown
/// let result = a && b
/// // result = nil (unknown, because b is unknown)
/// ```
public enum TernaryLogic {}

// MARK: - Protocol

extension TernaryLogic {
    /// A type that represents three-valued (ternary) logic.
    ///
    /// Ternary logic extends classical boolean logic with a third value representing "unknown" or "indeterminate". Conforming types gain all Strong Kleene logic operators (`&&`, `||`, `!`, `^`, `!&&`, `!||`, `!^`) through protocol extensions, enabling SQL-like three-valued reasoning.
    ///
    /// ## Example
    ///
    /// ```swift
    /// enum Tribool: TernaryLogic.Protocol {
    ///     case yes, no, maybe
    ///
    ///     static var `true`: Tribool { .yes }
    ///     static var `false`: Tribool { .no }
    ///     static var unknown: Tribool { .maybe }
    ///
    ///     static func from(_ value: Tribool) -> Bool? {
    ///         switch value {
    ///         case .yes: true
    ///         case .no: false
    ///         case .maybe: nil
    ///         }
    ///     }
    ///
    ///     init(_ bool: Bool?) {
    ///         switch bool {
    ///         case true: self = .yes
    ///         case false: self = .no
    ///         case nil: self = .maybe
    ///         }
    ///     }
    /// }
    ///
    /// let a = Tribool.yes
    /// let b = Tribool.maybe
    /// let result = a && b
    /// // result = .maybe (unknown)
    /// ```
    public protocol `Protocol` {
        /// The true value.
        static var `true`: Self { get }

        /// The false value.
        static var `false`: Self { get }

        /// The unknown/indeterminate value.
        static var unknown: Self { get }

        /// Converts the ternary value to its optional Bool representation.
        static func from(_ self: Self) -> Bool?

        /// Creates a ternary value from an optional Bool.
        ///
        /// - Parameter bool: `true`, `false`, or `nil` for unknown.
        init(_ bool: Bool?)
    }
}

// MARK: - AND Operator

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic AND (static implementation).
    ///
    /// Returns `false` if either operand is `false` (short-circuits), `unknown` if either operand is `unknown` and neither is `false`, or `true` only if both operands are `true`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.and(true as Bool?, nil)
    /// // result = nil (unknown)
    /// ```
    @inlinable
    public static func and<T: TernaryLogic.`Protocol`>(
        _ lhs: T,
        _ rhs: @autoclosure () throws -> T
    ) rethrows -> T {
        if T.from(lhs) == false { return .false }
        let rhs = try rhs()
        if T.from(rhs) == false { return .false }
        if T.from(lhs) == nil || T.from(rhs) == nil { return .unknown }
        return .true
    }
}

/// Performs Strong Kleene three-valued logic AND.
///
/// Returns `false` if either operand is `false` (short-circuits), `unknown` if either operand is `unknown` and neither is `false`, or `true` only if both operands are `true`.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = true
/// let b: Bool? = nil
/// let result = a && b
/// // result = nil (unknown)
/// ```
@inlinable
public func && <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    try TernaryLogic.and(lhs, rhs())
}

// MARK: - OR Operator

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic OR (static implementation).
    ///
    /// Returns `true` if either operand is `true` (short-circuits), `unknown` if either operand is `unknown` and neither is `true`, or `false` only if both operands are `false`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.or(false as Bool?, nil)
    /// // result = nil (unknown)
    /// ```
    @inlinable
    public static func or<T: TernaryLogic.`Protocol`>(
        _ lhs: T,
        _ rhs: @autoclosure () throws -> T
    ) rethrows -> T {
        if T.from(lhs) == true { return .true }
        let rhs = try rhs()
        if T.from(rhs) == true { return .true }
        if T.from(lhs) == nil || T.from(rhs) == nil { return .unknown }
        return .false
    }
}

/// Performs Strong Kleene three-valued logic OR.
///
/// Returns `true` if either operand is `true` (short-circuits), `unknown` if either operand is `unknown` and neither is `true`, or `false` only if both operands are `false`.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = false
/// let b: Bool? = nil
/// let result = a || b
/// // result = nil (unknown)
/// ```
@inlinable
public func || <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    try TernaryLogic.or(lhs, rhs())
}

// MARK: - NOT Operator

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic NOT (static implementation).
    ///
    /// Returns `unknown` if the operand is `unknown`, otherwise returns the logical negation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.not(nil as Bool?)
    /// // result = nil (unknown)
    /// ```
    @inlinable
    public static func not<T: TernaryLogic.`Protocol`>(_ value: T) -> T {
        switch T.from(value) {
        case true: return .false
        case false: return .true
        case nil: return .unknown
        }
    }
}

/// Performs Strong Kleene three-valued logic NOT.
///
/// Returns `unknown` if the operand is `unknown`, otherwise returns the logical negation.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = nil
/// let result = !a
/// // result = nil (unknown)
/// ```
@inlinable
public prefix func ! <T: TernaryLogic.`Protocol`>(value: T) -> T {
    TernaryLogic.not(value)
}

// MARK: - XOR Operator

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic XOR (exclusive OR) (static implementation).
    ///
    /// Returns `unknown` if either operand is `unknown`, otherwise returns `true` if exactly one operand is `true`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.xor(true as Bool?, nil)
    /// // result = nil (unknown)
    /// ```
    @inlinable
    public static func xor<T: TernaryLogic.`Protocol`>(_ lhs: T, _ rhs: T) -> T {
        guard let l = T.from(lhs), let r = T.from(rhs) else { return .unknown }
        return l != r ? .true : .false
    }
}

/// Performs Strong Kleene three-valued logic XOR (exclusive OR).
///
/// Returns `unknown` if either operand is `unknown`, otherwise returns `true` if exactly one operand is `true`.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = true
/// let b: Bool? = nil
/// let result = a ^ b
/// // result = nil (unknown)
/// ```
@inlinable
public func ^ <T: TernaryLogic.`Protocol`>(lhs: T, rhs: T) -> T {
    TernaryLogic.xor(lhs, rhs)
}

// MARK: - NAND Operator

// Custom infix operator for NAND
infix operator !&& : LogicalConjunctionPrecedence

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic NAND (NOT AND) (static implementation).
    ///
    /// Returns the negation of the AND result.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.nand(true as Bool?, true)
    /// // result = false (negation of true AND true)
    /// ```
    @inlinable
    public static func nand<T: TernaryLogic.`Protocol`>(
        _ lhs: T,
        _ rhs: @autoclosure () throws -> T
    ) rethrows -> T {
        try not(and(lhs, rhs()))
    }
}

/// Performs Strong Kleene three-valued logic NAND (NOT AND).
///
/// Returns the negation of the AND result.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = true
/// let b: Bool? = true
/// let result = a !&& b
/// // result = false (negation of true AND true)
/// ```
@inlinable
public func !&& <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    try TernaryLogic.nand(lhs, rhs())
}

// MARK: - NOR Operator

// Custom infix operator for NOR
infix operator !|| : LogicalDisjunctionPrecedence

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic NOR (NOT OR) (static implementation).
    ///
    /// Returns the negation of the OR result.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.nor(false as Bool?, false)
    /// // result = true (negation of false OR false)
    /// ```
    @inlinable
    public static func nor<T: TernaryLogic.`Protocol`>(
        _ lhs: T,
        _ rhs: @autoclosure () throws -> T
    ) rethrows -> T {
        try not(or(lhs, rhs()))
    }
}

/// Performs Strong Kleene three-valued logic NOR (NOT OR).
///
/// Returns the negation of the OR result.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = false
/// let b: Bool? = false
/// let result = a !|| b
/// // result = true (negation of false OR false)
/// ```
@inlinable
public func !|| <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    try TernaryLogic.nor(lhs, rhs())
}

// MARK: - XNOR Operator

// Custom infix operator for XNOR
infix operator !^ : ComparisonPrecedence

extension TernaryLogic {
    /// Performs Strong Kleene three-valued logic XNOR (equivalence) (static implementation).
    ///
    /// Returns `unknown` if either operand is `unknown`, otherwise returns `true` if both operands have the same value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = TernaryLogic.xnor(true as Bool?, true)
    /// // result = true (both are true)
    /// ```
    @inlinable
    public static func xnor<T: TernaryLogic.`Protocol`>(_ lhs: T, _ rhs: T) -> T {
        guard let l = T.from(lhs), let r = T.from(rhs) else { return .unknown }
        return l == r ? .true : .false
    }
}

/// Performs Strong Kleene three-valued logic XNOR (equivalence).
///
/// Returns `unknown` if either operand is `unknown`, otherwise returns `true` if both operands have the same value.
///
/// ## Example
///
/// ```swift
/// let a: Bool? = true
/// let b: Bool? = true
/// let result = a !^ b
/// // result = true (both are true)
/// ```
@inlinable
public func !^ <T: TernaryLogic.`Protocol`>(lhs: T, rhs: T) -> T {
    TernaryLogic.xnor(lhs, rhs)
}
