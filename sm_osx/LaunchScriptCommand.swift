
import SwiftUI
import Cocoa

class LaunchRepoAppleScript: ObservableObject {
    static let shared = LaunchRepoAppleScript()
    @Published var repoID = ""
    @Published var didOpenApp = false
}

class LaunchScriptCommand: NSScriptCommand {
    
    var launcherRepoAppleScript = LaunchRepoAppleScript.shared
    
    override func performDefaultImplementation() -> Any? {
        let repoId = self.evaluatedArguments?["Repo"] as? String ?? ""
        let menu = self.evaluatedArguments?["Menu"] as? String ?? ""
                
        if menu == "Yes" {
            launcherRepoAppleScript.didOpenApp = true
            print("App was closed, opening up in menu bar mode.")
        }
        if !repoId.isEmpty {
            print("Launching Repo With ID \(repoId)")
        }
        
        launcherRepoAppleScript.repoID = repoId
        return "Launching Repo With ID \(repoId)\nMenu: \(menu)"
    }
}
