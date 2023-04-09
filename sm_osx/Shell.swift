
import SwiftUI

class Shell {
    
    private func fetchLaunchers(using dataController: DataController) -> [LauncherRepos] {
        let fetchRequest: NSFetchRequest<LauncherRepos>
        fetchRequest = LauncherRepos.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        let objects = try? dataController.container.viewContext.fetch(fetchRequest)
        
        return objects ?? []
    }
    
    func intelShell(_ command: String, _ waitTillExit: Bool = true) throws -> String {
        let process = Process()
        var output = ""
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-cl", "arch -x86_64 /bin/zsh -cl '\(command)'"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                
                output.append(line)
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
        }
        
        try process.run()
        if waitTillExit {
            process.waitUntilExit()
        }
        
        return output
    }
    
    func scriptShell(_ command: String) throws -> String {
        
        var error: NSDictionary?
        var returnOutput = ""
        
        if let scriptObject = NSAppleScript(source: "do shell script \"arch -arm64 /bin/zsh -cl '\(command)' 2>&1\" ") {
            let output = scriptObject.executeAndReturnError(&error)
            returnOutput.append(output.stringValue ?? "")
            print(output.stringValue ?? "")
            if (error != nil) {
                print("error: \(String(describing: error))")
            }
        }
        
        return returnOutput
    }
    
    func shell(_ command: String, _ waitTillExit: Bool = true) throws -> String {
        let process = Process()
        var output = ""
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-cl", command]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                
                output.append(line)
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
        }
        
        try process.run()
        if waitTillExit {
            process.waitUntilExit()
        }
        
        return output
    }
}
