
import SwiftUI
import Sparkle

struct MenuCommands: Commands {
    @State var existingRepo = URL(string: "")
    @Binding var showAddRepos: Bool
    @State var launcherRepos = [LauncherRepos]()
    @StateObject var dataController: DataController
    var updaterController: SPUStandardUpdaterController
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
            
            Text("Entries").onAppear {
                launcherRepos = fetchLaunchers()
            }
            
            Divider()
            
            if !launcherRepos.isEmpty {
                ForEach(launcherRepos) { LauncherRepo in
                    Button(LauncherRepo.title ?? "Unrecognized Repo") {
                        for iE in 0...launcherRepos.count - 1 {
                            launcherRepos[iE].isEditing = false
                        }
                        
                        print(try? Shell().shell("\(LauncherRepo.path ?? "its broken") \(LauncherRepo.args ?? "")", false))
                    }
                }
            }
        }
        
        CommandMenu("Repos") {
            Button("Add New Repo") {
                showAddRepos = true
            }
        }
        
        CommandMenu("Updater") {
            CheckForUpdatesView(updater: updaterController.updater)
            
            Link("Check Latest Changelog", destination: URL(string: "https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
        }
        
        CommandGroup(replacing: .newItem) { }
    }
}
