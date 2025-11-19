import Testing
import Formatting

// MARK: - Test Parsers

fileprivate enum TestParseError: Error {
    case notUppercase
    case notNumeric
}

fileprivate struct TestLowercaseParser: Format.Parsing {
    func parse(_ value: String) throws -> String {
        guard value == value.uppercased() else {
            throw TestParseError.notUppercase
        }
        return value.lowercased()
    }
}

fileprivate struct TestIntParser: Format.Parsing {
    func parse(_ value: String) throws -> Int {
        guard let int = Int(value) else {
            throw TestParseError.notNumeric
        }
        return int
    }
}

// MARK: - Tests

@Suite("Format.Parsing Tests")
struct ParserTests {

    @Test("Parser protocol conformance")
    func parserConformance() throws {
        let parser = TestLowercaseParser()
        let result = try parser.parse("HELLO")
        #expect(result == "hello")
    }

    @Test("Parser parsing failure")
    func parserParsingFailure() {
        let parser = TestLowercaseParser()
        #expect(throws: TestParseError.self) {
            try parser.parse("hello")
        }
    }

    @Test("Int parsing with custom parser")
    func intParsing() throws {
        let parser = TestIntParser()
        let result = try parser.parse("42")
        #expect(result == 42)
    }

    @Test("Int parsing failure")
    func intParsingFailure() {
        let parser = TestIntParser()
        #expect(throws: TestParseError.self) {
            try parser.parse("not a number")
        }
    }

    @Test("Parser call as function")
    func callAsFunction() throws {
        let parser = TestLowercaseParser()
        let result = try parser("HELLO")
        #expect(result == "hello")
    }
}
