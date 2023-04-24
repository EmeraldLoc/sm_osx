//

import SwiftUI

struct CreateAppShortcutView: View {
    
    let i: Int
    @State var iconPath: String? = nil
    @State var appName = ""
    @State var isInstallingAppShortcut = false
    @State var notAnimatedIsInstallingAppShortcut = false
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>

    var body: some View {
        VStack {
            TextField("App Name", text: $appName)
                .onAppear {
                    appName = launcherRepos[i].title ?? ""
                }.frame(maxWidth: 200).padding([.top, .horizontal])
            
            ImagePicker(text: "Select Icon", launcherImage: false, image: $iconPath)
            
            Spacer()
            
            Button("Create Shortcut") {
                
                withAnimation {
                    isInstallingAppShortcut = true
                }
                
                notAnimatedIsInstallingAppShortcut = true
                                
                let id = launcherRepos[i].id?.uuidString ?? ""
                let script = """
                #!/bin/sh
                osascript -e 'tell application "sm_osx" to menu bar "Yes"'
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
                
                if iconPath != nil {
                    if let icon = NSImage(contentsOf: URL(fileURLWithPath: iconPath ?? "")) {
                        let result = NSWorkspace.shared.setIcon(icon, forFile: "/Applications/\(appName).app", options: [])
                        print(result)
                    }
                }
                
                dismiss()
            }.buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }.padding(.bottom).disabled(notAnimatedIsInstallingAppShortcut)
            
            if isInstallingAppShortcut {
                ProgressView()
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
            }
        }
    }
}
