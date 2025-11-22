// StringProtocol.swift
// swift-standards
//
// Pure Swift StringProtocol utilities

// MARK: - Case Formatting

extension StringProtocol {
    /// Formats the string using the specified case transformation
    /// - Parameter case: The case format to apply
    /// - Returns: Formatted string
    ///
    /// Example:
    /// ```swift
    /// "hello world".formatted(as: .upper)  // "HELLO WORLD"
    /// "hello world".formatted(as: .title)  // "Hello World"
    /// let sub = "hello world"[...]; sub.formatted(as: .upper)  // Works on Substring too
    /// ```
    public func formatted(as case: String.Case) -> String {
        `case`.transform(String(self))
    }
}

// MARK: - String Search Operations

extension StringProtocol {
    /// Finds the range of the first occurrence of a given string
    ///
    /// Foundation-free implementation for finding substrings.
    /// Works with both String and Substring for zero-copy operations.
    ///
    /// - Parameter string: The string to search for
    /// - Returns: Range of the first occurrence, or nil if not found
    ///
    /// Example:
    /// ```swift
    /// "Hello World".range(of: "World")  // Range at position 6
    /// "test".range(of: "xyz")           // nil
    ///
    /// // Works with Substring (zero-copy)
    /// let sub = "Hello World"[...]
    /// sub.range(of: "World")            // Range in Substring
    /// ```
    public func range(of string: some StringProtocol) -> Range<Index>? {
        guard !string.isEmpty else { return startIndex..<startIndex }
        guard string.count <= count else { return nil }

        let searchChars = Array(string)

        var searchIndex = startIndex
        while searchIndex < endIndex {
            let remainingDistance = distance(from: searchIndex, to: endIndex)
            guard remainingDistance >= string.count else { break }

            var matchIndex = searchIndex
            var patternIndex = searchChars.startIndex

            // Try to match the pattern starting at searchIndex
            while patternIndex < searchChars.endIndex {
                if self[matchIndex] != searchChars[patternIndex] {
                    break
                }
                matchIndex = index(after: matchIndex)
                patternIndex = searchChars.index(after: patternIndex)
            }

            // If we matched the entire pattern, return the range
            if patternIndex == searchChars.endIndex {
                let endIndex = index(searchIndex, offsetBy: string.count)
                return searchIndex..<endIndex
            }

            searchIndex = index(after: searchIndex)
        }

        return nil
    }
}
