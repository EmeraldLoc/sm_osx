
import SwiftUI

struct PatchesView: View {
    
    @State var repo: Repo
    @State var isOmm = false
    @State var isToadStars = false
    @State var extMoveset = false
    @State var isFPS = false
    @State var isCam = false
    @State var isDist = false
    @State var extData = false
    @State var debug = false
    @State var timeTrials = false
    @State var isQOLFeat = false
    @State var isQOLFix = false
    @State var starRoad = false
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var patches = [Patches]()
    @AppStorage("devMode") var devMode = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Select a Patch")
                .lineLimit(nil)
                .padding(.top)
                        
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        if repo == .sm64ex_coop || repo == .sm64ex_coop_dev {
                            Toggle(isOn: $debug) {
                                Text("Debug")
                                    .lineLimit(nil)
                            }.onChange(of: debug) { _ in
                                
                                if debug {
                                    patches.append(.debug)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .debug) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                        }
                        
                        if repo == .sm64ex || repo == .sm64ex_alo {
                            Toggle(isOn: $isFPS) {
                                Text("60 FPS")
                                    .lineLimit(nil)
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
                            
                            if repo != .sm64ex_alo {
                                Toggle(isOn: $timeTrials) {
                                    Text("Time Trial")
                                        .lineLimit(nil)
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
                                
                                Toggle(isOn: $extMoveset) {
                                    Text("Extended Moveset")
                                        .lineLimit(nil)
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
                            }
                        }
                        
                        if repo == .sm64ex || repo == .sm64ex_coop || repo == .render96ex || repo == .moonshine || repo == .sm64ex_alo || repo == .sm64ex_coop_dev {
                            if repo != .sm64ex_coop && repo != .sm64ex_coop_dev {
                                Toggle(isOn: $isCam) {
                                    Text("Better Camera")
                                        .lineLimit(nil)
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
                            }
                            
                            if repo != .moonshine && repo != .sm64ex_alo && repo != .sm64ex_coop && repo != .sm64ex_coop_dev {
                                Toggle(isOn: $extData) {
                                    Text("External Data")
                                        .lineLimit(nil)
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
                        }
                        
                        if repo != .sm64ex_coop && repo != .sm64ex_coop_dev {
                            Toggle(isOn: $isDist) {
                                Text("No Draw Distance")
                                    .lineLimit(nil)
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
                        
                        if repo == .sm64ex_alo {
                            Toggle(isOn: $isQOLFeat) {
                                Text("Quality of Life Features")
                                    .lineLimit(nil)
                            }.onChange(of: isQOLFeat) { _ in
                                
                                if isQOLFeat {
                                    patches.append(.qolFeatures)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .qolFeatures) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            Toggle(isOn: $isQOLFix) {
                                Text("Quality of Life Fixes")
                                    .lineLimit(nil)
                            }.onChange(of: isQOLFix) { _ in
                                
                                if isQOLFix {
                                    patches.append(.qolFixes)
                                }
                                else {
                                    if let i = patches.firstIndex(of: .qolFixes) {
                                        patches.remove(at: i)
                                    }
                                }
                            }
                            
                            if devMode {
                                Toggle(isOn: $starRoad) {
                                    Text("Star Road (Romhack)")
                                        .lineLimit(nil)
                                }.onChange(of: starRoad) { _ in
                                    
                                    if starRoad {
                                        patches.append(.star_road)
                                    }
                                    else {
                                        if let i = patches.firstIndex(of: .star_road) {
                                            patches.remove(at: i)
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }.padding(5).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack {
                
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                }
                
                Button {
                    repoView = false
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                
                NavigationLink("Next", value: patches)
                    .buttonStyle(.borderedProminent)
            }
        }
        .transparentBackgroundStyle()
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}
