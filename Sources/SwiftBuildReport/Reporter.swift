//
//  Reporter.swift
//
//  Created by ToKoRo on 2016-12-08.
//

import Foundation

protocol Reporter {
    var outputPath: String { get set }
    func send(line: String)
}
