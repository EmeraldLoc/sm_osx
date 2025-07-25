
import SwiftUI
import Sparkle

struct MenuCommands: Commands {
    @State var existingRepo = URL(string: "")
    @Binding var showAddRepos: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var launcherRepos = [LauncherRepos]()
    @StateObject var dataController: DataController
    @StateObject var networkMonitor = NetworkMonitor()
    @AppStorage("keepInMenuBar") var keepInMenuBar = true
    @Environment(\.openWindow) var openWindow
    @ObservedObject var addingRepo = AddingRepo.shared
    var updaterController: SPUStandardUpdaterController
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func fetchLaunchers() -> [LauncherRepos] {
        let fetchRequest: NSFetchRequest<LauncherRepos>
        fetchRequest = LauncherRepos.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        let context = dataController.container.viewContext
        
        let objects = try? context.fetch(fetchRequest)
        
        return objects ?? []
    }
    
    var body: some Commands {
        CommandMenu("Launch") {
            if !launcherRepos.isEmpty {
                ForEach(launcherRepos) { LauncherRepo in
                    Button(LauncherRepo.title ?? "Unrecognized Repo") {
                        for iE in 0...launcherRepos.count - 1 {
                            launcherRepos[iE].isEditing = false
                        }
                        
                        Task {
                            let (success, logs) = await Shell().shellAsync("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")")
                            
                            if !success {
                                if NSApp.activationPolicy() == .prohibited {
                                    showApp()
                                }
                                
                                openWindow(id: "crash-log", value: logs)
                            }
                        }
                    }
                }.onChange(of: reloadMenuBarLauncher) { _ in
                    launcherRepos = fetchLaunchers()
                    reloadMenuBarLauncher = false
                }
            } else {
                Text("No Repos")
                    .onAppear {
                        launcherRepos = fetchLaunchers()
                        reloadMenuBarLauncher = false
                    }
                    .onChange(of: reloadMenuBarLauncher) { _ in
                        launcherRepos = fetchLaunchers()
                        reloadMenuBarLauncher = false
                    }
            }
        }
        
        CommandGroup(replacing: .appTermination) {
            Button("Quit sm_osx") {
                if keepInMenuBar {
                    NSApp.setActivationPolicy(.prohibited)
                } else {
                    exit(0)
                }
            }.keyboardShortcut("q").disabled(addingRepo.isCompiling)
        }
        
        CommandGroup(replacing: .toolbar) { }
        
        CommandGroup(replacing: .appInfo) {
            Button("About sm_osx") {
                openWindow(id: "about")
            }
        }
        
        CommandGroup(replacing: .newItem) { }
        
        CommandGroup(after: .appSettings) {
            Section {
                CheckForUpdatesView(updater: updaterController.updater)
                    .environmentObject(networkMonitor)
                
                Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
                    .disabled(!networkMonitor.isConnected)
            }
        }
        
        CommandGroup(after: .newItem) {
            Button("Add New Repo") {
                showAddRepos = true
            }
        }
    }
}

struct menuExtras: Scene {
    
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var updaterController: SPUStandardUpdaterController
    @State var dataController: DataController
    @State var launcherRepos = [LauncherRepos]()
    @Binding var showAddRepos: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @AppStorage("firstLaunch") var firstLaunch = true
    @StateObject var networkMonitor = NetworkMonitor()
    @ObservedObject var addingRepo = AddingRepo.shared
    @ObservedObject var launchRepoAppleScript = LaunchRepoAppleScript.shared
    @Environment(\.openWindow) var openWindow
    
    private func fetchLaunchers() -> [LauncherRepos] {
        let fetchRequest: NSFetchRequest<LauncherRepos>
        fetchRequest = LauncherRepos.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        
        let context = dataController.container.viewContext
        
        let objects = try? context.fetch(fetchRequest)
        
        return objects ?? []
    }
    
    var body: some Scene {
        MenuBarExtra() {
            Section {
                ForEach(launcherRepos) { Launcher in
                    Button(Launcher.title ?? "") {
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                        
                        Task {
                            let (success, logs) = await Shell().shellAsync("\(Launcher.path ?? "its broken") \(Launcher.args ?? "")")
                            
                            if !success {
                                if NSApp.activationPolicy() == .prohibited {
                                    showApp()
                                }
                                
                                openWindow(id: "crash-log", value: logs)
                            }
                        }
                    }
                }
            }
            
            Section {
                Button("Add New Repo") {
                    showAddRepos = true
                }
            }
            
            Section {
                CheckForUpdatesView(updater: updaterController.updater)
                    .environmentObject(networkMonitor)
                
                Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
                    .disabled(!networkMonitor.isConnected)
            }
            
            Section {
                Button("Show App") {
                    showApp()
                }
            }
            
            Section {
                Button("Quit") {
                    exit(0)
                }.disabled(addingRepo.isCompiling)
            }
        } label: {
            if !firstLaunch {
                let image: NSImage = {
                    $0.size.height = 16
                    $0.size.width = 16
                    return $0
                }(NSImage(named: "menu_bar_icon")!)
                
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .onAppear {
                        launcherRepos = fetchLaunchers()
                        
                        reloadMenuBarLauncher = false
                    }.onChange(of: reloadMenuBarLauncher) { _ in
                        launcherRepos = fetchLaunchers()
                        
                        reloadMenuBarLauncher = false
                    }.onChange(of: launchRepoAppleScript.repoID) { repoID in
                        if !launcherRepos.isEmpty {
                            for i in 0...launcherRepos.count - 1 {
                                if launcherRepos[i].id?.uuidString == repoID {
                                    Task {
                                        let (success, logs) = await Shell().shellAsync("\(launcherRepos[i].path ?? "its broken") \(launcherRepos[i].args ?? "")")
                                        
                                        if !success {
                                            if NSApp.activationPolicy() == .prohibited {
                                                showApp()
                                            }
                                            
                                            openWindow(id: "crash-log", value: logs)
                                        }
                                    }
                                    
                                    launchRepoAppleScript.repoID = ""
                                }
                            }
                        }
                    }.onChange(of: launchRepoAppleScript.didOpenApp) { didOpenApp in
                        if didOpenApp {
                            NSApp.setActivationPolicy(.prohibited)
                        }
                    }
            } else {
                Image("menu_bar_icon") // <-- Bug, this is why I am removing it as a option, and instead opting with macos' built in system for that
            }
        }
    }
}

