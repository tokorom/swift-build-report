//
//  DefaultIgnoreLinesTests.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import XCTest
@testable import SwiftBuildReport

class DefaultIgnoreLinesTests: XCTestCase {
    let subject = DefaultIgnoreLines()

    func testNpmError() {
        let bret = subject.ignore(line: "npm ERR! foo/bar")
        XCTAssertTrue(bret)
    }

    func testNpmWarn() {
        let bret = subject.ignore(line: "npm WARN xxxxx")
        XCTAssertTrue(bret)
    }

    func testNormalLine() {
        let bret = subject.ignore(line: "foo bar")
        XCTAssertFalse(bret)
    }
}
