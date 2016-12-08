//
//  AnsiColor.swift
//
//  Created by ToKoRo on 2016-12-08.
//

import Foundation

public enum AnsiColor {
    case reset
    case black
    case red
    case green
    case yellow
    case blue
    case magenda
    case cyan
    case white

    private static let prefix = "\u{001B}[0;"
    private static let suffix = "m"

    var text: String {
        return AnsiColor.prefix + index + AnsiColor.suffix
    }

    private var index: String {
        switch self {
        case .reset: return "0"
        case .black: return "30"
        case .red: return "31"
        case .green: return "32"
        case .yellow: return "33"
        case .blue: return "34"
        case .magenda: return "35"
        case .cyan: return "36"
        case .white: return "37"
        }
    }
}
