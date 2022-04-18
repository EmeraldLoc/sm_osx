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
    
    func asyncShell(_ command: String, waitTillExit: Bool = true) throws -> String {
        let task = Process()

        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-cl", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { [self] pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                // Update your view with the new text here
                
                log.append(line)
            } else {
                print("Error decoding data. why do I program...: \(pipe.availableData)")
            }
        }
        
        try task.run()
        if waitTillExit {
            task.waitUntilExit()
        }
        
        return ""
    }
    func shell(_ command: String) throws -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-cl", command]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding.utf8) ?? ""
            
        return output
    }
}

struct RomView: View {
    
    var patch: Array<Patches>
    var repo: Repo
    @State var isCompiled = false
    @State var status: CompilationProcess = .nothing
    @State var allowFinish = false
    @State var log = ""
    @State var betterCamera = 0
    @State var drawDistance = 0
    @State var doLog = false
    @State var compSpeed: Speed = .normal
    @State var extData = 0
    @State var shell = Shell()
    @Binding var repoView: Bool
    @AppStorage("logData") var logData = false
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
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
                Text("Before we start the compiler, please make sure you have your legally obtained Super Mario 64 rom, and make sure it is named baserom.us.z64. Put it in the Download directory. You only need to have it in this folder for your first compilation.")
                    .lineLimit(nil)
                
                if repo == .sm64ex_coop {
                    Text("MAKE SURE YOU ARE RUNNING THIS APPLICATION WITH ROSSETA. Also, you will need to get the INTEL VERSION of HOMEBREW. To do so, launch terminal with Rosetta and follow instructions at brew.sh")
                        .padding()
                        .lineLimit(nil)

                    Text("IMPORTANT! After the compilation is finished, open this app without Rosetta, and then hit the Install Dependencies button.")
                        .padding()
                        .lineLimit(nil)
                }
                
                if repo == .sm64ex_coop {
                    Button(action: {
                        
                        log = ""
                        
                        isCompiled = true
                        status = .instDependencies
                        
                        do {
                            log = try shell.shell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils wget && brew uninstall glew sdl2")
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
                            log.append(try shell.shell("cd ~/ && cp ~/Downloads/baserom.us.z64 ~/SM64Repos"))
                            
                            log.append(try shell.shell("cd ~/SM64Repos && cp baserom.us.z64 sm64ex-coop"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos/sm64ex-coop && gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64 EXTERNAL_DATA=\(extData) \(compSpeed.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex-coop-build && gcp -r sm64ex-coop/build/us_pc/ sm64ex-coop-build"))
                        }
                        catch {
                            status = .error
                        }
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf sm64ex-coop"))
                        }
                        catch {
                            status = .error
                        }
                         
                        let launcherRepo = LauncherRepos(context: moc)
                        
                        launcherRepo.title = "sm64ex-coop"
                        launcherRepo.isEditing = false
                        launcherRepo.path = "~/SM64Repos/sm64ex-coop-build/sm64.us.f3dex2e"
                        launcherRepo.args = ""
                        launcherRepo.id = UUID()
                        
                        do {
                            try moc.save()
                        }
                        catch {
                            print(error)
                        }
                        
                        status = .finished
                        isCompiled = false
                        
                    }) {
                        Text("Start the Compiler")
                    }.disabled(disableCompilation)
                }
                
                else if repo == .sm64ex || repo == .render96ex || repo == .moonshine || repo == .moon64 || repo == .sm64ex_master {
                    
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
                            log.append(try shell.shell("cp baserom.us.z64 ~/SM64Repos"))
                            
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
                            log.append(try shell.shell("cd ~/SM64Repos/sm64ex && gmake OSX_BUILD=1 BETTERCAMERA=\(betterCamera) EXTERNAL_DATA=\(extData) NODRAWDISTANCE=\(drawDistance) \(compSpeed.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf \(repo)-build && gcp -r sm64ex/build/us_pc/ \(repo)-build"))
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
                        
                        if repo == .moon64 {
                            let launcherRepo = LauncherRepos(context: moc)
                            
                            launcherRepo.title = "\(repo)"
                            launcherRepo.isEditing = false
                            launcherRepo.path = "~/SM64Repos/\(repo)-build/moon64.us.f3dex2e"
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
                            
                            launcherRepo.title = "\(repo)"
                            launcherRepo.isEditing = false
                            launcherRepo.path = "~/SM64Repos/\(repo)-build/sm64.us.f3dex2e"
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
                            log.append(try shell.shell("cd ~/Downloads && cp baserom.us.z64 ~/SM64Repos"))
                            
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
                        
                        do {
                            log.append(try shell.shell("cd ~/SM64Repos && rm -rf \(repo)-build && gcp -r target_osx/build/us_pc/ \(repo)-build"))
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

                        let launcherRepo = LauncherRepos(context: moc)
                        
                        launcherRepo.title = "sm64port"
                        launcherRepo.isEditing = false
                        launcherRepo.path = "~/SM64Repos/sm64port-build/sm64.us.f3dex2e"
                        launcherRepo.args = ""
                        launcherRepo.id = UUID()
                        
                        do {
                            try moc.save()
                        }
                        catch {
                            print("its broken \(error)")
                        }
                        
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }.disabled(!disableCompilation)
                }
                
                Text("The app will freeze until compilation is finished. The compilation may take 1-8 min. Please keep your computer awake.")
                    .lineLimit(nil)
                
                Text(status.rawValue)
                
                Toggle(isOn: $doLog) {
                    Text("Log Data")
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
                
                if doLog && (status == .error || status == .finished || status == .rosetta || status == .notRosetta) {
                    ScrollView {
                        TextEditor(text: $shell.log)
                            .disabled(true)
                    }
                }
                
                Button(action:{
                    repoView = false
                }) {
                    Text("Finish")
                }.disabled(!allowFinish)
                
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
                
                doLog = logData
                compSpeed = compilationSpeed
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
