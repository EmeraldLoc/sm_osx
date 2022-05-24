//
//  RomView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI
import UserNotifications

class Shell {
    
    @Binding var log: String
    
    init(log: Binding<String> = .constant("")) {
        _log = log
    }
    
    func intelShell(_ command: String, _ waitTillExit: Bool = true) throws -> String {
        let task = Process()
        var output = ""

        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-cl", "arch -x86_64 /bin/zsh -cl '\(command)'"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                
                output.append(line)
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
        }
        
        try task.run()
        if waitTillExit {
            task.waitUntilExit()
        }
        
        return output
    }
    
    func scriptShell(_ command: String) throws -> String {
        
        var error: NSDictionary?
        var returnOutput = ""
        
        if let scriptObject = NSAppleScript(source: "do shell script \"arch -arm64 /bin/zsh -cl '\(command)' 2>&1\" ") {
            let output = scriptObject.executeAndReturnError(&error)
            returnOutput.append(output.stringValue ?? "")
            print(output.stringValue ?? "")
            self.log.append(output.stringValue ?? "")
            if (error != nil) {
                print("error: \(String(describing: error))")
            }
        }
        
        return returnOutput
    }
    
    func shell(_ command: String, _ waitTillExit: Bool = true) throws -> String {
        let task = Process()
        var output = ""

        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-cl", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                
                output.append(line)
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
        }
        
        try task.run()
        if waitTillExit {
            task.waitUntilExit()
        }
        
        return output
    }
}

struct RomView: View {
    
    var patch: Array<Patches>
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
    @Binding var repoView: Bool
    @AppStorage("romURL") var romURL = URL(fileURLWithPath: "")
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("launchEntry") var launcherEntry = true
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @State var startedCompilation = false
    @State var commandsCompile = ""
    #if arch(x86_64)
    var disableCompilation = false
    #else
    var disableCompilation = true
    #endif
    
    func compile() {
        
        //install dependencies
        
        if repo == .sm64ex_coop || repo == .sm64ex_coop_dev || repo == .moon64 {
            commandsCompile = "echo 'Installing Deps' && brew uninstall glew sdl2; arch -x86_64 /bin/zsh -cl '/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils'; "
        }
        else {
            commandsCompile = "echo 'Installing Deps' && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils; "
        }
        
        //clone the repo
        if repo != .sm64port {
            commandsCompile.append("echo 'Started Clone' && cd ~/SM64Repos && rm -rf \(repo) && git clone \(repo.rawValue) \(repo) && ")
        }
        else {
            commandsCompile.append("cd ~/SM64Repos && rm -rf target_osx.zip target_osx __MACOSX | echo 'Started Clone' && wget \(repo.rawValue) && unzip target_osx.zip && rm -rf target_osx.zip && mv target_osx \(repo) && ")
        }
        
        //copy files
        
        commandsCompile.append("cp baserom.us.z64 \(repo) | echo 'Rom Files Done' && cd \(repo) && ")
        
        //patch
        
        if !patch.isEmpty {
            commandsCompile.append("echo 'Patching Files' && ")
        }
        
        if repo == .moon64 {
            if patch.contains(.highfps) {
                commandsCompile.append("cd ~/SM64Repos/\(repo) && cp enhancements/moon64_60fps.patch 60fps_ex.patch && git apply --reject --ignore-whitespace '60fps_ex.patch' && ")
            }
        }
        
        if repo == .sm64ex {
            if patch.contains(.omm) {
                commandsCompile.append("cd ~/SM64Repos && git clone https://github.com/PeachyPeachSM64/sm64pc-omm.git && cp sm64pc-omm/patch/omm.patch \(repo) && rm -rf sm64pc-omm && cd \(repo) && git apply --reject --ignore-whitespace 'omm.patch' && ")
            }
        
            if patch.contains(.highfps) {
                commandsCompile.append("cd ~/SM64Repos/\(repo) && cp enhancements/60fps_ex.patch 60fps_ex.patch && git apply --reject --ignore-whitespace '60fps_ex.patch' && ")
            }
            
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
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget -O star_road_release.patch https://raw.githubusercontent.com/EmeraldLoc/star_road_release_patch/main/star_road_release.patch && git apply --reject --ignore-whitespace \"star_road_release.patch\" && ")
            }
        }
        
