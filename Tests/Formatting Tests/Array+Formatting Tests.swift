import Testing
import Formatting

// MARK: - Custom Test Styles

fileprivate struct ArrayNumberedListStyle: Formatting {
    func format(_ value: [String]) -> String {
        value.enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
    }
}

fileprivate struct ArrayIntSumStyle: Formatting {
    func format(_ value: [Int]) -> String {
        "Sum: \(value.reduce(0, +))"
    }
}

// MARK: - Tests

@Suite("Array+Formatting Tests")
struct ArrayFormattingTests {

    // MARK: - Custom Style Tests

    @Test("String array formatted with custom numbered list style")
    func customNumberedListFormatting() {
        let input = ["first", "second", "third"]
        let result = input.formatted(ArrayNumberedListStyle())
        #expect(result == "1. first\n2. second\n3. third")
    }

    @Test("Int array formatted with custom sum style")
    func customIntSumFormatting() {
        let input = [1, 2, 3, 4, 5]
        let result = input.formatted(ArrayIntSumStyle())
        #expect(result == "Sum: 15")
    }

    // MARK: - Fluent API Tests

    @Test("String array formatted with fluent list style")
    func fluentList() {
        let input = ["apple", "banana", "cherry"]
        let result = input.formatted(.list)
        #expect(result == "apple, banana, cherry")
    }

    @Test("String array formatted with fluent bullets style")
    func fluentBullets() {
        let input = ["first", "second", "third"]
        let result = input.formatted(.bullets)
        #expect(result == "• first\n• second\n• third")
    }

    @Test("Empty array with fluent list style")
    func emptyFluentList() {
        let input: [String] = []
        let result = input.formatted(.list)
        #expect(result == "")
    }

    @Test("Single element array with fluent list style")
    func singleElementFluentList() {
        let input = ["only"]
        let result = input.formatted(.list)
        #expect(result == "only")
    }

    @Test("Two element array with fluent list style")
    func twoElementFluentList() {
        let input = ["first", "second"]
        let result = input.formatted(.list)
        #expect(result == "first, second")
    }
}
