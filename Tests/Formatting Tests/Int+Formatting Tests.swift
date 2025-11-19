import Testing
import Formatting

// MARK: - Custom Test Styles

fileprivate struct IntThousandsStyle: Formatting {
    func format(_ value: Int) -> String {
        "\(value / 1000)k"
    }
}

fileprivate struct IntSignedStyle: Formatting {
    func format(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }
}

// MARK: - Tests

@Suite("Int+Formatting Tests")
struct IntFormattingTests {

    // MARK: - Custom Style Tests

    @Test("Int formatted with custom thousands style")
    func customThousandsFormatting() {
        let input = 5000
        let result = input.formatted(IntThousandsStyle())
        #expect(result == "5k")
    }

    @Test("Int formatted with custom signed style")
    func customSignedFormatting() {
        let input = 42
        let result = input.formatted(IntSignedStyle())
        #expect(result == "+42")
    }

    // MARK: - Fluent API Tests

    @Test("Int formatted with fluent number style")
    func fluentNumber() {
        let input = 42
        let result = input.formatted(.number)
        #expect(result == "42")
    }

    @Test("Int formatted with fluent hex style")
    func fluentHex() {
        let input = 255
        let result = input.formatted(.hex)
        #expect(result == "0xff")
    }

    @Test("Int formatted with fluent binary style")
    func fluentBinary() {
        let input = 7
        let result = input.formatted(.binary)
        #expect(result == "0b111")
    }

    @Test("Negative int with fluent number style")
    func negativeFluentNumber() {
        let input = -42
        let result = input.formatted(.number)
        #expect(result == "-42")
    }

    @Test("Zero int with fluent number style")
    func zeroFluentNumber() {
        let input = 0
        let result = input.formatted(.number)
        #expect(result == "0")
    }
}
