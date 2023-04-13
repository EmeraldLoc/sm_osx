
import SwiftUI
import Cocoa

class LaunchRepoAppleScript: ObservableObject {
    static let shared = LaunchRepoAppleScript()
    @Published var repoID = ""
}


class LaunchScriptCommand: NSScriptCommand {
    
    var launcherRepoAppleScript = LaunchRepoAppleScript.shared
    
    override func performDefaultImplementation() -> Any? {
        let repoId = self.evaluatedArguments!["Repo"] as! String
        print("Launching Repo With ID \(repoId)")
        launcherRepoAppleScript.repoID = repoId
        return "Launching Repo With ID \(repoId)"
    }
}
