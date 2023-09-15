

import SwiftUI

struct RepoView: View {
    
    @AppStorage("devMode") var devMode = true
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var repo = Repo.none
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select a Repo")
                    .lineLimit(nil)
                    .padding(.top)
                                
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack {
                            Picker("", selection: $repo) {
                                Text("sm64ex")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64ex)
                                
                                Text("sm64ex-master (Old)")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64ex_master)
                                
                                Text("sm64ex-alo")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64ex_alo)
                                
                                Text("sm64ex-coop")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64ex_coop)
                                
                                if devMode {
                                    Text("sm64ex-coop-dev (Only for devs)")
                                        .lineLimit(nil)
                                        .tag(Repo.sm64ex_coop_dev)
                                }
                                
                                Text("Render96ex")
                                    .lineLimit(nil)
                                    .tag(Repo.render96ex)
                                
                                Text("Moonshine")
                                    .lineLimit(nil)
                                    .tag(Repo.moonshine)
                                
                                Text("Moon64 (Discontinued)")
                                    .lineLimit(nil)
                                    .tag(Repo.moon64)
                                
                            }.pickerStyle(.radioGroup).padding(.vertical, 5)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                HStack {
                    Button {} label: {
                        Text("Back")
                    }.disabled(true)
                    
                    Button {
                        repoView = false
                    } label: {
                        Text("Cancel")
                    }
                    
                    Spacer()
                    
                    NavigationLink("Next", value: repo)
                        .buttonStyle(.borderedProminent)
                        .disabled(repo == .none)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationDestination(for: Repo.self) { repo in
                PatchesView(repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
            }
            .navigationDestination(for: [Patches].self) { patches in
                RomView(patch: patches, repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
            }
        }
        .transparentBackgroundStyle()
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 300, minHeight: 300, idealHeight: 300, maxHeight: 300)
    }
}
