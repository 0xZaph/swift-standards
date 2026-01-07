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

extension Stack where Element: ~Copyable {
    /// Errors that can occur during stack operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The requested capacity is invalid (negative).
        case invalidCapacity

        /// Memory allocation failed.
        case allocationFailed

        /// The stack is full.
        case overflow
    }
}
