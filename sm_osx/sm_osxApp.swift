
import SwiftUI
import Sparkle

@main
struct sm_osxApp: App {
    
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject private var dataController = DataController()
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @AppStorage("devMode") var devMode = false
    @State var existingRepo = URL(string: "")
    @State var reloadMenuBarLauncher = false
    @State var showAddRepos = false
    let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
        devMode = false
    }
    
    var body: some Scene {
        
        WindowGroup() {
            LauncherView(repoView: $showAddRepos, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                .environmentObject(networkMonitor)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear {
                    if showMenuExtra {
                        NSApp.setActivationPolicy(.regular)
                    }
                    
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
                .onDisappear {
                    if showMenuExtra {
                        NSApp.setActivationPolicy(.prohibited)
                    }
                }.onOpenURL { url in
                    print(url.absoluteString)
                }

            
        }.commands {
            SidebarCommands()
            
            MenuCommands(showAddRepos: $showAddRepos, reloadMenuBarLauncher: $reloadMenuBarLauncher, dataController: dataController, updaterController: updaterController)
        }
        
        WindowGroup("Crash Log", id: "crash-log", for: String.self) { s in
            if s.wrappedValue != nil {
                CrashView(log: s.wrappedValue!)
                    .frame(minWidth: 420, idealWidth: 420, minHeight: 400, idealHeight: 400)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .onAppear {
                        NSWindow.allowsAutomaticWindowTabbing = false
                    }
            }
        }
        
        WindowGroup("Game Log", id: "regular-log", for: Int.self) { i in
            if i.wrappedValue != nil {
                LogView(index: i.wrappedValue!)
                    .frame(minWidth: 420, idealWidth: 420, minHeight: 400, idealHeight: 400)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .onAppear {
                        NSWindow.allowsAutomaticWindowTabbing = false
                    }
            }
        }
        
        Settings {
            SettingsView(updater: updaterController.updater)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(networkMonitor)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        
        menuExtras(updaterController: updaterController, dataController: dataController, showAddRepos: $showAddRepos, reloadMenuBarLauncher: $reloadMenuBarLauncher)
    }
}
