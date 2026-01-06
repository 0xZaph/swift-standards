// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-standards open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-standards project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Collections.Dictionary.Ordered {
    /// Typed error for ordered dictionary operations.
    ///
    /// Uses typed throws for compile-time exhaustiveness.
    public enum Error: Swift.Error {
        /// An index was out of bounds.
        case bounds(Collections.Error.Bounds)

        /// An operation was attempted on an empty dictionary.
        case empty(Collections.Error.Empty)

        /// A duplicate key was detected during initialization.
        case duplicate(Duplicate)
    }
}

// MARK: - Duplicate Payload

extension Collections.Dictionary.Ordered.Error {
    /// Duplicate key payload.
    ///
    /// Data-only struct carrying information about a duplicate key.
    /// Does **not** conform to `Swift.Error`.
    public struct Duplicate {
        /// The duplicate key.
        public let key: Key

        /// Index of the first occurrence.
        public let first: Int

        /// Index where the duplicate was found.
        public let second: Int

        @inlinable
        public init(key: Key, first: Int, second: Int) {
            self.key = key
            self.first = first
            self.second = second
        }
    }
}

// MARK: - Sendable

extension Collections.Dictionary.Ordered.Error: Sendable where Key: Sendable {}
extension Collections.Dictionary.Ordered.Error.Duplicate: Sendable where Key: Sendable {}

// MARK: - Equatable

extension Collections.Dictionary.Ordered.Error: Equatable where Key: Equatable {}
extension Collections.Dictionary.Ordered.Error.Duplicate: Equatable where Key: Equatable {}

// MARK: - CustomStringConvertible

extension Collections.Dictionary.Ordered.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bounds(let e): return e.description
        case .empty(let e): return e.description
        case .duplicate(let e): return e.description
        }
    }
}

extension Collections.Dictionary.Ordered.Error.Duplicate: CustomStringConvertible {
    public var description: String {
        "duplicate key '\(key)' at indices \(first) and \(second)"
    }
}
