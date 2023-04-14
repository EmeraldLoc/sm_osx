
import SwiftUI

struct AppearenceSettingsView: View {
    
    @AppStorage("isGrid") var isGrid = false
    @AppStorage("transparentBar") var transparentBar = TitlebarAppearence.normal
    
    var body: some View {
        List {
            Picker("Launcher View", selection: $isGrid.animation()) {
                Text("Grid")
                    .tag(true)
                
                Text("List")
                    .tag(false)
            }.frame(idealWidth: 200, maxWidth: 200)
            
            Picker("Title Bar", selection: $transparentBar.animation()) {
                Text("Normal")
                    .tag(TitlebarAppearence.normal)
                
                Text("Unified")
                    .tag(TitlebarAppearence.unified)
            }.frame(idealWidth: 200, maxWidth: 200)
        }
    }
}
