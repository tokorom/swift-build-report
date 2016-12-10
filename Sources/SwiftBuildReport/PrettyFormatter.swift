//
//  PrettyFormatter.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import Foundation

class PrettyFormatter: DefaultFormatter {
    lazy var allTestsFinishedPattern: ReplacePattern = ReplacePattern(
        pattern: "Test Suite 'All tests' (passed|failed) "
    )

    lazy var allTestsPassedPattern: ReplacePattern = ReplacePattern(
        pattern: "^.*Executed [0-9]+ tests?, with 0 failures? \\(0 unexpected\\).*$",
        template: "$0",
        ansiColor: .green
    )

    lazy var allTestsFailedPattern: ReplacePattern = ReplacePattern(
        pattern: "^.*Executed [0-9]+ tests?, with [0-9]+ failures? \\([0-9]+ unexpected\\).*$",
        template: "$0",
        ansiColor: .red
    )

    var isAllTestsFinished = false

    override init() {
        super.init()

        replacers[.testSuiteStarted] = .replacePattern(ReplacePattern(
            pattern: "^Test Suite '([^']+)' .*$",
            template: "$1",
            ansiColor: .white
        ))
        replacers[.testSuitePassed] = .ignore
        replacers[.testSuiteFailed] = .ignore
        replacers[.testCaseStarted] = .ignore
        replacers[.testCasePassed] = .replacePattern(ReplacePattern(
            pattern: "^Test Case '-\\[[^ ]+ ([^ ]+)\\]' passed (\\([0-9.]+ seconds\\))\\.$",
            template: "    " + AnsiColor.green.text + "✓" + AnsiColor.reset.text + " $1 $2",
            ansiColor: nil
        ))
        replacers[.testCaseFailed] = .ignore
        replacers[.errorPoint] = .color(.cyan)
        replacers[.testError] = .replacePattern(ReplacePattern(
            pattern: "^.* error: -\\[[^ ]+ ([^ ]+)\\] : ([^ ]+) failed: (.*) -.*$",
            template: "    " + AnsiColor.red.text + "✗" + AnsiColor.reset.text + " "
                + AnsiColor.red.text + "$1" + AnsiColor.reset.text
                + ", $2 failed: "
                + AnsiColor.blue.text + "$3" + AnsiColor.reset.text,
            ansiColor: nil
        ))
        replacers[.testSummary] = .ignore

        replacers[.compileError] = .color(.red)
        replacers[.compileStart] = .color(.cyan)

        replacers[.linking] = .color(.white)
        replacers[.buildSummaryWithError] = .color(.red)
    }

    override func handle(formattedLine: FormattedLine, rawLine: String) {
        switch formattedLine.kind {
        case .testSuitePassed, .testSuiteFailed:
            if allTestsFinishedPattern.test(line: rawLine) {
                isAllTestsFinished = true
            }
        case .testSummary:
            if isAllTestsFinished {
                printAllTestsSummary(with: rawLine)
                isAllTestsFinished = false
            }
        default:
            break
        }
    }

    func printAllTestsSummary(with line: String) {
        let summary: String

        if allTestsPassedPattern.test(line: line), let colored = allTestsPassedPattern.replace(line: line) {
            summary = colored
        } else if allTestsFailedPattern.test(line: line), let colored = allTestsFailedPattern.replace(line: line) {
            summary = colored
        } else {
            summary = line
        }

        print("\n" + summary)
    }
}
