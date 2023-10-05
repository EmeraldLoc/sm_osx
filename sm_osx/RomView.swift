
import SwiftUI
import UserNotifications

struct RomView: View {
    
    @State var patch: Array<Patches>
    @State var repo: Repo
    @State var allowFinish = true
    @State var log = ""
    @State var doLauncher = true
    @State var doKeepRepo = true
    @State var betterCamera = 0
    @State var drawDistance = 0
    @State var highFPS = 0
    @State var qolFix = 0
    @State var qolFeatures = 0
    @State var debug = 0
    @State var doLog = false
    @State var compSpeed: Speed = .normal
    @State var extData = 0
    @State var shell = Shell()
    @State var execPath = ""
    @State var errorMessage = ""
    @State var showWarningMessage = false
    @State var showWarningAlert = false
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var customRepo: CustomRepo
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("launchEntry") var launcherEntry = true
    @Environment(\.dismiss) var dismiss
    @State var startedCompilation = false
    @State var commandsCompile = ""
    
    func compile() {
        //install dependencies
        if (repo == .sm64ex_coop || repo == .sm64ex_coop_dev || (repo == .custom && customRepo.x86_64)) && isArm() {
            commandsCompile = "echo 'sm_osx: Installing Deps'; brew uninstall --ignore-dependencies glew sdl2; arch -x86_64 /bin/zsh -cl '/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw libusb audiofile coreutils wget'; brew install make mingw-w64 gcc pkg-config glfw libusb audiofile coreutils wget; "
        }
        else {
            commandsCompile = "echo 'sm_osx: Installing Deps' && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb audiofile coreutils wget; "
        }
        
        //clone the repo
        if repo == .custom {
            commandsCompile.append("echo 'sm_osx: Starting Clone' && cd ~/SM64Repos && rm -rf \(customRepo.name) && git clone \(customRepo.cloneURL) \(customRepo.name) && ")
            print("Custom Repo Name: \(customRepo.cloneURL)")
        } else {
            commandsCompile.append("echo 'sm_osx: Starting Clone' && cd ~/SM64Repos && rm -rf \(repo) && git clone \(repo.rawValue) \(repo) && ")
        }
        
        //copy files
        if repo == .custom {
            commandsCompile.append("echo 'sm_osx: Rom Files Done' && cp baserom.us.z64 \(customRepo.name) && cd \(customRepo.name) && ")
        } else {
            commandsCompile.append("echo 'sm_osx: Rom Files Done' && cp baserom.us.z64 \(repo) && cd \(repo) && ")
        }
        
        //patch
        if !patch.isEmpty {
            commandsCompile.append("echo 'sm_osx: Patching Files' && ")
        }

        if repo == .sm64ex {
            if patch.contains(.timeTrials) {
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget https://sm64pc.info/downloads/patches/time_trials.2.4.hotfix.patch && git apply --reject --ignore-whitespace 'time_trials.2.4.hotfix.patch' && ")
            }
            
            if patch.contains(.captainToadStars) {
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget https://sm64pc.info/downloads/patches/captain_toad_stars.patch && git apply --reject --ignore-whitespace 'captain_toad_stars.patch' && ")
            }
            
            if patch.contains(.extMoveset) {
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget https://sm64pc.info/downloads/patches/Extended.Moveset.v1.03b.sm64ex.patch && git apply --reject --ignore-whitespace 'Extended.Moveset.v1.03b.sm64ex.patch' && ")
            }
        }

        if repo == .sm64ex_alo {
            if patch.contains(.star_road) {
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget -O star_road_release.patch http://drive.google.com/uc\\?id\\=1kXskWESOTUJDoeCGVV9JMUkn0tLd_GXO && git apply --reject --ignore-whitespace star_road_release.patch && ")
            }
        }
        
        //compile
        if repo == .moonshine {
            extData = 1
        }

        commandsCompile.append("echo 'sm_osx: Compiling Now' && ")

        if repo == .custom {
            if customRepo.x86_64 {
                commandsCompile.append("cd ~/SM64Repos/\(customRepo.name) && arch -x86_64 /bin/zsh -cl 'gmake \(customRepo.useOsxBuildFlag ? "OSX_BUILD=1" : "") \(customRepo.buildFlags) \(compSpeed.rawValue)' && ")
            } else {
                commandsCompile.append("cd ~/SM64Repos/\(customRepo.name) && gmake \(customRepo.useOsxBuildFlag ? "OSX_BUILD=1" : "") \(customRepo.buildFlags) \(compSpeed.rawValue) &&")
            }
        } else if repo == .sm64ex_coop || repo == .sm64ex_coop_dev {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && arch -x86_64 /bin/zsh -cl 'gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64 USE_APP=0 EXTERNAL_DATA=0 DEBUG=\(debug) COLOR=0 \(compSpeed.rawValue)' && ")
        }
        else if repo == .sm64ex_alo {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=0 NODRAWDISTANCE=\(drawDistance) QOL_FEATURES=\(qolFeatures) QOL_FIXES=\(qolFix) HIGH_FPS_PC=\(highFPS) COLOR=0 \(compSpeed.rawValue) && ")
        }
        else {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue) && ")
        }
        
