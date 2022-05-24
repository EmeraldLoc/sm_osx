//
//  DeveloperView.swift
//  sm_osx
//
//  Created by Caleb Elmasri on 5/24/22.
//

import SwiftUI

struct DeveloperView: View {
    
    @AppStorage("devMode") var devMode = true
    
    var body: some View {
        List {
            Toggle(isOn: $devMode) {
                Text("Enable dev repos (Not recommended)")
            }
        }
    }
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView()
    }
}
