
import SwiftUI

struct FirstLaunchView: View {
    
    @State var status = FirstLaunchStatus.none
    @State var showAppNotInApplicationsFolderAlert = false
    @State var homebrewInstallAlert = false
    @State var installHomebrew = false
    @State var homebrewLog = ""
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
                        } else {
                            withAnimation {
                                status = .launcherView
                            }
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
                    }
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
                            status = .checkingHomebrewInstallation
                        }
                    }
                }
            } else if status == .checkingHomebrewInstallation {
                Text("Checking Homebrew Installation...")
                    .onAppear {
                        var searchPath = "/usr/local/bin/brew"
                        if isArm() {
                            searchPath = "/opt/homebrew/bin/brew"
                        }
                        searchPath = "/nonesense/gasg"
                        
                        if !FileManager.default.fileExists(atPath: searchPath) {
                            homebrewInstallAlert = true
                        }
                    }.onReceive(timer) { _ in
                        var searchPath = "/usr/local/bin/brew"
                        if isArm() {
                            searchPath = "/opt/homebrew/bin/brew"
                        }
                        searchPath = "/nonesense/gasg"
                        
                        if FileManager.default.fileExists(atPath: searchPath) && !installHomebrew {
                            status = .installingDeps
                        } else if !FileManager.default.fileExists(atPath: searchPath) && !installHomebrew {
                            homebrewInstallAlert = true
                        }
                    }.alert("Homebrew is not installed", isPresented: $homebrewInstallAlert) {
                        Button("Download") {
                            installHomebrew = true
                        }
                        
                        Button("Skip") {
                            status = .finishingUp
                        }
                    } message: {
                        Text("This app won't function properly without homebrew. It is recommend to install it. This will open up a terminal window which will prompt you with instructions to install homebrew.")
                    }.sheet(isPresented: $installHomebrew) {
                        VStack {
                            Text("Installing Homebrew...")
                                .padding(.top)
                                .font(.title3)
                            
                            GroupBox {
                                VStack {
                                    BetterTextEditor(text: $homebrewLog, isEditable: false, autoScroll: true)
                                }
                            }.padding([.horizontal, .bottom])
                        }
                        .task {
                            let askpassPath = "/tmp/askpass.sh"
                            let askpassScript = """
                            #!/bin/bash
                            osascript -e 'Tell application "System Events" to display dialog "Your password is needed to install Homebrew." default answer "" with hidden answer buttons {"OK"} default button 1 with icon caution' -e 'text returned of result'
                            """
                            
                            do {
                                try askpassScript.write(toFile: askpassPath, atomically: true, encoding: .utf8)
                                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: askpassPath)
                            } catch {
                                print("Failed to create askpass script")
                                return
                            }
                            
                            let command = """
                                export SUDO_ASKPASS="\(askpassPath)" && \
                                NONINTERACTIVE=1 /usr/bin/script -q /dev/null /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                                """

                            await Shell().shellAsync(command) { output in
                                homebrewLog += output + "\n"
                            }
                            installHomebrew = false
                        }
                        .frame(minWidth: 500, minHeight: 500)
                        .interactiveDismissDisabled()
                    }
            } else if status == .installingDeps {
                Text("Installing Dependencies...")
                    .onAppear {
                        
                        var dependenciesCommand = ""
                        
                        if isArm() {
                            dependenciesCommand = "brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb coreutils wget; echo 'sm_osx: Finished Installing Deps'"
                        } else {
                            dependenciesCommand = "brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb coreutils wget; echo 'sm_osx: Finished Installing Deps'"
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
                Text("Finishing Up...")
                    .onAppear {
                        if !FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos") {
                            do {
                                try FileManager.default.createDirectory(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos", withIntermediateDirectories: true)
                                print("Created Folder SM64Repos in the home folder.")
                            } catch {
                                print("Error, could not create folder (this is probably ok), error: \(error)")
                            }
                        }
                        
                        do {
                            try FileManager.default.removeItem(atPath: "/tmp/askpass.sh")
                        } catch {
                            print("Failed to remove file, probably doesn't exist.")
                        }
                        
                        withAnimation {
                            firstLaunch = false
                            if !restartApp() {
                                status = .restarting
                            }
                        }
                    }
            } else if status == .restarting {
                Text("Restarting the app failed for some reason. Close the app and boot it up manually")
                
                Button("Close") {
                    exit(0)
                }
            }
            
        }.onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                status = .starting
            }
        }
    }
}
