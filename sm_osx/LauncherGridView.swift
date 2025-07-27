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
    @State var presentEditSheet = false
    @State var presentEditItem = 0
    let layout = [GridItem(.adaptive(minimum: 260))]
    
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
                        
                        Task {
                            let (success, logs) = await Shell().shellAsync("\(launcherRepos[i].path ?? "its broken") \(launcherRepos[i].args ?? "")")
                            
                            if !success {
                                if NSApp.activationPolicy() == .prohibited {
                                    showApp()
                                }
                                
                                openWindow(id: "crash-log", value: logs)
                            }
                        }
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
                                presentEditItem = i
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
                            Image(systemName: "chevron.down")
                        }
                    }
                    .menuIndicator(.hidden)
                    .fixedSize()
                    .bold()
                    .padding(.bottom)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $presentEditSheet) {
            LauncherEditView(i: presentEditItem, existingRepo: $existingRepo, reloadMenuBarLauncher: $reloadMenuBarLauncher)
        }
        .alert("Are You Sure You Want to Remove the Repo?", isPresented: $removeEntireRepo) {
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
        .alert("Remove Repo \(launcherRepos.isEmpty ? "" : launcherRepos[item ?? 0].title ?? "")?", isPresented: $removeRepo) {
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
