//
//  SimpleFormatter.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import Foundation

class SimpleFormatter: Formatter {
    lazy var formats: [Format] = [
        Format(kind: .testSuiteStarted, pattern: "^Test Suite .* started ", replacer: .color(.white)),
        Format(kind: .testSuitePassed, pattern: "^Test Suite .* passed at ", replacer: .color(.green)),
        Format(kind: .testSuiteFailed, pattern: "^Test Suite .* failed at ", replacer: .color(.green)),
        Format(kind: .testCaseStarted, pattern: "^Test Case .* started.$", replacer: .color(.white)),
        Format(kind: .testCasePassed, pattern: "^Test Case .* passed [(]", replacer: .color(.green)),
        Format(kind: .testCaseFailed, pattern: "^Test Case .* failed [(]", replacer: .color(.red)),
        Format(kind: .testErrorPoint, pattern: " *\\^~* *", replacer: .color(.cyan)),
        Format(kind: .testError, pattern: "^\\/.* failed: .*- *$", replacer: .patterns([
            ReplacePattern(pattern: " \\([^()]+\\) ", ansiColor: .blue),
            ReplacePattern(pattern: "^.*$", ansiColor: .red),
        ])),
        Format(kind: .testSummary, pattern: " Executed [0-9]+ tests?, with [0-9]+ failures? ", replacer: .patterns([
            ReplacePattern(pattern: "0 failures [(]0 unexpected[)]", ansiColor: .green),
            ReplacePattern(pattern: "[1-9][0-9]* failures? [(][0-9]+ unexpected[)]", ansiColor: .red),
        ])),
        Format(kind: .compileError, pattern: "^\\/.* error: ", replacer: .color(.red)),
        Format(kind: .compileStart, pattern: "^Compile Swift Module ", replacer: .color(.cyan)),
        Format(kind: .linking, pattern: "^Linking ", replacer: .color(.green)),
        Format(kind: .buildSummaryWithError, pattern: " error: build had [0-9]+ command failures?$", replacer: .color(.red)),
    ]

    func format(line: String) -> String {
        let formattedLine = parse(line: line)
        return formattedLine.line
    }

    func parse(line: String) -> FormattedLine {
        for format in formats {
            if let formatted = format.test(line: line) {
                return FormattedLine(kind: format.kind, line: formatted)
            }
        }
        return FormattedLine(kind: .normal, line: line)
    }
}

struct FormattedLine {
    let kind: Kind
    let line: String

    enum Kind {
        case testSuiteStarted
        case testSuitePassed
        case testSuiteFailed
        case testCaseStarted
        case testCasePassed
        case testCaseFailed
        case testError
        case testErrorPoint
        case testSummary
        case compileError
        case compileErrorSupplement
        case linking
        case compileStart
        case buildSummaryWithError
        case normal
    }
}

class Format {
    let kind: FormattedLine.Kind
    let pattern: String
    let replacer: Replacer

    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.pattern)

    init(kind: FormattedLine.Kind, pattern: String, replacer: Replacer) {
        self.kind = kind
        self.pattern = pattern
        self.replacer = replacer
    }

    func test(line: String) -> String? {
        let range = NSRange(location: 0, length: line.characters.count)
        if let _ = regexp?.firstMatch(in: line, range: range) {
            return replacer.replace(line: line)
        }
        return nil
    }
}

class ReplacePattern {
    let pattern: String
    let ansiColor: AnsiColor

    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.pattern)

    init(pattern: String, ansiColor: AnsiColor) {
        self.pattern = pattern
        self.ansiColor = ansiColor
    }

    func replace(line: String) -> String {
        let range = NSRange(location: 0, length: line.characters.count)
        let template = ansiColor.text + "$0" + AnsiColor.reset.text
        guard let result = regexp?.stringByReplacingMatches(in: line, range: range, withTemplate: template) else {
            return line
        }
        return result
    }
}

enum Replacer {
    case color(AnsiColor)
    case patterns([ReplacePattern])
    case custom((String) -> String)

    func replace(line: String) -> String {
        switch self {
        case .color(let color):
            return color.text + line + AnsiColor.reset.text
        case .patterns(let replacePatterns):
            var result = line
            for replacePattern in replacePatterns {
                result = replacePattern.replace(line: result)
            }
            return result
        case .custom(let replaceFunction):
            return replaceFunction(line)
        }
    }
}
