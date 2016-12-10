//
//  SimpleFormatterTests.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import XCTest
@testable import SwiftBuildReport

class SimpleFormatterTests: XCTestCase {
    let subject = SimpleFormatter()

    func testTestError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/DefaultFormatterTests.swift"
            + ":45: error: -[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary] : "
            + "XCTAssertEqual failed: (\"normal\") is not equal to (\"buildSummaryWithError\") -"
        let expected: FormattedLine.Kind = .testError

        let formatted = subject.parse(line: line)
        let kind = formatted.kind
        let result = formatted.line

        XCTAssertEqual(kind, expected)
        XCTAssertEqual(
            result,
            "\u{001B}[0;31m/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/"
                + "DefaultFormatterTests.swift"
                + ":45: error: -[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary] : "
                + "XCTAssertEqual failed:\u{001B}[0;34m (\"normal\") \u{001B}[0;0mis not equal to"
                + "\u{001B}[0;34m (\"buildSummaryWithError\") \u{001B}[0;0m-\u{001B}[0;0m"
        )
    }

    func testTestSummary() {
        let line = "    Executed 10 tests, with 1 failure (0 unexpected) in 0.008 (0.009) seconds"
        let expected: FormattedLine.Kind = .testSummary

        let formatted = subject.parse(line: line)
        let kind = formatted.kind
        let result = formatted.line

        XCTAssertEqual(kind, expected)
        XCTAssertEqual(result, "    Executed 10 tests, with \u{001B}[0;31m1 failure (0 unexpected)\u{001B}[0;0m in 0.008 (0.009) seconds")
    }

    func testFailedSample() {
        XCTAssertEqual("foo", "bar")
    }
}
