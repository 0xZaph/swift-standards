import Testing
import Formatting

// MARK: - Custom Test Styles

fileprivate struct StringUppercaseStyle: Formatting {
    func format(_ value: String) -> String {
        value.uppercased()
    }
}

fileprivate struct StringLowercaseStyle: Formatting {
    func format(_ value: String) -> String {
        value.lowercased()
    }
}

fileprivate struct StringReverseStyle: Formatting {
    func format(_ value: String) -> String {
        String(value.reversed())
    }
}

// MARK: - Tests

@Suite("String+Formatting Tests")
struct StringFormattingTests {

    // MARK: - Custom Style Tests

    @Test("String formatted with custom uppercase style")
    func customUppercaseFormatting() {
        let input = "hello world"
        let result = input.formatted(StringUppercaseStyle())
        #expect(result == "HELLO WORLD")
    }

    @Test("String formatted with custom lowercase style")
    func customLowercaseFormatting() {
        let input = "HELLO WORLD"
        let result = input.formatted(StringLowercaseStyle())
        #expect(result == "hello world")
    }

    @Test("String formatted with custom reverse style")
    func customReverseFormatting() {
        let input = "hello"
        let result = input.formatted(StringReverseStyle())
        #expect(result == "olleh")
    }

    // MARK: - Fluent API Tests

    @Test("String formatted with fluent uppercased")
    func fluentUppercased() {
        let input = "hello world"
        let result = input.formatted(.uppercased)
        #expect(result == "HELLO WORLD")
    }

    @Test("String formatted with fluent lowercased")
    func fluentLowercased() {
        let input = "HELLO WORLD"
        let result = input.formatted(.lowercased)
        #expect(result == "hello world")
    }

    @Test("String formatted with fluent capitalized")
    func fluentCapitalized() {
        let input = "hello world"
        let result = input.formatted(.capitalized)
        #expect(result == "Hello World")
    }

    @Test("Empty string formatting with fluent API")
    func emptyStringFluentFormatting() {
        let input = ""
        let result = input.formatted(.uppercased)
        #expect(result == "")
    }
}
