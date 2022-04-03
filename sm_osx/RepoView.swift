//
//  RepoView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/16/22.
//

import SwiftUI

struct RepoView: View {
    
    @State var shell = RomView(patch: [Patches](), repo: .sm64ex, repoView: .constant(false))
    @Binding var repoView: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("What repo would you like to use")
                        .lineLimit(nil)
                    List {
                        
                        NavigationLink(destination: RomView(patch: [], repo: .sm64port, repoView: $repoView)) {
                            
                            Text("sm64port")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex, repoView: $repoView)) {
                            
                            Text("sm64ex")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex_master, repoView: $repoView)) {
                            
                            Text("sm64ex-master (Old)")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .sm64ex_coop, repoView: $repoView)) {
                            
                            Text("sm64ex-coop (Runs via Rosetta)")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .render96ex, repoView: $repoView)) {
                            
                            Text("Render96ex")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .moonshine, repoView: $repoView)) {
                            
                            Text("Moonshine")
                                .lineLimit(nil)
                        }
                        
                        NavigationLink(destination: PatchesView(repo: .moon64, repoView: $repoView)) {
                            
                            Text("Moon64 (Discontinued)")
                                .lineLimit(nil)
                        }
                    }
                    Spacer()
                    
                    Button("Cancel") {
                        repoView = false
                    }.padding(.vertical)
                }
            }
        }
    }
}

struct RepoView_Previews: PreviewProvider {
    static var previews: some View {
        RepoView(repoView: .constant(false))
    }
}
