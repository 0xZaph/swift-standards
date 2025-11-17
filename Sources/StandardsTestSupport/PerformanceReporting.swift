// PerformanceReporting.swift
// StandardsTestSupport
//
// Performance test reporting and formatting

import Foundation
import Standards

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension StandardsTestSupport {
    /// Print a performance measurement summary
    ///
    /// Example:
    /// ```swift
    /// let measurement = StandardsTestSupport.measure(iterations: 100) { operation() }
    /// StandardsTestSupport.printPerformance("Operation Name", measurement)
    /// ```
    public static func printPerformance(
        _ name: String,
        _ measurement: StandardsTestSupport.Performance.Measurement,
        allocations: [Int]? = nil
    ) {
        var output = """
            ⏱️ \(name)
               Iterations: \(measurement.durations.count)
               Min:        \(formatDuration(measurement.min))
               Median:     \(formatDuration(measurement.median))
               Mean:       \(formatDuration(measurement.mean))
               p95:        \(formatDuration(measurement.p95))
               p99:        \(formatDuration(measurement.p99))
               Max:        \(formatDuration(measurement.max))
               StdDev:     \(formatDuration(measurement.standardDeviation))
            """

        if let allocations = allocations, !allocations.isEmpty {
            let minAlloc = allocations.min() ?? 0
            let maxAlloc = allocations.max() ?? 0
            let avgAlloc = allocations.reduce(0, +) / allocations.count

            output += """

               Allocations:
                 Min:      \(formatBytes(minAlloc))
                 Median:   \(formatBytes(allocations.sorted()[allocations.count / 2]))
                 Max:      \(formatBytes(maxAlloc))
                 Avg:      \(formatBytes(avgAlloc))
            """
        }

        print(output)
    }

    private static func formatBytes(_ bytes: Int) -> String {
        if bytes == 0 {
            return "0 bytes"
        } else if bytes < 1024 {
            return "\(bytes) bytes"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.2f KB", Double(bytes) / 1024.0)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.2f MB", Double(bytes) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.2f GB", Double(bytes) / (1024.0 * 1024.0 * 1024.0))
        }
    }
}

/// Performance comparison report
public struct PerformanceComparison: Sendable {
    public let name: String
    public let current: StandardsTestSupport.Performance.Measurement
    public let baseline: StandardsTestSupport.Performance.Measurement
    public let metric: StandardsTestSupport.Performance.Metric

    public init(
        name: String,
        current: StandardsTestSupport.Performance.Measurement,
        baseline: StandardsTestSupport.Performance.Measurement,
        metric: StandardsTestSupport.Performance.Metric = .median
    ) {
        self.name = name
        self.current = current
        self.baseline = baseline
        self.metric = metric
    }

    public var currentValue: Duration {
        metric.extract(from: current)
    }

    public var baselineValue: Duration {
        metric.extract(from: baseline)
    }

    public var change: Double {
        (currentValue.inSeconds - baselineValue.inSeconds) / baselineValue.inSeconds
    }

    public var isRegression: Bool {
        change > 0
    }

    public var isImprovement: Bool {
        change < 0
    }

    public func formatted() -> String {
        let changePercent = abs(change) * 100
        let changeSymbol = isRegression ? "↑" : "↓"
        let changeColor = isRegression ? "🔴" : "🟢"

        return """
            \(changeColor) \(name)
                Baseline: \(baselineValue.formatted())
                Current:  \(currentValue.formatted())
                Change:   \(changeSymbol) \(String(format: "%.1f", changePercent))%
            """
    }
}

extension StandardsTestSupport {
    /// Print comparison report for multiple benchmarks
    public static func printComparisonReport(_ comparisons: [PerformanceComparison]) {
        print("\n╔══════════════════════════════════════════════════════════╗")
        print("║           PERFORMANCE COMPARISON REPORT                  ║")
        print("╚══════════════════════════════════════════════════════════╝\n")

        for comparison in comparisons {
            print(comparison.formatted())
            print("")
        }

        let regressions = comparisons.filter { $0.isRegression }.count
        let improvements = comparisons.filter { $0.isImprovement }.count
        let neutral = comparisons.count - regressions - improvements

        print("Summary: \(improvements) improvements, \(neutral) neutral, \(regressions) regressions")
        print("╚══════════════════════════════════════════════════════════╝\n")
    }
}

/// Performance benchmark suite
///
/// Collects and reports on multiple related benchmarks.
///
/// Example:
/// ```swift
/// var suite = PerformanceSuite(name: "Sequence Operations")
///
/// suite.benchmark("sum") {
///     numbers.sum()
/// }
///
/// suite.benchmark("product") {
///     numbers.product()
/// }
///
/// suite.printReport()
/// ```
public struct PerformanceSuite {
    public let name: String
    private var benchmarks: [(name: String, measurement: StandardsTestSupport.Performance.Measurement)] = []

    public init(name: String) {
        self.name = name
    }

    public mutating func benchmark<T>(
        _ name: String,
        warmup: Int = 0,
        iterations: Int = 10,
        operation: () -> T
    ) -> T {
        let (result, measurement) = StandardsTestSupport.measure(warmup: warmup, iterations: iterations, operation: operation)
        benchmarks.append((name, measurement))
        return result
    }

    public mutating func benchmark<T>(
        _ name: String,
        warmup: Int = 0,
        iterations: Int = 10,
        operation: () async throws -> T
    ) async rethrows -> T {
        let (result, measurement) = try await StandardsTestSupport.measure(warmup: warmup, iterations: iterations, operation: operation)
        benchmarks.append((name, measurement))
        return result
    }

    public func printReport(metric: StandardsTestSupport.Performance.Metric = .median) {
        print("\n╔══════════════════════════════════════════════════════════╗")
        print("║  \(name.padding(toLength: 56, withPad: " ", startingAt: 0))║")
        print("╚══════════════════════════════════════════════════════════╝\n")

        let maxNameLength = benchmarks.map { $0.name.count }.max() ?? 0

        for (name, measurement) in benchmarks {
            let value = metric.extract(from: measurement)
            let paddedName = name.padding(toLength: maxNameLength, withPad: " ", startingAt: 0)
            print("  \(paddedName)  \(value.formatted())")
        }

        print("\n╚══════════════════════════════════════════════════════════╝\n")
    }
}
