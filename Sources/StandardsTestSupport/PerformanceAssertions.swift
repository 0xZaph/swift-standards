// PerformanceAssertions.swift
// StandardsTestSupport
//
// Performance threshold assertions for Swift Testing

import Foundation
import Standards

extension StandardsTestSupport {
    /// Assert that an operation completes within a duration threshold
    ///
    /// Example:
    /// ```swift
    /// StandardsTestSupport.expectPerformance(lessThan: .milliseconds(100)) {
    ///     numbers.sum()
    /// }
    /// ```
    @discardableResult
    public static func expectPerformance<T>(
        lessThan threshold: Duration,
        warmup: Int = 0,
        iterations: Int = 10,
        metric: Performance.Metric = .median,
        operation: () -> T
    ) -> (result: T, measurement: Performance.Measurement) {
        let (result, measurement) = measure(warmup: warmup, iterations: iterations, operation: operation)

        let actualDuration = metric.extract(from: measurement)

        guard actualDuration <= threshold else {
            fatalError("""
                Performance expectation failed:
                Expected \(metric) < \(formatDuration(threshold))
                Actual: \(formatDuration(actualDuration))
                Exceeded by: \(formatDuration(actualDuration - threshold))
                """)
        }

        return (result, measurement)
    }

    /// Assert that an async operation completes within a duration threshold
    @discardableResult
    public static func expectPerformance<T>(
        lessThan threshold: Duration,
        warmup: Int = 0,
        iterations: Int = 10,
        metric: Performance.Metric = .median,
        operation: () async throws -> T
    ) async rethrows -> (result: T, measurement: Performance.Measurement) {
        let (result, measurement) = try await measure(warmup: warmup, iterations: iterations, operation: operation)

        let actualDuration = metric.extract(from: measurement)

        guard actualDuration <= threshold else {
            fatalError("""
                Performance expectation failed:
                Expected \(metric) < \(formatDuration(threshold))
                Actual: \(formatDuration(actualDuration))
                Exceeded by: \(formatDuration(actualDuration - threshold))
                """)
        }

        return (result, measurement)
    }
}

extension StandardsTestSupport.Performance {
    /// Performance metrics that can be asserted against
    public enum Metric: String, Sendable {
        case min
        case max
        case median
        case mean
        case p95
        case p99

        func extract(from measurement: Measurement) -> Duration {
            switch self {
            case .min: return measurement.min
            case .max: return measurement.max
            case .median: return measurement.median
            case .mean: return measurement.mean
            case .p95: return measurement.p95
            case .p99: return measurement.p99
            }
        }
    }
}

extension StandardsTestSupport {
    /// Performance regression detector
    ///
    /// Compares current performance against a baseline with tolerance.
    ///
    /// Example:
    /// ```swift
    /// let baseline = PerformanceMeasurement(durations: [.milliseconds(10)])
    /// let (result, measurement) = StandardsTestSupport.measure { operation() }
    ///
    /// StandardsTestSupport.expectNoRegression(
    ///     current: measurement,
    ///     baseline: baseline,
    ///     tolerance: 0.10  // 10% regression allowed
    /// )
    /// ```
    public static func expectNoRegression(
        current: Performance.Measurement,
        baseline: Performance.Measurement,
        tolerance: Double = 0.10,
        metric: Performance.Metric = .median
    ) {
        let currentValue = metric.extract(from: current)
        let baselineValue = metric.extract(from: baseline)

        let regression = (currentValue.inSeconds - baselineValue.inSeconds) / baselineValue.inSeconds

        guard regression <= tolerance else {
            fatalError("""
                Performance regression detected:
                Baseline \(metric): \(formatDuration(baselineValue))
                Current \(metric): \(formatDuration(currentValue))
                Regression: \(String(format: "%.1f", regression * 100))%
                Tolerance: \(String(format: "%.1f", tolerance * 100))%
                """)
        }
    }
}
