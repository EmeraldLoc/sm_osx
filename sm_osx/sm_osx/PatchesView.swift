//
//  PatchesView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 3/6/22.
//

import SwiftUI

struct PatchesView: View {
    
    var repo: Repo
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Select a Patch")
                    
                    Spacer()
                    
                    List {
                        if repo == .sm64ex {
                            NavigationLink(destination: RomView(patch: .omm, repo: repo)) {
                                Text("Oddysey Mario Moveset")
                            }
                        }
                        
                        NavigationLink(destination:RomView(patch: .nothing, repo: repo)) {
                            Text("None")
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
