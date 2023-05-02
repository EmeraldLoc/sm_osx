
import AppKit

class Shell {
    @discardableResult
    func shell(_ command: String, _ waitTillExit: Bool = true) -> String {
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
                output.append(line)
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
            
            outHandle.stopReadingIfPassedEOF()
        }
        
        do {
            try process.run()
        } catch {
            print("Oh no, it failed to run!! DISASTER: \(error)")
        }
        
        if waitTillExit {
            process.waitUntilExit()
        }
        
        return output
    }
}

extension FileHandle {
    func stopReadingIfPassedEOF() {
        if self.availableData.count == 0 {
            readabilityHandler = nil
        }
    }
}
