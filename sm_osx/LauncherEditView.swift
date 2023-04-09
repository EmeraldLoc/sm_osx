
import SwiftUI
import PhotosUI

struct LauncherEditView: View {
    
    @State var repoTitle = ""
    @State var repoArgs = ""
    @State var i: Int
    @State var image: String? = nil
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @Binding var existingRepo: URL?
    
    var body: some View {
        VStack {
            TextField("Name of Repo", text: $repoTitle)
                .lineLimit(nil)
                .padding(.top).frame(width: 200)
            TextField("Arguments", text: $repoArgs)
                .lineLimit(nil)
                .frame(width: 200)
            
            Button("Change Executable") {
                existingRepo = showExecFilePanel()
            }
            
            Button("Create App Shortcut") {
                let name = launcherRepos[i].title ?? "no name"
                let id = launcherRepos[i].id?.uuidString ?? ""                
                let script = """
                
                #!/bin/sh
                
                cd \(Bundle.main.bundlePath)/../
                
                open sm_osx.app
                
                openwin() { osascript -e "tell application \"$1\" to activate" -e 'tell application "System Events" to keystroke "\(i)" using command down and shift down'; }
                
                openwin sm_osx.app

                """
                
                try? Shell().shell("cd /Applications && rm -rf \(name).app && echo '\(script)' > \(name).app && chmod +x \(name).app", false)
            }
            
            ImagePicker(text: "Change Image", image: $image)
                .padding([.horizontal, .bottom])
            
            Button("Save") {
                
                launcherRepos[i].isEditing = false
                launcherRepos[i].title = repoTitle
                launcherRepos[i].args = repoArgs
                launcherRepos[i].path = existingRepo?.path
                launcherRepos[i].imagePath = image
                
                do {
                    try moc.save()
                }
                catch {
                    print("Its broken \(error)")
                }
            }.buttonStyle(.borderedProminent)
            
            Button {
                launcherRepos[i].isEditing = false
            } label: {
                Text("Cancel")
                    .foregroundColor(.red)
            }.padding(.bottom).padding(.horizontal)
        }.frame(width: 250, height: 250)
            .onAppear {
                repoTitle = launcherRepos[i].title ?? ""
                repoArgs = launcherRepos[i].args ?? ""
                existingRepo = URL(string: launcherRepos[i].path ?? "")
                image = launcherRepos[i].imagePath
            }
    }
}
