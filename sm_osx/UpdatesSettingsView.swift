//

import SwiftUI

struct UpdatesSettingsView: View {
    
    @AppStorage("checkUpdateAuto") var checkUpdateAuto = true
    
    var body: some View {
        VStack {
            List {
                Toggle(isOn: $checkUpdateAuto) {
                    Text("Check for Updates Automatically")
                }
            }
        }
    }
}
