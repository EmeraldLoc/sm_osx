//
//  LauncherView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 4/2/22.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import UserNotifications

struct LauncherView: View {
    
    @Binding var repoView: Bool
    @AppStorage("devMode") var devMode = false
    var shell = Shell()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @Binding var updateAlert: Bool
    @State var existingRepo = URL(string: "")
    @State var latestVersion = ""
    @State var crashStatus = false
    @State var crashLog = ""
    @State var readableCrashLog = ""
    @State var allowAddingRepos = true
    @State var beginLogging = false
    @AppStorage("firstLaunch") var firstLaunch = true
    @AppStorage("checkUpdateAuto") var checkUpdateAuto = true
    @State var romURL = URL(string: "")
    @State var crashIndex = 0
    @State var logIndex = 0
    @State var homebrewText = ""
    @State var isLogging = false
    @Binding var noUpdateAlert: Bool
    @State var noUpdateAlertEmpty = false
    let rom: UTType = .init(filenameExtension: "z64") ?? UTType.unixExecutable
    let layout = [GridItem(.adaptive(minimum: 260))]
    
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
                    ScrollView {
                        LazyVGrid(columns: layout) {
                            ForEach(launcherRepos) { LauncherRepo in
                                VStack {
                                    
                                    let i = launcherRepos.firstIndex(of: LauncherRepo) ?? 0
                                    
                                    Button {
                                        
                                        if launcherRepos.isEmpty { return }
                                        
                                        for i in 0...launcherRepos.count - 1 {
                                            launcherRepos[i].isEditing = false
                                        }
                                        
                                        try? launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", index: i)
                                        
                                        print(LauncherRepo.path ?? "")
                                    } label: {
                                        if !launcherRepos.isEmpty {
                                            if launcherRepos[i].imagePath == nil {
                                                GroupBox {
                                                    Text(LauncherRepo.title ?? "")
                                                        .frame(width: 250, height: 140)
                                                }.playHover()
                                            } else {
                                                VStack {
                                                    Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: LauncherRepo.imagePath ?? ""))!)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 250, height: 150)
                                                        .playHover()
                                                    
                                                    Text(LauncherRepo.title ?? "Unknown Title")
                                                }
                                            }
                                        }
                                    }.buttonStyle(.plain)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Button(action: {
                                            
                                            if launcherRepos.isEmpty { return }
                                            
                                            for i in 0...launcherRepos.count - 1 {
                                                launcherRepos[i].isEditing = false
                                            }
                                            
                                            try? launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", index: i)
                                            
                                            logIndex = i
                                            
                                            beginLogging = true
                                            
                                            print(LauncherRepo.path ?? "")
                                        }) {
                                            Text("Log")
                                            
                                            Image(systemName: "arrow.right.circle.fill")
                                        }
                                        
                                        Button(action: {
                                            
                                            if launcherRepos.isEmpty { return }
                                            
                                            for i in 0...launcherRepos.count - 1 {
                                                launcherRepos[i].isEditing = false
                                            }
                                            
                                            let launcherRepo = launcherRepos[i]
                                            
                                            moc.delete(launcherRepo)
                                            
                                            do {
                                                try moc.save()
                                                print("Repo Correctly Removed")
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
                                    }.frame(width: 210).sheet(isPresented: .constant(LauncherRepo.isEditing)) {
                                        LauncherEditView(i: i, existingRepo: $existingRepo)
                                    }
                                }
                            }
                        }
                    }.padding()
                }
                else {
                    
                    Spacer()
                    
                    if !allowAddingRepos {
                        Text("You have no repos, add a repo to begin!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        Text("Please select your sm64 rom.")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
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
                        
                        try? shell.shell("cp \(romURL?.path ?? "") ~/SM64Repos/baserom.us.z64")
                        
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
                    }.buttonStyle(.borderedProminent)
                }

                
                Text(homebrewText)
                    .padding(.horizontal)
            }.toolbar {
                ToolbarItem {
                    Menu {
                        Button(action: {
                            
                            if !launcherRepos.isEmpty {
                                for i in 0...launcherRepos.count - 1 {
                                    launcherRepos[i].isEditing = false
                                }
                            }
                            
                            repoView = true
                        }) {
                            Text("Add New Repo")
                        }.buttonStyle(.borderedProminent).disabled(allowAddingRepos)
                        
                        Button("Add Existing Repo") {
                            
                            if !launcherRepos.isEmpty {
                                for i in 0...launcherRepos.count - 1 {
                                    launcherRepos[i].isEditing = false
                                }
                            }
                            
                            existingRepo = showExecFilePanel()
                            
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
                    } label: {
                        Text("Repos")
                            .frame(maxWidth: .infinity)
                    }.frame(width: 70)
                }
            }.alert("You are up to date!", isPresented: $noUpdateAlert) {
                
            } message: {
                Text("You are up to  date, your current version is \(currentVersion)")
            }
        }.onAppear {
            
            devMode = false
            
            let detectArmBrewInstall = try? shell.shell("which brew")
            let detectIntelBrewInstall = try? shell.shell("which /usr/local/bin/brew")
            
            if (detectArmBrewInstall?.contains("/opt/homebrew/bin/brew") ?? false && detectIntelBrewInstall == "/usr/local/bin/brew\n" && isArm()) || (detectIntelBrewInstall == "/usr/local/bin/brew\n" && !isArm())  {
                    homebrewText = ""
            }
            else if !(detectArmBrewInstall?.contains("/opt/homebrew/bin/brew") ?? false) && detectIntelBrewInstall == "/usr/local/bin/brew\n" && isArm() {
                    
                homebrewText = "Arm homebrew is not installed. Please install at brew.sh\n\nIntel homebrew is installed"
            }
            else if (detectArmBrewInstall?.contains("/opt/homebrew/bin/brew") ?? false) && detectIntelBrewInstall != "/usr/local/bin/brew\n" && isArm() {
                    
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
            
            if checkUpdateAuto {
                Task {
                    let result = await checkForUpdates()
                    
                    if result == 0 {
                        noUpdateAlert = true
                    } else {
                        updateAlert = true
                    }
                }
            }

            try? print(shell.shell("cd ~/ && mkdir SM64Repos"))
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            if launcherRepos.isEmpty { return }
            
            for i in 0...launcherRepos.count - 1 {
                launcherRepos[i].isEditing = false
                launcherRepos[i].log = ""
            }
            
        }.alert("An Update is Avalible", isPresented: $updateAlert) {
            Button("Update", role: .none) {
                try? shell.shell("cd ~/Downloads && wget https://github.com/EmeraldLoc/sm_osx/releases/latest/download/sm_osx.zip && unzip sm_osx.zip && rm -rf sm_osx.zip /Applications/sm_osx.app && mv sm_osx.app /Applications && open /Applications/sm_osx.app")
                
                exit(0)
            }
            
            Button("Not now", role: .cancel) {}
        } message: {
            Text("A new update is now avalible.")
        }.sheet(isPresented: $repoView) {
            RepoView(repoView: $repoView)
                .frame(minWidth: 650, idealWidth: 750, maxWidth: 850, minHeight: 400, idealHeight: 500, maxHeight: 550)
        }.sheet(isPresented: $crashStatus) {
            CrashView(beginLogging: $beginLogging, crashStatus: $crashStatus, index: $crashIndex)
        }.sheet(isPresented: $beginLogging) {
            LogView(index: $logIndex)
        }.frame(minWidth: 300, minHeight: 250)
    }
}
