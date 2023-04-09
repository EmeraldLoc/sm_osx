
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
                    TextEditor(text: .constant(log))
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.never)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }.padding(.horizontal)
                
            
            Button("Close") {
                dismiss()
            }.padding(.bottom)
        }
    }
}
