//
//  GlobalFunctions.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 6/14/22.
//

import Foundation

public func isArm() -> Bool {
    #if arch(x86_64)
        return false
    #else
        return true
    #endif
}
