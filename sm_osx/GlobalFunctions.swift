//
//  GlobalFunctions.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 6/14/22.
//

import Foundation
import UniformTypeIdentifiers
import AppKit

public let currentVersion = "v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "v0")\n"


public func isArm() -> Bool {
    #if arch(x86_64)
        return false
    #else
        return true
    #endif
}

public func showExecFilePanel() -> URL? {
    
    let sm64: UTType = .init(filenameExtension: "f3dex2e") ?? UTType.unixExecutable
    
    let openPanel = NSOpenPanel()
    openPanel.allowedContentTypes = [.unixExecutable, sm64]
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    let response = openPanel.runModal()
    return response == .OK ? openPanel.url : nil
}

public func checkForUpdates(updateAlert: inout Bool) {
    
    print(currentVersion)
    
    var latestVersion = ""
    
    do {
        latestVersion = try Shell().shell("curl -s https://raw.githubusercontent.com/EmeraldLoc/sm_osx/main/CurVer")
    }
    catch {
        print("Failed: \(error)")
    }
    
    if latestVersion != currentVersion && !latestVersion.isEmpty {
        updateAlert = true
    }
}
