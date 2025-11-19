import Testing
import Formatting

// MARK: - Test Format Styles

fileprivate struct TestUppercaseStyle: Formatting {
    func format(_ value: String) -> String {
        value.uppercased()
    }
}

fileprivate struct TestIntToStringStyle: Formatting {
    func format(_ value: Int) -> String {
        "Number: \(value)"
    }
}

// MARK: - Tests

@Suite("Formatting Tests")
struct StyleTests {

    @Test("Style protocol conformance")
    func styleConformance() {
        let style = TestUppercaseStyle()
        let result = style.format("hello")
        #expect(result == "HELLO")
    }

    @Test("Style call as function")
    func callAsFunction() {
        let style = TestUppercaseStyle()
        let result = style("hello")
        #expect(result == "HELLO")
    }

    @Test("Style with different types")
    func differentTypes() {
        let style = TestIntToStringStyle()
        let result = style.format(42)
        #expect(result == "Number: 42")
    }
}
