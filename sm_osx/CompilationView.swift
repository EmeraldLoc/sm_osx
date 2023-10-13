
import SwiftUI
import UserNotifications

struct CompilationView: View {
    
    @Binding var compileCommands: String
    @Binding var repo: Repo
    @Binding var customRepo: CustomRepo
    @Binding var execPath: String
    @Binding var doLauncher: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @Binding var finishedCompiling: Bool
    @Binding var developmentEnvironment: Bool
    @Binding var fullExecPath: String
    @State var compilationStatus = CompStatus.nothing
    @State var compilationStatusString = " "
    @State var compilesSucess = false
    @State var shell = Shell()
    @State var log = ""
    @State var totalLog = ""
    @State var height: Double = 100
    @State var cancelCompilation = false
    @State var showingLog = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var addingRepo = AddingRepo.shared
    let process = Process()
    let pipe = Pipe()
    
    var body: some View {
        VStack {
            Text(compilationStatusString)
                .padding(.top, showingLog ? 10 : 0)
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
            
            ProgressView(value: compilationStatus.rawValue, total: 100)
                .progressViewStyle(.linear)
                .padding(.horizontal, 7)
            
            if showingLog {
                GroupBox {
                    VStack {
                        BetterTextEditor(text: $totalLog, isEditable: false, autoScroll: true)
                    }
                }.padding([.horizontal, .bottom]).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            ZStack {
                if !showingLog {
                    if !log.isEmpty {
                        Text(log)
                            .lineLimit(1)
                            .padding(.bottom, 5)
                    } else {
                        Text(" ")
                            .lineLimit(1)
                            .padding(.bottom, 5)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    if compilesSucess == false && compilationStatus == .finished {
                        Button("Close") {
                            pipe.fileHandleForReading.readabilityHandler = nil
                            dismiss()
                        }
                        .padding(.bottom, showingLog ? 10 : 0)
                    } else {
                        Button("Cancel") {
                            cancelCompilation = true
                        }
                        .disabled(cancelCompilation)
                        .padding(.bottom, showingLog ? 10 : 0)
                    }
                    
                    Button() {
                        showingLog.toggle()
                    } label: {
                        VStack {
                            Text(Image(systemName: "chevron.down"))
                                .fontWeight(.bold)
                                .rotationEffect(showingLog ? .degrees(180) : .zero)
                                .disabled(compilesSucess == false && compilationStatus == .finished)
                        }
                    }
                    .padding(.trailing)
                    .padding(.bottom, showingLog ? 10 : 0)
                }
            }
        }.onAppear {
            switch showingLog {
            case false:
                height = 100
            case true:
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
                    
                    if cancelCompilation {
                        process.terminate()
                        self.pipe.fileHandleForReading.readabilityHandler = nil
                        
                        if !developmentEnvironment {
                            shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                            if repo != .custom {
                                shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                            } else {
                                shell.shell("cd ~/SM64Repos && rm -rf \(customRepo.name)", false)
                            }
                        }
                        
                        dismiss()
                    }
                    
                    totalLog.append(line)
                    
                    print(line)
                    
                    if !line.isEmpty {
                        if line.rangeOfCharacter(from: number) != nil || line.rangeOfCharacter(from: letters) != nil {
                            log = String(line.prefix(67))
                            if line.count > 67 {
                                log.append("...")
                            }
                        }
                    }
                                        
                    if log.contains("sm_osx: Done") {
                        if process.isRunning {
                            process.terminate()
                        }
                        
                        compilationStatus = .finished
                        var execDir = ""
                        
                        if repo == .custom {
                            if developmentEnvironment {
                                execDir = "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(customRepo.name)/build/us_pc/\(customRepo.customEndFileName.isEmpty ? "sm64.us.f3dex2e" : customRepo.customEndFileName)"
                            } else {
                                execDir = "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(execPath)/\(customRepo.customEndFileName.isEmpty ? "sm64.us.f3dex2e" : customRepo.customEndFileName)"
                            }
                        } else {
                            if developmentEnvironment {
                                execDir = "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(repo)/build/us_pc/sm64.us.f3dex2e"
                            } else {
                                execDir = "\(FileManager.default.homeDirectoryForCurrentUser.path())SM64Repos/\(execPath)/sm64.us.f3dex2e"
                            }
                        }
                        
                        if FileManager.default.fileExists(atPath: execDir) {
                            let content = UNMutableNotificationContent()
                            content.title = "Build Finished Successfully"
                            content.subtitle = "The repo \(repo == .custom ? customRepo.name : "\(repo)") has finished building successfully."
                            content.sound = UNNotificationSound.default
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            
                            compilesSucess = true
                            
                            if doLauncher {
                                let launcherRepo = LauncherRepos(context: moc)

                                launcherRepo.title = "\(repo == .custom ? customRepo.name : "\(repo)")"
                                launcherRepo.isEditing = false
                                launcherRepo.path = "~/SM64Repos/\(execPath)/\(customRepo.customEndFileName.isEmpty || repo != .custom ? "sm64.us.f3dex2e" : customRepo.customEndFileName)"
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
                            
                            fullExecPath = execDir
                            finishedCompiling = true
                            dismiss()
                        } else {
                            
                            let content = UNMutableNotificationContent()
                            content.title = "Build Failed"
                            content.subtitle = "The build \(repo) has failed."
                            content.sound = UNNotificationSound.default
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            
                            compilesSucess = false
                            showingLog = true
                            
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
        }.onChange(of: showingLog) { _ in
            if !compilesSucess {
                switch showingLog {
                case false:
                    height = 100
                case true:
                    height = 575
                }
            }
        }.onDisappear {
            pipe.fileHandleForReading.readabilityHandler = nil
        }
    }
}
