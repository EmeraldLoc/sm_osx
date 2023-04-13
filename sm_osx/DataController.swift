
import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "DataStore")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error, failed to load CoreData due to \(error.localizedDescription)")
            }
        }
    }
}
