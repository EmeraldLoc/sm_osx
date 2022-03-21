//
//  PatchesView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI

struct PatchesView: View {
    
    var repo: Repo
    @State var isOmm = false
    @State var isToadStars = false
    @State var extMoveset = false
    @State var isFPS = false
    @State var isCam = false
    @State var isDist = false
    @State var extData = false
    @State var timeTrials = false
    @State var patches = [Patches]()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Select a Patch")
                    
                    Spacer()
                    
                    List {
                        if repo == .sm64ex {
                            Toggle(isOn: $isFPS) {
                                Text("60 FPS")
                            }.onChange(of: isFPS) { _ in
                                
                                if isFPS {
                                    patches.append(.highfps)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .highfps) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $timeTrials) {
                                Text("Time Trial")
                            }.onChange(of: timeTrials) { _ in
                                
                                if timeTrials {
                                    patches.append(.timeTrials)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .timeTrials) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $isToadStars) {
                                Text("\(Patches.captainToadStars.rawValue)")
                            }.onChange(of: isToadStars) { _ in
                                
                                if isToadStars {
                                    patches.append(.captainToadStars)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .captainToadStars) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $isOmm) {
                                Text("Oddysey Mario Moveset")
                            }.onChange(of: isOmm) { _ in
                                
                                if isOmm {
                                    patches.append(.omm)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .omm) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $extMoveset) {
                                Text("External Moveset")
                            }.onChange(of: extMoveset) { _ in
                                
                                if extMoveset {
                                    patches.append(.extMoveset)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .extMoveset) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $isDist) {
                                Text("No Draw Distance")
                            }.onChange(of: isDist) { _ in
                                
                                if isDist {
                                    patches.append(.drawdistance)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .drawdistance) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                        }
                        if repo == .sm64ex || repo == .sm64ex_coop || repo == .render96ex {
                            Toggle(isOn: $isCam) {
                                Text("Better Camera")
                            }.onChange(of: isCam) { _ in
                                
                                if isCam {
                                    patches.append(.bettercam)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .bettercam) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $extData) {
                                Text("External Data")
                            }.onChange(of: extData) { _ in
                                
                                if extData {
                                    patches.append(.extData)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .extData) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                        }
                        if repo == .sm64ex || repo == .render96ex {
                            
                        }
                        
                        NavigationLink(destination:RomView(patch: patches, repo: repo)) {
                            Text("Next")
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct PatchesView_Previews: PreviewProvider {
    static var previews: some View {
        PatchesView(repo: .sm64ex)
    }
}
