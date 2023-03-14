//

import SwiftUI

struct UpdatesSettingsView: View {
    
    @AppStorage("checkUpdateAuto") var checkUpdateAuto = true
    @Binding var noUpdateAlert: Bool
    @Binding var updateAlert: Bool
    
    var body: some View {
        VStack {
            List {
                Toggle(isOn: $checkUpdateAuto) {
                    Text("Check for Updates Automatically")
                }
                
                Button("Check for Updates") {
                    Task {
                        let result = await checkForUpdates()
                        
                        if result == 0 {
                            noUpdateAlert = true
                        } else {
                            updateAlert = true
                        }
                    }
                }
            }
        }
    }
}
