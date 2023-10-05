
import SwiftUI
import UserNotifications

struct CompilationView: View {
    
    @Binding var compileCommands: String
    @Binding var repo: Repo
    @Binding var customRepo: CustomRepo
    @Binding var execPath: String
    @Binding var doLauncher: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var compilationStatus = CompStatus.nothing
    @State var compilationStatusString = " "
    @State var compilesSucess = false
    @State var shell = Shell()
    @State var log = ""
    @State var totalLog = ""
    @State var height: Double = 125
    @State var cancelCompilation = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var addingRepo = AddingRepo.shared
    @AppStorage("compilationAppearence") var compilationAppearence = CompilationAppearence.compact
    let process = Process()
    let pipe = Pipe()
    
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
                            if !compilesSucess {
                                compilationStatusString = "Compilation Failed."
                            }
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
                            if compilesSucess {
                                compilationStatusString = "Finished..."
                            } else {
                                compilationStatusString = "Failed to Compile"
                            }
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
                    Button("Close") {
                        pipe.fileHandleForReading.readabilityHandler = nil
                        dismiss()
                    }.padding(.bottom)
                } else {
                    Button("Cancel") {
                        cancelCompilation = true
                    }
                    .padding(.bottom)
                    .disabled(cancelCompilation)
                }
            }

            if compilationStatus != .finished && compilationAppearence == .compact {
                HStack {
                    Spacer()
                    
                    Button("Cancel") {
                        cancelCompilation = true
                    }
                    .padding([.bottom, .trailing])
                    .disabled(cancelCompilation)
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
            
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-cl", "cd ~/SM64Repos && rm -rf \(execPath) && cd ~/; \(compileCommands)"]
            
            process.standardOutput = pipe
            process.standardError = pipe
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
                    
                    if cancelCompilation {
                        process.terminate()
                        self.pipe.fileHandleForReading.readabilityHandler = nil
                        
                        shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                        if repo != .custom {
                            shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                        } else {
                            shell.shell("cd ~/SM64Repos && rm -rf \(customRepo.name)", false)
                        }
                        
                        dismiss()
                    }
                                        
                    if log.contains("sm_osx: Done") {
                        if process.isRunning {
                            process.terminate()
                        }
                        
                        compilationStatus = .finished
                        
                        if FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(execPath)/sm64.us.f3dex2e") && repo != .custom {
                            
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
                            
                            dismiss()
                        } else if FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(execPath)/\(customRepo.customEndFileName.isEmpty ? "sm64.us.f3dex2e" : customRepo.customEndFileName)") {
                            
                            let content = UNMutableNotificationContent()
                            content.title = "Build Finished Successfully"
                            content.subtitle = "The build \(customRepo.name) has finished successfully."
                            content.sound = UNNotificationSound.default
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            
                            compilesSucess = true
                            
                            if doLauncher {
                                
                                let launcherRepo = LauncherRepos(context: moc)
                                
                                launcherRepo.title = "\(customRepo.name)"
                                launcherRepo.isEditing = false
                                launcherRepo.path = "~/SM64Repos/\(execPath)/\(customRepo.customEndFileName.isEmpty ? "sm64.us.f3dex2e" : customRepo.customEndFileName)"
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
                            
                            dismiss()
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
                        
                        outHandle.readabilityHandler = nil
                    }
                    else if log.contains("sm_osx: Finishing Up") {
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
            }

            try? process.run()
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
        }.onDisappear {
            pipe.fileHandleForReading.readabilityHandler = nil
        }
    }
}
