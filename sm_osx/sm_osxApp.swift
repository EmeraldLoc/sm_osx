//
//  sm_osxApp.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI

@main
struct sm_osxApp: App {
    
    @StateObject private var dataController = DataController()
    @State var existingRepo = URL(string: "")
    @State var showAddRepos = false
    @State var updateAlert = false
    
    var body: some Scene {
        
        WindowGroup {
            LauncherView(repoView: $showAddRepos, updateAlert: $updateAlert)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }.commands {
            SidebarCommands()
            
            MenuCommands(updateAlert: $updateAlert, showAddRepos: $showAddRepos, dataController: dataController)
        }

        Settings {
            SettingsView()
                .environment(\.managedObjectContext, dataController.container.viewContext)

        }
    }
}


struct menuExtras: Scene {
    
    @State var dataController: DataController
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    @Binding var updateAlert: Bool
    @Binding var showAddRepos: Bool
    
    private func fetchLaunchers() -> [LauncherRepos] {
        let fetchRequest: NSFetchRequest<LauncherRepos>
        fetchRequest = LauncherRepos.fetchRequest()
        
        let context = dataController.container.viewContext
        
        let objects = try? context.fetch(fetchRequest)
        
        return objects ?? []
    }
    
    
    var body: some Scene {
        if #available(macOS 13.0, *) {
            return MenuBarExtra(isInserted: .constant(true)) {
                ForEach(fetchLaunchers()) { Launcher in
                    Button(Launcher.title ?? "") {
                        
                        let launcherRepos = fetchLaunchers()
                        
                        for iE in 0...launcherRepos.count - 1 {
                            launcherRepos[iE].isEditing = false
                        }
                        
                        try? Shell().shell("\(Launcher.path ?? "its broken") \(Launcher.args ?? "")", false)
                    }
                }
                
                Divider()
                
                Button("Add New Repo") {
                    showAddRepos = true
                }
                
                Divider()
                
                Button("Check for Updates") {
                    checkForUpdates(updateAlert: &updateAlert)
                }
                
                Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
            } label: {
                Image("menu_bar_icon")
                    .resizable()
            }
        } else {
            return WindowGroup { EmptyView() }
        }
    }
}
