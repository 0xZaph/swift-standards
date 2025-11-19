import Testing
import Formatting

// MARK: - Test Reversible Styles

fileprivate enum TestParseError: Error {
    case notUppercase
}

fileprivate struct TestCaseInvertingStyle: Format.Reversible {
    func format(_ value: String) -> String {
        value.uppercased()
    }

    func parse(_ value: String) throws -> String {
        guard value == value.uppercased() else {
            throw TestParseError.notUppercase
        }
        return value.lowercased()
    }
}

fileprivate struct TestPrefixedStringStyle: Format.Reversible {
    func format(_ value: String) -> String {
        "PREFIX:\(value)"
    }

    func parse(_ value: String) throws -> String {
        guard value.hasPrefix("PREFIX:") else {
            throw TestParseError.notUppercase
        }
        return String(value.dropFirst(7))
    }
}

// MARK: - Tests

@Suite("Format.Reversible Tests")
struct ReversibleTests {

    @Test("Reversible formatting")
    func reversibleFormat() {
        let style = TestCaseInvertingStyle()
        let formatted = style.format("hello")
        #expect(formatted == "HELLO")
    }

    @Test("Reversible parsing")
    func reversibleParse() throws {
        let style = TestCaseInvertingStyle()
        let parsed = try style.parse("HELLO")
        #expect(parsed == "hello")
    }

    @Test("Round-trip conversion")
    func roundTrip() throws {
        let style = TestPrefixedStringStyle()
        let original = "hello"
        let formatted = style.format(original)
        #expect(formatted == "PREFIX:hello")
        let parsed = try style.parse(formatted)
        #expect(parsed == "hello")
    }

    @Test("Bidirectional conversion")
    func bidirectionalConversion() throws {
        let style = TestCaseInvertingStyle()

        // Format then parse
        let original = "hello"
        let formatted = style.format(original)
        #expect(formatted == "HELLO")

        let parsed = try style.parse(formatted)
        #expect(parsed == "hello")
    }
}
