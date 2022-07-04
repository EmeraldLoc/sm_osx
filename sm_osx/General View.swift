//
//  General View.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 5/24/22.
//

import SwiftUI

struct General_View: View {
    
    @AppStorage("launchEntry") var launchEntry = true
    @AppStorage("compilationSpeed") var compilationSpeed: Speed = .normal
    @AppStorage("keepRepo") var keepRepo = false
    @AppStorage("checkUpdateAuto") var checkUpdateAuto = true
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    Toggle(isOn: $launchEntry) {
                        Text("Create Launcher Entry By Default")
                    }
                    
                    Toggle(isOn: $keepRepo) {
                        Text("Keep Previously Compiled Repo By Default")
                    }
                    
                    Toggle(isOn: $checkUpdateAuto) {
                        Text("Check for Updates Automatically")
                    }
                    
                    Picker("Default Speed", selection: $compilationSpeed) {
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
                    }.frame(idealWidth: 200, maxWidth: 200)
                }
            }
        }
    }
}

struct General_View_Previews: PreviewProvider {
    static var previews: some View {
        General_View()
    }
}
