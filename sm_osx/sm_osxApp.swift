
import SwiftUI
import Sparkle

@main
struct sm_osxApp: App {
    
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject private var dataController = DataController()
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @State var existingRepo = URL(string: "")
    @State var showAddRepos = false
    @State var updateAlert = false
    @State var noUpdateAlert = false
    let updaterController: SPUStandardUpdaterController
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    
    var body: some Scene {
        
        WindowGroup {
            LauncherView(repoView: $showAddRepos, updateAlert: $updateAlert, noUpdateAlert: $noUpdateAlert)
                .environmentObject(networkMonitor)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }.commands {
            SidebarCommands()
            
            MenuCommands(showAddRepos: $showAddRepos, dataController: dataController, updaterController: updaterController)
        }
        
        Settings {
            SettingsView(updater: updaterController.updater)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(networkMonitor)
        }
        
        menuExtras(dataController: dataController, updateAlert: $updateAlert, noUpdateAlert: $noUpdateAlert, showAddRepos: $showAddRepos)
    }
}


struct menuExtras: Scene {
    
    @State var dataController: DataController
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    @Binding var updateAlert: Bool
    @Binding var noUpdateAlert: Bool
    @Binding var showAddRepos: Bool
    @AppStorage("showMenuExtra") var showMenuExtra = true
    
    private func fetchLaunchers() -> [LauncherRepos] {
        let fetchRequest: NSFetchRequest<LauncherRepos>
        fetchRequest = LauncherRepos.fetchRequest()
        
        let context = dataController.container.viewContext
        
        let objects = try? context.fetch(fetchRequest)
        
        return objects ?? []
    }
    
    
    var body: some Scene {
        if #available(macOS 13.0, *) {
            return MenuBarExtra() {
                ForEach(fetchLaunchers()) { Launcher in
                    Button(Launcher.title ?? "") {
                        
                        let launcherRepos = fetchLaunchers()
                        
                        for iE in 0...launcherRepos.count - 1 {
                            launcherRepos[iE].isEditing = false
                        }
                        
                        try? Shell().shell("\(Launcher.path ?? "its broken") \(Launcher.args ?? "")", false)
                    }
                }
                
                Divider()
                
                Button("Add New Repo") {
                    showAddRepos = true
                }
                
                Divider()
                
                Button("Check for Updates") {
                    Task {
                        let result = await checkForUpdates()
                        
                        if result == 0 {
                            noUpdateAlert = true
                        } else {
                            updateAlert = true
                        }
                    }
                }
                
                Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
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
                } else {
                    //if this stops working in later versions it was probably a bug :/
                    Image("menu_bar_icon")
                }
            }
        } else {
            return WindowGroup { EmptyView() }
        }
    }
}
