import SwiftUI

struct ImagePicker: View {
    
    @State var text: String
    @Binding var image: String?
    
    var body: some View {
        HStack {
            Button(text) {
                let openPanel = NSOpenPanel()
                openPanel.prompt = "Select File"
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.canChooseFiles = true
                openPanel.allowedContentTypes = [.image]
                openPanel.begin { (result) -> Void in
                    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                        let selectedPath = openPanel.url!.path
                        image = selectedPath
                    }
                }
            }
            
            Button {
                image = nil
            } label: {
                Image(systemName: "trash")
            }.disabled(image == nil)
            
            if image != nil {
                Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: image ?? ""))!)
                    .resizable()
                    .frame(width: 35.56, height: 20)
            }
        }
    }
}
