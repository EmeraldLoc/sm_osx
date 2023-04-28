//

import SwiftUI

struct LauncherGridView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.openWindow) var openWindow
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var existingRepo: URL?
    let layout = [GridItem(.adaptive(minimum: 260))]
    
    private func launcherShell(_ command: String) {
        
        let process = Process()
        var output = ""
        process.launchPath = "/bin/zsh"
        process.arguments = ["-cl", "\(command)"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                output.append(line)
            } else {
                print("Error decoding data, aaaa: \(pipe.availableData)")
            }
        }
        
        NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: process, queue: nil, using: { _ in
            if process.terminationStatus != 0 {
                
                if NSApp.activationPolicy() == .prohibited {
                    showApp()
                }
                
                openWindow(id: "crash-log", value: output)
            }
        })
        
        try? process.run()
    }
    
    var body: some View {
        LazyVGrid(columns: layout) {
            ForEach(launcherRepos) { LauncherRepo in
                let i = launcherRepos.firstIndex(of: LauncherRepo) ?? 0
                VStack {
                    Button {
                        
                        if launcherRepos.isEmpty { return }
                        
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                        
                        launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")")
                        
                        print(LauncherRepo.path ?? "")
                    } label: {
                        if !launcherRepos.isEmpty {
                            if NSImage(contentsOf: URL(fileURLWithPath: LauncherRepo.imagePath ?? "")) == nil {
                                GroupBox {
                                    Text(LauncherRepo.title ?? "")
                                        .frame(width: 250, height: 140)
                                }
                            } else {
                                VStack {
                                    Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: LauncherRepo.imagePath ?? "")) ?? NSImage())
                                        .resizable()
                                }
                            }
                        }
                    }.buttonStyle(PlayHover(image: LauncherRepo.imagePath ?? ""))
                    
                    if launcherRepos[i].imagePath != nil && NSImage(contentsOf: URL(fileURLWithPath: LauncherRepo.imagePath ?? "")) != nil {
                        Text(LauncherRepo.title ?? "Unknown Title")
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            
                            if launcherRepos.isEmpty { return }
                            
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                            
                            openWindow(id: "regular-log", value: i)
                            
                            print(LauncherRepo.path ?? "")
                        }) {
                            Text("Log")
                            
                            Image(systemName: "play.fill")
                        }
                        
                        Button(action: {
                            
                            if launcherRepos.isEmpty { return }
                            
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                            
                            let launcherRepo = launcherRepos[i]
                            
                            moc.delete(launcherRepo)
                            
                            do {
                                try withAnimation {
                                    try moc.save()
                                }
                                reloadMenuBarLauncher = true
                            }
                            catch {
                                print("Error: its broken: \(error)")
                            }
                        }) {
                            Text("Remove Repo")
                        }
                        
                        Button(action: {
                            
                            if launcherRepos.isEmpty { return }
                            
                            for iEdit in 0...launcherRepos.count - 1 {
                                launcherRepos[iEdit].isEditing = false
                            }
                            
                            launcherRepos[i].isEditing = true
                        }) {
                            Text("Edit \(Image(systemName: "pencil"))")
                        }
                        
                    } label: {
                        Text("Options")
                    }.frame(maxWidth: 250)
                }.sheet(isPresented: .constant(LauncherRepo.isEditing)) {
                    LauncherEditView(i: i, existingRepo: $existingRepo, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                }
            }
        }.padding(15)
    }
}
