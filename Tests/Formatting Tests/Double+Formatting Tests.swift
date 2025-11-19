import Testing
import Formatting

// MARK: - Custom Test Styles

fileprivate struct DoubleRoundedStyle: Formatting {
    func format(_ value: Double) -> String {
        "\(Int(value.rounded()))"
    }
}

fileprivate struct DoubleSimpleStyle: Formatting {
    func format(_ value: Double) -> String {
        "\(value)"
    }
}

// MARK: - Tests

@Suite("Double+Formatting Tests")
struct DoubleFormattingTests {

    // MARK: - Custom Style Tests

    @Test("Double formatted with custom rounded style")
    func customRoundedFormatting() {
        let input = 3.14159
        let result = input.formatted(DoubleRoundedStyle())
        #expect(result == "3")
    }

    @Test("Double formatted with custom simple style")
    func customSimpleFormatting() {
        let input = 1.5
        let result = input.formatted(DoubleSimpleStyle())
        #expect(result == "1.5")
    }

    // MARK: - Fluent API Tests

    @Test("Double formatted with fluent percent style")
    func fluentPercent() {
        let input = 0.75
        let result = input.formatted(.percent)
        #expect(result == "75%")
    }

    @Test("Double formatted with fluent number style")
    func fluentNumber() {
        let input = 3.14159
        let result = input.formatted(.number)
        #expect(result == "3.14159")
    }

    @Test("Zero double with fluent percent style")
    func zeroFluentPercent() {
        let input = 0.0
        let result = input.formatted(.percent)
        #expect(result == "0%")
    }

    @Test("Negative double with fluent percent style")
    func negativeFluentPercent() {
        let input = -0.5
        let result = input.formatted(.percent)
        #expect(result == "-50%")
    }

    @Test("Full percent with fluent percent style")
    func fullFluentPercent() {
        let input = 1.0
        let result = input.formatted(.percent)
        #expect(result == "100%")
    }
}
