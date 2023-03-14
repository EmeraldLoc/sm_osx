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
    
    func compile() {
        
        //install dependencies
        
        if (repo == .sm64ex_coop || repo == .sm64ex_coop_dev || repo == .moon64) && isArm() {
            commandsCompile = "echo 'Installing Deps' && brew uninstall glew sdl2; arch -x86_64 /bin/zsh -cl '/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils wget'; brew install make mingw-w64 gcc pkg-config glfw3 libusb audiofile coreutils wget; "
        }
        else {
            commandsCompile = "echo 'Installing Deps' && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils wget; "
        }
        
        //clone the repo
        
        commandsCompile.append("echo 'Started Clone' && cd ~/SM64Repos && rm -rf \(repo) && git clone \(repo.rawValue) \(repo) && ")
        
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
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget https://raw.githubusercontent.com/PeachyPeachSM64/sm64ex-omm/master/patch/omm.patch && wget https://raw.githubusercontent.com/PeachyPeachSM64/sm64ex-omm/nightly/omm.mk && wget https://raw.githubusercontent.com/PeachyPeachSM64/sm64ex-omm/nightly/omm_defines.mk && git apply --reject --ignore-whitespace 'omm.patch'; ")
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
                commandsCompile.append("cd ~/SM64Repos/\(repo) && wget -O star_road_release.patch http://drive.google.com/uc\\?id\\=1kXskWESOTUJDoeCGVV9JMUkn0tLd_GXO && git apply --reject --ignore-whitespace star_road_release.patch && ")
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
            commandsCompile.append("cd ~/SM64Repos/\(repo) && arch -x86_64 /bin/zsh -cl 'gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64 USE_APP=0 EXTERNAL_DATA=0 DEBUG=\(debug) COLOR=0 \(compSpeed.rawValue)' && ")
        }
        else if repo == .moon64 {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && arch -x86_64 /bin/zsh -cl 'gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue)' && ")
        }
        else if repo == .sm64ex_alo {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=0 NODRAWDISTANCE=\(drawDistance) QOL_FEATURES=\(qolFeatures) QOL_FIXES=\(qolFix) HIGH_FPS_PC=\(highFPS) COLOR=0 \(compSpeed.rawValue) && ")
        }
        else {
            commandsCompile.append("cd ~/SM64Repos/\(repo) && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue) && ")
        }
        
        execPath = "\(repo)-build"
        
        if doKeepRepo {
            
            var checkExecPath = ""
            
            do {
                checkExecPath = try shell.shell("ls ~/SM64Repos/")
            }
            catch {
                print("thats bad")
            }
            
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
        
        commandsCompile.append("echo 'Finishing Up' && cd ~/SM64Repos && rm -rf \(execPath) && gcp -r \(repo)/build/us_pc/ \(execPath) && rm -rf \(repo);")
        
        if repo == .sm64ex_coop || repo == .sm64ex_coop_dev || repo == .moon64 {
            commandsCompile.append("brew install glew sdl2;")
            
            if repo == .sm64ex_coop || repo == .sm64ex_coop_dev {
                commandsCompile.append("cd \(execPath) && cp discord_game_sdk.dylib /usr/local/lib/;")
            }
        }
        
        commandsCompile.append(" echo 'Finished Doin Stonks'")

        startedCompilation = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                List {
                    Toggle(isOn: $doLauncher) {
                        Text("Add Repo to Launcher")
                    }
                    Toggle(isOn: $doKeepRepo) {
                        Text("Keep Previously Compiled Repo")
                    }
                    
                    Picker(selection: $compSpeed) {
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
                    .padding(.horizontal, 3)
                    .frame(idealWidth: 200, maxWidth: 200)
                    
                    Button("Compile") {
                        compile()
                    }.padding(.top, 3).sheet(isPresented: $startedCompilation) {
                        CompilationView(compileCommands: $commandsCompile, repo: $repo, execPath: $execPath, doLauncher: $doLauncher)
                    }
                }
            }
            .frame(minWidth: 200)
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
        }
    }
}
