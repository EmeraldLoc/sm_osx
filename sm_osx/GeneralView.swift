
import SwiftUI
import UserNotifications

struct GeneralView: View {
    
    public func depsShell(_ command: String, _ waitTillExit: Bool = false) {
        let task = Process()
        
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-cl", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                if line.contains("Finished installing deps") {
                    
                    withAnimation() {
                        isInstallingDeps = false
                    }
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Finished installing dependencies"
                    content.subtitle = "Dependencies are now installed."
                    content.sound = UNNotificationSound.default
                    
                    // show this notification instantly
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                    
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
        }
        
        try? task.run()
        if waitTillExit {
            task.waitUntilExit()
        }
    }
    
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @EnvironmentObject var network: NetworkMonitor
    @AppStorage("launchEntry") var launchEntry = true
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("showMenuExtra") var showMenuExtra = true
    @AppStorage("keepInMenuBar") var keepInMenuBar = true
    @State var isInstallingDeps = false
    
    var body: some View {
        List {
            Toggle(isOn: $launchEntry) {
                Text("Create Launcher Entry by Default")
            }
            
            Toggle(isOn: $keepRepo) {
                Text("Keep Previously Compiled Repo by Default")
            }
            
            Toggle(isOn: $showMenuExtra.animation()) {
                Text("Show in Menu Bar")
            }
            
            Toggle(isOn: $keepInMenuBar) {
                Text("Keep App When Closed in Menu Bar")
            }.disabled(!showMenuExtra)
            
            Picker("Default Speed", selection: $compilationSpeed) {
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
            }.frame(idealWidth: 200, maxWidth: 200)
            
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
                        depsShell("/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils; brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils; echo 'Finished installing deps'")
                    } else {
                        depsShell("/usr/local/bin/brew install gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils; echo 'Finished installing deps'")
                    }
                }) {
                    Text("Install Package Dependencies")
                }.buttonStyle(.bordered).padding(.bottom).disabled(!network.isConnected).disabled(isInstallingDeps)
                
                if isInstallingDeps {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .padding(.bottom)
                        .transition(.scale)
                }
            }
        }.scrollDisabled(true).transparentListStyle()
    }
}
