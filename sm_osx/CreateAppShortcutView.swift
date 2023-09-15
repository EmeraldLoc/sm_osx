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
    
    func createInfoPlist(appName: String, iconName: String, plistPath: String) {
        var infoDict: [String: Any] = [:]
        
        infoDict["CFBundleIdentifier"] = "com.CubingStudios.\(appName)"
        infoDict["CFBundleName"] = appName
        infoDict["CFBundleExecutable"] = appName
        infoDict["CFBundleShortVersionString"] = "1.0"
        infoDict["CFBundleVersion"] = "1"
        infoDict["CFBundleDisplayName"] = appName
        infoDict["CFBundleIconFile"] = iconName

        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: infoDict, format: .xml, options: 0)
            
            try plistData.write(to: URL(fileURLWithPath: plistPath))
            
            print("Info.plist created successfully.")
        } catch {
            print("Error creating Info.plist: \(error)")
        }
    }

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
                osascript -e 'run script \"if application \\\"sm_osx\\\" is not running then\ntell application \\\"sm_osx\\\" to menu bar \\\"Yes\\\"\nend if\ntell application \\\"sm_osx\\\" to launch repo \\\"\(id)\\\"\"'
                """
                let appPath = "/Applications/\(appName).app/Contents/"
                let filePath = "/Applications/\(appName).app/Contents/MacOS"
                let resourcesPath = "/Applications/\(appName).app/Contents/Resources"
                let iconEndPath = "\(resourcesPath)/\(iconPath?.components(separatedBy: "/").last ?? "")"
                
                do {
                    try FileManager.default.removeItem(atPath: "/Applications/\(appName).app")
                } catch {
                    print("Failed to delete file (this is probably ok) error: \(error)")
                }
                
                var attributes = [FileAttributeKey : Any]()
                attributes[.posixPermissions] = 0o755
                
                do {
                    try FileManager.default.createDirectory(at: URL(filePath: filePath), withIntermediateDirectories: true)
                    try FileManager.default.createDirectory(at: URL(filePath: resourcesPath), withIntermediateDirectories: true)
                } catch {
                    print("Error: Could not create directories, \(error)")
                    return
                }
                
                FileManager.default.createFile(atPath: "\(filePath)/\(appName)", contents: script.data(using: .utf8), attributes: attributes)
                
                if iconPath != nil {
                    do {
                        try FileManager.default.copyItem(atPath: iconPath!, toPath: iconEndPath)
                    } catch {
                        print("Warning: Failed to transfer icon, \(error)")
                    }
                }
                
                createInfoPlist(appName: appName, iconName: iconPath?.components(separatedBy: "/").last ?? "", plistPath: "\(appPath)/Info.plist")
                
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
