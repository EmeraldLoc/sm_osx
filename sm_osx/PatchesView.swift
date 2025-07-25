
import SwiftUI

struct PatchesView: View {
    
    @State var repo: Repo
    @State var isOmm = false
    @State var isToadStars = false
    @State var extMoveset = false
    @State var isFPS = false
    @State var isCam = false
    @State var isDist = false
    @State var extData = false
    @State var debug = false
    @State var dev = false
    @State var timeTrials = false
    @State var isQOLFeat = false
    @State var isQOLFix = false
    @State var starRoad = false
    @Binding var repoView: Bool
    @Binding var reloadMenuBarLauncher: Bool
    @State var patches = [Patch]()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Select a Patch")
                .lineLimit(nil)
                .padding(.top)
                        
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(Array(builtinPatches.keys.sorted()).filter { key in
                            builtinPatches[key]?.repoCompatibility.contains(repo.name) ?? false
                        }, id: \.self) { key in
                            let patch = builtinPatches[key]
                            Toggle(patch?.name ?? "nil", isOn: .init(
                                get: { patches.contains(patch ?? Patch()) },
                                set: { _ in
                                    if patches.contains(patch ?? Patch()) {
                                        if let index = patches.firstIndex(of: patch ?? Patch()) {
                                            patches.remove(at: index)
                                        }
                                    } else {
                                        patches.append(patch ?? Patch())
                                    }
                                }
                            ))
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }.padding(5).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack {
                
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                }
                
                Button {
                    repoView = false
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                
                NavigationLink("Next", value: patches)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}
