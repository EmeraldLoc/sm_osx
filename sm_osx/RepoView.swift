

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
                                Text("sm64ex-alo")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64ex_alo)
                                
                                Text("sm64ex-coop")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64ex_coop)
                                
                                Text("sm64coopdx")
                                    .lineLimit(nil)
                                    .tag(Repo.sm64coopdx)
                                
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
                                
                                Text("Custom")
                                    .lineLimit(nil)
                                    .tag(Repo.custom)
                                
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
                if repo == .custom {
                    CustomRepoView(repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                } else {
                    PatchesView(repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                }
            }
            .navigationDestination(for: [Patches].self) { patches in
                RomView(patch: patches, repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher, customRepo: .constant(CustomRepo()))
            }
            .navigationDestination(for: CustomRepo.self) { customRepo in
                RomView(patch: [Patches](), repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher, customRepo: .constant(customRepo))
            }
        }
        .transparentBackgroundStyle()
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 300, minHeight: 300, idealHeight: 300, maxHeight: 300)
    }
}
