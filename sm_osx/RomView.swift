//
//  RomView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI
import UserNotifications

class Shell {
    
    @State var log = ""
    
    func intelShell(_ command: String) throws -> String {
        
        var error: NSDictionary?
        var returnOutput = ""
        
        if let scriptObject = NSAppleScript(source: "do shell script \"arch -x86_64 /bin/zsh -cl '\(command)' 2>&1\" ") {
            let output = scriptObject.executeAndReturnError(&error)
            returnOutput.append(output.stringValue ?? "")
            print(output.stringValue ?? "")
            self.log.append(output.stringValue ?? "")
            if (error != nil) {
                print("error: \(String(describing: error))")
                
                returnOutput.append("NSAppleScriptError: \(String(describing: error))")
            }
        }
        
        return returnOutput
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
    func ashell(_ command: String, _ waitTillExit: Bool = true) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-cl", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        try task.run()
        if waitTillExit {
            task.waitUntilExit()
        }
        
        let data = try? pipe.fileHandleForReading.readToEnd()
        let output = String(data: data ?? Data(), encoding: .utf8)!
        
        return output
    }
}

struct RomView: View {
    
    var patch: Array<Patches>
    var repo: Repo
    @State var status: CompilationProcess = .nothing
    @State var allowFinish = true
    @State var log = ""
    @State var doLauncher = true
    @State var betterCamera = 0
    @State var drawDistance = 0
    @State var highFPS = 0
    @State var qolFix = 0
    @State var qolFeatures = 0
    @State var doLog = false
    @State var compSpeed: Speed = .normal
    @State var extData = 0
    @State var shell = Shell()
    @Binding var repoView: Bool
    @AppStorage("romURL") var romURL = URL(fileURLWithPath: "")
    @AppStorage("logData") var logData = false
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("launchEntry") var launcherEntry = true
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    #if arch(x86_64)
    var disableCompilation = false
    #else
    var disableCompilation = true
    #endif
    
