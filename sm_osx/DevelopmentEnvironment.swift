
import SwiftUI

struct DevelopmentEnvironment: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var fullCompileCommands: String
    @Binding var repo: Repo
    @Binding var execPath: String
    @Binding var doLauncher: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var repoView: Bool
    @Binding var recompileCommands: String
    @Binding var alreadyCompiled: Bool
    @State var compileCommand = ""
    @State var compileRepo = false
    @State var fullExecPath = ""
    @State var arguments = ""
    @Environment(\.openWindow) var openWindow
    
    func launcherShell(_ command: String) {
        
        let process = Process()
        var output = ""
        process.launchPath = "/bin/zsh"
        process.arguments = ["-cl", "\(command)"]
        
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
        
        var observer : NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: process, queue: nil) { [observer] _ in
            if process.terminationStatus != 0 {
                
                if NSApp.activationPolicy() == .prohibited {
                    showApp()
                }
                
                openWindow(id: "crash-log", value: output)
            }
            
            NotificationCenter.default.removeObserver(observer as Any)
        }
        
        try? process.run()
    }
    
    var body: some View {
        VStack {
            Text("Development Environment")
                .lineLimit(nil)
                .padding(.top)
            
            GroupBox {
                VStack() {
                    
                    TextField("Arguments", text: $arguments)
                        .disabled(!alreadyCompiled)
                    
                    Button("Launch") {
                        launcherShell("\(fullExecPath) \(arguments)")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!alreadyCompiled)
                    
                    Button("Open Repo in Finder") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo.name)")
                    }.disabled(!alreadyCompiled)
                    
                    Button("Recompile from Scratch") {
                        compileCommand = fullCompileCommands
                        compileRepo = true
                    }.disabled(!alreadyCompiled)
                    
                    Button(alreadyCompiled ? "Recompile" : "Compile") {
                        if alreadyCompiled {
                            compileCommand = recompileCommands
                        } else {
                            compileCommand = fullCompileCommands
                        }
                        
                        compileRepo = true
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sheet(isPresented: $compileRepo) {
                    CompilationView(compileCommands: $compileCommand, repo: $repo, execPath: $execPath, doLauncher: $doLauncher, reloadMenuBarLauncher: $reloadMenuBarLauncher, finishedCompiling: $alreadyCompiled, developmentEnvironment: .constant(true), fullExecPath: $fullExecPath)
                }
            }
            
            Spacer()
            
            HStack {
                Button {
                    repoView = false
                } label: {
                    Text("Cancel")
                }
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}
