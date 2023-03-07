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
        NavigationView {
            List {
                NavigationLink(destination: General_View(), isActive: $defaultView, label: {Text("General")})
                
                NavigationLink(destination: DeveloperView(), label: {Text("Developer")})
            }.listStyle(.sidebar).frame(minWidth: 50)
        }
    }
}
