
import SwiftUI
import Sparkle

struct SettingsView: View {
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
    }
    
    var body: some View {
        TabView {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            UpdatesSettingsView(updater: updater)
                .tabItem {
                    Label("Updates", systemImage: "arrow.down.circle")
                }
            
            DeveloperView()
                .tabItem {
                    Label("Developer", systemImage: "hammer")
                }
        }.frame(minWidth: 250, minHeight: 250)
    }
}
