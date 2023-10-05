
import SwiftUI

struct CustomRepoView: View {
    
    let repo: Repo
    @State var customRepo = CustomRepo()
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
                    TextField("Name", text: $customRepo.name)
                        .onChange(of: customRepo.name) { _ in
                            let filteredName
                                = customRepo.name
                                .replacingOccurrences(of: " ", with: "")
                            customRepo.name = filteredName
                        }
                    TextField("Clone URL", text: $customRepo.cloneURL)
                        .onChange(of: customRepo.cloneURL) { _ in
                            let filteredCloneURL 
                                = customRepo.cloneURL
                                .replacingOccurrences(of: " ", with: "")
                            customRepo.cloneURL = filteredCloneURL
                        }
                    TextField("Build Flags", text: $customRepo.buildFlags)
                    TextField("Exec File Name (Usually leave empty)", text: $customRepo.customEndFileName)
                        .onChange(of: customRepo.customEndFileName) { _ in
                            let filteredCustomEndFileName = customRepo.customEndFileName.replacingOccurrences(of: " ", with: "")
                            customRepo.customEndFileName = filteredCustomEndFileName
                        }
                    Toggle("Use OSX_BUILD=1 Build Flag", isOn: $customRepo.useOsxBuildFlag)
                    if isArm() {
                        Toggle("Uses x86_64 (Intel)", isOn: $customRepo.x86_64)
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
                
                NavigationLink("Next", value: customRepo)
                    .buttonStyle(.borderedProminent)
                    .disabled(!customRepo.cloneURL.hasSuffix(".git") || customRepo.name.isEmpty)
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}
