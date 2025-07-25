import SwiftUI
import AppKit
import UniformTypeIdentifiers
import UserNotifications

struct LauncherView: View {
    
    @EnvironmentObject var network: NetworkMonitor
    @Binding var repoView: Bool
    @Environment(\.managedObjectContext) var moc
    @Environment(\.openWindow) var openWindow
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @State var existingRepo = URL(string: "")
    @State var romInserted = false
    @AppStorage("firstLaunch") var firstLaunch = true
    @AppStorage("checkUpdateAuto") var checkUpdateAuto = true
    @AppStorage("isGrid") var isGrid = false
    @State var romURL = URL(string: "")
    @State var isLogging = false
    @State var showPackageInstall = false
    @Binding var reloadMenuBarLauncher: Bool
    @ObservedObject var launchRepoAppleScript = LaunchRepoAppleScript.shared
    let rom: UTType = .init(filenameExtension: "z64") ?? UTType.unixExecutable

    func showOpenPanelForRom() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [rom]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    
    @MainActor
    var body: some View {
        VStack {
            if !launcherRepos.isEmpty {
                List {
                    if isGrid {
                        LauncherGridView(reloadMenuBarLauncher: $reloadMenuBarLauncher, existingRepo: $existingRepo)
                    } else {
                        LauncherListView(reloadMenuBarLauncher: $reloadMenuBarLauncher, existingRepo: $existingRepo)
                    }
                }
                .padding(.top, 1)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.never)
            }
            
            if launcherRepos.isEmpty {
                if romInserted {
                    Text("You have no repos, add a repo to begin!")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Please select your Super Mario 64 rom")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            
            if !romInserted {
                Button("Select Rom") {
                    if !launcherRepos.isEmpty {
                        for i in 0...launcherRepos.count - 1 {
                            launcherRepos[i].isEditing = false
                        }
                    }
                    
                    romURL = showOpenPanelForRom()
                    romURL? = URL(fileURLWithPath: romURL?.path.replacingOccurrences(of: " ", with: #"\ "# , options: .literal, range: nil) ?? "")
                    
                    Shell().shell("cp \(romURL?.path ?? "") ~/SM64Repos/baserom.us.z64")
                    
                    if FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos/baserom.us.z64") {
                        romInserted = true
                    } else {
                        romInserted = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom)
            } else if launcherRepos.isEmpty {
                Button("Add Repo") {
                    repoView = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }.toolbar {
            ToolbarItem {
                Menu {
                    Button(action: {
                        if !launcherRepos.isEmpty {
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                        }
                        
                        repoView = true
                    }) {
                        Text("Add New Repo")
                    }.buttonStyle(.borderedProminent).disabled(!romInserted)
                    
                    Button("Add Existing Repo") {
                        if !launcherRepos.isEmpty {
                            for i in 0...launcherRepos.count - 1 {
                                launcherRepos[i].isEditing = false
                            }
                        }
                        
                        existingRepo = showExecFilePanel()
                        
                        if existingRepo != nil {
                            
                            let repo = LauncherRepos(context: moc)
                            
                            repo.title = "New Repo \(launcherRepos.count)"
                            repo.path = existingRepo?.path
                            repo.args = ""
                            repo.id = UUID()
                            
                            do {
                                try moc.save()
                                
                                reloadMenuBarLauncher = true
                            }
                            catch {
                                print("it BROKE \(error)")
                            }
                        }
                    }
                } label: {
                    Label("Repo", systemImage: "plus")
                }
                .menuIndicator(.hidden)
            }
        }.task {
            if FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos/baserom.us.z64") {
                romInserted = true
            } else {
                romInserted = false
            }

            if !FileManager.default.fileExists(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos") {
                do {
                    try FileManager.default.createDirectory(atPath: "\(FileManager.default.homeDirectoryForCurrentUser.path())/SM64Repos", withIntermediateDirectories: true)
                    print("Created Folder SM64Repos in the home folder.")
                } catch {
                    print("Error, could not create folder (this is probably ok), error: \(error)")
                }
            }
            
            do {
                let success = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                if success {
                    print("Finished Launch Sequence")
                } else {
                    print("Notification authorization was not granted.")
                }
            } catch {
                print(error)
            }
            
            if launcherRepos.isEmpty { return }
            
            for i in 0...launcherRepos.count - 1 {
                launcherRepos[i].isEditing = false
                
                let launchID = UserDefaults.standard.string(forKey: "launch-repo-id") ?? ""
                
                if launchID == launcherRepos[i].id?.uuidString {
                    let (success, logs) = await Shell().shellAsync("\(launcherRepos[i].path ?? "its broken") \(launcherRepos[i].args ?? "")")
                    
                    if !success {
                        if NSApp.activationPolicy() == .prohibited {
                            showApp()
                        }
                        
                        openWindow(id: "crash-log", value: logs)
                    }
                }
            }
            
        }.sheet(isPresented: $repoView) {
            RepoView(repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                //.frame(minWidth: 650, idealWidth: 750, maxWidth: 850, minHeight: 400, idealHeight: 500, maxHeight: 550)
        }.frame(minWidth: 300, minHeight: 250)
    }
}

