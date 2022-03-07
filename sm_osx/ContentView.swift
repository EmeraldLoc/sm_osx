//
//  ContentView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var shell = RomView(patch: .nothing, repo: .sm64ex)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("What repo would you like to use (More will be added in th future)")
                    List {
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex)) {
                            
                            Text("sm64ex")
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex_coop)) {
                            
                            Text("sm64ex-coop (Runs via Rosetta)")
                                .lineLimit(nil)
                        }
                    }
                    Spacer()
                    
                    Button("Install all dependencies") {
                        print(try? shell.shell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
