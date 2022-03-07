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
    @State var status: CompilationProcess = .nothing
    @State var log = ""
    
    func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-cl", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        try task.run()
        
        let data = try? pipe.fileHandleForReading.readToEnd()
        let output = String(data: data ?? Data(), encoding: .utf8)!
        
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
                        
                        isCompiled = true
                        status = .instDependencies
                        
                        do {
                            log = try shell("/usr/local/bin/brew install make mingw-w64 gcc gcc@9 sdl2 pkg-config glew glfw3 libusb audiofile coreutils")
                        }
                        catch {
                            status = .rosetta
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell("cd ~/Downloads && rm -rf sm64ex-coop && git clone \(repo.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell("cd ~/Downloads && cp baserom.us.z64 sm64ex-coop && cd sm64ex-coop"))
                            }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling
                        
                        do {
                            log.append(try shell("cd ~/Downloads/sm64ex-coop && gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        do {
                            log.append(try shell("cd ~/Downloads && gcp -r sm64ex-coop/build/us_pc/ bin"))
                        }
                        catch {
                            status = .error
                        }
                        
                        do {
                            log.append(try shell("cd ~/Downloads && rm -rf sm64ex-coop"))
                        }
                        catch {
                            status = .error
                        }
                        
                        status = .finished
                        isCompiled = false
                        
                    }) {
                        Text("Start the Compiler")
                    }.disabled(isCompiled)
                }
                
                else if patch == .nothing {
                    
                    Button(action:{
                        
                        status = .instDependencies
                        
                        do {
                            log.append(try shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile"))
                        }
                        catch {
                            status = .notRosetta
                            
                            return
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell("cd ~/Downloads && rm -rf sm64ex && git clone https://github.com/EmeraldLoc/sm64ex.git"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell("cd ~/Downloads && cp baserom.us.z64 sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling
                        
                        do {
                            log.append(try shell("cd ~/Downloads/sm64ex && gmake OSX_BUILD=1 TARGET_ARCH=x86_64-apple-darwin TARGET_BITS=64"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        do {
                            log.append(try shell("cd ~/Downloads && gcp -r sm64ex/build/us_pc/ bin"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        do {
                            log.append(try shell("cd ~/Downloads && rm -rf sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }
                }
                else if patch == .omm {
                    Button(action:{
                        
                        status = .instDependencies
                        
                        do {
                            log.append(try shell("brew install make mingw-w64 gcc sdl2 pkg-config glew glfw3 libusb audiofile"))
                        }
                        catch {
                            status = .notRosetta
                            
                            return
                        }
                        
                        status = .instRepo
                        
                        do {
                            log.append(try shell("cd ~/Downloads && rm -rf sm64pc-omm && rm -rf sm64ex && git clone \(repo.rawValue) && git clone \(patch.rawValue)"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .copyingFiles
                        
                        do {
                            log.append(try shell("cd ~/Downloads && cp baserom.us.z64 \(repo) && cp sm64pc-omm/patch/omm.patch sm64ex"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .patching
                        
                        do {
                            log.append(try shell("git apply --reject --ignore-whitespace 'omm.patch'"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .compiling
                        
                        do {
                            log.append(try shell("cd ~/Downloads/\(repo) && gmake OSX_BUILD=1"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        status = .finishingUp
                        
                        do {
                            log.append(try shell("cd ~/Downloads && gcp -r sm64ex/build/us_pc/ bin"))
                        }
                        catch {
                            status = .error
                            
                            return
                        }
                        
                        do {
                            log.append(try shell("cd ~/Downloads && rm -rf sm64ex"))
                        }
                        catch {
                            status = .error
                        }
                        
                        status = .finished
                        
                    }) {
                        Text("Start the Compiler")
                    }
                }
                
                Text("The app will freeze until compilation is finished")
                
                Text(status.rawValue)
                
                ScrollView {
                    Text(log)
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
