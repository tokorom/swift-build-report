//
//  AnsiColorTests.swift
//
//  Created by ToKoRo on 2016-12-08.
//

import XCTest
@testable import SwiftBuildReport

class AnsiColorTests: XCTestCase {
    func testRed() {
        let color = AnsiColor.red
        let text = color.text
        XCTAssertEqual(text, "\u{001B}[0;31m")
    }

    func testGreen() {
        let text = AnsiColor.red.text
        XCTAssertEqual(text, "\u{001B}[0;31m")
    }
}
