//
//  DefaultFormatter.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import Foundation

class DefaultFormatter: Formatter {
    lazy var formats: [Format] = [
        Format(kind: .testSuiteStarted, pattern: "^Test Suite .* started "),
        Format(kind: .testSuitePassed, pattern: "^Test Suite .* passed at "),
        Format(kind: .testSuiteFailed, pattern: "^Test Suite .* failed at "),
        Format(kind: .testCaseStarted, pattern: "^Test Case .* started.$"),
        Format(kind: .testCasePassed, pattern: "^Test Case .* passed [(]"),
        Format(kind: .testCaseFailed, pattern: "^Test Case .* failed [(]"),
        Format(kind: .testError, pattern: "^\\/.* failed: .*- *$"),
        Format(kind: .testSummary, pattern: " Executed [0-9]+ tests?, with [0-9]+ failures? "),
        Format(kind: .compileError, pattern: "^\\/.* error: "),
        Format(kind: .compileStart, pattern: "^Compile Swift Module "),
        Format(kind: .errorPoint, pattern: " *\\^~* *"),
        Format(kind: .linking, pattern: "^Linking "),
        Format(kind: .buildSummaryWithError, pattern: " error: build had [0-9]+ command failures?$"),
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

    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.pattern)

    init(kind: FormattedLine.Kind, pattern: String) {
        self.kind = kind
        self.pattern = pattern
    }

    func test(line: String) -> Bool {
        let range = NSRange(location: 0, length: line.characters.count)
        if let _ = regexp?.firstMatch(in: line, range: range) {
            return true
        } else {
            return false
        }
    }
}

class ColorPattern {
    let pattern: String
    let ansiColor: AnsiColor

    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.pattern)

    init(pattern: String, ansiColor: AnsiColor) {
        self.pattern = pattern
        self.ansiColor = ansiColor
    }

    func replace(line: String) -> String? {
        let range = NSRange(location: 0, length: line.characters.count)
        let template = ansiColor.text + "$0" + AnsiColor.reset.text
        guard let result = regexp?.stringByReplacingMatches(in: line, range: range, withTemplate: template) else {
            return line
        }
        return result
    }
}

class ReplacePattern {
    let pattern: String
    let template: String
    let ansiColor: AnsiColor?

    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.pattern)

    init(pattern: String, template: String = "", ansiColor: AnsiColor? = nil) {
        self.pattern = pattern
        self.template = template
        self.ansiColor = ansiColor
    }

    func test(line: String) -> Bool {
        let range = NSRange(location: 0, length: line.characters.count)
        if let _ = regexp?.firstMatch(in: line, range: range) {
            return true
        } else {
            return false
        }
    }

    func replace(line: String) -> String? {
        let range = NSRange(location: 0, length: line.characters.count)
        let colorTemplate: String
        if let ansiColor = ansiColor {
            colorTemplate = ansiColor.text + template + AnsiColor.reset.text
        } else {
            colorTemplate = template
        }
        guard let result = regexp?.stringByReplacingMatches(in: line, range: range, withTemplate: colorTemplate) else {
            return line
        }
        return result
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
