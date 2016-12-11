//
//  PrettyFormatterAllTestsSumaryTests.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import XCTest
@testable import SwiftBuildReport

class PrettyFormatterAllTestsSumaryTests: XCTestCase {
    let utils = Utils()

    func testAllTestsSummary() {
        let subject = PrettyFormatter()
        subject.maskPrint = true

        _ = subject.format(line: "Test Suite 'All tests' passed at 2016-12-10 18:37:45.581.")
        _ = subject.format(line: "    Executed 10 tests, with 1 failure (0 unexpected) in 0.008 (0.009) seconds")

        let result = utils.removeColorCode(subject.allTestsSummary ?? "")
        XCTAssertEqual(result, "    Executed 10 tests, with 1 failure (0 unexpected) in 0.008 (0.009) seconds")
    }

    func testTestSuiteSummary() {
        let subject = PrettyFormatter()
        subject.maskPrint = true

        _ = subject.format(line: "Test Suite 'DefaultFormatterTests' passed at 2016-12-10 14:31:04.973.")
        _ = subject.format(line: "    Executed 10 tests, with 1 failure (0 unexpected) in 0.008 (0.009) seconds")

        XCTAssertNil(subject.allTestsSummary)
    }
}
