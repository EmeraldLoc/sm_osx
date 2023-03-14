//
//  SettingsView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/23/22.
//

import SwiftUI

struct SettingsView: View {
    @State var defaultView = true
    @Binding var noUpdateAlert: Bool
    @Binding var updateAlert: Bool
    var body: some View {
        TabView {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            UpdatesSettingsView(noUpdateAlert: $noUpdateAlert, updateAlert: $updateAlert)
                .tabItem {
                    Label("Updates", systemImage: "arrow.down.circle")
                }
            
            DeveloperView()
                .tabItem {
                    Label("Developer", systemImage: "hammer")
                }
        }.frame(minWidth: 250, minHeight: 250)
    }
}
