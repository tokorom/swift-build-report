//
//  PrettyFormatterTests.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import XCTest
@testable import SwiftBuildReport

class PrettyFormatterTests: XCTestCase {
    let subject = PrettyFormatter()
    let utils = Utils()

    func testTestSuiteStarted() {
        let line = "Test Suite 'All tests' started at 2016-12-10 16:04:52.126"
        let expected = "All tests"
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestSuitePassed() {
        let line = "Test Suite 'DefaultFormatterTests' passed at 2016-12-10 14:31:04.973."
        let expected = ""
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestSuiteFailed() {
        let line = "Test Suite 'DefaultFormatterTests' failed at 2016-12-10 14:34:46.050."
        let expected = ""
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestCaseStarted() {
        let line = "Test Case '-[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary]' started."
        let expected: String? = nil
        let result = subject.parse(line: line).line
        XCTAssertEqual(result, expected)
    }

    func testTestCasePassed() {
        let line = "Test Case '-[SwiftBuildReportTests.DefaultFormatterTests testErrorPoint]' passed (0.000 seconds)."
        let expected = "    ✓ testErrorPoint (0.000 seconds) "
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestCaseFailed() {
        let line = "Test Case '-[SwiftBuildReportTests.DefaultFormatterTests testTestCasePassed]' failed (0.002 seconds)."
        let expected = ""
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/DefaultFormatterTests.swift"
            + ":45: error: -[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary] : "
            + "XCTAssertEqual failed: (\"normal\") is not equal to (\"buildSummaryWithError\") -"
        let expected = "    ✗ testBuildErrorSummary, XCTAssertEqual failed: (\"normal\") "
            + "is not equal to (\"buildSummaryWithError\") "
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestSummary() {
        let line = "    Executed 10 tests, with 1 failure (0 unexpected) in 0.008 (0.009) seconds"
        let expected = ""
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testCompileError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Sources/SwiftBuildReport/main.swift:31:1: error: foo bar"
        let expected = "❌  /Users/tokorom/develop/github/swift-build-report/Sources/SwiftBuildReport/main.swift:31:1: foo bar "
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testCompileWarning() {
        let line = "/Users/hoge/develop/Hoge.swift:28:9: warning: expression following 'return' is treated as an argument of the 'return'"
        let expected = "⚠️  /Users/hoge/develop/Hoge.swift:28:9: expression following 'return' is treated as an argument of the 'return' "
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testCompileNote() {
        let line = "Foundation/Hoge.swift:28:9: note: indent the expression to silence this warning"
        let expected = "note: Foundation/Hoge.swift:28:9: indent the expression to silence this warning "
        let result = utils.removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }
}
