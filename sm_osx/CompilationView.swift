
import SwiftUI
import UserNotifications

struct CompilationView: View {
    
    @Binding var compileCommands: String
    @State var compilationStatus = CompStatus.nothing
    @State var compilationStatusString = " "
    @State var compilesSucess = false
    @Binding var repo: Repo
    @Binding var execPath: String
    @Binding var doLauncher: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var shell = Shell()
    @State var log = ""
    @State var totalLog = ""
    @State var height: Double = 125
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var addingRepo = AddingRepo.shared
    @AppStorage("compilationAppearence") var compilationAppearence = CompilationAppearence.compact
    let task = Process()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            if compilationAppearence == .compact {
                if !log.isEmpty {
                    Text(log)
                        .lineLimit(2)
                        .padding([.horizontal, .top], 5)
                } else {
                    Text(" ")
                        .lineLimit(2)
                        .padding([.horizontal, .top], 5)
                }
            } else {
                Text(compilationStatusString)
                    .onChange(of: compilationStatus) { _ in
                        switch compilationStatus {
                        case .instDependencies:
                            compilationStatusString = "Installing Dependencies..."
                        case .instRepo:
                            compilationStatusString = "Downloading Repo..."
                        case .patching:
                            compilationStatusString = "Patching..."
                        case .copyingFiles:
                            compilationStatusString = "Copying Required Files..."
                        case .compiling:
                            compilationStatusString = "Compiling..."
                        case .finishingUp:
                            compilationStatusString = "Finishing..."
                        case .finished:
                            compilationStatusString = "Finished..."
                        case .nothing:
                            compilationStatusString = "Starting..."
                        }
                    }
            }
            
            ProgressView(value: compilationStatus.rawValue, total: 100)
                .progressViewStyle(.linear)
                .padding(.horizontal, 7)
            
            if compilationAppearence == .compact {
                Text(compilationStatusString)
                    .onChange(of: compilationStatus) { _ in
                        switch compilationStatus {
                        case .instDependencies:
                            compilationStatusString = "Installing Dependencies..."
                        case .instRepo:
                            compilationStatusString = "Downloading Repo..."
                        case .patching:
                            compilationStatusString = "Patching..."
                        case .copyingFiles:
                            compilationStatusString = "Copying Required Files..."
                        case .compiling:
                            compilationStatusString = "Compiling..."
                        case .finishingUp:
                            compilationStatusString = "Finishing..."
                        case .finished:
                            compilationStatusString = "Finished..."
                        case .nothing:
                            compilationStatusString = "Starting..."
                        }
                    }
            }
            
            if (compilesSucess == false && compilationStatus == .finished) || compilationAppearence == CompilationAppearence.full {
                GroupBox {
                    VStack {
                        BetterTextEditor(text: $totalLog, isEditable: false, autoScroll: true)
                    }
                }.padding(.horizontal).frame(maxWidth: .infinity, maxHeight: .infinity)
            
                if compilesSucess == false && compilationStatus == .finished {
                    Button("Finish") {
                        dismiss.callAsFunction()
                    }.padding(.bottom)
                } else {
                    Button("Cancel") {
                        log = "Canceling"
                    }.padding(.bottom)
                }
            }

