import Testing
import Standards

@Suite("BinaryInteger+Formatting Tests")
struct BinaryIntegerFormattingTests {

    // MARK: - Hex Formatting

    @Test("Hex formatting")
    func hexFormatting() {
        #expect(255.formatted(.hex) == "0xff")
        #expect(0.formatted(.hex) == "0x0")
        #expect(16.formatted(.hex) == "0x10")
        #expect(UInt8(255).formatted(.hex) == "0xff")
    }

    @Test("Hex uppercase")
    func hexUppercase() {
        #expect(255.formatted(.hex.uppercase()) == "0xFF")
        #expect(16.formatted(.hex.uppercase()) == "0x10")
    }

    @Test("Hex with sign strategy")
    func hexWithSign() {
        #expect(42.formatted(.hex.sign(strategy: .always)) == "+0x2a")
        #expect((-42).formatted(.hex.sign(strategy: .always)) == "-0x2a")
    }

    // MARK: - Binary Formatting

    @Test("Binary formatting")
    func binaryFormatting() {
        #expect(5.formatted(.binary) == "0b101")
        #expect(0.formatted(.binary) == "0b0")
        #expect(42.formatted(.binary) == "0b101010")
        #expect(UInt8(255).formatted(.binary) == "0b11111111")
    }

    @Test("Binary with sign strategy")
    func binaryWithSign() {
        #expect(5.formatted(.binary.sign(strategy: .always)) == "+0b101")
        #expect((-5).formatted(.binary.sign(strategy: .always)) == "-0b101")
    }

    // MARK: - Octal Formatting

    @Test("Octal formatting")
    func octalFormatting() {
        #expect(8.formatted(.octal) == "0o10")
        #expect(0.formatted(.octal) == "0o0")
        #expect(64.formatted(.octal) == "0o100")
        #expect(UInt8(255).formatted(.octal) == "0o377")
    }

    @Test("Octal with sign strategy")
    func octalWithSign() {
        #expect(8.formatted(.octal.sign(strategy: .always)) == "+0o10")
        #expect((-8).formatted(.octal.sign(strategy: .always)) == "-0o10")
    }

    // MARK: - Different Integer Types

    @Test("Different integer types")
    func differentTypes() {
        #expect(Int8(127).formatted(.hex) == "0x7f")
        #expect(Int16(1000).formatted(.hex) == "0x3e8")
        #expect(Int32(100000).formatted(.hex) == "0x186a0")
        #expect(Int64(1000000).formatted(.hex) == "0xf4240")
        #expect(UInt(255).formatted(.hex) == "0xff")
        #expect(UInt16(65535).formatted(.hex) == "0xffff")
        #expect(UInt32(4294967295).formatted(.hex) == "0xffffffff")
    }
}
