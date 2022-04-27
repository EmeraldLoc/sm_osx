//
//  SettingsView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/23/22.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("logData") var logData = false
    @AppStorage("launchEntry") var launchEntry = true
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    Toggle(isOn: $logData) {
                        Text("Log Data By Default")
                    }
                    
                    Toggle(isOn: $launchEntry) {
                        Text("Create Launcher Entry By Default")
                    }
                    
                    Picker("Compilation Speed By Default", selection: $compilationSpeed) {
                        Text("Slow")
                            .tag(Speed.slow)
                        Text("Normal")
                            .tag(Speed.normal)
                        Text("Fast")
                            .tag(Speed.fast)
                        Text("Very Fast")
                            .tag(Speed.veryFast)
                        Text("Fastest")
                            .tag(Speed.fastest)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
