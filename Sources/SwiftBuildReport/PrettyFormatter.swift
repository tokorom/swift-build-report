//
//  PrettyFormatter.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import Foundation

class PrettyFormatter: DefaultFormatter {
    lazy var allTestsPassedPattern: ColorPattern = ColorPattern(
        pattern: RegexPattern.testSummaryWithPassed.pattern,
        ansiColor: .green
    )

    lazy var allTestsFailedPattern: ColorPattern = ColorPattern(
        pattern: RegexPattern.testSummaryWithFailed.pattern,
        ansiColor: .red
    )

    var maskPrint = false
    var isAllTestsFinished = false
    var allTestsSummary: String? = nil

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
        replacers[.testCasePassed] = .replacePattern(PrettyReplacePattern(
            pattern: "^Test Case '-\\[[^ ]+ ([^ ]+)\\]' passed (\\([0-9.]+ seconds\\))\\.$",
            template: "$1 $2",
            emoji: "✓",
            emojiColor: AnsiColor.green,
            indent: 4
        ))
        replacers[.testCaseFailed] = .ignore
        replacers[.errorPoint] = .color(.cyan)
        replacers[.testError] = .replacePattern(PrettyReplacePattern(
            pattern: "^.* error: -\\[[^ ]+ ([^ ]+)\\] : ?([^ ]*) failed:? (.*)$",
            template: AnsiColor.red.text + "$1" + AnsiColor.reset.text
                + ", $2 failed: "
                + AnsiColor.blue.text + "$3" + AnsiColor.reset.text,
            emoji: "✗",
            emojiColor: AnsiColor.red,
            indent: 4
        ))
        replacers[.testSummary] = .ignore

        replacers[.compileError] = .replacePattern(PrettyReplacePattern(
            pattern: "^(.*) error: (.*)$",
            template: "$1" + " "
                + AnsiColor.red.text + "$2" + AnsiColor.reset.text,
            emoji: "❌ "
        ))
        replacers[.compileStart] = .color(.cyan)

        replacers[.compileWarning] = .replacePattern(PrettyReplacePattern(
            pattern: "^(.*) warning: (.*)$",
            template: "$1" + " "
                + AnsiColor.yellow.text + "$2" + AnsiColor.reset.text,
            emoji: "⚠️ "
        ))

        replacers[.compileNote] = .replacePattern(PrettyReplacePattern(
            pattern: "^(.*) note: (.*)$",
            template: "$1" + " "
                + AnsiColor.blue.text + "$2" + AnsiColor.reset.text,
            emoji: "note:",
            emojiColor: AnsiColor.blue
        ))

        replacers[.linking] = .color(.white)
        replacers[.buildSummaryWithError] = .color(.red)
    }

    override func handle(formattedLine: FormattedLine, rawLine: String) {
        switch formattedLine.kind {
        case .testSuitePassed, .testSuiteFailed:
            if RegexPattern.allTestsFinished.test(line: rawLine) {
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

        if allTestsPassedPattern.test(line: line) {
            summary = allTestsPassedPattern.replace(line: line)
        } else if allTestsFailedPattern.test(line: line) {
            summary = allTestsFailedPattern.replace(line: line)
        } else {
            summary = line
        }

        allTestsSummary = summary

        guard !maskPrint else {
            return
        }

        print("\n" + summary)
    }
}

class PrettyReplacePattern: ReplacePattern {
    init(pattern: String, template: String = "", emoji: String, emojiColor: AnsiColor? = nil, indent: Int = 0) {
        let prettyEmoji: String
        if let emojiColor = emojiColor {
            prettyEmoji = emojiColor.text + emoji + AnsiColor.reset.text
        } else {
            prettyEmoji = emoji
        }

        let prettyTemplate = String(repeating: " ", count: indent)
            + prettyEmoji
            + " "
            + template
            + " "

        super.init(pattern: pattern, template: prettyTemplate, ansiColor: nil)
    }
}
