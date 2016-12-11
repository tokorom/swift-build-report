//
//  RegexPattern.swift
//
//  Created by ToKoRo on 2016-12-11.
//

import Foundation

class RegexPattern {
    let pattern: String
    let replaceTemplate: String
    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.pattern)

    init(_ pattern: String, replaceTemplate: String = "") {
        self.pattern = pattern
        self.replaceTemplate = replaceTemplate
    }

    func test(line: String) -> Bool {
        if let _ = regexp?.firstMatch(in: line, range: range(for: line)) {
            return true
        } else {
            return false
        }
    }

    func replace(line: String) -> String {
        let result = regexp?.stringByReplacingMatches(in: line, range: range(for: line), withTemplate: replaceTemplate)
        guard let validResult = result else {
            return line
        }
        return validResult
    }

    private func range(for line: String) -> NSRange {
        return NSRange(location: 0, length: line.characters.count)
    }
}

extension RegexPattern {
    static let testSuiteStarted = RegexPattern("^Test Suite .* started ")
    static let testSuitePassed = RegexPattern("^Test Suite .* passed at ")
    static let testSuiteFailed = RegexPattern("^Test Suite .* failed at ")
    static let testCaseStarted = RegexPattern("^Test Case .* started.$")
    static let testCasePassed = RegexPattern("^Test Case .* passed [(]")
    static let testCaseFailed = RegexPattern("^Test Case .* failed [(]")
    static let testError = RegexPattern("^\\/.* error: -\\[[^:]*\\] : ?.* failed:? .*$")
    static let testSummary = RegexPattern(" Executed [0-9]+ tests?, with [0-9]+ failures? ")
    static let compileError = RegexPattern("^.*:[0-9]*:[0-9]*: error: ")
    static let compileWarning = RegexPattern("^.*:[0-9]*:[0-9]*: warning: ")
    static let compileNote = RegexPattern("^.*:[0-9]*:[0-9]*: note: ")
    static let compileStart = RegexPattern("^Compile Swift Module ")
    static let errorPoint = RegexPattern(" *\\^~* *")
    static let linking = RegexPattern("^Linking ")
    static let buildSummaryWithError = RegexPattern(" error: build had [0-9]+ command failures?$")

    static let allTestsFinished = RegexPattern("Test Suite 'All tests' (passed|failed) ")
    static let testSummaryWithPassed = RegexPattern("^.*Executed [0-9]+ tests?, with 0 failures? \\(0 unexpected\\).*$")
    static let testSummaryWithFailed = RegexPattern("^.*Executed [0-9]+ tests?, with [0-9]+ failures? \\([0-9]+ unexpected\\).*$")
}
