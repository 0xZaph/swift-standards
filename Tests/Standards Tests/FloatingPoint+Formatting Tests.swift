import Testing
import Standards

@Suite("FloatingPoint+Formatting Tests")
struct FloatingPointFormattingTests {

    // MARK: - Percent Formatting

    @Test("Double formatted as percent")
    func doublePercent() {
        #expect(0.75.formatted(.percent) == "75.0%")
        #expect(0.5.formatted(.percent) == "50.0%")
        #expect(1.0.formatted(.percent) == "100.0%")
        #expect(0.0.formatted(.percent) == "0.0%")
    }

    @Test("Float formatted as percent")
    func floatPercent() {
        #expect(Float(0.75).formatted(.percent) == "75.0%")
        #expect(Float(0.5).formatted(.percent) == "50.0%")
        #expect(Float(1.0).formatted(.percent) == "100.0%")
    }

    @Test("Percent with rounding")
    func percentRounded() {
        #expect(0.755.formatted(.percent.rounded()) == "76.0%")
        #expect(0.745.formatted(.percent.rounded()) == "75.0%")
        #expect(0.5.formatted(.percent.rounded()) == "50.0%")
    }

    @Test("Percent with precision")
    func percentPrecision() {
        #expect(0.755.formatted(.percent.precision(2)) == "75.5%")
        #expect(0.1234.formatted(.percent.precision(1)) == "12.3%")
        #expect(0.5.formatted(.percent.precision(2)) == "50.0%")
    }

    @Test("Percent with rounding and precision")
    func percentRoundedAndPrecision() {
        #expect(0.755.formatted(.percent.rounded().precision(2)) == "76.0%")
        #expect(0.745.formatted(.percent.rounded().precision(2)) == "75.0%")
    }

    // MARK: - Edge Cases

    @Test("Very small values")
    func verySmallValues() {
        #expect(0.0001.formatted(.percent) == "0.01%")
        #expect(0.00001.formatted(.percent) == "0.001%")
    }

    @Test("Large values")
    func largeValues() {
        #expect(10.0.formatted(.percent) == "1000.0%")
        #expect(100.0.formatted(.percent) == "10000.0%")
    }

    @Test("Zero values")
    func zeroValues() {
        #expect(0.0.formatted(.percent) == "0.0%")
        #expect(0.0.formatted(.percent.rounded()) == "0.0%")
        #expect(0.0.formatted(.percent.precision(2)) == "0.0%")
    }

    @Test("Negative values")
    func negativeValues() {
        #expect((-0.5).formatted(.percent) == "-50.0%")
        #expect((-0.755).formatted(.percent.precision(2)) == "-75.5%")
        #expect((-0.25).formatted(.percent.rounded()) == "-25.0%")
    }

    // MARK: - Float Specific

    @Test("Float with precision")
    func floatPrecision() {
        #expect(Float(0.755).formatted(.percent.precision(2)) == "75.5%")
    }

    @Test("Float with rounding")
    func floatRounded() {
        #expect(Float(0.755).formatted(.percent.rounded()) == "76.0%")
    }
}
