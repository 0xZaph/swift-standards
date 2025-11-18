import Testing
@testable import Standards

// UInt8 Base64 and Hex encoding tests have been moved to swift-rfc-4648
// UInt8 ASCII tests have been moved to swift-incits-4-1986

// MARK: - String Conversion Tests

@Test("String to bytes conversion")
func testStringToBytes() {
    let string = "Hello, World!"
    let bytes = [UInt8](utf8: string)

    #expect(bytes == Array(string.utf8))
    #expect(bytes.count == 13)
}

@Test("Bytes to UTF-8 string conversion")
func testBytesToUTF8String() {
    let bytes: [UInt8] = [72, 101, 108, 108, 111]
    let string = String(bytes)

    #expect(string == "Hello")
}

// ASCII string validation tests have been moved to swift-incits-4-1986

// MARK: - Integer Deserialization Tests

@Test("Deserialize UInt32 little-endian")
func testDeserializeUInt32Little() {
    let bytes: [UInt8] = [0x78, 0x56, 0x34, 0x12]
    let value = UInt32(bytes: bytes, endianness: .little)

    #expect(value == 0x12345678)
}

@Test("Deserialize UInt32 big-endian")
func testDeserializeUInt32Big() {
    let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
    let value = UInt32(bytes: bytes, endianness: .big)

    #expect(value == 0x12345678)
}

@Test("Deserialize with wrong size returns nil")
func testDeserializeWrongSize() {
    let bytes: [UInt8] = [0x12, 0x34, 0x56]
    let value = UInt32(bytes: bytes)

    #expect(value == nil)
}

@Test("Roundtrip serialization and deserialization")
func testRoundtrip() {
    let original: UInt64 = 0x0123456789ABCDEF
    let bytes = original.bytes(endianness: .big)
    let deserialized = UInt64(bytes: bytes, endianness: .big)

    #expect(deserialized == original)
}

// MARK: - Subsequence Search Tests

@Test("Find subsequence at beginning")
func testFirstIndexAtBeginning() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [1, 2]

    #expect(bytes.firstIndex(of: needle) == 0)
}

@Test("Find subsequence in middle")
func testFirstIndexInMiddle() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [3, 4]

    #expect(bytes.firstIndex(of: needle) == 2)
}

@Test("Find subsequence at end")
func testFirstIndexAtEnd() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [4, 5]

    #expect(bytes.firstIndex(of: needle) == 3)
}

@Test("Subsequence not found returns nil")
func testFirstIndexNotFound() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [6, 7]

    #expect(bytes.firstIndex(of: needle) == nil)
}

@Test("Empty needle returns start index")
func testFirstIndexEmptyNeedle() {
    let bytes: [UInt8] = [1, 2, 3]
    let needle: [UInt8] = []

    #expect(bytes.firstIndex(of: needle) == 0)
}

// MARK: - Split Tests

@Test("Split on delimiter")
func testSplit() {
    let bytes: [UInt8] = [1, 2, 0, 3, 4, 0, 5]
    let parts = bytes.split(separator: [0])

    #expect(parts.count == 3)
    #expect(parts[0] == [1, 2])
    #expect(parts[1] == [3, 4])
    #expect(parts[2] == [5])
}

@Test("Split on multi-byte delimiter")
func testSplitMultiByte() {
    let bytes: [UInt8] = [1, 2, 255, 255, 3, 4, 255, 255, 5]
    let parts = bytes.split(separator: [255, 255])

    #expect(parts.count == 3)
    #expect(parts[0] == [1, 2])
    #expect(parts[1] == [3, 4])
    #expect(parts[2] == [5])
}

@Test("Split with empty separator returns original")
func testSplitEmptySeparator() {
    let bytes: [UInt8] = [1, 2, 3]
    let parts = bytes.split(separator: [])

    #expect(parts.count == 1)
    #expect(parts[0] == bytes)
}

@Test("Split CRLF delimiters")
func testSplitCRLF() {
    let bytes: [UInt8] = Array("Line1\r\nLine2\r\nLine3".utf8)
    let parts = bytes.split(separator: [UInt8](utf8: "\r\n"))

    #expect(parts.count == 3)
    #expect(String(parts[0]) == "Line1")
    #expect(String(parts[1]) == "Line2")
    #expect(String(parts[2]) == "Line3")
}

// MARK: - Mutation Helper Tests

@Test("Append UTF-8 string")
func testAppendUTF8() {
    var bytes: [UInt8] = [1, 2, 3]
    bytes.append(utf8: "Hi")

    #expect(bytes == [1, 2, 3, 72, 105])
}

@Test("Append integer with little-endian")
func testAppendIntegerLittle() {
    var bytes: [UInt8] = []
    bytes.append(UInt16(0x1234), endianness: .little)

    #expect(bytes == [0x34, 0x12])
}

@Test("Append integer with big-endian")
func testAppendIntegerBig() {
    var bytes: [UInt8] = []
    bytes.append(UInt32(0x12345678), endianness: .big)

    #expect(bytes == [0x12, 0x34, 0x56, 0x78])
}

@Test("Build complex byte sequence")
func testBuildSequence() {
    var bytes: [UInt8] = []
    bytes.append(utf8: "HTTP/1.1 ")
    bytes.append(UInt16(200), endianness: .big)
    bytes.append(utf8: " OK\r\n")

    let expected: [UInt8] = Array("HTTP/1.1 ".utf8) + [0x00, 0xC8] + Array(" OK\r\n".utf8)
    #expect(bytes == expected)
}
