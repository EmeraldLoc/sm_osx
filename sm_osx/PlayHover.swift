
import SwiftUI

struct PlayHover: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .frame(width: 250, height: 150)
            .overlay(.black.opacity(isHovered ? 0.7 : 0))
            .overlay(content: {
                if isHovered {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            })
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: .black, radius: configuration.isPressed ? 3 : isHovered ? 7 : 5)
            .scaleEffect(configuration.isPressed ? 0.95 : isHovered ? 1.03 : 1)
            .animation(.linear(duration: 0.2), value: configuration.isPressed)
            .onHover { hovered in
                withAnimation(.linear(duration: 0.2)) {
                    isHovered = hovered
                }
            }
    }
}
