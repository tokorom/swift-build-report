//
//  SimpleFormatter.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import Foundation

class SimpleFormatter: DefaultFormatter {
    override init() {
        super.init()

        replacers[.testSuiteStarted] = .color(.white)
        replacers[.testSuitePassed] = .color(.green)
        replacers[.testSuiteFailed] = .color(.red)
        replacers[.testCaseStarted] = .color(.white)
        replacers[.testCasePassed] = .color(.green)
        replacers[.testCaseFailed] = .color(.red)
        replacers[.errorPoint] = .color(.cyan)
        replacers[.testError] = .colorPatterns([
            ColorPattern(pattern: " \\([^()]+\\) ", ansiColor: .blue),
            ColorPattern(pattern: "^.*$", ansiColor: .red),
        ])
        replacers[.testSummary] = .colorPatterns([
            ColorPattern(pattern: "0 failures [(]0 unexpected[)]", ansiColor: .green),
            ColorPattern(pattern: "[1-9][0-9]* failures? [(][0-9]+ unexpected[)]", ansiColor: .red),
        ])
        replacers[.compileError] = .color(.red)
        replacers[.compileWarning] = .color(.yellow)
        replacers[.compileNote] = .color(.blue)
        replacers[.compileStart] = .color(.cyan)
        replacers[.linking] = .color(.green)
        replacers[.buildSummaryWithError] = .color(.red)
    }
}
