
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
    @State var height = 125
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    let task = Process()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            if !log.isEmpty {
                Text(log)
                    .lineLimit(2)
                    .padding([.horizontal, .top], 5)
            } else {
                Text(" ")
                    .padding([.horizontal, .top], 5)
                    .lineLimit(2)
            }
            
            ProgressView(value: compilationStatus.rawValue, total: 100)
                .progressViewStyle(.linear)
                .padding(.horizontal, 7)
            
            Text(compilationStatusString)
                .onChange(of: compilationStatus) { _ in
                    
                    print(compilationStatus)
                    
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
            
            if compilesSucess == false && compilationStatus == .finished {
                
                TextEditor(text: .constant(totalLog))
                
                Button("Finish") {
                    dismiss.callAsFunction()
                }.padding(.bottom)
            }
            
            if compilationStatus != .finished {
                HStack {
                    Spacer()
                    
                    Button("Cancel") {
                        
                        log = "Canceling"
                        
                        try? shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                        try? shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                        
                        dismiss.callAsFunction()
                    }.padding([.bottom, .trailing])
                }
            }
            
            
        }.onAppear {
            
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
                    
                    print(line)
                    
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
            
        }.frame(width: 700, height: CGFloat(height))
    }
}
