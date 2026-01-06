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
    /// Bounds violation payload.
    ///
    /// Data-only struct carrying information about an index out of valid range.
    /// Does **not** conform to `Swift.Error`; only per-type error enums are throwable.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// extension Deque {
    ///     public enum Error: Swift.Error {
    ///         case bounds(Collections.Error.Bounds)
    ///     }
    /// }
    /// ```
    public struct Bounds: Sendable, Equatable {
        /// The invalid index that was accessed.
        public let index: Int

        /// The valid count at the time of access.
        public let count: Int

        /// Creates a bounds violation payload.
        ///
        /// - Parameters:
        ///   - index: The invalid index.
        ///   - count: The valid count.
        @inlinable
        public init(index: Int, count: Int) {
            self.index = index
            self.count = count
        }
    }
}

// MARK: - CustomStringConvertible

extension Collections.Error.Bounds: CustomStringConvertible {
    public var description: String {
        "index \(index) out of bounds for count \(count)"
    }
}
