//
//  Array+FixedWidthInteger.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

// MARK: - Byte Deserialization

extension Array where Element: FixedWidthInteger {
    /// Creates an array of integers from a flat byte collection (authoritative implementation)
    ///
    /// - Parameters:
    ///   - bytes: Collection of bytes representing multiple integers
    ///   - endianness: Byte order of the input bytes (defaults to little-endian)
    /// - Returns: Array of integers, or nil if byte count is not a multiple of integer size
    ///
    /// Example:
    /// ```swift
    /// // Deserialize 4 bytes into two UInt16 values (little-endian)
    /// let bytes: [UInt8] = [0x01, 0x00, 0x02, 0x00]
    /// let values = [UInt16](bytes: bytes)  // [1, 2]
    ///
    /// // Deserialize as big-endian
    /// let bigEndian = [UInt16](bytes: bytes, endianness: .big)  // [256, 512]
    ///
    /// // Works with any FixedWidthInteger type
    /// let int32s = [Int32](bytes: someBytes)
    /// let int64s = [Int64](bytes: someBytes)
    /// ```
    public init?<C: Collection>(bytes: C, endianness: [UInt8].Endianness = .little)
    where C.Element == UInt8 {
        let elementSize = MemoryLayout<Element>.size
        guard bytes.count % elementSize == 0 else { return nil }

        var result: [Element] = []
        result.reserveCapacity(bytes.count / elementSize)

        let byteArray: [UInt8] = .init(bytes)
        for i in stride(from: 0, to: byteArray.count, by: elementSize) {
            let chunk: [UInt8] = .init(byteArray[i..<i + elementSize])
            guard let element = Element(bytes: chunk, endianness: endianness) else {
                return nil
            }
            result.append(element)
        }

        self = result
    }
}
