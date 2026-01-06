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
    /// Capacity violation payload.
    ///
    /// Carries information about a capacity request that could not be satisfied.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// extension Collections.Deque {
    ///     public enum Error: Swift.Error {
    ///         case capacity(Collections.Error.Capacity)
    ///     }
    /// }
    /// ```
    public struct Capacity: Sendable, Equatable {
        /// The capacity that was requested.
        public let requested: Int

        /// The maximum capacity that can be provided.
        public let maximum: Int

        /// Creates a capacity violation payload.
        ///
        /// - Parameters:
        ///   - requested: The requested capacity.
        ///   - maximum: The maximum available capacity.
        @inlinable
        public init(requested: Int, maximum: Int) {
            self.requested = requested
            self.maximum = maximum
        }
    }
}

// MARK: - CustomStringConvertible

extension Collections.Error.Capacity: CustomStringConvertible {
    public var description: String {
        "requested capacity \(requested) exceeds maximum \(maximum)"
    }
}
