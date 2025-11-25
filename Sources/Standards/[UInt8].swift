// [UInt8].swift
// swift-standards
//
// Pure Swift byte array utilities

extension [UInt8] {
    /// Byte order for multi-byte integer serialization
    public enum Endianness {
        case little
        case big
    }
}

// MARK: - Single Integer Serialization

extension [UInt8] {
    /// Creates a byte array from any fixed-width integer
    ///
    /// - Parameters:
    ///   - value: The integer value to convert
    ///   - endianness: Byte order for the output bytes (defaults to little-endian)
    ///
    /// Example:
    /// ```swift
    /// let int32Bytes = [UInt8](Int32(256), endianness: .little)  // [0, 1, 0, 0]
    /// let int32BytesBE = [UInt8](Int32(256), endianness: .big)   // [0, 0, 1, 0]
    /// let int8Bytes = [UInt8](Int8(42))                          // [42]
    /// ```
    public init<T: FixedWidthInteger>(_ value: T, endianness: Endianness = .little) {
        let converted: T
        switch endianness {
        case .little:
            converted = value.littleEndian
        case .big:
            converted = value.bigEndian
        }
        self = Swift.withUnsafeBytes(of: converted) { Array($0) }
    }
}

// MARK: - Collection Serialization

extension [UInt8] {
    /// Creates a byte array from a collection of fixed-width integers
    ///
    /// - Parameters:
    ///   - values: Collection of integers to convert
    ///   - endianness: Byte order for the output bytes (defaults to little-endian)
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8](serializing: [Int16(1), Int16(2)], endianness: .little)
    /// // [1, 0, 2, 0] (4 bytes total)
    ///
    /// let int32s: [Int32] = [256, 512]
    /// let serialized = [UInt8](serializing: int32s, endianness: .big)
    /// // [0, 0, 1, 0, 0, 0, 2, 0] (8 bytes total)
    /// ```
    public init<C: Collection>(serializing values: C, endianness: Endianness = .little)
    where C.Element: FixedWidthInteger {
        var result: [UInt8] = []
        result.reserveCapacity(values.count * MemoryLayout<C.Element>.size)
        for value in values {
            result.append(contentsOf: [UInt8](value, endianness: endianness))
        }
        self = result
    }
}

// MARK: - String Conversions
extension [UInt8] {
    /// Creates a byte array from a UTF-8 encoded string
    /// - Parameter string: The string to convert to UTF-8 bytes
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8](utf8: "Hello")  // [72, 101, 108, 108, 111]
    /// ```
    public init(utf8 string: some StringProtocol) {
        self = Array(string.utf8)
    }
}

// MARK: - Subsequence Search and Splitting
extension [UInt8] {
    /// Finds the first occurrence of a byte subsequence
    /// - Parameter needle: The byte sequence to search for
    /// - Returns: Index of the first occurrence, or nil if not found
    public func firstIndex(of needle: [UInt8]) -> Int? {
        guard !needle.isEmpty else { return startIndex }
        guard needle.count <= count else { return nil }

        for i in 0...(count - needle.count) {
            if self[i..<i + needle.count].elementsEqual(needle) {
                return i
            }
        }

        return nil
    }

    /// Finds the last occurrence of a byte subsequence
    /// - Parameter needle: The byte sequence to search for
    /// - Returns: Index of the last occurrence, or nil if not found
    public func lastIndex(of needle: [UInt8]) -> Int? {
        guard !needle.isEmpty else { return endIndex }
        guard needle.count <= count else { return nil }

        for i in stride(from: count - needle.count, through: 0, by: -1) {
            if self[i..<i + needle.count].elementsEqual(needle) {
                return i
            }
        }

        return nil
    }

    /// Checks if the byte array contains a subsequence
    /// - Parameter needle: The byte sequence to search for
    /// - Returns: True if the subsequence is found, false otherwise
    public func contains(_ needle: [UInt8]) -> Bool {
        firstIndex(of: needle) != nil
    }

    /// Splits the byte array at all occurrences of a delimiter sequence
    /// - Parameter separator: The byte sequence to split on
    /// - Returns: Array of byte arrays split at the delimiter
    public func split(separator: [UInt8]) -> [[UInt8]] {
        guard !separator.isEmpty else { return [self] }

        var result: [[UInt8]] = []
        var start = 0

        while start < count {
            // Check if there's enough bytes left for the separator
            guard start + separator.count <= count else {
                result.append(Array(self[start...]))
                break
            }

            // Search for separator starting from current position
            var found = false
            for i in start...(count - separator.count) where self[i..<i + separator.count].elementsEqual(separator) {
                result.append(Array(self[start..<i]))
                start = i + separator.count
                found = true
                break
            }

            if !found {
                result.append(Array(self[start...]))
                break
            }
        }

        return result
    }
}

// MARK: - Mutation Helpers
extension [UInt8] {
    /// Appends a UTF-8 string as bytes
    /// - Parameter string: The string to append as UTF-8 bytes
    public mutating func append(utf8 string: some StringProtocol) {
        append(contentsOf: string.utf8)
    }

    /// Appends a single byte
    /// - Parameter value: The byte value to append
    ///
    /// This overload exists to avoid ambiguity with the generic FixedWidthInteger method.
    /// For UInt8, we can append directly without endianness conversion.
    public mutating func append(_ value: UInt8) {
        append(contentsOf: CollectionOfOne(value))
    }

    /// Appends an integer as bytes with specified endianness
    /// - Parameters:
    ///   - value: The integer value to append
    ///   - endianness: Byte order for the serialized bytes (defaults to little-endian)
    public mutating func append<T: FixedWidthInteger>(
        _ value: T,
        endianness: Endianness = .little
    ) {
        append(contentsOf: value.bytes(endianness: endianness))
    }
}
