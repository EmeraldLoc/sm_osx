//

import SwiftUI

struct LauncherListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.openWindow) var openWindow
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var existingRepo: URL?
    @State var removeEntireRepo = false
    @State var removeRepo = false
    @State var item: Int? = nil
    @State var presentEditSheet = false
    
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
            ForEach(launcherRepos) { LauncherRepo in
                
                let i = launcherRepos.firstIndex(of: LauncherRepo) ?? 0
                
                Form {
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
                                presentEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .labelStyle(.titleAndIcon)
                            }
                            
                            Button {
                                if launcherRepos.isEmpty { return }
                                
                                for i in 0...launcherRepos.count - 1 {
                                    launcherRepos[i].isEditing = false
                                }
                                
                                item = i
                                removeRepo = true
                            } label: {
                                Label("Remove Repo", systemImage: "trash")
                                    .labelStyle(.titleAndIcon)
                            }
                        } label: {
                            Text("Options")
                        }
                        
                        Button {
                            if launcherRepos.isEmpty { return }
                            
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                            
                            launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")")
                            
                            print(LauncherRepo.path ?? "")
                        } label: {
                            Label("Play", systemImage: "play.fill")
                                .labelStyle(.titleAndIcon)
                        }
                    }.sheet(isPresented: $presentEditSheet) {
                        LauncherEditView(i: i, existingRepo: $existingRepo, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                    }
                }
            }.alert("Are You Sure You Want to Remove the Repo?", isPresented: $removeEntireRepo) {
                Button("Yes", role: .destructive) {
                    
                    if launcherRepos.isEmpty { return }
                    
                    let launcherRepo = launcherRepos[item!]
                    
                    let path = URL(filePath: (launcherRepo.path!)).deletingLastPathComponent().path()
                    
                    Shell().shell("rm -rf \(path)")
                    
                    moc.delete(launcherRepo)
                    
                    do {
                        try withAnimation {
                            try moc.save()
                        }
                        reloadMenuBarLauncher = true
                    } catch {
                        print("Error: its broken: \(error)")
                    }
                    
                    item = nil
                }
                
                Button("No", role: .cancel) {}
            } message: {
                Text("Make sure there are no important files in that folder!")
            }
        }.alert("Remove Repo \(launcherRepos[item ?? 0].title ?? "")?", isPresented: $removeRepo) {
            Button("Remove Repo", role: .destructive) {
                removeEntireRepo = true
            }
            
            Button("Remove Entry", role: .destructive) {
                if item != nil {
                    if launcherRepos.isEmpty { return }
                    
                    let launcherRepo = launcherRepos[item!]
                    
                    moc.delete(launcherRepo)
                    
                    do {
                        try withAnimation {
                            try moc.save()
                        }
                        reloadMenuBarLauncher = true
                    } catch {
                        print("Error: its broken: \(error)")
                    }
                    
                    item = nil
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
}
