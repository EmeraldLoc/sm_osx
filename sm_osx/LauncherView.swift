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
    @AppStorage("devMode") var devMode = false
    var shell = Shell()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @State var existingRepo = URL(string: "")
    @State var repoTitle = ""
    @State var currentVersion = "v1.2.1\n"
    @State var updateAlert = false
    @State var latestVersion = ""
    @State var repoArgs = ""
    @State var crashStatus = false
    @State var crashLog = ""
    @State var readableCrashLog = ""
    @State var allowAddingRepos = true
    @State var beginLogging = false
    @AppStorage("firstLaunch") var firstLaunch = true
    @State var romURL = URL(string: "")
    @State var crashIndex = 0
    @State var logIndex = 0
    @State var homebrewText = ""
    let sm64: UTType = .init(filenameExtension: "f3dex2e") ?? UTType.unixExecutable
    let rom: UTType = .init(filenameExtension: "z64") ?? UTType.unixExecutable
    
    func launcherShell(_ command: String, index: Int, isLogging: Bool = false) throws -> String {
        self.launcherRepos[index].log = ""
        
        let task = Process()
        var output = ""
        task.launchPath = "/bin/zsh"
        task.arguments = ["-cl", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        var obs1 : NSObjectProtocol?
        obs1 = NotificationCenter.default.addObserver(forName: Notification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) {  notification -> Void in
            let data = outHandle.availableData
            
            if data.count > 0 {
                if let str = String(data: data, encoding: .utf8) {
                    output.append(str)
                    
                    self.launcherRepos[index].log!.append(str)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else   {
               print("EOF on stdout from process")
               NotificationCenter.default.removeObserver(obs1 as Any)
            }
        }

        var obs2 : NSObjectProtocol?
        obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil) { notification -> Void in
            print("terminated")
            
            if task.terminationStatus != 0 {
                self.launcherRepos[index].log?.append("\n A Crash has happend. Termination Status: \(task.terminationStatus)")
                
                crashIndex = index
                
                self.crashStatus = true
            }
            
            NotificationCenter.default.removeObserver(obs2 as Any)
        }
        
        try? task.run()
        
        return(output)
    }

    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.unixExecutable, sm64]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    
    func showOpenPanelForRom() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [rom]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    
    func checkRom(_ command: String) throws -> Bool {
        let task = Process()
        var output = false
        task.launchPath = "/bin/zsh"
        task.arguments = ["-cl", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        try? task.run()
        task.waitUntilExit()
        if task.terminationStatus != 0 {
            output = true
        }
        else {
            output = false
        }
        
        return(output)
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
                                
                                Menu {
                                    Button(action: {
                                        
                                        for i in 0...launcherRepos.count - 1 {
                                            launcherRepos[i].isEditing = false
                                        }
                                        
                                        print(try? launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", index: i))
                                        
                                        logIndex = i
                                        
                                        beginLogging = true
                                        
                                        print(LauncherRepo.path ?? "")
                                    }) {
                                        Text("Log")
                                        
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    
                                    Button(action: {
                                        
                                        for i in 0...launcherRepos.count - 1 {
                                            launcherRepos[i].isEditing = false
                                        }
                                        
                                        let launcherRepo = launcherRepos[i]
                                        
                                        moc.delete(launcherRepo)
                                        
                                        do {
                                            try moc.save()
                                        }
                                        catch {
                                            print("Error: its broken: \(error)")
                                        }
                                    }) {
                                        Text("Remove Repo")
                                    }
                                } label: {
                                    Text("...")
                                }.frame(width: 40)
                                
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
                                        
                                        Button("Change Repo") {
                                            existingRepo = showOpenPanel()
                                            
                                            launcherRepos[i].path = existingRepo?.path
                                            
                                            for i in 0...launcherRepos.count - 1 {
                                                launcherRepos[i].isEditing = false
                                            }
                                        }
                                    }.onAppear {
                                        repoTitle = launcherRepos[i].title ?? ""
                                        repoArgs = launcherRepos[i].args ?? ""
                                    }
                                }
                                
                                Button(action: {
                                    
                                    for i in 0...launcherRepos.count - 1 {
                                        launcherRepos[i].isEditing = false
                                    }
                                    
                                    print(try? launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", index: i))
                                    
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
                
                if allowAddingRepos {
                    Button(action:{
                        
                        if !launcherRepos.isEmpty {
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                        }
                        
                        romURL = showOpenPanelForRom()
                        
                        romURL? = URL(fileURLWithPath: romURL?.path.replacingOccurrences(of: " ", with: #"\ "#
                                                                                         , options: .literal, range: nil) ?? "")
                        
                        print(try? shell.shell("cp \(romURL?.path ?? "") ~/SM64Repos/baserom.us.z64") )
                        
                        if let doesExist = try? checkRom("ls ~/SM64Repos/baserom.us.z64") {
                            if doesExist {
                                allowAddingRepos = true
                            }
                            else {
                                allowAddingRepos = false
                            }
                        }
                    }) {
                        Text("Select Rom")
                    }
                }

                Button(action:{
                    
                    if !launcherRepos.isEmpty {
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                    }
                    
                    repoView = true
                }) {
                    Text("Add New Repo")
                }.buttonStyle(.borderedProminent).sheet(isPresented: $repoView) {
                    RepoView(repoView: $repoView)
                        .frame(minWidth: 750, minHeight: 500)
                }.disabled(allowAddingRepos)
                
                Button("Add Existing Repo") {
                    
                    if !launcherRepos.isEmpty {
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                    }
                    
                    existingRepo = showOpenPanel()
                    
                    if existingRepo != nil {
                    
                        let repo = LauncherRepos(context: moc)
                        
                        repo.title = "New Repo \(launcherRepos.count)"
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
                
                Text(homebrewText)
                    .padding(.horizontal)
                
                Button(action:{
                    
                    for i in 0...launcherRepos.count - 1 {
                        launcherRepos[i].isEditing = false
                    }
                    
                    print(try? shell.shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                    
                    print("its intel's turn nerd what an idiot man")
                    
                    do {
                        print(try shell.intelShell("/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                    }
                    catch {}
                    
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
            
            devMode = false
            
            let detectArmBrewInstall = try? shell.shell("which brew")
            let detectIntelBrewInstall = try? shell.shell("which /usr/local/bin/brew")
            
            if detectArmBrewInstall?.contains("/opt/homebrew/bin/brew") ?? false && detectIntelBrewInstall == "/usr/local/bin/brew\n" {
                homebrewText = "Both versions of homebrew are installed."
            }
            else if !(detectArmBrewInstall?.contains("/opt/homebrew/bin/brew") ?? false) && detectIntelBrewInstall == "/usr/local/bin/brew\n" {
                    
                homebrewText = "Arm homebrew is not installed. Please install at brew.sh\n\nIntel homebrew is installed"
            }
            else if (detectArmBrewInstall?.contains("/opt/homebrew/bin/brew") ?? false) && detectIntelBrewInstall != "/usr/local/bin/brew\n" {
                    
                homebrewText = "Arm homebrew is installed\n\nIntel homebrew is not installed. Install by launching your terminal with rosetta, and then follow instructions at brew.sh"
            }
            else {
                homebrewText = "Homebrew is not installed, please install at brew.sh"
            }
            
            do {
                if try checkRom("ls ~/SM64Repos/baserom.us.z64") {
                    allowAddingRepos = true
                }
                else {
                    allowAddingRepos = false
                }
            }
            catch {
                print("Failed: \(error)")
            }
            
            do {
                latestVersion = try shell.shell("curl -s https://raw.githubusercontent.com/EmeraldLoc/sm_osx/main/CurVer")
            }
            catch {
                print("Failed: \(error)")
            }
            
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
                launcherRepos[i].log = ""
            }
            
        }.alert("An Update is Avalible", isPresented: $updateAlert) {
            Button("Update", role: .none) {
                print(try? shell.shell("cd ~/Downloads && wget https://github.com/EmeraldLoc/sm_osx/releases/latest/download/sm_osx.zip && unzip sm_osx.zip && rm -rf sm_osx.zip /Applications/sm_osx.app && mv sm_osx.app /Applications && open /Applications/sm_osx.app"))
                
                exit(0)
            }
            
            Button("Not now", role: .cancel) {}
        }.sheet(isPresented: $crashStatus) {
            CrashView(beginLogging: $beginLogging, crashStatus: $crashStatus, index: $crashIndex)
        }.sheet(isPresented: $beginLogging) {
            LogView(index: $logIndex)
        }
    }
}

struct LauncherView_Previews: PreviewProvider {
    static var previews: some View {
        LauncherView()
    }
}
