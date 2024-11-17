
import SwiftUI

struct CustomRepoView: View {
    
    @State var repo: Repo
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Configure Custom Repo")
                .lineLimit(nil)
                .padding(.top)
            
            GroupBox {
                VStack(alignment: .leading) {
                    TextField("Name", text: $repo.name)
                        .onChange(of: repo.name) { _ in
                            let filteredName
                                = repo.name
                                .replacingOccurrences(of: " ", with: "")
                            repo.name = filteredName
                        }
                    TextField("Clone URL", text: $repo.cloneURL)
                        .onChange(of: repo.cloneURL) { _ in
                            let filteredCloneURL 
                                = repo.cloneURL
                                .replacingOccurrences(of: " ", with: "")
                            repo.cloneURL = filteredCloneURL
                        }
                    TextField("Branch", text: $repo.branch)
                        .onChange(of: repo.cloneURL) { _ in
                            let filteredCloneURL
                                = repo.cloneURL
                                .replacingOccurrences(of: " ", with: "")
                            repo.cloneURL = filteredCloneURL
                        }
                    TextField("Build Flags", text: $repo.buildFlags)
                    TextField("Exec File Name (Usually leave empty)", text: $repo.customEndFileName)
                        .onChange(of: repo.customEndFileName) { _ in
                            let filteredCustomEndFileName = repo.customEndFileName.replacingOccurrences(of: " ", with: "")
                            repo.customEndFileName = filteredCustomEndFileName
                        }
                    Toggle("Use OSX_BUILD=1 Build Flag", isOn: $repo.useOsxBuildFlag)
                    if isArm() {
                        Toggle("Uses x86_64 (Intel)", isOn: $repo.x86_64)
                    }
                    
                    Spacer()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
            
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
                
                NavigationLink("Next", value: repo)
                    .buttonStyle(.borderedProminent)
                    .disabled(!repo.cloneURL.hasSuffix(".git") || repo.name.isEmpty)
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}
