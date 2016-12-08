//
//  Formatter.swift
//
//  Created by ToKoRo on 2016-12-08.
//

import Foundation

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

    enum Replacer {
        case color(AnsiColor)

        func replace(line: String) -> String {
            switch self {
            case .color(let color):
                return color.text + line + AnsiColor.reset.text
            }
        }
    }
}

class Formatter {
    lazy var formats: [Format] = [
        // swift build
        Format(kind: .linking, pattern: "^Linking ", replacer: .color(.green)),
        Format(kind: .compileStart, pattern: "^Compile Swift Module ", replacer: .color(.cyan)),
        Format(kind: .compileError, pattern: "^\\/", replacer: .color(.red)),
        // npm
        Format(kind: .npmError, pattern: "^npm ERR! ", replacer: .color(.red)),
        Format(kind: .npmWarning, pattern: "^npm WARN ", replacer: .color(.yellow)),
    ]

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
        case normal
        case compileError
        case compileErrorSupplement
        case linking
        case compileStart
        case buildErrorSummary

        case npmError
        case npmWarning
    }
}
