//
//  DataController.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 4/2/22.
//

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

