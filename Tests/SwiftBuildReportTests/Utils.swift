//
//  Utils.swift
//
//  Created by ToKoRo on 2016-12-10.
//

import Foundation

class Utils {
    var colorCodePattern = "\u{001B}\\[0;[0-9]+m"
    lazy var regexp: NSRegularExpression? = try? NSRegularExpression(pattern: self.colorCodePattern)

    func removeColorCode(_ line: String) -> String {
        let range = NSRange(location: 0, length: line.characters.count)
        guard let result = regexp?.stringByReplacingMatches(in: line, range: range, withTemplate: "") else {
            return line
        }
        return result
    }
}
