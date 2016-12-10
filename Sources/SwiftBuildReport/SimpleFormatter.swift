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
        replacers[.testSuiteFailed] = .color(.green)
        replacers[.testCaseStarted] = .color(.white)
        replacers[.testCasePassed] = .color(.green)
        replacers[.testCaseFailed] = .color(.red)
        replacers[.testErrorPoint] = .color(.cyan)
        replacers[.testError] = .patterns([
            ReplacePattern(pattern: " \\([^()]+\\) ", ansiColor: .blue),
            ReplacePattern(pattern: "^.*$", ansiColor: .red),
        ])
        replacers[.testSummary] = .patterns([
            ReplacePattern(pattern: "0 failures [(]0 unexpected[)]", ansiColor: .green),
            ReplacePattern(pattern: "[1-9][0-9]* failures? [(][0-9]+ unexpected[)]", ansiColor: .red),
        ])
        replacers[.compileError] = .color(.red)
        replacers[.compileStart] = .color(.cyan)
        replacers[.linking] = .color(.green)
        replacers[.buildSummaryWithError] = .color(.red)
    }
}
