import SwiftUI

struct RepoView: View {
    
    @AppStorage("devMode") var devMode = true
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var repo : Repo?
    
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
                                ForEach(Array(builtinRepos.keys.sorted()), id: \.self) { key in
                                    let repo = builtinRepos[key]
                                    Text(repo?.name ?? "nil")
                                        .tag(repo)
                                }
                                
                                Text("Custom")
                                    .tag(Repo())
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
                if repo == Repo() {
                    CustomRepoView(repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                } else if builtinRepos.contains(where: { $0.value == repo }) {
                    PatchesView(repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                } else {
                    RomView(patches: [Patch](), repo: repo, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
                }
            }
            .navigationDestination(for: [Patch].self) { patches in
                RomView(patches: patches, repo: repo!, repoView: $repoView, reloadMenuBarLauncher: $reloadMenuBarLauncher)
            }
        }
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 300, minHeight: 300, idealHeight: 300, maxHeight: 300)
    }
}

