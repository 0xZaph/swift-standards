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

extension Deque {
    /// Typed error for Deque operations.
    ///
    /// Uses typed throws (`throws(Deque.Error)`) for compile-time exhaustiveness.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     let element = try deque.pop()
    /// } catch .empty {
    ///     print("Deque was empty")
    /// } catch .bounds(let info) {
    ///     print("Index \(info.index) out of bounds")
    /// }
    /// ```
    public enum Error: Swift.Error, Sendable, Equatable {
        /// An operation was attempted on an empty deque.
        case empty(Collections.Error.Empty)

        /// An index was out of bounds.
        case bounds(Collections.Error.Bounds)

        /// A capacity request could not be satisfied.
        case capacity(Collections.Error.Capacity)
    }
}

// MARK: - CustomStringConvertible

extension Deque.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty(let e): return e.description
        case .bounds(let e): return e.description
        case .capacity(let e): return e.description
        }
    }
}
