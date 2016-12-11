//
//  DefaultFormatter.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import Foundation

class DefaultFormatter: Formatter {
    lazy var formats: [Format] = [
        Format(kind: .testSuiteStarted, pattern: RegexPattern.testSuiteStarted),
        Format(kind: .testSuitePassed, pattern: RegexPattern.testSuitePassed),
        Format(kind: .testSuiteFailed, pattern: RegexPattern.testSuiteFailed),
        Format(kind: .testCaseStarted, pattern: RegexPattern.testCaseStarted),
        Format(kind: .testCasePassed, pattern: RegexPattern.testCasePassed),
        Format(kind: .testCaseFailed, pattern: RegexPattern.testCaseFailed),
        Format(kind: .testError, pattern: RegexPattern.testError),
        Format(kind: .testSummary, pattern: RegexPattern.testSummary),
        Format(kind: .compileError, pattern: RegexPattern.compileError),
        Format(kind: .compileWarning, pattern: RegexPattern.compileWarning),
        Format(kind: .compileNote, pattern: RegexPattern.compileNote),
        Format(kind: .compileStart, pattern: RegexPattern.compileStart),
        Format(kind: .errorPoint, pattern: RegexPattern.errorPoint),
        Format(kind: .linking, pattern: RegexPattern.linking),
        Format(kind: .buildSummaryWithError, pattern: RegexPattern.buildSummaryWithError),
    ]

    var replacers: [FormattedLine.Kind: Replacer] = [:]

    var startMessage: String? {
        return nil
    }

    var summary: String? {
        return nil
    }

    init() {}

    func format(line: String) -> String? {
        let formattedLine = parse(line: line)
        return formattedLine.line
    }

    func parse(line: String) -> FormattedLine {
        for format in formats {
            if format.test(line: line) {
                let formatted = replace(line: line, for: format.kind)
                let formattedLine = FormattedLine(kind: format.kind, line: formatted)
                handle(formattedLine: formattedLine, rawLine: line)
                return formattedLine
            }
        }
        return FormattedLine(kind: .normal, line: line)
    }

    func replace(line: String, for kind: FormattedLine.Kind) -> String? {
        if let replacer = replacers[kind] {
            return replacer.replace(line: line)
        } else {
            return line
        }
    }

    func handle(formattedLine: FormattedLine, rawLine: String) {
    }
}

struct FormattedLine {
    let kind: Kind
    let line: String?

    enum Kind {
        case testSuiteStarted
        case testSuitePassed
        case testSuiteFailed
        case testCaseStarted
        case testCasePassed
        case testCaseFailed
        case testError
        case errorPoint
        case testSummary
        case compileError
        case compileWarning
        case compileNote
        case linking
        case compileStart
        case buildSummaryWithError
        case normal
    }
}

class Format {
    let kind: FormattedLine.Kind
    let pattern: RegexPattern

    init(kind: FormattedLine.Kind, pattern: RegexPattern) {
        self.kind = kind
        self.pattern = pattern
    }

    func test(line: String) -> Bool {
        return pattern.test(line: line)
    }
}

class ReplacePattern {
    let regexPattern: RegexPattern

    init(pattern: String, template: String = "", ansiColor: AnsiColor? = nil) {
        let replaceTemplate: String
        if let ansiColor = ansiColor {
            replaceTemplate = ansiColor.text + template + AnsiColor.reset.text
        } else {
            replaceTemplate = template
        }

        self.regexPattern = RegexPattern(pattern, replaceTemplate: replaceTemplate)
    }

    func test(line: String) -> Bool {
        return regexPattern.test(line: line)
    }

    func replace(line: String) -> String {
        return regexPattern.replace(line: line)
    }
}

class ColorPattern: ReplacePattern {
    init(pattern: String, ansiColor: AnsiColor) {
        super.init(pattern: pattern, template: "$0", ansiColor: ansiColor)
    }
}


enum Replacer {
    case color(AnsiColor)
    case colorPatterns([ColorPattern])
    case replacePattern(ReplacePattern)
    case ignore
    case custom((String) -> String?)

    func replace(line: String) -> String? {
        switch self {
        case .color(let color):
            return color.text + line + AnsiColor.reset.text
        case .colorPatterns(let colorPatterns):
            var result: String? = line
            for colorPattern in colorPatterns {
                guard let line = result else {
                    break
                }
                result = colorPattern.replace(line: line)
            }
            return result
        case .replacePattern(let replacePattern):
            return replacePattern.replace(line: line)
        case .ignore:
            return nil
        case .custom(let replaceFunction):
            return replaceFunction(line)
        }
    }
}
