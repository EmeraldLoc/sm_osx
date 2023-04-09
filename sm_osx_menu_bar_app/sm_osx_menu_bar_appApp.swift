//

import SwiftUI
//import Sparkle

@main
struct sm_osx_menu_bar_appApp: App {
    
    @StateObject private var dataController = DataController()
    @State var showAddRepos = false
    
    var body: some Scene {
        menuExtras(dataController: dataController, showAddRepos: $showAddRepos)
    }
}
