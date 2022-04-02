//
//  RepoView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/16/22.
//

import SwiftUI

struct RepoView: View {
    
    @State var shell = RomView(patch: [Patches](), repo: .sm64ex)
    @State var currentVersion = "v1.0.9\n"
    @State var updateAlert = false
    @State var latestVersion = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("What repo would you like to use (More will be added in th future)")
                    List {
                        
                        NavigationLink(destination: RomView(patch: [], repo: .sm64port)) {
                            
                            Text("sm64port")
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex)) {
                            
                            Text("sm64ex")
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex_master)) {
                            
                            Text("sm64ex-master (Old)")
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex_coop)) {
                            
                            Text("sm64ex-coop (Runs via Rosetta)")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .render96ex)) {
                            
                            Text("Render96ex")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .moonshine)) {
                            
                            Text("Moonshine")
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .moon64)) {
                            
                            Text("Moon64 (Discontinued)")
                        }
                    }
                    Spacer()
                    
                    Button(action:{
                        print(try! shell.shell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils && brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile coreutils"))
                    }) {
                        Text("Install Dependencies")
                    }.padding(.vertical).buttonStyle(.plain)
                }
            }
        }.onAppear {
            latestVersion = try! shell.shell("curl https://github.com/EmeraldLoc/sm_osx/releases/latest -s | grep -o 'v[0-9].[0-9].[0-9]*' | sort -u")
            
            print("Latest Version: \(latestVersion), Current Version: \(currentVersion)")
            
            if latestVersion != currentVersion && !latestVersion.isEmpty {
                updateAlert = true
            }
        }.alert("An Update is Avalible", isPresented: $updateAlert) {
            Button("Update", role: .none) {
                print(try! shell.shell("cd ~/Downloads && wget https://github.com/EmeraldLoc/sm_osx/releases/latest/download/sm_osx.zip && unzip sm_osx.zip && rm -rf sm_osx.zip /Applications/sm_osx.app && mv sm_osx.app /Applications"))
                
                exit(0)
            }
            
            Button("Not now", role: .cancel) {}
        }
    }
}

struct RepoView_Previews: PreviewProvider {
    static var previews: some View {
        RepoView()
    }
}
