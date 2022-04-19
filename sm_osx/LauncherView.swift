//
//  LauncherView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 4/2/22.
//

import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct LauncherView: View {
    
    @State var repoView = false
    var shell = Shell()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @State var existingRepo = URL(string: "")
    @State var repoTitle = ""
    @State var currentVersion = "v1.1.3\n"
    @State var updateAlert = false
    @State var latestVersion = ""
    @State var repoArgs = ""
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
                                    
                                    for iEdit in 0...launcherRepos.count - 1 {
                                        launcherRepos[iEdit].isEditing = false
                                    }
                                    
                                    launcherRepos[i].isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                }.popover(isPresented: Binding.constant(launcherRepos[i].isEditing)) {
                                    
                                    VStack {
                                        TextField("Name of Repo", text: $repoTitle)
                                            .lineLimit(nil)
                                            .scaledToFill()
                                            .onChange(of: repoTitle) { _ in
                                                launcherRepos[i].title = repoTitle
                                                do {
                                                    try moc.save()
                                                }
                                                catch {
                                                    print("Its broken \(error)")
                                                }
                                            }
                                        TextField("Arguments", text: $repoArgs)
                                            .lineLimit(nil)
                                            .scaledToFill()
                                            .onChange(of: repoArgs) { _ in
                                                launcherRepos[i].args = repoArgs
                                                
                                                do {
                                                    try moc.save()
                                                }
                                                catch {
                                                    print("Its broken \(error)")
                                                }
                                            }
                                    }.onAppear {
                                        repoTitle = launcherRepos[i].title ?? ""
                                        repoArgs = launcherRepos[i].args ?? ""
                                    }
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
                                    try? print(shell.asyncShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", waitTillExit: false))
                                    
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
                        repo.args = ""
                        repo.id = UUID()
                        
                        do {
                            try moc.save()
                        }
                        catch {
                            print("it BROKE \(error)")
                        }
                    }
                }
                
                Button("Install Homebrew") {
                    print(shell.installBrew("/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""))
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Finished installing homebrew"
                    content.subtitle = "Homebrew is now installed. If this is your first time with homebrew, please hit the install dependencies button."
                    content.sound = UNNotificationSound.default

                    // show this notification instantly
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
                
                Text("Homebrew is REQUIRED for this software to work, please install homebrew at brew.sh")
                    .padding(.horizontal)
                
                Text("\nOptional: Homebrew Intel version is nice to have. Install by launching terminal with Rosetta and installing at brew.sh")
                    .padding(.horizontal)
                
                Button(action:{
                    print(try! shell.shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                    
                    print("its intel's turn nerd what an idiot man")
                    
                    print(try! shell.intelShell("/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Finished installing dependencies"
                    content.subtitle = "Dependencies are now installed."
                    content.sound = UNNotificationSound.default

                    // show this notification instantly
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
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

            try? print(shell.shell("cd ~/ && mkdir SM64Repos"))
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
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
