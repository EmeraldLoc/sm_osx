import UniformTypeIdentifiers
import AppKit

public let currentVersion = "v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "v0")"


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

public func showApp() {
    NSApp.setActivationPolicy(.regular)
    
    for window in NSApplication.shared.windows {
        if window.title == "sm_osx" {
            window.orderFrontRegardless()
        }
    }
}

func restartApp() -> Bool {
    let bundlePath = Bundle.main.bundlePath
    let command = "echo Restarting; sleep 1; open \"\(bundlePath)\""

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", command]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
        try process.run()
    } catch {
        print("Error restarting app:", error)
        return false
    }
    
    exit(0)
}

class AddingRepo: ObservableObject {
    static let shared = AddingRepo()
    var isCompiling = false
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            background()
        }
    }
}
