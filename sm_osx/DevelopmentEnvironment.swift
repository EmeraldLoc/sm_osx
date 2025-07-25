
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
                        Task {
                            let (success, logs) = await Shell().shellAsync("\(fullExecPath) \(arguments)")
                            
                            if !success {
                                if NSApp.activationPolicy() == .prohibited {
                                    showApp()
                                }
                                
                                openWindow(id: "crash-log", value: logs)
                            }
                        }
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
