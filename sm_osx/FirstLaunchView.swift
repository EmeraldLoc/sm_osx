
import SwiftUI

struct FirstLaunchView: View {
    
    @State var status = FirstLaunchStatus.none
    @State var showAppNotInApplicationsFolderAlert = false
    @AppStorage("firstLaunch") var firstLaunch = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(minWidth: 150, maxWidth: 150, minHeight: 150, maxHeight: 150)
                .opacity(status == .none ? 0 : 1)
            
            if status == .starting {
                Text("Starting...")
                    .onAppear {
                        let path = "/Applications/sm_osx.app"
                        if !FileManager.default.fileExists(atPath: path) {
                            showAppNotInApplicationsFolderAlert = true
                        } else { status = .checkingHomebrewInstallation }
                    }.alert("sm_osx is not in the Applications Folder, would you like to quit the app to move it?", isPresented: $showAppNotInApplicationsFolderAlert) {
                        Button(role: .cancel) {
                            withAnimation {
                                status = .checkingHomebrewInstallation
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
                    }
            } else if status == .checkingHomebrewInstallation {
                Text("Checking Homebrew Installation...")
                    .onAppear {
                        if isArm() {
                            if !((try? Shell().shell("which brew")) ?? "").contains("/opt/homebrew/bin/brew") {
                                
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
                            if !((try? Shell().shell("which brew")) ?? "").contains("/usr/local/bin/brew") {
                                
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
                            if ((try? Shell().shell("which brew")) ?? "").contains("/opt/homebrew/bin/brew") {
                                withAnimation {
                                    status = .checkingIntelHomebrewInstallation
                                }
                            }
                        } else {
                            if ((try? Shell().shell("which brew")) ?? "").contains("/usr/local/bin/brew") {
                                withAnimation {
                                    status = .installingDeps
                                }
                            }
                        }
                    }
            } else if status == .checkingIntelHomebrewInstallation {
                Text("Checking Intel Homebrew Installation...")
                    .onAppear {
                        if !((try? Shell().shell("which /usr/local/bin/brew")) ?? "").contains("/usr/local/bin/brew\n") {
                            
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
                        if ((try? Shell().shell("which /usr/local/bin/brew")) ?? "").contains("/usr/local/bin/brew\n") {
                            withAnimation {
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
                    try? Shell().shell("cd ~/ && mkdir SM64Repos")
                    
                    firstLaunch = false
                    
                    restart()
                }
            }
            
        }.onAppear {
            withAnimation(.easeOut(duration: 0.75)) {
                status = .starting
            }
        }
    }
}

enum FirstLaunchStatus {
    case none
    case starting
    case checkingHomebrewInstallation
    case checkingIntelHomebrewInstallation
    case installingDeps
    case finishingUp
}
