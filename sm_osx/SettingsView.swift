//
//  SettingsView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/23/22.
//

import SwiftUI

struct SettingsView: View {
    @State var defaultView = true
    var body: some View {
        TabView {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            UpdatesSettingsView()
                .tabItem {
                    Label("Update", systemImage: "arrow.down.circle")
                }
            
            DeveloperView()
                .tabItem {
                    Label("Developer", systemImage: "hammer")
                }
        }.frame(minWidth: 250, minHeight: 250)
    }
}
