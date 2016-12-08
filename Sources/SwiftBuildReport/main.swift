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
let stdout = FileHandle.standardOutput

let reporter = Reporter()
let formatter = Formatter()

/// MARK: - functions

func printIfNeeded(for line: String) {
    if isPretty && !line.isEmpty {
        let formatted = formatter.parse(line: line).line
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
        printIfNeeded(for: line)
        reportIfNeeded(for: line)
    }
}

// MARK: - main

stdin.readabilityHandler = { fileHandle in
    let data = fileHandle.availableData
    handle(data: data)
}

let _ = stdout.readDataToEndOfFile()
