//
//  main.swift
//
//  Created by ToKoRo on 2016-12-07.
//

import Foundation
import Commander

// MARK: - enums

enum FormatKind: String {
    case simple = "simple"

    var formatter: Formatter {
        switch self {
        case .simple: return DefaultFormatter()
        }
    }
}

enum ReportKind: String {
    case `default` = "default"

    var reporter: Reporter {
        fatalError("\(#function) is not implemented")
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

    init(formatter: Formatter?, reporter: Reporter?, ignoreLines: IgnoreLines?) {
        self.formatter = formatter
        self.reporter = reporter
        self.ignoreLines = ignoreLines
    }

    func run() {
        while waitAndReadAvailableData() {}
    }

    func printIfNeeded(for line: String) {
        if !line.isEmpty, let formatter = formatter {
            let formatted = formatter.format(line: line)
            print(formatted)
        } else {
            print(line)
        }
    }

    func reportIfNeeded(for line: String) {
        reporter?.add(line: line)
    }

    func handle(data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        let lines = string.characters.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
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
  Option("format", "simple", description: "the print format for swift build/text"),
  Option("report", "none", description: "the output path for error report"),
  Option("ignore", "default", description: "the setting for ignore lines (default or none)")
) { (formatParam: String, reportParam: String, ignoreParam: String) in
    let formatter = FormatKind(rawValue: formatParam)?.formatter
    let reporter = ReportKind(rawValue: reportParam)?.reporter
    let ignoreLines = IgnoreKind(rawValue: ignoreParam)?.ignoreLines

    let main = Main(formatter: formatter, reporter: reporter, ignoreLines: ignoreLines)
    main.run()
}.run()
