//
//  MenuBarView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 6/24/22.
//

import SwiftUI


struct MenuCommands: Commands {
    @State var existingRepo = URL(string: "")
    @Binding var updateAlert: Bool
    @Binding var showAddRepos: Bool
    @StateObject var dataController: DataController
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    private func fetchLaunchers() -> [LauncherRepos] {
        let fetchRequest: NSFetchRequest<LauncherRepos>
        fetchRequest = LauncherRepos.fetchRequest()
        
        let context = dataController.container.viewContext
        
        let objects = try? context.fetch(fetchRequest)
        
        return objects ?? []
    }
    
    var body: some Commands {
        CommandMenu("Launch") {
            let launcherRepos = fetchLaunchers()
            
            ForEach(launcherRepos) { LauncherRepo in
                Button(LauncherRepo.title ?? "Unrecognized Repo") {
                    for iE in 0...launcherRepos.count - 1 {
                        launcherRepos[iE].isEditing = false
                    }
        
                    print(try? Shell().shell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", false))
                }
            }
        }
        
        CommandMenu("Repos") {
            Button("Add New Repo") {
                showAddRepos = true
            }
        }
        
        CommandMenu("Updater") {
            Button("Check for Updates") {
                checkForUpdates(updateAlert: &updateAlert)
            }
            
            Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
        }
    }
}
