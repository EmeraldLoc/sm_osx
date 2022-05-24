//
//  CrashView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 5/24/22.
//

import SwiftUI

struct CrashView: View {
    
    @State var readableCrashLog = ""
    @Binding var beginLogging: Bool
    @Binding var crashStatus: Bool
    @Binding var index: Int
    @FetchRequest(sortDescriptors:[SortDescriptor(\.title)]) var launcherRepos: FetchedResults<LauncherRepos>
    
    var body: some View {
        VStack {
            Text("Your Game Crashed")

            ScrollView {
                
                TextEditor(text: $readableCrashLog)
                    .frame(minWidth: 350, minHeight: 350)
                    .onChange(of: readableCrashLog) { _ in
                        readableCrashLog = launcherRepos[index].log ?? "Error, could not get log data. We are sorry for the inconvienience"
                    }
                    .onAppear {
                        readableCrashLog = launcherRepos[index].log ?? "Error, could not get log data. We are sorry for the inconvienience"
                    }
            }
            
            Button("Close") {
                launcherRepos[index].log? = ""
                
                crashStatus = false
            }
        }.frame(minWidth: 350, maxHeight: 350)
    }
}
