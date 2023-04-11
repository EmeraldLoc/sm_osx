
import SwiftUI
import Sparkle

@main
struct sm_osxApp: App {
    
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject private var dataController = DataController()
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @AppStorage("devMode") var devMode = false
    @AppStorage("firstLaunch") var firstLaunch = true
    @State var window: NSWindow!
    @State var existingRepo = URL(string: "")
    @State var reloadMenuBarLauncher = false
    @State var showAddRepos = false
    let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
        devMode = false
    }
    
    var body: some Scene {
        WindowGroup(firstLaunch ? "FirstLaunch" : "sm_osx") {
            if firstLaunch {
                FirstLaunchView()
                    .background {
                        if window == nil {
                            Color.clear.onReceive(NotificationCenter.default.publisher(for:
                                                                                        NSWindow.didBecomeKeyNotification)) { notification in
                                if let window = notification.object as? NSWindow {
                                    window.standardWindowButton(.closeButton)?.isHidden = true
                                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                                    window.standardWindowButton(.zoomButton)?.isHidden = true
                                    window.titlebarAppearsTransparent = true
                                    window.titleVisibility = .hidden
                                }
                            }
                        }
                    }.frame(width: 500, height: 400)
            } else {
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
            }
        }.windowResizability(firstLaunch ? .contentSize : .automatic).commands {
            SidebarCommands()
            
            if !firstLaunch {
                MenuCommands(showAddRepos: $showAddRepos, reloadMenuBarLauncher: $reloadMenuBarLauncher, dataController: dataController, updaterController: updaterController)
            }
            
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .keyboardShortcut(".")
                        .disabled(true)
                }
            }
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
