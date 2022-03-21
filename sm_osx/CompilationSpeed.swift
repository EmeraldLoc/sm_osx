//
//  CompilationSpeed.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/11/22.
//

import Foundation

enum Speed: String {
    case slow = ""
    case fast = "-j2"
    case veryFast = "-j4"
    case fastest = "-j8"
}
