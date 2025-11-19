import Testing
import Formatting

@Suite("Chaining Tests")
struct ChainingTests {

    // MARK: - String Chaining

    @Test("String chaining with prefix")
    func stringPrefix() {
        let input = "hello world"
        let result = input.formatted(.uppercased.prefix(5))
        #expect(result == "HELLO")
    }

    @Test("String chaining lowercased with prefix")
    func stringLowercasedPrefix() {
        let input = "HELLO WORLD"
        let result = input.formatted(.lowercased.prefix(5))
        #expect(result == "hello")
    }

    // MARK: - Int Chaining

    @Test("Int chaining with sign strategy")
    func intSignStrategy() {
        let input = 42
        let result = input.formatted(.number.sign(strategy: .always))
        #expect(result == "+42")
    }

    @Test("Int chaining negative with sign strategy")
    func intNegativeSignStrategy() {
        let input = -42
        let result = input.formatted(.number.sign(strategy: .always))
        #expect(result == "-42")
    }

    @Test("Int chaining hex with uppercase")
    func intHexUppercase() {
        let input = 255
        let result = input.formatted(.hex.uppercase())
        #expect(result == "0xFF")
    }

    @Test("Int chaining binary")
    func intBinary() {
        let input = 7
        let result = input.formatted(.binary)
        #expect(result == "0b111")
    }

    // MARK: - Double Chaining

    @Test("Double chaining percent with rounded")
    func doublePercentRounded() {
        let input = 0.755
        let result = input.formatted(.percent.rounded())
        #expect(result == "76%")
    }

    @Test("Double chaining percent with precision")
    func doublePercentPrecision() {
        let input = 0.12345
        let result = input.formatted(.percent.precision(2))
        #expect(result == "12.35%")
    }

    @Test("Double chaining number with rounded")
    func doubleNumberRounded() {
        let input = 3.7
        let result = input.formatted(.number.rounded())
        #expect(result == "4.0")
    }

    @Test("Double chaining number with precision")
    func doubleNumberPrecision() {
        let input = 3.14159
        let result = input.formatted(.number.precision(2))
        #expect(result == "3.14")
    }

    // MARK: - Array Chaining

    @Test("Array chaining list with custom separator")
    func arrayListSeparator() {
        let input = ["a", "b", "c"]
        let result = input.formatted(.list.separator("; "))
        #expect(result == "a; b; c")
    }

    @Test("Array chaining list with pipe separator")
    func arrayListPipeSeparator() {
        let input = ["a", "b", "c"]
        let result = input.formatted(.list.separator(" | "))
        #expect(result == "a | b | c")
    }

    @Test("Array chaining bullets with custom prefix")
    func arrayBulletsPrefix() {
        let input = ["first", "second", "third"]
        let result = input.formatted(.bullets.prefix("→ "))
        #expect(result == "→ first\n→ second\n→ third")
    }

    @Test("Array chaining bullets with dash prefix")
    func arrayBulletsDashPrefix() {
        let input = ["first", "second", "third"]
        let result = input.formatted(.bullets.prefix("- "))
        #expect(result == "- first\n- second\n- third")
    }
}
