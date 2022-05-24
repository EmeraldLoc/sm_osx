//
//  BuildingSteps.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/7/22.
//

import Foundation

enum CompStatus: Double {
    case patching = 45
    case instDependencies = 2
    case instRepo = 5
    case copyingFiles = 15
    case compiling = 65
    case finishingUp = 90
    case finished = 100
    case nothing = 0
}
