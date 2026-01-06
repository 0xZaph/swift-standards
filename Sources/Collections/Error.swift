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

/// Namespace for shared collection error payloads.
///
/// These are data-only structs that carry structured error information.
/// They do not conform to `Swift.Error`; each collection defines its own
/// typed error enum that embeds these payloads.
public enum Collections {
    public enum Error {}
}
