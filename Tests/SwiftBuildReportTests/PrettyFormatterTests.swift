//
//  PrettyFormatterTests.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import XCTest
@testable import SwiftBuildReport

class PrettyFormatterTests: XCTestCase {
    let subject = PrettyFormatter()

    var colorCodePattern = "\u{001B}\\[0;[0-9]+m"
    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.colorCodePattern)

    func testTestSuiteStarted() {
        let line = "Test Suite 'All tests' started at 2016-12-10 16:04:52.126"
        let expected = "All tests"
        let result = removeColorCode(subject.parse(line: line).line ?? "")
        XCTAssertEqual(result, expected)
    }

    func testTestCaseStarted() {
        let line = "Test Case '-[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary]' started."
        let expected: String? = nil
        let result = subject.parse(line: line).line
        XCTAssertEqual(result, expected)
    }
}

extension PrettyFormatterTests {
    func removeColorCode(_ line: String) -> String {
        let range = NSRange(location: 0, length: line.characters.count)
        guard let result = regexp?.stringByReplacingMatches(in: line, range: range, withTemplate: "") else {
            return line
        }
        return result
    }
}
