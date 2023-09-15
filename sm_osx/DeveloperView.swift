
import SwiftUI

struct DeveloperView: View {
    
    @AppStorage("devMode") var devMode = true
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle(isOn: $devMode.animation()) {
                    Text("Enable development repos (Not recommended)")
                }
            }
        }.transparentListStyle().scrollDisabled(true)
    }
}
