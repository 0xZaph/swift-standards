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

extension Collections.Error {
    /// Empty collection payload.
    ///
    /// Indicates an operation was attempted on an empty collection.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// extension Deque {
    ///     public enum Error: Swift.Error {
    ///         case empty(Collections.Error.Empty)
    ///     }
    /// }
    /// ```
    public struct Empty: Sendable, Equatable {
        /// Creates an empty collection payload.
        @inlinable
        public init() {}
    }
}

// MARK: - CustomStringConvertible

extension Collections.Error.Empty: CustomStringConvertible {
    public var description: String {
        "operation attempted on empty collection"
    }
}
