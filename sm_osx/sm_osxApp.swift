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
    
    func isVentura() -> Bool {
        if #available(macOS 13.0, *) { return true } else { return false }
    }
    
    var body: some Scene {
        
        WindowGroup {
            LauncherView(repoView: $showAddRepos, updateAlert: $updateAlert)
                .frame(minWidth: 300, minHeight: 250)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }.commands {
            SidebarCommands()
            
            MenuCommands(updateAlert: $updateAlert, showAddRepos: $showAddRepos, dataController: dataController)
            
        }
        
        Settings {
            SettingsView()
        }
    }
}
