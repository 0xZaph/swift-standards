# StandardsTestSupport

A performance testing library for Swift Testing framework, providing trait-based performance measurement and threshold enforcement.

## Overview

StandardsTestSupport extends Swift Testing with declarative performance testing capabilities through custom traits. It provides:

- **Trait-based performance testing** - Measure tests declaratively with `@Test(.performance(...))`
- **Threshold enforcement** - Automatically fail tests that exceed performance budgets
- **Statistical analysis** - Min, max, median, mean, p95, p99, standard deviation
- **Baseline tracking** - Compare against historical performance (coming soon)
- **Manual measurement API** - Direct access to `measure()` for custom scenarios

## Requirements

- Swift 6.1+ (for trait system)
- macOS 13.0+, iOS 16.0+, watchOS 9.0+, tvOS 16.0+ (for Duration APIs)
- Swift Testing framework

## Quick Start

### Basic Performance Measurement

The simplest way to measure performance is with `.measurePerformance`:

```swift
import Testing
import StandardsTestSupport

@Test(.measurePerformance)
func `string concatenation`() {
    var result = ""
    for i in 0..<1000 {
        result += "\(i)"
    }
}
```

Output:
```
⏱️  `string concatenation`()
    Iterations: 10
    Min:        2.35ms
    Median:     2.45ms
    Mean:       2.48ms
    p95:        2.89ms
    p99:        2.89ms
    Max:        2.89ms
    StdDev:     152.34µs
```

### Enforcing Performance Thresholds

Use `.performance()` to both measure and enforce performance requirements:

```swift
@Test(.performance(printResults: true, threshold: .milliseconds(5)))
func `string concatenation must be fast`() {
    var result = ""
    for i in 0..<1000 {
        result += "\(i)"
    }
}
```

This test will:
1. Run 10 iterations (default) with timing
2. Print statistical analysis
3. **Fail if median exceeds 5ms** with detailed error message

### Performance Test Suites

For multiple related performance tests, use `.serialized` at the suite level:

```swift
@Suite(.serialized)
struct `String Performance` {

    @Test(.performance(printResults: true, threshold: .milliseconds(5)))
    func `concatenation`() {
        var result = ""
        for i in 0..<1000 { result += "\(i)" }
    }

    @Test(.performance(printResults: true, threshold: .milliseconds(1)))
    func `interpolation`() {
        _ = (0..<1000).map { "\($0)" }.joined()
    }
}
```

## Trait API Reference

### `.measurePerformance`

Measure and print performance without enforcing thresholds. Ideal for exploration and performance profiling.

```swift
@Test(.measurePerformance)
func myTest() { /* ... */ }
```

**Configuration:**
- Iterations: 10
- Warmup: 0
- Print results: Yes
- Threshold: None

### `.performance(...)`

Full control over measurement configuration with optional threshold enforcement.

```swift
@Test(.performance(
    iterations: 100,           // Number of measurement runs
    warmup: 5,                 // Warmup iterations before measuring
    printResults: true,        // Print statistical analysis
    threshold: .milliseconds(10), // Optional: fail if exceeded
    metric: .median            // Metric to check against threshold
))
func myTest() { /* ... */ }
```

**Parameters:**
- `iterations: Int = 10` - Number of timed executions
- `warmup: Int = 0` - Number of untimed warmup runs
- `printResults: Bool = false` - Whether to print statistics
- `threshold: Duration? = nil` - Optional performance budget
- `metric: PerformanceMetric = .median` - Metric for threshold checking

**Performance Metrics:**
- `.min` - Fastest execution
- `.max` - Slowest execution
- `.median` - 50th percentile (default, most stable)
- `.mean` - Average
- `.p95` - 95th percentile
- `.p99` - 99th percentile

### `.performanceThreshold(...)`

Convenience for threshold-only enforcement without printing (rarely needed).

```swift
@Test(.performanceThreshold(.milliseconds(10)))
func myTest() { /* ... */ }
```

## Manual Measurement API

For scenarios requiring manual control (comparing algorithms, expensive setup):

