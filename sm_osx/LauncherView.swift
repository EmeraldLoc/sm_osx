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
    
    @EnvironmentObject var network: NetworkMonitor
    @Binding var repoView: Bool
    @Environment(\.managedObjectContext) var moc
    @Environment(\.openWindow) var openWindow
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @State var existingRepo = URL(string: "")
    @State var allowAddingRepos = true
    @AppStorage("firstLaunch") var firstLaunch = true
    @AppStorage("checkUpdateAuto") var checkUpdateAuto = true
    @State var romURL = URL(string: "")
    @State var homebrewText = ""
    @State var isLogging = false
    @State var showPackageInstall = false
    @Binding var reloadMenuBarLauncher: Bool
    let rom: UTType = .init(filenameExtension: "z64") ?? UTType.unixExecutable
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

                                        try? launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")")
                                                                                
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
                                    
                                    if launcherRepos[i].imagePath != nil || NSImage(contentsOf: URL(fileURLWithPath: LauncherRepo.imagePath ?? "")) != nil {
                                        
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
                                                try moc.save()
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
                                    }.frame(width: 210).sheet(isPresented: .constant(LauncherRepo.isEditing)) {
                                        LauncherEditView(i: i, existingRepo: $existingRepo)
                                    }
                                }
                            }
                        }.padding(15)
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
                        
                        try? Shell().shell("cp \(romURL?.path ?? "") ~/SM64Repos/baserom.us.z64")
                        
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
                                    
                                    reloadMenuBarLauncher = true
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
            }
        }.onAppear {
            
            let detectArmBrewInstall = try? Shell().shell("which brew")
            let detectIntelBrewInstall = try? Shell().shell("which /usr/local/bin/brew")
            
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

            try? Shell().shell("cd ~/ && mkdir SM64Repos")
            
            if launcherRepos.isEmpty { return }
            
            for i in 0...launcherRepos.count - 1 {
                launcherRepos[i].isEditing = false
                print(launcherRepos[i].id)
                
                let launchID = UserDefaults.standard.string(forKey: "launch-repo-id") ?? ""
                
                if launchID == launcherRepos[i].id?.uuidString {
                    try? launcherShell("\(launcherRepos[i].path ?? "its broken") \(launcherRepos[i].args ?? "")")
                }
            }
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Finished Launch Sequence")
                } else if let error = error {
                    print(error)
                }
            }
            
        }.sheet(isPresented: $repoView) {
            RepoView(repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                .frame(minWidth: 650, idealWidth: 750, maxWidth: 850, minHeight: 400, idealHeight: 500, maxHeight: 550)
        }.frame(minWidth: 300, minHeight: 250)
    }
}
