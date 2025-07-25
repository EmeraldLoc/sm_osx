import AppKit

class Shell {
    @discardableResult
    func shell(_ command: String) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-cl", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        } catch {
            return "Failed to run command: \(error)"
        }
    }
    
    @discardableResult
    func shellAsync(_ command: String) async -> Bool {
        let (success, _) = await shellAsync(command)
        return success
    }
    
    @discardableResult
    func shellAsync(_ command: String) async -> (Bool, String) {
        var log = ""
        let success = await shellAsync(command) { output in
            log += output + "\n"
        }
        return (success, log)
    }
    
    @discardableResult
    func shellAsync(_ command: String, logHandler: @escaping (String) -> Void) async -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-cl", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let handle = pipe.fileHandleForReading

        do {
            try process.run()
        } catch {
            logHandler("Failed to run command: \(error)\n")
            return false
        }

        do {
            for try await line in handle.bytes.lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    logHandler(trimmed)
                }
            }
        } catch {
            logHandler("Error reading process output: \(error)\n")
        }

        process.waitUntilExit()
        
        if process.terminationReason == .exit && process.terminationStatus == 0 {
            return true
        } else {
            logHandler("Process crashed or exited abnormally.\n")
            return false
        }
    }
}
