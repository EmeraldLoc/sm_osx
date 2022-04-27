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
    
    var body: some Scene {
        
        WindowGroup {
            LauncherView()
                .frame(minWidth: 300, minHeight: 250)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }.commands {
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
        }
    }
}
