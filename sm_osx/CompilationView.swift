//
//  CompilationView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 5/21/22.
//

import SwiftUI
import UserNotifications

struct CompilationView: View {
    
    @Binding var compileCommands: String
    @State var compilationStatus = CompStatus.nothing
    @State var compilesSucess = false
    @Binding var repo: Repo
    @Binding var execPath: String
    @Binding var doLauncher: Bool
    @State var shell = Shell()
    @State var log = ""
    @State var totalLog = ""
    @State var height = 80
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    let task = Process()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text(log)
                .lineLimit(2)
            
            ProgressView(value: compilationStatus.rawValue, total: 100)
                .progressViewStyle(.linear)
                .padding(.horizontal, 7)
            
            if compilesSucess == false && compilationStatus == .finished {
                
                TextEditor(text: .constant(totalLog))
                
                Button("Finish") {
                    dismiss.callAsFunction()
                }
            }
            
            if compilationStatus != .finished {
                HStack {
                    Spacer()
                    
                    Button("Cancel") {
                        try? shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                        try? shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                        
                        dismiss.callAsFunction()
                    }.padding(.bottom).padding(.trailing)
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
                    // Update your view with the new text here
                    
                    let number = CharacterSet(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
                    let lowerLetters = CharacterSet.lowercaseLetters
                    let upperLetters = CharacterSet.uppercaseLetters
                    
                    print(line)
                    
                    totalLog.append(line)
                    
                    let prevLog = log
                    
                    if !line.isEmpty {
                        if line.rangeOfCharacter(from: number) != nil {
                            log = line
                        }
                        else if line.rangeOfCharacter(from: lowerLetters) != nil {
                            log = line
                        }
                        else if line.rangeOfCharacter(from: upperLetters) != nil {
                            log = line
                        }
                    }
                    
                    if log.contains("Installing Deps") {
                        compilationStatus = .instDependencies
                        
                        log = prevLog
                    }
                    else if log.contains("Started Clone") {
                        compilationStatus = .instRepo
                        
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
                    else if log.contains("Compiling Now") {
                        compilationStatus = .compiling
                        
                        log = prevLog
                    }
                    else if log.contains("Finishing Up") {
                        compilationStatus = .finishingUp
                        
                        log = prevLog
                    }
                    else if log.contains("Finished Doin Stonks") {
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
                            
                            height = 550
                            
                            try? shell.shell("cd ~/SM64Repos && rm -rf \(execPath)", false)
                            try? shell.shell("cd ~/SM64Repos && rm -rf \(repo)", false)
                        }
                    }
                } else {
                    print("Error decoding data. why do I program...: \(pipe.availableData)")
                }
            }
            
            try? task.run()
            
        }.frame(width: 700, height: CGFloat(height))
    }
}
