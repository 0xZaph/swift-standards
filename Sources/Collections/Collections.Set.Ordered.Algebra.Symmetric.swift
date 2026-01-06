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

extension Collections.Set.Ordered.Algebra {
    /// Namespace for symmetric set operations.
    public struct Symmetric {
        @usableFromInline
        let set: Collections.Set.Ordered<Element>

        @usableFromInline
        init(set: Collections.Set.Ordered<Element>) {
            self.set = set
        }
    }
}

// MARK: - Symmetric Operations

extension Collections.Set.Ordered.Algebra.Symmetric {
    /// Returns a new set with elements in either set, but not both.
    ///
    /// Elements from `self` come first in their original order,
    /// followed by elements from `other` that are not in `self`.
    ///
    /// - Parameter other: The other set.
    /// - Returns: A new set with elements in exactly one of the sets.
    /// - Complexity: O(n + m) where n and m are the sizes of the sets.
    @inlinable
    public func difference(_ other: Collections.Set.Ordered<Element>) -> Collections.Set.Ordered<Element> {
        var result = Collections.Set.Ordered<Element>()

        // Elements in self but not in other
        for element in set {
            if !other.contains(element) {
                result.insert(element)
            }
        }

        // Elements in other but not in self
        for element in other {
            if !set.contains(element) {
                result.insert(element)
            }
        }

        return result
    }
}
