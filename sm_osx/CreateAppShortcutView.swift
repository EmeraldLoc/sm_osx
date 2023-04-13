//

import SwiftUI

struct CreateAppShortcutView: View {
    
    let i: Int
    @State var iconPath = ""
    @State var appName = ""
    @State var isInstallingAppShortcut = false
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>

    var body: some View {
        
        VStack {
            HStack {
                Text("App Name: ")
                
                TextField("App Name", text: $appName)
                    .onAppear {
                        appName = launcherRepos[i].title ?? ""
                    }.frame(maxWidth: 200)
            }.padding(.top)
            
            Button("Pick Icon") {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.image]
                panel.allowsMultipleSelection = false
                if panel.runModal() == .OK {
                    iconPath = panel.url?.path() ?? ""
                }
            }
            
            Spacer()
            
            Button("Create Shortcut") {
                
                isInstallingAppShortcut = true
                
                try? Shell().shell("brew install fileicon")
                
                let id = launcherRepos[i].id?.uuidString ?? ""
                let script = """
#!/bin/sh
osascript -e 'tell application "sm_osx" to launch repo "\(id)"'
"""
                
                let filePath = "/Applications/\(appName).app"
                
                do {
                    try FileManager.default.removeItem(atPath: "/Applications/\(appName).app")
                } catch {
                    print("Failed to delete file (this is probably ok) error: \(error)")
                }
                
                var attributes = [FileAttributeKey : Any]()
                attributes[.posixPermissions] = 0o755
                
                FileManager.default.createFile(atPath: filePath, contents: script.data(using: .utf8), attributes: attributes)

                print(iconPath)
                
                try? Shell().shell("fileicon set /Applications/\(appName).app \(iconPath)")
                
                dismiss()
            }.buttonStyle(.borderedProminent)
            
            Button("Cancel", role: .destructive) {
                dismiss()
            }.padding(.bottom)
        }
    }
}
