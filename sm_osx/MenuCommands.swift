
import SwiftUI
import Sparkle

struct MenuCommands: Commands {
    @State var existingRepo = URL(string: "")
    @Binding var showAddRepos: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var launcherRepos = [LauncherRepos]()
    @StateObject var dataController: DataController
    @StateObject var networkMonitor = NetworkMonitor()
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @Environment(\.openWindow) var openWindow
    var updaterController: SPUStandardUpdaterController
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
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
                        
                        launcherShell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")")
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
        
        CommandMenu("Repos") {
            Button("Add New Repo") {
                showAddRepos = true
            }
        }
        
        CommandMenu("Updater") {
            CheckForUpdatesView(updater: updaterController.updater)
                .environmentObject(networkMonitor)
            
            Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
                .disabled(!networkMonitor.isConnected)
        }
        
        CommandGroup(replacing: .appTermination) {
            Button("Quit sm_osx") {
                if showMenuExtra {
                    NSApp.setActivationPolicy(.prohibited)
                } else {
                    exit(0)
                }
            }.keyboardShortcut("q")
        }
        
        CommandGroup(replacing: .toolbar) { }
    }
}

struct menuExtras: Scene {
    
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var updaterController: SPUStandardUpdaterController
    @State var dataController: DataController
    @State var launcherRepos = [LauncherRepos]()
    @Binding var showAddRepos: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @StateObject var networkMonitor = NetworkMonitor()
    @Environment(\.openWindow) var openWindow
    
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
                        
                        launcherShell("\(Launcher.path ?? "its broken") \(Launcher.args ?? "")")
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
                }
            }
        } label: {
            if showMenuExtra {
                let image: NSImage = {
                    let ratio = $0.size.height / $0.size.width
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
                    }
            } else {
                //if this stops working in later versions it was probably a bug :/
                Image("menu_bar_icon")
            }
        }
    }
}