        //compile
        
        if repo == .moonshine {
            extData = 1
        }
        else if repo == .moon64 {
            extData = 0
        }

        commandsCompile.append("echo 'Compiling Now' && ")
        
        if repo == .sm64ex_coop || repo == .sm64ex_coop_dev {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && arch -x86_64 /bin/zsh -cl 'gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64 EXTERNAL_DATA=\(extData) DEBUG=\(debug) \(compSpeed.rawValue)' && ")
        }
        else if repo == .moon64 {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && arch -x86_64 /bin/zsh -cl 'gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue)' && ")
        }
        else if repo == .sm64ex_alo {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=0 NODRAWDISTANCE=\(drawDistance) QOL_FEATURES=\(qolFeatures) QOL_FIXES=\(qolFix) HIGH_FPS_PC=\(highFPS) \(compSpeed.rawValue) && ")
        }
        else if repo == .sm64port {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake \(compSpeed.rawValue) && ")
        }
        else {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue) && ")
        }
        
        execPath = "\(repo)-build"
        
        if doKeepRepo {
            let checkExecPath = try? shell.shell("ls ~/SM64Repos/")
            
            var numbCur = 0
            
            while checkExecPath!.contains(execPath) {
                
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
        
        commandsCompile.append("echo 'Finishing Up' && cd ~/SM64Repos && rm -rf \(execPath) && gcp -r \(repo)/build/us_pc/ \(execPath) && rm -rf \(repo);")
        
        if repo == .sm64ex_coop || repo == .sm64ex_coop_dev || repo == .moon64 {
            commandsCompile.append("brew install glew sdl2;")
            
            if repo == .sm64ex_coop || repo == .sm64ex_coop_dev {
                commandsCompile.append("cd \(execPath) && cp discord_game_sdk.dylib /usr/local/lib/;")
            }
        }
        
        commandsCompile.append(" echo 'Finished Doin Stonks'")
        
        if doLauncher {
            let launcherRepo = LauncherRepos(context: moc)
            
            launcherRepo.title = "\(repo)"
            launcherRepo.isEditing = false
            if repo != .moon64 {
                launcherRepo.path = "~/SM64Repos/\(execPath)/sm64.us.f3dex2e"
            }
            else {
                launcherRepo.path = "~/SM64Repos/\(execPath)/moon64.us.f3dex2e"
            }
            launcherRepo.args = ""
            launcherRepo.id = UUID()
            
            do {
                try moc.save()
            }
            catch {
                print(error)
            }
        }

        startedCompilation = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                if repo == .sm64ex_coop || repo == .moon64 || repo == .sm64ex_coop_dev {
                    Text("For this repo, make sure you have the intel version of homebrew. To install homebrew this, launch your terminal with rosetta and follow install instructions at brew.sh")
                        .lineLimit(nil)
                        .padding(.top, 3)
                        .padding(.horizontal, 3)
                }

                Button("Start the Compiler") {
                    compile()
                }.padding(.top, 3).sheet(isPresented: $startedCompilation) {
                    CompilationView(compileCommands: $commandsCompile, repo: $repo, execPath: $execPath)
                        .onAppear {
                            dismiss.callAsFunction()
                        }
                }
                
                VStack {
                    Toggle(isOn: $doLauncher) {
                        Text("Add Repo to Launcher")
                    }
                    Toggle(isOn: $doKeepRepo) {
                        Text("Keep Previously Compiled Repo")
                    }
                
                    Picker("Compilation Speed", selection: $compSpeed) {
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
                    }.padding(.horizontal, 3)
                }
                
                Spacer()
                
                
            }.onAppear {
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
        }
    }
}