    var body: some View {
        ZStack {
            VStack {
                
                if repo == .sm64ex_coop || repo == .moon64 {
                    Text("\n For this repo, make sure you have the intel version of homebrew. To do this, launch your terminal with rosetta and follow install instructions at brew.sh")
                        .lineLimit(nil)
                }
                
                if repo == .sm64ex_coop {
                    Button(action: {
                        
                        log = ""

                        status = .instDependencies
                        
                        do {
                            log.append(try shell.shell("brew uninstall glew sdl2"))
                            
                            log.append(try shell.intelShell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                        }
                        catch {
                            status = .rosetta
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex-coop && git clone \(repo.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && cp baserom.us.z64 sm64ex-coop"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling
                        
                        do {
                            //buffer
                            print(try shell.shell("ls ."))
                            
                            log.append(try shell.intelShell("cd ~/SM64Repos/sm64ex-coop && gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64 EXTERNAL_DATA=\(extData) \(compSpeed.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        var execPath = "sm64ex-coop-build"
                        
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
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && gcp -r sm64ex-coop/build/us_pc/ \(execPath)"))
                        }
                        catch {
                            status = .error
                        }
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex-coop && brew install glew sdl2 && cd \(execPath) && cp discord_game_sdk.dylib /usr/local/lib/"))
                        }
                        catch {
                            status = .error
                        }
                         
                        if doLauncher {
                            let launcherRepo = LauncherRepos(context: moc)
                            
                            launcherRepo.title = "sm64ex-coop"
                            launcherRepo.isEditing = false
                            launcherRepo.path = "~/SM64Repos/\(execPath)/sm64.us.f3dex2e"
                            launcherRepo.args = ""
                            launcherRepo.id = UUID()
                            
                            do {
                                try moc.save()
                            }
                            catch {
                                print(error)
                            }
                        }
                        
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }
                }
                
                else if repo == .sm64ex || repo == .render96ex || repo == .moonshine || repo == .moon64 || repo == .sm64ex_master {
                    
                    Button(action:{
                        
                        log = ""
                        
                        status = .instDependencies
                        
                        do {
                            if repo != .moon64 {
                                log.append(try shell.shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                            }
                            else {
                                log.append(try shell.shell("brew uninstall glew sdl2"))
                                
                                log.append(try shell.intelShell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils wget"))
                            }
                        }
                        catch {
                            status = .notRosetta
                            
                            return
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex && git clone \(repo.rawValue) sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        if repo == .moon64 {
                            if patch.contains(.highfps) {
                                status = .patching
                                
                                do {
                                    log.append(try shell.shell("cd ~/SM64Repos/sm64ex && cp enhancements/moon64_60fps.patch 60fps_ex.patch && git apply --reject --ignore-whitespace '60fps_ex.patch'"))
                                }
                                catch {
                                    status = .error
                                    
                                    return
                                }
                            }
                        }
                        
                        if repo == .sm64ex {
                            if patch.contains(.omm) {
                                status = .patching
                                
                                do {
                                    log.append(try shell.shell("cd ~/SM64Repos && git clone https://github.com/PeachyPeachSM64/sm64pc-omm.git && cp sm64pc-omm/patch/omm.patch sm64ex && rm -rf sm64pc-omm && cd sm64ex && git apply --reject --ignore-whitespace 'omm.patch'"))
                                }
                                catch {
                                    status = .error
                                    
                                    return
                                }
                            }
                        
                            if patch.contains(.highfps) {
                                status = .patching
                                
                                do {
                                    log.append(try shell.shell("cd ~/SM64Repos/sm64ex && cp enhancements/60fps_ex.patch 60fps_ex.patch && git apply --reject --ignore-whitespace '60fps_ex.patch'"))
                                }
                                catch {
                                    status = .error
                                    
                                    return
                                }
                            }
                            
                            if patch.contains(.timeTrials) {
                                status = .patching
                                
                                do {
                                    log.append(try shell.shell("cd ~/SM64Repos/sm64ex && wget https://sm64pc.info/downloads/patches/time_trials.2.4.hotfix.patch && git apply --reject --ignore-whitespace 'time_trials.2.4.hotfix.patch'"))
                                }
                                catch {
                                    status = .error
                                    
                                    return
                                }
                            }
                            
                            if patch.contains(.captainToadStars) {
                                status = .patching
                                
                                do {
                                    log.append(try shell.shell("cd ~/SM64Repos/sm64ex && wget https://sm64pc.info/downloads/patches/captain_toad_stars.patch && git apply --reject --ignore-whitespace 'captain_toad_stars.patch'"))
                                }
                                catch {
                                    status = .error
                                    
                                    return
                                }
                            }
                            
                            if patch.contains(.extMoveset) {
                                status = .patching
                                
                                do {
                                    log.append(try shell.shell("cd ~/SM64Repos/sm64ex && wget https://sm64pc.info/downloads/patches/Extended.Moveset.v1.03b.sm64ex.patch && git apply --reject --ignore-whitespace 'Extended.Moveset.v1.03b.sm64ex.patch'"))
                                }
                                catch {
                                    status = .error
                                    
                                    return
                                }
                            }
                        }
                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && cp baserom.us.z64 sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling

                        if repo == .moonshine {
                            extData = 1
                        }
                        else if repo == .moon64 {
                            extData = 0
                        }
                        
                        do {
                            if repo != .moon64 {
                                log.append(try shell.shell("cd ~/SM64Repos/sm64ex && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue)"))
                            }
                            else {
                                ///buffer
                                print(try shell.shell("ls ."))
                                
                                log.append(try shell.intelShell("cd ~/SM64Repos/sm64ex && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue)"))
                            }
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        var execPath = "\(repo)-build"
                        
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
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf \(execPath) && gcp -r sm64ex/build/us_pc/ \(execPath)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        if doLauncher {
                            if repo == .moon64 {
                                let launcherRepo = LauncherRepos(context: moc)
                                
                                launcherRepo.title = "\(execPath)"
                                launcherRepo.isEditing = false
                                launcherRepo.path = "~/SM64Repos/\(execPath)/moon64.us.f3dex2e"
                                launcherRepo.args = ""
                                launcherRepo.id = UUID()
                                
                                do {
                                    try moc.save()
                                }
                                catch {
                                    print("its broken \(error)")
                                }
                            }
                            else {
                                let launcherRepo = LauncherRepos(context: moc)
                                
                                launcherRepo.title = "\(execPath)"
                                launcherRepo.isEditing = false
                                launcherRepo.path = "~/SM64Repos/\(execPath)/sm64.us.f3dex2e"
                                launcherRepo.args = ""
                                launcherRepo.id = UUID()
                                
                                do {
                                    try moc.save()
                                }
                                catch {
                                    print("its broken \(error)")
                                }
                            }
                        }
                            
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }.disabled(!disableCompilation)
                }
                else if repo == .sm64port {
                    Button(action:{
                        
                        log = ""
                        
                        status = .instDependencies
                        
                        do {
                            log.append(try shell.shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                        }
                        catch {
                            status = .notRosetta
                            
                            return
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf target_osx.zip target_osx __MACOSX && wget \(repo.rawValue) && unzip target_osx.zip && rm -rf target_osx.zip"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }

                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && cp baserom.us.z64 target_osx"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling

                        do {
                            log.append(try shell.shell("cd ~/SM64Repos/target_osx && gmake \(compSpeed.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        var execPath = "\(repo)-build"
                        
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
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf \(execPath) && gcp -r target_osx/build/us_pc/ \(execPath) "))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf target_osx __MACOSX"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }

                        if doLauncher {
                            let launcherRepo = LauncherRepos(context: moc)
                            
                            launcherRepo.title = "sm64port"
                            launcherRepo.isEditing = false
                            launcherRepo.path = "~/SM64Repos/\(execPath)/sm64.us.f3dex2e"
                            launcherRepo.args = ""
                            launcherRepo.id = UUID()
                            
                            do {
                                try moc.save()
                            }
                            catch {
                                print("its broken \(error)")
                            }
                        }
                            
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }.disabled(!disableCompilation)
                }
                else if repo == .sm64ex_alo {
                    
                    Button(action:{
                        
                        log = ""
                        
                        status = .instDependencies
                        
                        do {
                            log.append(try shell.shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                        }
                        catch {
                            status = .notRosetta
                            
                            return
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex && git clone \(repo.rawValue) sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && cp baserom.us.z64 sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        if patch.contains(.star_road) {
                            status = .patching
                            
                            do {
                                //buffer
                                log.append(try shell.shell("ls ."))
                                
                                log.append(try shell.scriptShell("cd ~/SM64Repos/sm64ex && rm -rf star_road_release.patch && wget -O star_road_release.patch https://raw.githubusercontent.com/EmeraldLoc/star_road_release_patch/main/star_road_release.patch"))
                                
                                log.append(try shell.shell("cd ~/SM64Repos/sm64ex && git apply --reject --ignore-whitespace \"star_road_release.patch\""))
                            }
                            catch {
                                status = .error
                                
                                return
                            }
                        }
                        
                        status = .compiling
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos/sm64ex && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=0 NODRAWDISTANCE=\(drawDistance) QOL_FEATURES=\(qolFeatures) QOL_FIXES=\(qolFix) HIGH_FPS_PC=\(highFPS) \(compSpeed.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        var execPath = "\(repo)-build"
                        
                        let checkExecPath = try? shell.shell("ls ~/SM64Repos/")
                        
                        print(checkExecPath)
                        
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
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf \(execPath) && gcp -r sm64ex/build/us_pc/ \(execPath)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        if doLauncher {
                            let launcherRepo = LauncherRepos(context: moc)
                            
                            launcherRepo.title = "\(repo)"
                            launcherRepo.isEditing = false
                            launcherRepo.path = "~/SM64Repos/\(execPath)/sm64.us.f3dex2e"
                            launcherRepo.args = ""
                            launcherRepo.id = UUID()
                            
                            do {
                                try moc.save()
                            }
                            catch {
                                print("its broken \(error)")
                            }
                        }
                            
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }.disabled(!disableCompilation)
                }
                
                Text("The app will freeze until compilation is finished. The compilation may take 1-8 min. Please keep your computer awake.")
                    .lineLimit(nil)
                
                Text(status.rawValue)
                
                VStack {
                    Toggle(isOn: $doLog) {
                        Text("Log Data")
                    }
                    Toggle(isOn: $doLauncher) {
                        Text("Add Repo to Launcher")
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
                    }
                }
                
                if doLog && (status == .error || status == .finished || status == .rosetta || status == .notRosetta) {
                    ScrollView {
                        TextEditor(text: $log)
                            .disabled(true)
                    }
                }
                VStack {
                    Button(action:{
                        repoView = false
                    }) {
                        Text("Finish")
                    }.disabled(allowFinish)
                }
                
                Spacer()
                
                
            }.onAppear {
                if patch.contains(.bettercam) {
                    betterCamera = 1
                }
                else {
                    betterCamera = 0
                }
                
                if patch.contains(.drawdistance) {
                    drawDistance = 1
                }
                else {
                    drawDistance = 0
                }
                
                if patch.contains(.extData) {
                    extData = 1
                }
                else {
                    extData = 0
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
                
                doLog = logData
                compSpeed = compilationSpeed
                doLauncher = launcherEntry
            }.onChange(of: status) { _ in
                if status != .finished {
                    allowFinish = true
                }
                else {
                    allowFinish = false
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Build Completed"
                    content.subtitle = "The compilation for \(repo) is now finished"
                    content.sound = UNNotificationSound.default

                    // show this notification five seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
}

struct RomView_Previews: PreviewProvider {
    static var previews: some View {
        RomView(patch: [Patches](), repo: .sm64ex, repoView: .constant(false))
    }
}
