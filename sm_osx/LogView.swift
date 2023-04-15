
import SwiftUI

struct LogView: View {
    
    let index: Int
    @State var log = ""
    @State var launched = false
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    let shell = Shell()

    var body: some View {
        VStack {
            Text("\(launcherRepos[index].title ?? "No Name")")
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
        }.onAppear {
            if !launched {
                let task = Process()
                
                task.launchPath = "/bin/sh"
                task.arguments = ["-c", "\(launcherRepos[index].path ?? "its broken") \(launcherRepos[index].args ?? "")"]
                
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe
                let outHandle = pipe.fileHandleForReading
                
                outHandle.readabilityHandler = { pipe in
                    if let line = String(data: pipe.availableData, encoding: .utf8) {
                        log.append(line)
                    } else {
                        print("Error decoding data, aaaa: \(pipe.availableData)")
                    }
                }
                
                try? task.run()
                
                launched = true
            }
        }.transparentBackgroundStyle()
    }
}
