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

extension Collections.Set.Ordered {
    /// Typed error for ordered set operations.
    ///
    /// Uses typed throws (`throws(Ordered.Error)`) for compile-time exhaustiveness.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// An index was out of bounds.
        case bounds(Collections.Error.Bounds)

        /// An operation was attempted on an empty set.
        case empty(Collections.Error.Empty)
    }
}

// MARK: - CustomStringConvertible

extension Collections.Set.Ordered.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bounds(let e): return e.description
        case .empty(let e): return e.description
        }
    }
}
