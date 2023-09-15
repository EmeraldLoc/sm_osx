
import SwiftUI

struct AppearenceSettingsView: View {
    
    @AppStorage("isGrid") var isGrid = false
    @AppStorage("compilationAppearence") var compilationAppearence = CompilationAppearence.compact
    @AppStorage("transparentBar") var transparentBar = TitlebarAppearence.normal
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    @AppStorage("transparencyDuringNotSelected") var transparencyDuringNotSelected = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Picker("Launcher Appearence", selection: $isGrid.animation()) {
                    Text("Grid")
                        .tag(true)
                    
                    Text("List")
                        .tag(false)
                }.frame(maxWidth: 300)
                
                Picker("Compilation Appearence", selection: $compilationAppearence.animation()) {
                    Text("Compact")
                        .tag(CompilationAppearence.compact)
                    
                    Text("Full")
                        .tag(CompilationAppearence.full)
                }.frame(maxWidth: 350)
                
                Picker("Title Bar", selection: $transparentBar.animation()) {
                    Text("Normal")
                        .tag(TitlebarAppearence.normal)
                    
                    Text("Unified")
                        .tag(TitlebarAppearence.unified)
                }.frame(maxWidth: 200)
                
                Picker("Transparency", selection: $transparency) {
                    Text("Normal")
                        .tag(TransparencyAppearence.normal)
                    
                    Text("More")
                        .tag(TransparencyAppearence.more)
                }
                
                Toggle("Transparency When Window is not Selected", isOn: $transparencyDuringNotSelected)
                    .disabled(transparency != .more)
            }
        }.transparentListStyle().scrollDisabled(true)
    }
}
