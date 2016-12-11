//
//  DefaultReporter.swift
//
//  Created by ToKoRo on 2016-12-11.
//

import Foundation

class DefaultReporter: Reporter {
    var outputPath: String = ""
    var firstLine = true

    var fileHandleInstance: FileHandle? = nil

    var lastLine: String? = nil

    var maskFileAccess = false

    var fileHandle: FileHandle? {
        guard !maskFileAccess else {
            return nil
        }

        if let fileHandleInstance = fileHandleInstance {
            return fileHandleInstance
        }

        FileManager.default.createFile(atPath: outputPath, contents: nil, attributes: nil)
        fileHandleInstance = FileHandle(forWritingAtPath: outputPath)
        return fileHandleInstance
    }

    func send(line: String) {
        if RegexPattern.compileStart.test(line: line) {
            clearFileIfNeeded()
        } else if RegexPattern.testSuiteStarted.test(line: line) {
            clearFileIfNeeded()
        } else if RegexPattern.buildSummaryWithError.test(line: line) {
            firstLine = true
        } else if RegexPattern.allTestsFinished.test(line: line) {
            firstLine = true
        } else if RegexPattern.compileError.test(line: line) {
            write(line: line)
        } else if RegexPattern.compileWarning.test(line: line) {
            write(line: line)
        } else if RegexPattern.testError.test(line: line) {
            write(line: line)
        }
    }

    func write(line: String, addReturnCode: Bool = true) {
        self.lastLine = line

        guard
            let fileHandle = fileHandle,
            let data = line.data(using: .utf8)
        else {
            return
        }

        fileHandle.write(data)

        if addReturnCode {
            write(line: "\r\n", addReturnCode: false)
        }
    }

    func clearFileIfNeeded() {
        if firstLine {
            clearFile()
            firstLine = false
        }
    }

    func clearFile() {
        if !maskFileAccess {
            try? FileManager.default.removeItem(atPath: self.outputPath)
            fileHandleInstance = nil
            fileHandle?.seek(toFileOffset: 0)
        }
        lastLine = nil
    }
}
