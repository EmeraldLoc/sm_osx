//
//  CompilationSpeed.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/11/22.
//

import Foundation

enum Speed: String {
    case slow = ""
    case normal = "-j2"
    case fast = "-j3"
    case veryFast = "-j6"
    case fastest = "-j$(nproc)"
}
