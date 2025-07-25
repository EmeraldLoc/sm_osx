
import SwiftUI
import Sparkle
import UserNotifications

struct SettingsView: View {    
    @AppStorage("isGrid") var isGrid = false
    @AppStorage("transparentBar") var transparentBar = TitlebarAppearence.normal
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @EnvironmentObject var network: NetworkMonitor
    @AppStorage("launchEntry") var launchEntry = true
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("keepInMenuBar") var keepInMenuBar = true
    @AppStorage("devMode") var devMode = true
    @State var isInstallingDeps = false

    public func depsShell(_ command: String, _ waitTillExit: Bool = false) {
        let task = Process()
        
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-cl", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if pipe.availableData.count > 0 {
                if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                    if line.contains("Finished installing deps") {
                        
                        withAnimation() {
                            isInstallingDeps = false
                        }
                        
                        let content = UNMutableNotificationContent()
                        content.title = "Finished installing dependencies"
                        content.subtitle = "Dependencies are now installed."
                        content.sound = UNNotificationSound.default
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request)
                    }
                } else {
                    print("Error decoding data. why do I program...: \(pipe.availableData)")
                }
            } else {
                outHandle.readabilityHandler = nil
            }
        }
        
        try? task.run()
        if waitTillExit {
            task.waitUntilExit()
        }
    }
    
    private let updater: SPUUpdater
    
    @State private var automaticallyChecksForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }
    
    var body: some View {
        Form {
            Section("Repo Settings") {
                Toggle(isOn: $launchEntry) {
                    Text("Create launcher entry by default")
                }
                
                Toggle(isOn: $keepRepo) {
                    Text("Keep previously compiled repo by default")
                }
                
                Toggle(isOn: $keepInMenuBar) {
                    Text("Keep app in menu bar while closed")
                }
                
                Picker("Default compile speed", selection: $compilationSpeed) {
                    Text("Slow")
                        .tag(Speed.slow)
                    Text("Normal")
                        .tag(Speed.normal)
                    Text("Fast")
                        .tag(Speed.fast)
                    Text("Very Fast")
                        .tag(Speed.veryFast)
                    Text("Fastest")
                        .tag(Speed.fastest)
                }
            }
            
            Section("Homebrew") {
                HStack {
                    Button(action:{
                        if !launcherRepos.isEmpty {
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                        }
                        
                        withAnimation() {
                            isInstallingDeps = true
                        }
                        
                        if isArm() {
                            depsShell("/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb coreutils; brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb coreutils; echo 'Finished installing deps'")
                        } else {
                            depsShell("/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb coreutils; echo 'Finished installing deps'")
                        }
                    }) {
                        Text("Install Dependencies")
                    }.disabled(!network.isConnected || isInstallingDeps)
                    
                    if isInstallingDeps {
                        ProgressView()
                            .progressViewStyle(.linear)
                            .transition(.scale)
                    }
                }
            }
            
            Section("Appearance") {
                Picker("Launcher appearance", selection: $isGrid.animation()) {
                    Text("Grid")
                        .tag(true)
                    
                    Text("List")
                        .tag(false)
                }
                
                Picker("Title bar", selection: $transparentBar.animation()) {
                    Text("Normal")
                        .tag(TitlebarAppearence.normal)
                    
                    Text("Unified")
                        .tag(TitlebarAppearence.unified)
                }
            }
            
            Section("Updates") {
                Toggle("Automatically check for updates", isOn: $automaticallyChecksForUpdates)
                    .onChange(of: automaticallyChecksForUpdates) { newValue in
                        updater.automaticallyChecksForUpdates = newValue
                    }
                
                Toggle("Automatically download updates", isOn: $automaticallyDownloadsUpdates)
                    .disabled(!automaticallyChecksForUpdates)
                    .onChange(of: automaticallyDownloadsUpdates) { newValue in
                        updater.automaticallyDownloadsUpdates = newValue
                    }
                
                CheckForUpdatesView(updater: updater)
                
                Button(action: {
                    //Use Old NSWorkspace to open url because for some reason the Environment object for openURL decides to break the initializer, and you cant make a Link look like a button :(
                    NSWorkspace.shared.open(URL(string:"https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
                }) {
                    Text("Check Latest Changelog")
                }
            }
            
            Section("Developer") {
                Toggle(isOn: $devMode.animation()) {
                    Text("See experimental repos")
                }
            }
        }.formStyle(.grouped)
    }
}
