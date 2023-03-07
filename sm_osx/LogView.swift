//
//  LogView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 5/24/22.
//

import SwiftUI

struct LogView: View {
    
    @State var readableCrashLog = ""
    @Binding var index: Int
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    
    var body: some View {
        VStack {
            
            Text(launcherRepos[index].title ?? "")
                .padding(.top)
            
            TextEditor(text: $readableCrashLog)
                .frame(minWidth: 350, minHeight: 350)
                .onChange(of: readableCrashLog) { _ in
                    readableCrashLog = launcherRepos[index].log ?? "Error, failed to log. We are sorry for the inconvience"
                }.onChange(of: launcherRepos[index].log) { _ in
                    readableCrashLog = launcherRepos[index].log ?? "Error, failed to log. We are sorry for the inconvience"
                }
                .onAppear {
                    print("Index is: \(String(index))")
                    
                    readableCrashLog = launcherRepos[index].log ?? "Error, failed to log. We are sorry for the inconvience"
                }.padding(.top)
            
            Spacer()
            
            Button("Finish") {
                dismiss.callAsFunction()
            }.padding()
        }
    }
}
