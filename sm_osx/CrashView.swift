
import SwiftUI

struct CrashView: View {
    let log: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Your Game Crashed")
                .padding(.top)
                .font(.title3)

            GroupBox {
                VStack {
                    BetterTextEditor(text: .constant(log), isEditable: false, autoScroll: true)
                }
            }.padding(.horizontal)
                
            Button("Close") {
                dismiss()
            }.padding(.bottom)
        }.transparentBackgroundStyle()
    }
}
