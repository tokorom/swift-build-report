import Foundation

public enum AnsiColor {
    case reset
    case red
    case green

    private static let prefix = "\u{001B}[0;"
    private static let suffix = "m"

    var text: String {
        return AnsiColor.prefix + index + AnsiColor.suffix
    }

    private var index: String {
        switch self {
        case .reset: return "0"
        case .red: return "31"
        case .green: return "32"
        }
    }
}

class Reporter {
    func add(line: String) {
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
        Format(kind: .linking, pattern: "^Linking ", replacer: .color(.green)),
        Format(kind: .compileSwiftModule, pattern: "^Compile Swift Module ", replacer: .color(.green)),
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
        case compileSwiftModule
        case buildErrorSummary
    }
}

// MARK: - debug

let isPretty = true

// MARK: - setup

let stdin = FileHandle.standardInput
let stdout = FileHandle.standardOutput

let reporter = Reporter()
let formatter = Formatter()

/// MARK: - functions

func prettyFormat(for line: String) -> String {
    return formatter.parse(line: line).line
}

func handle(data: Data) {
    guard let string = String(data: data, encoding: .utf8) else {
        return
    }

    let lines = string.characters.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    for line in lines {
        if isPretty && !line.isEmpty {
            print(prettyFormat(for: line))
        } else {
            print(line)
        }

        reporter.add(line: line)
    }
}

// MARK: - main

stdin.readabilityHandler = { fileHandle in
    let data = fileHandle.availableData
    handle(data: data)
}

let _ = stdout.readDataToEndOfFile()
