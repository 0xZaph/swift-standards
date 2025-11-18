// FixedWidthInteger.swift
// swift-standards
//
// Extensions for Swift standard library FixedWidthInteger protocol

extension FixedWidthInteger {
    /// Rotates bits left by specified count
    ///
    /// Circular left shift preserving all bits.
    /// Distinct from left shift which fills with zeros.
    ///
    /// Category theory: Automorphism in cyclic group of bit positions
    /// rotateLeft: ℤ/nℤ → ℤ/nℤ where n = bitWidth
    ///
    /// Example:
    /// ```swift
    /// let x: UInt8 = 0b11010011
    /// x.rotateLeft(by: 2)  // 0b01001111
    /// ```
    public func rotateLeft(by count: Int) -> Self {
        let shift = count % Self.bitWidth
        guard shift != 0 else { return self }

        return (self << shift) | (self >> (Self.bitWidth - shift))
    }

    /// Rotates bits right by specified count
    ///
    /// Circular right shift preserving all bits.
    /// Distinct from right shift which fills with sign or zeros.
    ///
    /// Category theory: Inverse of rotateLeft in cyclic group
    /// rotateRight: ℤ/nℤ → ℤ/nℤ where rotateRight(k) = rotateLeft(-k)
    ///
    /// Example:
    /// ```swift
    /// let x: UInt8 = 0b11010011
    /// x.rotateRight(by: 2)  // 0b11110100
    /// ```
    public func rotateRight(by count: Int) -> Self {
        let shift = count % Self.bitWidth
        guard shift != 0 else { return self }

        return (self >> shift) | (self << (Self.bitWidth - shift))
    }

    /// Reverses all bits
    ///
    /// Reflection operation inverting bit order.
    /// Useful in FFT algorithms, cryptography, and binary protocols.
    ///
    /// Category theory: Involution (self-inverse) reverseBits ∘ reverseBits = id
    ///
    /// Example:
    /// ```swift
    /// let x: UInt8 = 0b11010011
    /// x.reverseBits()  // 0b11001011
    /// ```
    public func reverseBits() -> Self {
        var result: Self = 0
        var value = self

        for _ in 0..<Self.bitWidth {
            result <<= 1
            result |= value & 1
            value >>= 1
        }

        return result
    }

    /// Converts to byte array with specified endianness
    ///
    /// Serializes integer to bytes respecting byte order.
    /// Enables portable binary representation.
    ///
    /// Category theory: Homomorphism from integer ring to byte sequences
    /// bytes: ℤ → Seq(UInt8) preserving arithmetic under deserialization
    ///
    /// Example:
    /// ```swift
    /// let x: UInt16 = 0x1234
    /// x.bytes(endianness: .big)     // [0x12, 0x34]
    /// x.bytes(endianness: .little)  // [0x34, 0x12]
    /// ```
    public func bytes(endianness: [UInt8].Endianness = .little) -> [UInt8] {
        let converted: Self
        switch endianness {
        case .little:
            converted = self.littleEndian
        case .big:
            converted = self.bigEndian
        }

        return Swift.withUnsafeBytes(of: converted) { Array($0) }
    }

    /// Creates an integer from byte array with specified endianness
    ///
    /// Deserializes bytes to integer respecting byte order.
    /// Inverse operation of bytes(endianness:).
    ///
    /// Category theory: Inverse homomorphism from byte sequences to integers
    /// init(bytes:endianness:): Seq(UInt8) → ℤ, inverse of bytes(endianness:)
    ///
    /// Example:
    /// ```swift
    /// let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
    /// let value = UInt32(bytes: bytes, endianness: .big)  // 0x12345678
    /// ```
    ///
    /// - Parameters:
    ///   - bytes: Byte array to deserialize
    ///   - endianness: Byte order of the input bytes (defaults to little-endian)
    /// - Returns: Integer value, or nil if byte count doesn't match type size
    public init?(bytes: [UInt8], endianness: [UInt8].Endianness = .little) {
        guard bytes.count == MemoryLayout<Self>.size else { return nil }

        let value = bytes.withUnsafeBytes { $0.load(as: Self.self) }

        switch endianness {
        case .little:
            self = Self(littleEndian: value)
        case .big:
            self = Self(bigEndian: value)
        }
    }
}
