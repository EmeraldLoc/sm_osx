//
//  SettingsView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/23/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: General_View(), label: {Text("General")})
                
                NavigationLink(destination: DeveloperView(), label: {Text("Developer")})
            }.listStyle(.sidebar)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
