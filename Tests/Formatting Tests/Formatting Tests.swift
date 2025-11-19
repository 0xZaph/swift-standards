import Testing
import Formatting

@Suite("Formatting Tests")
struct FormattingTests {

    @Test("Format namespace exists")
    func formatNamespaceExists() {
        // This test verifies that the Format namespace is accessible
        let _: Format.Type = Format.self
        #expect(Bool(true))
    }
}
