//

import SwiftUI

struct LauncherListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.openWindow) var openWindow
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var existingRepo: URL?
    
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
        ForEach(launcherRepos) { LauncherRepo in
            
            let i = launcherRepos.firstIndex(of: LauncherRepo) ?? 0
            
            HStack {
                Text(LauncherRepo.title ?? "Unknown Title")
                
                Spacer()
                
                Menu {
                    Button {
                        if launcherRepos.isEmpty { return }
                        
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                        
                        openWindow(id: "regular-log", value: i)
                        
                        print(LauncherRepo.path ?? "")
                    } label: {
                        Label("Log", systemImage: "play.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    
                    Button {
                        if launcherRepos.isEmpty { return }
                        
                        for iEdit in 0...launcherRepos.count - 1 {
                            launcherRepos[iEdit].isEditing = false
                        }
                        
                        launcherRepos[i].isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .labelStyle(.titleAndIcon)
                    }
                    
                    Button {
                        if launcherRepos.isEmpty { return }
                        
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                        
                        let launcherRepo = launcherRepos[i]
                        
                        moc.delete(launcherRepo)
                        
                        do {
                            try moc.save()
                            reloadMenuBarLauncher = true
                        }
                        catch {
                            print("Error: its broken: \(error)")
                        }
                    } label: {
                        Label("Trash", systemImage: "trash")
                            .labelStyle(.titleAndIcon)
                    }
                } label: {
                    Text("Options")
                }.frame(idealWidth: 80, maxWidth: 80)
                
                Button {
                    if launcherRepos.isEmpty { return }
                    
                    for i in 0...launcherRepos.count - 1 {
                        launcherRepos[i].isEditing = false
                    }
                    
                    try? launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")")
                    
                    print(LauncherRepo.path ?? "")
                } label: {
                    Label("Play", systemImage: "play.fill")
                }
            }.sheet(isPresented: .constant(LauncherRepo.isEditing)) {
                LauncherEditView(i: i, existingRepo: $existingRepo, reloadMenuBarLauncher: $reloadMenuBarLauncher)
            }.padding(.horizontal)
        }
    }
}