```swift
import Testing
import StandardsTestSupport

@Test
func `compare sorting algorithms`() {
    let data = Array(1...10_000).shuffled()

    // Measure first algorithm
    let (result1, measurement1) = measure(iterations: 50) {
        data.sorted()
    }

    // Measure second algorithm
    let (result2, measurement2) = measure(iterations: 50) {
        data.sorted(by: <)
    }

    printPerformance("stdlib sorted()", measurement1)
    printPerformance("sorted(by: <)", measurement2)

    #expect(measurement1.median < .milliseconds(20))
}
```

### Functions

#### `measure(warmup:iterations:operation:)`

Measures synchronous operation performance.

```swift
let (result, measurement) = measure(warmup: 3, iterations: 100) {
    expensiveOperation()
}
```

**Returns:** `(result: T, measurement: PerformanceMeasurement)`

#### `measure(warmup:iterations:operation:)` (async)

Measures async operation performance.

```swift
let (result, measurement) = await measure(iterations: 50) {
    await asyncOperation()
}
```

#### `time(operation:)`

Single-shot timing without statistical analysis.

```swift
let (result, duration) = time {
    quickOperation()
}
print("Took: \(duration.formatted())")
```

#### `printPerformance(_:_:)`

Prints formatted performance statistics.

```swift
printPerformance("My Operation", measurement)
```

#### `formatDuration(_:_:)`

Formats Duration for display with automatic unit selection.

```swift
let duration = Duration.milliseconds(5.823)
print(formatDuration(duration))  // "5.82ms"
```

### PerformanceMeasurement

Statistical analysis of multiple duration measurements.

```swift
struct PerformanceMeasurement {
    let durations: [Duration]

    var min: Duration
    var max: Duration
    var median: Duration
    var mean: Duration
    var p95: Duration
    var p99: Duration
    var standardDeviation: Duration

    func percentile(_ p: Double) -> Duration
}
```

## Memory Allocation Tracking

StandardsTestSupport can track memory allocations during test execution to ensure algorithms don't introduce unnecessary copies or allocations:

```swift
extension PerformanceTests {
    @Suite(.serialized)
    struct `Sequence Performance` {
        @Test(.timed(threshold: .milliseconds(30), maxAllocations: 60_000))
        func `sum is allocation-free`() {
            let numbers = Array(1...100_000)
            _ = numbers.sum()
        }
    }
}
```

The allocation tracking:
- Captures platform-specific malloc statistics (Darwin: `malloc_statistics_t`, Linux: `mallinfo`)
- Reports min/median/max/average allocations across iterations
- Fails tests that exceed allocation budgets
- Accounts for background system allocations

**Note**: Allocation limits should include headroom for system noise (~50-60KB on macOS).

## Best Practices

### 1. Separate Correctness from Performance

Keep correctness tests and performance tests in separate test functions:

```swift
// Correctness
@Test
func `sum returns correct total`() {
    #expect([1, 2, 3].sum() == 6)
}

// Performance
@Test(.performance(printResults: true, threshold: .milliseconds(50)))
func `sum 100k elements`() {
    let numbers = Array(1...100_000)
    _ = numbers.sum()
}
```

### 2. Choose Appropriate Thresholds

Set thresholds with 10-20% headroom over typical performance to account for:
- CI environment variability
- Different hardware
- Background system activity

```swift
// Measured: ~25ms typical
// Threshold: 30ms (20% buffer)
@Test(.performance(printResults: true, threshold: .milliseconds(30)))
func myTest() { /* ... */ }
```

### 3. Use Median for Threshold Checks

Median is more stable than mean, less affected by outliers:

```swift
@Test(.performance(
    printResults: true,
    threshold: .milliseconds(100),
    metric: .median  // Default, most reliable
))
func myTest() { /* ... */ }
```

Use `.p95` or `.p99` when you need to ensure worst-case performance.

### 4. Serialize Performance Tests

Performance tests should run sequentially to avoid interference:

```swift
@Suite(.serialized)
struct `My Performance Tests` {
    @Test(.performance(...))
    func test1() { /* ... */ }

    @Test(.performance(...))
    func test2() { /* ... */ }
}
```

### 5. Use Sufficient Iterations

