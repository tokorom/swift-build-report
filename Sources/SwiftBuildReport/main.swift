//
//  main.swift
//
//  Created by ToKoRo on 2016-12-07.
//

import Foundation
import Commander

// MARK: - enums

enum FormatKind: String {
    case pretty = "pretty"
    case simple = "simple"

    var formatter: Formatter {
        switch self {
        case .pretty: return PrettyFormatter()
        case .simple: return SimpleFormatter()
        }
    }
}

enum ReportKind: String {
    case `default` = "default"

    var reporter: Reporter {
        switch self {
        case .default: return DefaultReporter()
        }
    }
}

enum IgnoreKind: String {
    case `default` = "default"

    var ignoreLines: IgnoreLines {
        switch self {
        case .default: return DefaultIgnoreLines()
        }
    }
}

// MARK: - main class

class Main {
    let formatter: Formatter?
    let reporter: Reporter?
    let ignoreLines: IgnoreLines?

    lazy var stdin: FileHandle = FileHandle.standardInput
    var last: String?

    init(formatter: Formatter?, reporter: Reporter?, ignoreLines: IgnoreLines?) {
        self.formatter = formatter
        self.reporter = reporter
        self.ignoreLines = ignoreLines
    }

    func run() {
        printStartMessageIfNeeded()

        while waitAndReadAvailableData() {}

        printSumamryIfNeeded()
    }

    func printStartMessageIfNeeded() {
        guard let line = formatter?.startMessage else {
            return
        }
        print(line)
    }

    func printIfNeeded(for line: String) {
        if !line.isEmpty, let formatter = formatter {
            if let formatted = formatter.format(line: line) {
                print(formatted)
            }
        } else {
            print(line)
        }
    }

    func printSumamryIfNeeded() {
        guard let line = formatter?.summary else {
            return
        }
        print(line)
    }

    func reportIfNeeded(for line: String) {
        reporter?.send(line: line)
    }

    func handle(data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        let lineString: String
        if let last = last {
            lineString = last + string
        } else {
            lineString = string
        }

        var lines = lineString.characters.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        self.last = lines.popLast()

        for line in lines {
            guard !(ignoreLines?.ignore(line: line) ?? false) else {
                continue
            }
            printIfNeeded(for: line)
            reportIfNeeded(for: line)
        }
    }

    func waitAndReadAvailableData() -> Bool {
        let data = stdin.availableData

        guard 0 < data.count else {
            return false
        }

        handle(data: data)
        return true
    }
}

// MARK: - command

command(
  Option("format", "pretty", description: "the print format for swift build/text (pretty or simple)"),
  Option("report", "none", description: "the report format for swift build/text (default or none)"),
  Option("output", "./.build/errors.txt", description: "the output path for error report"),
  Option("ignore", "default", description: "the setting for ignore lines (default or none)")
) { (formatParam: String, reportParam: String, outputPath: String, ignoreParam: String) in
    let formatter = FormatKind(rawValue: formatParam)?.formatter
    var reporter = ReportKind(rawValue: reportParam)?.reporter
    let ignoreLines = IgnoreKind(rawValue: ignoreParam)?.ignoreLines

    reporter?.outputPath = outputPath

    let main = Main(formatter: formatter, reporter: reporter, ignoreLines: ignoreLines)
    main.run()
}.run()
