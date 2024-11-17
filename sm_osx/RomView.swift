
import SwiftUI
import UserNotifications

struct RomView: View {
    
    @State var patches: Array<Patch>
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
    @State var developmentEnvironment = false
    @State var showDevelopmentEnvironment = false
    @State var developmentAlreadyCompiled = false
    @State var recompileCommands = ""
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("launchEntry") var launcherEntry = true
    @Environment(\.dismiss) var dismiss
    @State var startedCompilation = false
    @State var commandsCompile = ""
    
    func compile() {
        //install dependencies
        if repo.x86_64 && isArm() {
            commandsCompile = "echo 'sm_osx: Installing Deps'; brew uninstall --ignore-dependencies glew; brew uninstall --ignore-dependencies sdl2; arch -x86_64 /bin/zsh -cl '/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw libusb audiofile coreutils wget'; brew install make mingw-w64 gcc pkg-config glfw libusb audiofile coreutils wget; "
            recompileCommands = "echo 'sm_osx: Installing Deps'; brew uninstall --ignore-dependencies glew sdl2; arch -x86_64 /bin/zsh -cl '/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw libusb audiofile coreutils wget'; brew install make mingw-w64 gcc pkg-config glfw libusb audiofile coreutils wget; "
        }
        else {
            commandsCompile = "echo 'sm_osx: Installing Deps' && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb audiofile coreutils wget; "
            recompileCommands = "echo 'sm_osx: Installing Deps' && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw libusb audiofile coreutils wget; "
        }
        
        //clone the repo
        commandsCompile.append("echo 'sm_osx: Starting Clone' && cd ~/SM64Repos && rm -rf \(repo.name) && git clone \(repo.cloneURL) \(repo.name) \(repo.branch.isEmpty ? "" : "-b \(repo.branch)") && ")
        
        //copy files
        commandsCompile.append("echo 'sm_osx: Rom Files Done' && cp baserom.us.z64 \(repo.name) && cd \(repo.name) && ")
        
        //patch
        if !patches.isEmpty {
            commandsCompile.append("echo 'sm_osx: Patching Files' && cd ~/SM64Repos/\(repo.name)/ && ")
            
            for patch in patches {
                if patch.patchInstallationCommand.isEmpty { continue }
                commandsCompile.append("echo 'sm_osx: Applying Patch \(patch.name)' && \(patch.patchInstallationCommand) && ")
            }
        }
        
        // compile
        commandsCompile.append("echo 'sm_osx: Compiling Now' && ")
        
        // get list of patch build flags
        var patchBuildFlags = ""
        for patch in patches {
            patchBuildFlags.append("\(patch.buildFlags) ")
        }
        
        var compilationCommand = ""
        
        if repo.x86_64 {
            compilationCommand = "cd ~/SM64Repos/\(repo.name) && arch -x86_64 /bin/zsh -cl 'gmake \(repo.useOsxBuildFlag ? "OSX_BUILD=1" : "") \(repo.buildFlags) \(patchBuildFlags)\(compSpeed.rawValue)' && "
        } else {
            compilationCommand = "cd ~/SM64Repos/\(repo.name) && gmake \(repo.useOsxBuildFlag ? "OSX_BUILD=1" : "") \(repo.buildFlags) \(patchBuildFlags)\(compSpeed.rawValue) && "
        }
        
        recompileCommands.append("rm -rf ~/SM64Repos/\(repo.name)/build/us_pc/\(repo.customEndFileName.isEmpty ? "sm64.us.f3dex2e" : repo.customEndFileName) && echo 'sm_osx: Compiling Now' && \(compilationCommand)")
        commandsCompile.append(compilationCommand)
        
        if !developmentEnvironment {
            execPath = "\(repo.name)-build"
            
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
            
            commandsCompile.append("echo 'sm_osx: Finishing Up' && cd ~/SM64Repos && rm -rf \(execPath) && gcp -r \(repo.name)/build/us_pc/ \(execPath) && rm -rf \(repo.name);")
        }
        
        if repo.x86_64 {
            commandsCompile.append("brew install glew sdl2;")
            recompileCommands.append("brew install glew sdl2;")
        }
        
        commandsCompile.append(" echo 'sm_osx: Done'")
        recompileCommands.append(" echo 'sm_osx: Done'")
        
        print(commandsCompile)

        if developmentEnvironment {
            doLauncher = false
            showDevelopmentEnvironment = true
        } else {
            startedCompilation = true
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
                        }.disabled(developmentEnvironment)
                            
                        Toggle(isOn: $doKeepRepo) {
                            Text("Keep Previously Compiled Repo")
                        }.disabled(developmentEnvironment)
                            
                        Toggle(isOn: $developmentEnvironment) {
                            Text("Development Environment")
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
                            
                            if compSpeed == .fastest {
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
                
                Button(developmentEnvironment ? "Next" : "Compile") {
                    
                    let customRepoFilePath = developmentEnvironment ? "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo.name)" : "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo.name)-build"
                    let repoFilePath = developmentEnvironment ? "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo)" : "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo)-build"
                    
                    if !doKeepRepo {
                        if FileManager.default.fileExists(atPath: customRepoFilePath) {
                            showWarningAlert = true
                            
                            return
                        }
                    }
                    
                    compile()
                    
                }
                .sheet(isPresented: $startedCompilation) {
                    CompilationView(compileCommands: $commandsCompile, repo: $repo, execPath: $execPath, doLauncher: $doLauncher, reloadMenuBarLauncher: $reloadMenuBarLauncher, finishedCompiling: .constant(false), developmentEnvironment: .constant(false), fullExecPath: .constant(""))
                    //CompilationView(compileCommands: $commandsCompile, repo: $repo, execPath: $execPath, doLauncher: $doLauncher, reloadMenuBarLauncher: $reloadMenuBarLauncher, finishedCompiling: .constant(false), developmentEnvironment: .constant(false), fullExecPath: .constant(""))
                }
                .navigationDestination(isPresented: $showDevelopmentEnvironment) {
                    DevelopmentEnvironment(fullCompileCommands: $commandsCompile, repo: $repo, execPath: $execPath, doLauncher: $doLauncher, reloadMenuBarLauncher: $reloadMenuBarLauncher, repoView: $repoView, recompileCommands: $recompileCommands, alreadyCompiled: $developmentAlreadyCompiled)
                }
                .buttonStyle(.borderedProminent)
                .alert("Repo Already Compiled", isPresented: $showWarningAlert) {
                    if developmentEnvironment {
                        Button {
                            developmentAlreadyCompiled = true
                            compile()
                        } label: {
                            Text("Use")
                        }
                    }
                    
                    Button(role: .destructive) {
                        if developmentEnvironment {
                            let customRepoFilePath = developmentEnvironment ? "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo.name)" : "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo.name)-build"
                            let repoFilePath = developmentEnvironment ? "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo)" : "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo)-build"
                            
                            try? FileManager.default.removeItem(atPath: customRepoFilePath)
                            
                            developmentAlreadyCompiled = false
                        }
                        
                        compile()
                    } label: {
                        Text("Replace")
                    }
                } message: {
                    Text("A repo seems to already be compiled. If you don't want to replace it, please enable the \"Keep Previously Compiled Repo\" option")
                }
            }
        }
        .onAppear {
            compSpeed = compilationSpeed
            doLauncher = launcherEntry
            doKeepRepo = keepRepo
        }
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
        .transparentBackgroundStyle()
    }
}
