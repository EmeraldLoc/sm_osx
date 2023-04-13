
import SwiftUI
import Sparkle


@main
struct sm_osxApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject private var dataController = DataController()
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @AppStorage("devMode") var devMode = false
    @AppStorage("firstLaunch") var firstLaunch = true
    @State var window: NSWindow!
    @State var aboutWindow: NSWindow!
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
                                    if window.title == "FirstLaunch" {
                                        window.standardWindowButton(.closeButton)?.isHidden = true
                                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                                        window.standardWindowButton(.zoomButton)?.isHidden = true
                                        window.titlebarAppearsTransparent = true
                                        window.titleVisibility = .hidden
                                    }
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
                        } else {
                            exit(0)
                        }
                    }.onOpenURL { url in
                        print(url.absoluteString)
                    }.frame(minWidth: 350, minHeight: 300)
            }
        }.windowResizability(firstLaunch ? .contentSize : .automatic).commands {
            SidebarCommands()
            
            if !firstLaunch {
                MenuCommands(showAddRepos: $showAddRepos, reloadMenuBarLauncher: $reloadMenuBarLauncher, dataController: dataController, updaterController: updaterController)
                
                CommandGroup(replacing: .saveItem) {}
            }
            
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .keyboardShortcut(".")
                        .disabled(true)
                }
                
                CommandGroup(replacing: .newItem) {}
                                
                CommandGroup(replacing: .saveItem) {}
            }
            
            CommandGroup(replacing: .saveItem) {}
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
        }.commands {
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .keyboardShortcut(".")
                        .disabled(true)
                }
            }
            
            CommandGroup(replacing: .saveItem) {}
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
        }.commands {
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .keyboardShortcut(".")
                        .disabled(true)
                }
            }
            
            CommandGroup(replacing: .saveItem) {}
        }
        
        WindowGroup("Create Repo Shortcut", id: "shortcut", for: Int.self) { i in
            if i.wrappedValue != nil {
                CreateAppShortcutView(i: i.wrappedValue!)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .onAppear {
                        NSWindow.allowsAutomaticWindowTabbing = false
                    }
            }
        }.commands {
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .keyboardShortcut(".")
                        .disabled(true)
                }
            }
            
            CommandGroup(replacing: .saveItem) {}
        }
        
        Window("About", id: "about") {
            AboutView()
                .background {
                    if aboutWindow == nil {
                        Color.clear.onReceive(NotificationCenter.default.publisher(for:
                                                                                    NSWindow.didBecomeKeyNotification)) { notification in
                            if let aboutWindow = notification.object as? NSWindow {
                                if aboutWindow.title == "About" {
                                    aboutWindow.standardWindowButton(.zoomButton)?.isHidden = true
                                }
                            }
                        }
                    }
                }.frame(width: 400, height: 250)
        }.windowResizability(.contentSize).windowStyle(.hiddenTitleBar).commands {
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .keyboardShortcut(".")
                        .disabled(true)
                }
            }
            
            CommandGroup(replacing: .saveItem) {}
        }
        
        Settings {
            SettingsView(updater: updaterController.updater)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(networkMonitor)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }.commands {
            if firstLaunch {
                CommandGroup(replacing: .appSettings) {
                    Text("Settings..")
                        .disabled(true)
                }
            }
            
            CommandGroup(replacing: .saveItem) {}
        }
        
        menuExtras(updaterController: updaterController, dataController: dataController, showAddRepos: $showAddRepos, reloadMenuBarLauncher: $reloadMenuBarLauncher)
    }
}

//why apple, why, WHY. Couldn't find anything that would work in the swiftui lifecycle, so this will do.
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        flushSavedWindowState()
    }
    
    func flushSavedWindowState() {
        do {
            let libURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            guard let appPersistentStateDirName = Bundle.main.bundleIdentifier?.appending(".savedState") else { print("Get bundleID Failed"); return }
            let windowsPlistFilePath = libURL.appendingPathComponent("Saved Application State", isDirectory: true)
                .appendingPathComponent(appPersistentStateDirName, isDirectory: true)
                .appendingPathComponent("windows.plist", isDirectory: false)
                .path
            
            try FileManager.default.removeItem(atPath: windowsPlistFilePath)
        } catch {
            print("exception: \(error)")
        }
    }
}
