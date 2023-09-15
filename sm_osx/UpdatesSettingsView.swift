
import SwiftUI
import Sparkle

struct UpdatesSettingsView: View {
    
    private let updater: SPUUpdater
    
    @State private var automaticallyChecksForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle("Automatically Check for Updates", isOn: $automaticallyChecksForUpdates)
                    .onChange(of: automaticallyChecksForUpdates) { newValue in
                        updater.automaticallyChecksForUpdates = newValue
                    }
                
                Toggle("Automatically Download Updates", isOn: $automaticallyDownloadsUpdates)
                    .disabled(!automaticallyChecksForUpdates)
                    .onChange(of: automaticallyDownloadsUpdates) { newValue in
                        updater.automaticallyDownloadsUpdates = newValue
                    }
                
                CheckForUpdatesView(updater: updater)
                
                Button(action: {
                    //Use Old NSWorkspace to open url because for some reason the Environment object for openURL decides to break the initializer, and you cant make a Link look like a button :(
                    NSWorkspace.shared.open(URL(string:"https://github.com/EmeraldLoc/sm_osx/releases/latest")!)
                }) {
                    Text("Check Latest Changelog")
                }
            }
        }.transparentListStyle().scrollDisabled(true)
    }
}
