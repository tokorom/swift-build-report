//
//  main.swift
//
//  Created by ToKoRo on 2016-12-07.
//

import Foundation

// MARK: - debug

let isPretty = true

// MARK: - setup

let stdin = FileHandle.standardInput

let reporter = Reporter()
let formatter: Formatter = DefaultFormatter()
let ignoreLines: IgnoreLines = DefaultIgnoreLines()

/// MARK: - functions

func printIfNeeded(for line: String) {
    if isPretty && !line.isEmpty {
        let formatted = formatter.format(line: line)
        print(formatted)
    } else {
        print(line)
    }
}

func reportIfNeeded(for line: String) {
    reporter.add(line: line)
}

func handle(data: Data) {
    guard let string = String(data: data, encoding: .utf8) else {
        return
    }

    let lines = string.characters.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    for line in lines {
        guard !ignoreLines.ignore(line: line) else {
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

// MARK: - main

while waitAndReadAvailableData() {}

exit(EXIT_SUCCESS)
