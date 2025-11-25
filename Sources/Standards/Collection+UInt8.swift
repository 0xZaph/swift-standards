//
//  Collection+UInt8.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

// MARK: - Byte Collection Trimming

extension Collection where Element == UInt8 {
    /// Trims bytes from both ends of a collection (authoritative implementation)
    ///
    /// - Parameters:
    ///   - bytes: The byte collection to trim
    ///   - predicate: A closure that returns `true` for bytes to trim
    /// - Returns: A subsequence with matching bytes trimmed from both ends
    ///
    /// This method returns a zero-copy view (SubSequence) of the original collection.
    ///
    /// Example:
    /// ```swift
    /// [UInt8].trimming([0x20, 0x48, 0x69, 0x20], where: { $0 == 0x20 })  // [0x48, 0x69]
    /// ```
    public static func trimming<C: Collection>(
        _ bytes: C,
        where predicate: (UInt8) -> Bool
    ) -> C.SubSequence where C.Element == UInt8 {
        var start = bytes.startIndex

        // Trim from start
        while start != bytes.endIndex, predicate(bytes[start]) {
            start = bytes.index(after: start)
        }

        // All bytes were trimmed
        if start == bytes.endIndex {
            return bytes[start..<start]
        }

        // Scan forward, remembering the last index that should NOT be trimmed
        var lastNonTrimIndex = start
        var i = start

        while i != bytes.endIndex {
            if !predicate(bytes[i]) {
                lastNonTrimIndex = i
            }
            i = bytes.index(after: i)
        }

        let end = bytes.index(after: lastNonTrimIndex)
        return bytes[start..<end]
    }

    /// Trims bytes from both ends of a collection
    ///
    /// Convenience overload that delegates to `trimming(_:where:)`.
    ///
    /// - Parameters:
    ///   - bytes: The byte collection to trim
    ///   - byteSet: The set of bytes to trim
    /// - Returns: A subsequence with the specified bytes trimmed from both ends
    ///
    /// Example:
    /// ```swift
    /// [UInt8].trimming([0x20, 0x48, 0x69, 0x20], of: [0x20])  // [0x48, 0x69]
    /// ```
    public static func trimming<C: Collection>(
        _ bytes: C,
        of byteSet: Set<UInt8>
    ) -> C.SubSequence where C.Element == UInt8 {
        trimming(bytes, where: byteSet.contains)
    }

    /// Trims bytes matching a predicate from both ends of the collection
    ///
    /// Delegates to the authoritative `Self.trimming(_:where:)` implementation.
    ///
    /// - Parameter predicate: A closure that returns `true` for bytes to trim
    /// - Returns: A subsequence with matching bytes trimmed from both ends
    ///
    /// Example:
    /// ```swift
    /// [0x20, 0x48, 0x69, 0x20].trimming(where: { $0 == 0x20 })  // [0x48, 0x69]
    /// bytes.trimming(where: { $0 < 0x21 })  // trim control chars and space
    /// ```
    public func trimming(where predicate: (UInt8) -> Bool) -> SubSequence {
        Self.trimming(self, where: predicate)
    }

    /// Trims bytes from both ends of the collection
    ///
    /// Delegates to the authoritative `Self.trimming(_:where:)` implementation.
    ///
    /// - Parameter byteSet: The set of bytes to trim
    /// - Returns: A subsequence with the specified bytes trimmed from both ends
    ///
    /// Example:
    /// ```swift
    /// [0x20, 0x48, 0x69, 0x20].trimming([0x20])  // [0x48, 0x69]
    /// bytes.trimming([0x20, 0x09, 0x0A, 0x0D])   // trim whitespace
    /// ```
    public func trimming(_ byteSet: Set<UInt8>) -> SubSequence {
        Self.trimming(self, of: byteSet)
    }
}