        if repo == .custom {
            execPath = "\(customRepo.name)-build"
        } else {
            execPath = "\(repo)-build"
        }
        
        if doKeepRepo {
            
            let checkExecPath = shell.shell("ls ~/SM64Repos/")
            
            var numbCur = 0
            
            while checkExecPath.contains(execPath) {
                
                numbCur += 1
                
                if numbCur == 1 {
                    execPath.append("-\(numbCur)")
                }
                else {
                    execPath.removeLast()
                    
                    execPath.append(String(numbCur))
                }
            }
        }
        
        if repo == .custom {
            commandsCompile.append("echo 'sm_osx: Finishing Up' && cd ~/SM64Repos && rm -rf \(execPath) && gcp -r \(customRepo.name)/build/us_pc/ \(execPath) && rm -rf \(customRepo.name);")
        } else {
            commandsCompile.append("echo 'sm_osx: Finishing Up' && cd ~/SM64Repos && rm -rf \(execPath) && gcp -r \(repo)/build/us_pc/ \(execPath) && rm -rf \(repo);")
        }
        
        if repo == .sm64ex_coop || repo == .sm64ex_coop_dev || (repo == .custom && customRepo.x86_64) {
            commandsCompile.append("brew install glew sdl2;")
            
            if repo == .sm64ex_coop || repo == .sm64ex_coop_dev {
                commandsCompile.append("cd \(execPath) && cp discord_game_sdk.dylib /usr/local/lib/;")
            }
        }
        
        commandsCompile.append(" echo 'sm_osx: Done'")

        if commandsCompile.contains("sm_osx: Done") {
            startedCompilation = true
        } else {
            withAnimation {
                errorMessage = "Error: Can't start due to unfinished commands, please try again."
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Compilation Options")
                .lineLimit(nil)
                .padding(.top)
            
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Toggle(isOn: $doLauncher) {
                            Text("Add Repo to Launcher")
                        }
                        Toggle(isOn: $doKeepRepo) {
                            Text("Keep Previously Compiled Repo")
                        }
                        
                        HStack {
                            Picker(selection: $compSpeed.animation()) {
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
                            } label: {
                                Text("Speed")
                                    .lineLimit(nil)
                            }
                            .padding(.leading, 3)
                            .frame(idealWidth: 200, maxWidth: 200)
                            
                            if (repo == .moonshine || repo == .custom) && compSpeed == .fastest {
                                Button {
                                    showWarningMessage = true
                                } label: {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                }.popover(isPresented: $showWarningMessage) {
                                    Text("Compiling on the \"Fastest\"\ncompilation speed might make\nthe compilation fail on this repo.")
                                        .padding()
                                }
                                .transition(.push(from: .trailing))
                            }
                        }
                        
                        Spacer()
                    }.padding(5)
                    
                    Spacer()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                }
                
                Button {
                    repoView = false
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                
                Button("Compile") {
                    if !doKeepRepo {
                        if repo == .custom {
                            if FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(customRepo.name)-build") {
                                showWarningAlert = true
                                
                                return
                            }
                        } else {
                            if FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo)-build") {
                                showWarningAlert = true
                                
                                return
                            }
                        }
                    }
                    
                    compile()
                    
                }.sheet(isPresented: $startedCompilation) {
                    CompilationView(compileCommands: $commandsCompile, repo: $repo, customRepo: $customRepo, execPath: $execPath, doLauncher: $doLauncher, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                }
                .buttonStyle(.borderedProminent)
                .alert("Repo Already Compiled", isPresented: $showWarningAlert) {
                    Button(role: .destructive) {
                        compile()
                    } label: {
                        Text("Replace")
                    }
                    
                    Button(role: .cancel) {}
                    label: {
                        Text("Cancel")
                    }
                } message: {
                    Text("A repo seems to already be compiled. If you don't want to replace it, please enable the \"Keep Previously Compiled Repo\" option")
                }
            }
        }
        .onAppear {
            if patch.contains(.bettercam) {
                betterCamera = 1
            }
            if patch.contains(.drawdistance) {
                drawDistance = 1
            }
            if patch.contains(.extData) {
                extData = 1
            }
            if patch.contains(.qolFeatures) {
                qolFeatures = 1
            }
            if patch.contains(.qolFixes) {
                qolFix = 1
            }
            if patch.contains(.highfps) {
                highFPS = 1
            }
            if patch.contains(.debug) {
                debug = 1
            }
            
            compSpeed = compilationSpeed
            doLauncher = launcherEntry
            doKeepRepo = keepRepo
        }
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
        .transparentBackgroundStyle()
    }
}
