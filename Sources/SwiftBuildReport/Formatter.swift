//
//  Formatter.swift
//
//  Created by ToKoRo on 2016-12-08.
//

import Foundation

public protocol Formatter {
    func format(line: String) -> String
}
