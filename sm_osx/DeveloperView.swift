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
                Text("Enable development repos (Not recommended)")
            }
        }
    }
}
