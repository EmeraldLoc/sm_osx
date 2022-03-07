//
//  RomView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI

struct RomView: View {
    
    var patch: Patches
    var repo: Repo
    @State var isCompiled = false
    @State var isCompiling = false
    
    func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-cl", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Before we start the compiler, please make sure you have your legally obtained Super Mario 64 rom, and make sure it is named baserom.us.z64. Put it in the Download directory. Make sure it is the us version of the rom. The final result will be in your Downloads folder")
                
                if repo == .sm64ex_coop {
                    Text("MAKE SURE YOU ARE RUNNING THIS APPLICATION WITH ROSSETA")
                        .padding()
                    
                    Text("This repo requires intel x86_64")
                    
                    Text("IMPORTANT! After the compilation is finished, open this app without Rosetta, and then hit the Install Dependencies button.")
                        .padding()
                }
                
                if repo == .sm64ex_coop {
                    Button(action:{
                        isCompiled = false
                        isCompiling = true
                        
                        do {
                            print(try shell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils && cd ~/Downloads && rm -rf sm64ex-coop && git clone \(repo.rawValue) && cp baserom.us.z64 sm64ex-coop && cd sm64ex-coop && gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64"))
                        }
                        catch {}
                        
                        isCompiled = true
                        isCompiling = false
                    }) {
                        Text("Start the Compiler")
                    }.disabled(isCompiled)
                }
                
                else if patch == .nothing {
                    
                    Button(action:{
                        isCompiled = false
                        isCompiling = true
                        
                        do {
                            print(try shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile && cd ~/Downloads && git clone https://github.com/EmeraldLoc/sm64ex.git && cp baserom.us.z64 sm64ex && cd sm64ex && gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64"))
                        }
                        catch {}
                        
                        isCompiling = false
                        isCompiled = true
                    }) {
                        Text("Start the Compiler")
                    }
                }
                else if patch == .omm {
                    Button(action:{
                        
                        isCompiled = false
                        isCompiling = true
                        
                        do {
                            print(try shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile && cd ~/Downloads && git clone \(repo.rawValue) && git clone \(patch.rawValue) && cp baserom.us.z64 \(repo) && cp sm64pc-omm/patch/omm.patch sm64ex && cd \(repo) && git apply --reject --ignore-whitespace 'omm.patch' && gmake OSX_BUILD=1"))
                        }
                        catch {}
                        
                        isCompiled = true
                        isCompiling = false
                    }) {
                        Text("Start the Compiler")
                    }
                }
                
                Text("The app will freeze until compilation is finished")
                
                if isCompiled && !isCompiling {
                    Text("Compiled")
                }
                else if !isCompiled && isCompiling {
                    Text("Compiling...")
                }
                
                Spacer()
                
                
            }
        }
    }
}

struct RomView_Previews: PreviewProvider {
    static var previews: some View {
        RomView(patch: .nothing, repo: .sm64ex)
    }
}
