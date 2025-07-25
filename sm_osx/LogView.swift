import SwiftUI

struct LogView: View {
    
    let index: Int
    @State var log = ""
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    let shell = Shell()

    var body: some View {
        VStack {
            Text("\(launcherRepos[index].title ?? "No Name")")
                .padding(.top)
                .font(.title3)
            
            GroupBox {
                VStack {
                    BetterTextEditor(text: $log, isEditable: false, autoScroll: true)
                }
            }.padding(.horizontal)
            
            Button("Close") {
                dismiss()
            }.padding(.bottom)
        }.task {
            await Shell().shellAsync("\(launcherRepos[index].path ?? "its broken") \(launcherRepos[index].args ?? "")") { output in
                log += output + "\n"
            }
        }
    }
}
