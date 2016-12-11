//
//  DefaultReporterTests.swift
//
//  Created by ToKoRo on 2016-12-11.
//

import XCTest
@testable import SwiftBuildReport

class DefaultReporterTests: XCTestCase {
    var subject = DefaultReporter()

    override func setUp() {
        super.setUp()

        subject = DefaultReporter()
        subject.maskFileAccess = true
    }

    func testNormalLine() {
        let line = "foo bar"
        subject.send(line: line)
        XCTAssertNil(subject.lastLine)
    }

    func testCompileError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Sources/SwiftBuildReport/main.swift:31:1: error: foo bar"
        subject.send(line: line)
        XCTAssertEqual(subject.lastLine, line)
    }

    func testCompileWarning() {
        let line = "/Users/hoge/develop/Hoge.swift:28:9: warning: expression following 'return' is treated as an argument of the 'return'"
        subject.send(line: line)
        XCTAssertEqual(subject.lastLine, line)
    }

    func testCompileNote() {
        let line = "Foundation/Hoge.swift:28:9: note: indent the expression to silence this warning"
        subject.send(line: line)
        XCTAssertNil(subject.lastLine)
    }

    func testTestError() {
        let line = "/Users/tokorom/develop/github/swift-build-report/Tests/SwiftBuildReportTests/DefaultFormatterTests.swift"
            + ":45: error: -[SwiftBuildReportTests.DefaultFormatterTests testBuildErrorSummary] : "
            + "XCTAssertEqual failed: (\"normal\") is not equal to (\"buildSummaryWithError\") -"
        subject.send(line: line)
        XCTAssertEqual(subject.lastLine, line)
    }

    func testBuildSummaryWithError() {
        let errorLine = "/Users/tokorom/develop/github/swift-build-report/Sources/SwiftBuildReport/main.swift:31:1: error: foo bar"
        subject.send(line: errorLine)
        XCTAssertNotNil(subject.lastLine)

        let buildSummary = "<unknown>:0: error: build had 1 command failures"
        subject.send(line: buildSummary)
        XCTAssertNotNil(subject.lastLine)
        XCTAssertTrue(subject.firstLine)

        let testStarted = "Test Suite 'DefaultFormatterTests' started at 2016-12-09 11:09:14.488"
        subject.send(line: testStarted)
        XCTAssertNil(subject.lastLine)
        XCTAssertFalse(subject.firstLine)
    }
}