            if compilationStatus != .finished && compilationAppearence == .compact {
                HStack {
                    Spacer()
                    
                    Button("Cancel") {
                        log = "Canceling"
                    }.padding([.bottom, .trailing])
                }
            }
            
        }.onAppear {
            
            switch compilationAppearence {
            case .compact:
                height = 125
            case .full:
                height = 575
            }
            
            addingRepo.isCompiling = true
            addingRepo.objectWillChange.send()
            
            print("Exec Path: \(execPath)\n Repo Path: \(repo)")
            
            print(compileCommands)
            
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            task.arguments = ["-cl", "cd ~/SM64Repos && rm -rf \(execPath) && cd ~/; \(compileCommands)"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            let outHandle = pipe.fileHandleForReading

            outHandle.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                    let number = CharacterSet.decimalDigits
                    let letters = CharacterSet.letters
                                        
                    totalLog.append(line)
                    
                    let prevLog = log
                    
                    if !line.isEmpty {
                        if line.rangeOfCharacter(from: number) != nil {
                            log = line
                        }
                        else if line.rangeOfCharacter(from: letters) != nil {
                            log = line
                        }
                    }
                     
                    if log.contains("Finished Doin Stonks") {
                        task.terminate()
                        
                        log = prevLog
                        
                        compilationStatus = .finished
                        
                        if try! shell.shell("ls ~/SM64Repos/\(execPath)/sm64.us.f3dex2e | echo y", true) == "y\n" && repo != .moon64 {
                            
                            let content = UNMutableNotificationContent()
                            content.title = "Build Finished Successfully"
                            content.subtitle = "The repo \(repo) has finished building successfully."
                            content.sound = UNNotificationSound.default
                            
                            // show this notification instantly
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            
                            compilesSucess = true
                            
                            if doLauncher {
                                
                                print("~/SM64Repos/\(execPath)/sm64.us.f3dex2e")
                                
                                let launcherRepo = LauncherRepos(context: moc)
                                
                                launcherRepo.title = "\(repo)"
                                launcherRepo.isEditing = false
                                launcherRepo.path = "~/SM64Repos/\(execPath)/sm64.us.f3dex2e"
                                launcherRepo.args = ""
                                launcherRepo.id = UUID()
                                
                                do {
                                    try moc.save()
                                    
                                    reloadMenuBarLauncher = true
                                }
                                catch {
                                    print(error)
                                }
                            }
                            
                            dismiss.callAsFunction()
                        }
                        else if try! shell.shell("ls ~/SM64Repos/\(execPath)/moon64.us.f3dex2e | echo y", true) == "y\n" {
                            
                            let content = UNMutableNotificationContent()
                            content.title = "Build Finished Successfully"
                            content.subtitle = "The build \(repo) has finished successfully."
                            content.sound = UNNotificationSound.default
                            
                            // show this notification instantly
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            
                            // choose a random identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            // add our notification request
                            UNUserNotificationCenter.current().add(request)
                            
                            compilesSucess = true
                            
                            if doLauncher {
                                
                                print("Moon")
                                
                                let launcherRepo = LauncherRepos(context: moc)
                                
                                launcherRepo.title = "\(repo)"
                                launcherRepo.isEditing = false
                                launcherRepo.path = "~/SM64Repos/\(execPath)/moon64.us.f3dex2e"
                                launcherRepo.args = ""
                                launcherRepo.id = UUID()
                                
                                do {
                                    try moc.save()
                                    
                                    reloadMenuBarLauncher = true
                                }
                                catch {
                                    print(error)
                                }
                            }
                            
                            dismiss.callAsFunction()
                        }
                        else {
                            
                            let content = UNMutableNotificationContent()
                            content.title = "Build Failed"
                            content.subtitle = "The build \(repo) has failed."
                            content.sound = UNNotificationSound.default
                            
                            // show this notification instantly
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            
                            // choose a random identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            // add our notification request
                            UNUserNotificationCenter.current().add(request)
                            
                            compilesSucess = false
                            
                            height = 575
                            
                            try? shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                            try? shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                        }
                    }
                    else if log.contains("Finishing Up") {
                        compilationStatus = .finishingUp
                        
                        log = prevLog
                    }
                    else if log.contains("Compiling Now") {
                        compilationStatus = .compiling
                        
                        print(compilationStatus)
                        
                        log = prevLog
                    }
                    else if log.contains("Patching Files") {
                        compilationStatus = .patching
                        
                        log = prevLog
                    }
                    else if log.contains("Rom Files Done") {
                        compilationStatus = .copyingFiles
                        
                        log = prevLog
                    }
                    else if log.contains("Started Clone") {
                        compilationStatus = .instRepo
                        
                        log = prevLog
                    }
                    else if log.contains("Installing Deps") {
                        compilationStatus = .instDependencies
                        
                        log = prevLog
                    }
                } else {
                    print("Error decoding data. why do I program...: \(pipe.availableData)")
                }
            }
            
            try? task.run()
            
        }
        .frame(width: 700, height: height)
        .onDisappear {
            addingRepo.isCompiling = false
            addingRepo.objectWillChange.send()
        }.onChange(of: compilationAppearence) { _ in
            if !compilesSucess {
                switch compilationAppearence {
                case .compact:
                    height = 125
                case .full:
                    height = 575
                }
            }
        }.onChange(of: log) { _ in
            if log == "Canceling" {
                task.terminate()
                
                try? shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                try? shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                
                dismiss.callAsFunction()
            }
        }
    }
}
