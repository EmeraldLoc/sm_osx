
import SwiftUI

struct AboutView: View {
    
    let sm_osx_about_text = "sm_osx is a app that allows you to compile Super Mario 64 Pc Port repos with ease. It has a launcher, so that you can launch all your repos from one place, and an auto updater, so no need to worry about checking the github every five seconds. sm_osx also includes multiple sections in the menu bar, so you can use the app without the big window being there at all times."
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(minWidth: 150, maxWidth: 150, minHeight: 150, maxHeight: 150)
                        .transition(.scale)
                    
                    Text("sm_osx v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                }
                
                Spacer()
                
                VStack {
                    Text(sm_osx_about_text)
                        .padding(.trailing)
                }
            }
        }
    }
}