Balance accuracy with test execution time:
- **Quick tests** (<1ms): 100-1000 iterations
- **Medium tests** (1-100ms): 10-50 iterations (default: 10)
- **Slow tests** (>100ms): 5-10 iterations

```swift
@Test(.performance(iterations: 100, threshold: .microseconds(500)))
func `very fast operation`() { /* ... */ }

@Test(.performance(iterations: 5, threshold: .seconds(1)))
func `expensive operation`() { /* ... */ }
```

### 6. Warmup for JIT-Compiled Code

Use warmup iterations when testing code affected by JIT compilation:

```swift
@Test(.performance(warmup: 5, iterations: 50))
func `JIT-affected code`() { /* ... */ }
```

## Advanced Patterns

### Performance Comparison

Compare multiple implementations manually:

```swift
@Test
func `compare implementations`() {
    let data = Array(1...10_000)

    let (_, measurement1) = measure(iterations: 50) {
        implementation1(data)
    }

    let (_, measurement2) = measure(iterations: 50) {
        implementation2(data)
    }

    printPerformance("Implementation 1", measurement1)
    printPerformance("Implementation 2", measurement2)

    // Assert implementation 1 is faster
    #expect(measurement1.median < measurement2.median)
}
```

### Custom Performance Suites

Use `PerformanceSuite` for collecting related benchmarks:

```swift
@Test
func `sequence operations benchmark suite`() {
    var suite = PerformanceSuite(name: "Sequence Operations")

    let numbers = Array(1...100_000)

    suite.benchmark("sum") {
        numbers.sum()
    }

    suite.benchmark("product") {
        numbers.product()
    }

    suite.benchmark("mean") {
        numbers.mean()
    }

    suite.printReport()
}
```

Output:
```
╔══════════════════════════════════════════════════════════╗
║  Sequence Operations                                     ║
╚══════════════════════════════════════════════════════════╝

  sum      25.42ms
  product  28.91ms
  mean     26.18ms

╚══════════════════════════════════════════════════════════╝
```

### Excluding Setup from Measurement

When setup is expensive, use manual measurement:

```swift
@Test
func `with expensive setup`() {
    // Expensive setup (not measured)
    let expensiveData = generateLargeDataset()

    // Measure only the operation
    let (_, measurement) = measure(iterations: 100) {
        processData(expensiveData)
    }

    #expect(measurement.median < .milliseconds(10))
}
```

## Duration Extensions

StandardsTestSupport extends `Duration` with convenience initializers and conversions:

```swift
// Construction
let duration = Duration.seconds(1.5)
let duration = Duration.milliseconds(100.5)
let duration = Duration.microseconds(500)
let duration = Duration.nanoseconds(1000)

// Conversion
let seconds = duration.inSeconds         // Double
let milliseconds = duration.inMilliseconds
let microseconds = duration.inMicroseconds
let nanoseconds = duration.inNanoseconds

// Formatting
formatDuration(duration)                 // Auto unit: "5.82ms"
formatDuration(duration, .milliseconds)  // Force unit: "5.82ms"
```

## Example: Complete Test File

```swift
import Testing
@testable import MyPackage
import StandardsTestSupport

// MARK: - Correctness Tests

@Suite
struct `Array Extensions` {
    @Test
    func `sum returns correct total`() {
        #expect([1, 2, 3, 4, 5].sum() == 15)
    }

    @Test
    func `product returns correct result`() {
        #expect([1, 2, 3, 4, 5].product() == 120)
    }
}

// MARK: - Performance Tests

@Suite(.serialized)
struct `Array Performance` {

    @Test(.performance(printResults: true, threshold: .milliseconds(50)))
    func `sum 100k elements`() {
        let numbers = Array(1...100_000)
        _ = numbers.sum()
    }

    @Test(.performance(printResults: true, threshold: .milliseconds(100)))
    func `product 100 elements`() {
        let numbers = Array(1...100)
        _ = numbers.product()
    }
}
```

## Future Enhancements

- **Baseline tracking** - Compare against saved baseline measurements
- **Regression detection** - Automatic detection of performance degradation
- **CI integration** - Export performance data for dashboards
- **Memory measurement** - Track memory allocations alongside time

## License

StandardsTestSupport is part of swift-standards and follows the same licensing.
