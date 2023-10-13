//

import SwiftUI

struct LauncherGridView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.openWindow) var openWindow
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var existingRepo: URL?
    @State var removeEntireRepo = false
    @State var removeRepo = false
    @State var item: Int? = nil
    let layout = [GridItem(.adaptive(minimum: 260))]
    
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
                                    Text("")
                                        .frame(width: 250, height: 150)
                                }
                                .border(Color.clear, width: 0)
                            } else {
                                VStack {
                                    Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: LauncherRepo.imagePath ?? "")) ?? NSImage())
                                        .resizable()
                                }
                            }
                        }
                    }.buttonStyle(PlayHover(image: LauncherRepo.imagePath ?? ""))
                    
                    HStack {
                        Text(LauncherRepo.title ?? "Unknown Title")
                        
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
                                item = i
                                removeRepo = true
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
                            Text(Image(systemName: "chevron.down"))
                                .fontWeight(.bold)
                        }
                    }
                    .menuIndicator(.hidden)
                    .fixedSize()
                    .padding(.bottom)
                    
                    Spacer()
                }.sheet(isPresented: .constant(LauncherRepo.isEditing)) {
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
        .padding(15)
        .alert("Remove Repo \(launcherRepos[item ?? 0].title ?? "")?", isPresented: $removeRepo) {
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
