
import SwiftUI
import Sparkle

struct SettingsView: View {
    private let updater: SPUUpdater
    @State var tabSelection = 0

    init(updater: SPUUpdater) {
        self.updater = updater
    }
    
    var body: some View {
        TabView(selection: $tabSelection.animation()) {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .frame(width: 350, height: 200)
                .tag(0)
            
            AppearenceSettingsView()
                .tabItem {
                    Label("Appearence", systemImage: "eye")
                }
                .frame(width: 350, height: 90)
                .tag(1)
            
            UpdatesSettingsView(updater: updater)
                .tabItem {
                    Label("Updates", systemImage: "arrow.down.circle")
                }
                .frame(width: 350, height: 150)
                .tag(2)
            
            DeveloperView()
                .tabItem {
                    Label("Developer", systemImage: "hammer")
                }
                .frame(width: 350, height: 60)
                .tag(3)
        }
    }
}
