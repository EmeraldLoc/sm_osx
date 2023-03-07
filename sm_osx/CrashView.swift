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
                .padding(.top)

            ZStack {
                TextEditor(text: .constant(launcherRepos[index].log ?? "Error, could not get log data. We are sorry for the inconvienience"))
                    .padding(.vertical)
                    
            }
            
            Button("Close") {
                launcherRepos[index].log? = ""
                
                crashStatus = false
            }.padding(.bottom)
        }.frame(width: 400, height: 400)
    }
}
