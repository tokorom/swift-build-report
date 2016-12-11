//
//  DefaultIgnoreLines.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import Foundation

class DefaultIgnoreLines: IgnoreLines {
    lazy var ignorePatterns: [RegexPattern] = [
        RegexPattern("^npm ERR! "),
        RegexPattern("^npm WARN "),
    ]

    func ignore(line: String) -> Bool {
        for pattern in ignorePatterns {
            if pattern.test(line: line) {
                return true
            }
        }
        return false
    }
}
