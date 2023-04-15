

import SwiftUI

struct RepoView: View {
    
    @Binding var repoView: Bool
    @AppStorage("devMode") var devMode = true
    @Binding var reloadMenuBarLauncher: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    
                    Text("Select a Repo")
                        .lineLimit(nil)
                        .padding(.top, 3)
                    
                    NavigationLink(destination: PatchesView(repo: .sm64ex, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                        
                        Text("sm64ex")
                            .lineLimit(nil)
                    }
                    
                    if isArm() {
                        NavigationLink(destination: PatchesView(repo: .sm64ex_master, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                            
                            Text("sm64ex-master (Old)")
                                .lineLimit(nil)
                        }
                    }
                    
                    NavigationLink(destination: PatchesView(repo: .sm64ex_alo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                        
                        Text("sm64ex-alo")
                            .lineLimit(nil)
                    }
                    
                    NavigationLink(destination: PatchesView(repo: .sm64ex_coop, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                        
                        Text("sm64ex-coop")
                            .lineLimit(nil)
                    }
                    
                    if devMode {
                        NavigationLink(destination: PatchesView(repo: .sm64ex_coop_dev, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                            
                            Text("sm64ex-coop-dev (Only avalible to devs)")
                                .lineLimit(nil)
                        }
                    }
                    
                    NavigationLink(destination: PatchesView(repo: .render96ex, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                        
                        Text("Render96ex")
                            .lineLimit(nil)
                    }
                    
                    NavigationLink(destination: PatchesView(repo: .moonshine, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                        
                        Text("Moonshine")
                            .lineLimit(nil)
                    }
                    
                    NavigationLink(destination: PatchesView(repo: .moon64, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)) {
                        
                        Text("Moon64 (Discontinued)")
                            .lineLimit(nil)
                    }
                }
                
                Spacer()
                
                Button("Cancel") {
                    repoView = false
                }.padding(.vertical)
            }
        }.transparentListStyle().transparentBackgroundStyle()
    }
}
