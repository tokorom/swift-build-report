//
//  AnsiColor.swift
//
//  Created by ToKoRo on 2016-12-08.
//

import Foundation

enum AnsiColor: Int {
    case reset = 0
    case black = 30
    case red = 31
    case green = 32
    case yellow = 33
    case blue = 34
    case magenda = 35
    case cyan = 36
    case white = 37
}

extension AnsiColor {
    var text: String {
        return AnsiColor.prefix + String(rawValue) + AnsiColor.suffix
    }
}

extension AnsiColor {
    fileprivate static let prefix = "\u{001B}[0;"
    fileprivate static let suffix = "m"
}
