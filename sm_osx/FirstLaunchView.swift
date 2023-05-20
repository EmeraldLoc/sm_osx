
import SwiftUI

struct FirstLaunchView: View {
    
    @State var status = FirstLaunchStatus.none
    @State var startingTimer = 0
    @State var showAppNotInApplicationsFolderAlert = false
    @AppStorage("compilationAppearence") var compilationAppearence = CompilationAppearence.compact
    @AppStorage("transparentBar") var transparentBar = TitlebarAppearence.normal
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    @AppStorage("firstLaunch") var firstLaunch = true
    @AppStorage("isGrid") var isGrid = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if status != .none {
                Image("logo")
                    .resizable()
                    .frame(minWidth: 150, maxWidth: 150, minHeight: 150, maxHeight: 150)
                    .transition(.scale)
            }
            
            if status == .starting {
                Text("Starting...")
                    .onAppear {
                        let path = "/Applications/sm_osx.app"
                        if !FileManager.default.fileExists(atPath: path) {
                            showAppNotInApplicationsFolderAlert = true
                        }
                    }.alert("sm_osx is not in the Applications Folder, would you like to quit the app to move it?", isPresented: $showAppNotInApplicationsFolderAlert) {
                        Button(role: .cancel) {
                            withAnimation {
                                status = .launcherView
                            }
                        } label: {
                            Text("No")
                        }
                        
                        Button {
                            exit(0)
                        } label: {
                            Text("Yes")
                        }.keyboardShortcut(.defaultAction)
                    } message: {
                        Text("It's recommended that you move the app to the Applications Folder.")
                    }.onReceive(timer, perform: { _ in
                        //some people hate this timer, but if you make a pr, im not accepting it, because I like it :)
                        
                        if !showAppNotInApplicationsFolderAlert {
                            startingTimer += 1
                            
                            if startingTimer >= 2 {
                                withAnimation {
                                    startingTimer = 0
                                    
                                    status = .launcherView
                                }
                            }
                        }
                    })
            } else if status == .launcherView {
                VStack {
                    Text("Select Launcher Appearence")
                    
                    Text("This can be changed at anytime in Settings")
                        .font(.caption)
                    
                    Picker("Launcher Layout", selection: $isGrid) {
                        Text("Grid")
                            .tag(true)
                        
                        Text("List")
                            .tag(false)
                    }.frame(idealWidth: 200, maxWidth: 200)
                    
                    Button("Continue") {
                        withAnimation {
                            status = .titleBarAppearence
                        }
                    }
                }
            } else if status == .titleBarAppearence {
                VStack {
                    Text("Select Titlebar Appearence")
                    
                    Text("This can be changed at anytime in Settings")
                        .font(.caption)
                    
                    Picker("Title Bar", selection: $transparentBar) {
                        Text("Normal")
                            .tag(TitlebarAppearence.normal)
                        
                        Text("Unified")
                            .tag(TitlebarAppearence.unified)
                    }.frame(idealWidth: 200, maxWidth: 200)
                    
                    Button("Continue") {
                        withAnimation {
                            status = .transparencyAppearence
                        }
                    }
                }
            } else if status == .transparencyAppearence {
                VStack {
                    Text("Select Transparency Appearence")
                    
                    Text("This can be changed at anytime in Settings")
                        .font(.caption)
                    
                    Picker("Transparency", selection: $transparency) {
                        Text("Normal")
                            .tag(TransparencyAppearence.normal)
                        
                        Text("More")
                            .tag(TransparencyAppearence.more)
                    }.frame(idealWidth: 200, maxWidth: 200)
                    
                    Button("Continue") {
                        withAnimation {
                            status = .compilingAppearence
                        }
                    }
                }
            } else if status == .compilingAppearence {
                VStack {
                    Text("Select Compiling Appearence")
                    
                    Text("This can be changed at anytime in Settings")
                        .font(.caption)
                    
                    Picker("Compilation Appearence", selection: $compilationAppearence) {
                        Text("Compact")
                            .tag(CompilationAppearence.compact)
                        
                        Text("Full")
                            .tag(CompilationAppearence.full)
                    }.frame(maxWidth: 300)
                    
                    Button("Continue") {
                        withAnimation {
                            status = .checkingHomebrewInstallation
                        }
                    }
                }
            }  else if status == .checkingHomebrewInstallation {
                Text("Checking Homebrew Installation...")
                    .onAppear {
                        if isArm() {
                            if !FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew") {
                                
                                let task = Process()
                                task.launchPath = "/usr/bin/osascript"
                                task.arguments = [Bundle.main.path(forResource: "HomebrewInstaller", ofType: "scpt") ?? "echo 'Failed to run applescript file'"]
                                
                                do {
                                    try task.run()
                                } catch {
                                    print("Failed to run applescript file: \(error)")
                                }
                            }
                        } else {
                            if !FileManager.default.fileExists(atPath: "/usr/local/bin/brew") {
                                
                                let task = Process()
                                task.launchPath = "/usr/bin/osascript"
                                task.arguments = [Bundle.main.path(forResource: "HomebrewInstaller", ofType: "scpt") ?? "echo 'Failed to run applescript file'"]
                                
                                do {
                                    try task.run()
                                } catch {
                                    print("Failed to run applescript file: \(error)")
                                }
                            }
                        }
                    }.onReceive(timer) { _ in
                        if isArm() {
                            if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew") {
                                withAnimation {
                                    status = .checkingIntelHomebrewInstallation
                                }
                            }
                        } else {
                            if FileManager.default.fileExists(atPath: "/usr/local/bin/brew") {
                                withAnimation {
                                    status = .installingDeps
                                }
                            }
                        }
                    }
            } else if status == .checkingIntelHomebrewInstallation {
                Text("Checking Intel Homebrew Installation...")
                    .onAppear {
                        if !FileManager.default.fileExists(atPath: "/usr/local/bin/brew") {
                            
                            let task = Process()
                            task.launchPath = "/usr/bin/osascript"
                            task.arguments = [Bundle.main.path(forResource: "IntelHomebrewInstaller", ofType: "scpt") ?? "echo 'Failed to run applescript file'"]
                            
                            do {
                                try task.run()
                            } catch {
                                print("Failed to run applescript file: \(error)")
                            }
                        }
                    }.onReceive(timer) { _ in
                        if FileManager.default.fileExists(atPath: "/usr/local/bin/brew") {
                            withAnimation(.linear(duration: 0.4)) {
                                status = .installingDeps
                            }
                        }
                    }
            } else if status == .installingDeps {
                Text("Installing Dependencies...")
                    .onAppear {
                        
                        var dependenciesCommand = ""
                        
                        if isArm() {
                            dependenciesCommand = "brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb audiofile coreutils wget; /usr/local/bin/brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb audiofile coreutils wget; echo 'sm_osx: Finished Installing Deps'"
                        } else {
                            dependenciesCommand = "brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb audiofile coreutils wget; echo 'sm_osx: Finished Installing Deps'"
                        }
                        
                        let process = Process()
                        
                        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
                        process.arguments = ["-cl", dependenciesCommand]
                        
                        let pipe = Pipe()
                        process.standardOutput = pipe
                        process.standardError = pipe
                        let outHandle = pipe.fileHandleForReading
                        
                        outHandle.readabilityHandler = { pipe in
                            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                                
                                if line.contains("sm_osx: Finished Installing Deps") {
                                    withAnimation {
                                        status = .finishingUp
                                    }
                                    process.terminate()
                                }
                            } else {
                                print("Error decoding data. why do I program...: \(pipe.availableData)")
                            }
                        }
                        
                        try? process.run()
                    }
                
                ProgressView().progressViewStyle(.linear)
                    .padding(.horizontal)
                    .frame(width: 300)
            } else if status == .finishingUp {
                Text("Finishing Up...").onAppear {
                    if !FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos") {
                        do {
                            try FileManager.default.createDirectory(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos", withIntermediateDirectories: true)
                            print("Created Folder SM64Repos in the home folder.")
                        } catch {
                            print("Error, could not create folder (this is probably ok), error: \(error)")
                        }
                    }
                    
                }.onReceive(timer, perform: { _ in
                    startingTimer += 1
                    
                    if startingTimer >= 2 {
                        withAnimation {
                            firstLaunch = false
                            
                            restart()
                        }
                    }
                    
                })
            }
            
        }.onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                status = .starting
            }
        }
    }
}
