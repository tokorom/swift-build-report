//
//  DefaultFormatterTests.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import XCTest
@testable import SwiftBuildReport

class DefaultFormatterTests: XCTestCase {
    let subject = DefaultFormatter()

    func testNormalLine() {
        let line = "foo bar"
        let expected: FormattedLine.Kind = .normal
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testCompileStart() {
        let line = "Compile Swift Module 'SwiftBuildReport' (7 sources)"
        let expected: FormattedLine.Kind = .compileStart
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testCompileError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Sources/SwiftBuildReport/main.swift:31:1: error: foo bar"
        let expected: FormattedLine.Kind = .compileError
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testCompileWarning() {
        let line = "/Users/hoge/develop/Hoge.swift:28:9: warning: expression following 'return' is treated as an argument of the 'return'"
        let expected: FormattedLine.Kind = .compileWarning
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testCompileNote() {
        let line = "Foundation/Hoge.swift:28:9: note: indent the expression to silence this warning"
        let expected: FormattedLine.Kind = .compileNote
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testLinking() {
        let line = "Linking ./.build/debug/SwiftBuildReport"
        let expected: FormattedLine.Kind = .linking
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testBuildErrorSummary() {
        let line = "<unknown>:0: error: build had 1 command failures"
        let expected: FormattedLine.Kind = .buildSummaryWithError
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestSuiteStarted() {
        let line = "Test Suite 'DefaultFormatterTests' started at 2016-12-09 11:09:14.488"
        let expected: FormattedLine.Kind = .testSuiteStarted
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestSuitePassed() {
        let line = "Test Suite 'DefaultFormatterTests' passed at 2016-12-10 14:31:04.973."
        let expected: FormattedLine.Kind = .testSuitePassed
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestSuiteFailed() {
        let line = "Test Suite 'DefaultFormatterTests' failed at 2016-12-10 14:34:46.050."
        let expected: FormattedLine.Kind = .testSuiteFailed
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestCaseStarted() {
        let line = "Test Case '-[SwiftBuildReportTests.AnsiColorTests testGreen]' started."
        let expected: FormattedLine.Kind = .testCaseStarted
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestCasePassed() {
        let line = "Test Case '-[SwiftBuildReportTests.DefaultFormatterTests testErrorPoint]' passed (0.000 seconds)."
        let expected: FormattedLine.Kind = .testCasePassed
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestCaseFailed() {
        let line = "Test Case '-[SwiftBuildReportTests.DefaultFormatterTests testTestCasePassed]' failed (0.002 seconds)."
        let expected: FormattedLine.Kind = .testCaseFailed
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/DefaultFormatterTests.swift"
            + ":45: error: -[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary] : "
            + "XCTAssertEqual failed: (\"normal\") is not equal to (\"buildSummaryWithError\") -"
        let expected: FormattedLine.Kind = .testError
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestErrorWithRuntimeError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Sources/SwiftBuildReport/DefaultReporter.swift:70: erro"
            + "r: -[SwiftBuildReportTests.DefaultReporterTests testBuildSummaryWithError] : failed: caught \"NSInvalidAr"
            + "gumentException\", \"*** -[NSFileManager fileSystemRepresentationWithPath:]: nil or empty path argument\""
        let expected: FormattedLine.Kind = .testError
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestErrorWithAssertNotNil() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/DefaultReporterTests.swift:64: "
            + "error: -[SwiftBuildReportTests.DefaultReporterTests testBuildSummaryWithError] : XCTAssertNotNil failed -"
        let expected: FormattedLine.Kind = .testError
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testErrorPoint() {
        let line = "  ^  "
        let expected: FormattedLine.Kind = .errorPoint
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testErrorPointLong() {
        let line = "  ^~~~~~  "
        let expected: FormattedLine.Kind = .errorPoint
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestErrorWithLongMessage() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/DefaultFormatterTests.swift:80"
            + ": error: -[SwiftBuildReportTests.DefaultFormatterTests testTestSummary] : XCTAssertEqual failed: (\"    Exec"
            + "uted 10 tests, with 2 failuers (0 unexpected) in 0.008 (0.009) seconds\") is not equal to (\"    Executed 10 tests"
            + ", with 2 failuers (0 unexpected) in 0.008 (0.009) seconds\") -"
        let expected: FormattedLine.Kind = .testError
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }

    func testTestSummary() {
        let line = "    Executed 10 tests, with 1 failure (0 unexpected) in 0.008 (0.009) seconds"
        let expected: FormattedLine.Kind = .testSummary
        let kind = subject.parse(line: line).kind
        XCTAssertEqual(kind, expected)
    }
}
