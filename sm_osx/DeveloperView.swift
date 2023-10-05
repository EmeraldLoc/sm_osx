
import SwiftUI

struct DeveloperView: View {
    
    @AppStorage("devMode") var devMode = true
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle(isOn: $devMode.animation()) {
                    Text("See developer repos and w.i.p repos and patches (Not recommended)")
                }
            }
        }.transparentListStyle().scrollDisabled(true)
    }
}
