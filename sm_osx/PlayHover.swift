//

import SwiftUI

struct PlayHover: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .overlay(.black.opacity(isHovered ? 0.7 : 0))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onHover { isHovered in
                    withAnimation {
                        self.isHovered = isHovered
                    }
                }
            
            if isHovered {
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.title)
            }
        }
    }
}


extension View {
    func playHover() -> some View {
        self.modifier(PlayHover())
    }
}
