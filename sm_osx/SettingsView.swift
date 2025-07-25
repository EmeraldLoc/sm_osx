import SwiftUI
import Sparkle
import UserNotifications

struct SettingsView: View {    
    @AppStorage("isGrid") var isGrid = false
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @EnvironmentObject var network: NetworkMonitor
    @AppStorage("launchEntry") var launchEntry = true
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("keepInMenuBar") var keepInMenuBar = true
    @State var isInstallingDeps = false
    @State var failedInstallingDependencies = ""
    @State var showFailedInstallSheet = false
    
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

            Section("Appearance") {
                Picker("Launcher appearance", selection: $isGrid.animation()) {
                    Text("Grid")
                        .tag(true)
                    
                    Text("List")
                        .tag(false)
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
                
                HStack {
                    Button("Update Dependencies For Compilation") {
                        withAnimation() {
                            isInstallingDeps = true
                        }
                        
                        let command = isArm() ? "/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb coreutils; brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb coreutils && brew upgrade make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb coreutils" : "brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb coreutils && brew upgrade gcc gcc@9 sdl2 pkg-config glew glfw3 libusb coreutils"
                        
                        Task {
                            let (succeeded, logs) = await Shell().shellAsync(command)
                            withAnimation {
                                isInstallingDeps = false
                                failedInstallingDependencies = succeeded ? "" : logs
                            }
                        }
                    }.disabled(!network.isConnected || isInstallingDeps)
                    
                    if isInstallingDeps {
                        ProgressView()
                            .progressViewStyle(.linear)
                            .transition(.scale)
                    } else if !failedInstallingDependencies.isEmpty {
                        Spacer()
                        
                        Button("Failed updating dependencies", systemImage: "info.circle") {
                            showFailedInstallSheet = !showFailedInstallSheet
                        }
                        .foregroundStyle(.red)
                        .popover(isPresented: $showFailedInstallSheet) {
                            BetterTextEditor(text: $failedInstallingDependencies, isEditable: false, autoScroll: true)
                                .presentationDetents([.large])
                        }
                    }
                }
                
                CheckForUpdatesView(updater: updater)
                
                Button(action: {
                    //Use Old NSWorkspace to open url because for some reason the Environment object for openURL decides to break the initializer, and you cant make a Link look like a button :(
                    NSWorkspace.shared.open(URL(string:"https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
                }) {
                    Text("Check Latest Changelog")
                }
            }
        }.formStyle(.grouped)
    }
}
