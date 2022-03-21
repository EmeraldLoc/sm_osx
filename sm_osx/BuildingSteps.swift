//
//  BuildingSteps.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/7/22.
//

import Foundation

enum CompilationProcess: String {
    case patching = "Patching..."
    case instDependencies = "Installing Dependencies..."
    case instRepo = "Downloading Repo..."
    case copyingFiles = "Copying Files..."
    case compiling = "Compiling, this may take a while, please be patient."
    case finishingUp = "Finishing Up..."
    case finished = "Finshed!"
    case nothing = ""
    case error = "Error!"
    case rosetta = "Make sure you are runing this app with rosetta"
    case notRosetta = "Make sure you are NOT running this app with rosetta"
}
