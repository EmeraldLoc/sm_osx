
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
                    
                    print(line)
                    
                    if !line.isEmpty {
                        if line.rangeOfCharacter(from: number) != nil {
                            log = line
                        }
                        else if line.rangeOfCharacter(from: letters) != nil {
                            log = line
                        }
                    }

                    if log.contains("sm_osx: Finishing Up") {
                        compilationStatus = .finishingUp
                    }
                    else if log.contains("sm_osx: Compiling Now") {
                        compilationStatus = .compiling
                    }
                    else if log.contains("sm_osx: Patching Files") {
                        compilationStatus = .patching
                    }
                    else if log.contains("sm_osx: Rom Files Done") {
                        compilationStatus = .copyingFiles
                    }
                    else if log.contains("sm_osx: Starting Clone") {
                        compilationStatus = .instRepo
                    }
                    else if log.contains("sm_osx: Installing Deps") {
                        compilationStatus = .instDependencies
                    }
                } else {
                    print("Error decoding data: \(pipe.availableData)")
                }
                
                if outHandle.availableData.count == 0 {
                    task.terminate()

                    compilationStatus = .finished
                    
                    if shell.shell("ls ~/SM64Repos/\(execPath)/sm64.us.f3dex2e | echo y", true) == "y\n" && repo != .moon64 {
                        
                        let content = UNMutableNotificationContent()
                        content.title = "Build Finished Successfully"
                        content.subtitle = "The repo \(repo) has finished building successfully."
                        content.sound = UNNotificationSound.default
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request)
                        
                        compilesSucess = true
                        
                        if doLauncher {
                            
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
                    else if shell.shell("ls ~/SM64Repos/\(execPath)/moon64.us.f3dex2e | echo y", true) == "y\n" {
                        
                        let content = UNMutableNotificationContent()
                        content.title = "Build Finished Successfully"
                        content.subtitle = "The build \(repo) has finished successfully."
                        content.sound = UNNotificationSound.default
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request)
                        
                        compilesSucess = true
                        
                        if doLauncher {
                            
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

                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)

                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                        UNUserNotificationCenter.current().add(request)
                        
                        compilesSucess = false
                        
                        height = 575
                        
                        shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                        shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                    }
                }
                
                outHandle.stopReadingIfPassedEOF()
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
                
                shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                
                dismiss.callAsFunction()
            }
        }
    }
}
