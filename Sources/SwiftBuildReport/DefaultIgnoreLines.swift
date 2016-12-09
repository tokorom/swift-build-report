//
//  DefaultIgnoreLines.swift
//
//  Created by ToKoRo on 2016-12-09.
//

import Foundation

class DefaultIgnoreLines: IgnoreLines {
    lazy var ignorePatterns: [Pattern] = [
        Pattern("^npm ERR! "),
        Pattern("^npm WARN "),
    ]

    func ignore(line: String) -> Bool {
        for pattern in ignorePatterns {
            if pattern.test(line: line) {
                return true
            }
        }
        return false
    }

    class Pattern {
        let string: String
        lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.string)

        init(_ string: String) {
            self.string = string
        }

        func test(line: String) -> Bool {
            let range = NSRange(location: 0, length: line.characters.count)
            if let _ = regexp?.firstMatch(in: line, range: range) {
                return true
            } else {
                return false
            }
        }
    }
}
