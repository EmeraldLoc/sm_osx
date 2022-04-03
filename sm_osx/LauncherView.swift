//
//  LauncherView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 4/2/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct LauncherView: View {
    
    @State var repoView = false
    @State var shell = RomView(patch: [Patches](), repo: .sm64ex, repoView: .constant(false))
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @State var existingRepo = URL(string: "")
    @State var repoTitle = ""
    @State var currentVersion = "v1.1.0\n"
    @State var updateAlert = false
    @State var latestVersion = ""
    @AppStorage("firstLaunch") var firstLaunch = true
    let sm64: UTType = .init(filenameExtension: "f3dex2e")!
    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.unixExecutable, sm64]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                if !launcherRepos.isEmpty {
                    List {
                        ForEach(launcherRepos) { LauncherRepo in
                            HStack {
                                
                                let i = launcherRepos.firstIndex(of: LauncherRepo) ?? 0
                                
                                    
                                Text(LauncherRepo.title  ?? "")
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    for i in 0...launcherRepos.count - 1 {
                                        launcherRepos[i].isEditing = false
                                    }
                                    
                                    launcherRepos[i].isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                }.popover(isPresented: Binding.constant(launcherRepos[i].isEditing)) {
                                    
                                    HStack {
                                        TextField("Name of Repo", text: $repoTitle)
                                            .onChange(of: repoTitle) { _ in
                                                launcherRepos[i].title = repoTitle
                                                
                                                do {
                                                    try moc.save()
                                                }
                                                catch {
                                                    print("Its broken \(error)")
                                                }
                                            }
                                    }.onAppear {repoTitle = launcherRepos[i].title ?? ""}
                                }
                                
                                Button(action: {
                                    
                                    let launcherRepo = launcherRepos[i]
                                    
                                    moc.delete(launcherRepo)
                                    
                                    do {
                                        try moc.save()
                                    }
                                    catch {
                                        print("Error: its broken: \(error)")
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                
                                Button(action: {
                                    try? print(shell.shell("\(LauncherRepo.path ?? "its broken")"))
                                    
                                    print(LauncherRepo.path ?? "")
                                }) {
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                            }
                        }
                    }
                }
                else {
                    
                    Spacer()
                    
                    Text("You have no repos, add a repo to begin!")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
                
                Button(action:{
                    repoView = true
                }) {
                    Text("Add New Repo")
                }.buttonStyle(.borderedProminent).sheet(isPresented: $repoView) {
                    RepoView(repoView: $repoView)
                        .frame(minWidth: 750, minHeight: 500)
                }
                
                Button("Add Existing Repo") {
                    existingRepo = showOpenPanel()
                    
                    if existingRepo != nil {
                    
                        let repo = LauncherRepos(context: moc)
                        
                        repo.title = "Repo \(launcherRepos.count)"
                        repo.path = existingRepo?.path
                        
                        do {
                            try moc.save()
                        }
                        catch {
                            print("it BROKE \(error)")
                        }
                    }
                }
                
                Text("Homebrew is REQUIRED for this software to work, please install homebrew at brew.sh")
                    .padding(.horizontal)
                
                Button(action:{
                    print(try! shell.shell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                }) {
                    Text("Install Dependencies")
                }.buttonStyle(.bordered).padding(.vertical)
            }
        }.onAppear {
            
            latestVersion = try! shell.shell("curl https://github.com/EmeraldLoc/sm_osx/releases/latest -s | grep -o 'v[0-9].[0-9].[0-9]*' | sort -u")
            
            print("Latest Version: \(latestVersion), Current Version: \(currentVersion)")
            
            if latestVersion != currentVersion && !latestVersion.isEmpty {
                updateAlert = true
            }
            
            if firstLaunch {
                try? shell.shell("cd ~/ && mkdir SM64Repos")
            }
            
            if launcherRepos.isEmpty {return}
            
            for i in 0...launcherRepos.count - 1 {
                launcherRepos[i].isEditing = false
            }
            
        }.alert("An Update is Avalible", isPresented: $updateAlert) {
            Button("Update", role: .none) {
                print(try! shell.shell("cd ~/Downloads && wget https://github.com/EmeraldLoc/sm_osx/releases/latest/download/sm_osx.zip && unzip sm_osx.zip && rm -rf sm_osx.zip /Applications/sm_osx.app && mv sm_osx.app /Applications"))
                
                exit(0)
            }
            
            Button("Not now", role: .cancel) {}
        }
    }
}

struct LauncherView_Previews: PreviewProvider {
    static var previews: some View {
        LauncherView()
    }
}
