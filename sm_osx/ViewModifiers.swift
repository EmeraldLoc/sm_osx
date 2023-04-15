
import SwiftUI

struct TransparentListStyle: ViewModifier {
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    func body(content: Content) -> some View {
        if transparency == .normal {
            content.listStyle(.automatic)
        } else if transparency == .more {
            content.listStyle(.sidebar)
        }
    }
}

extension View {
    func transparentListStyle() -> some View {
        modifier(TransparentListStyle())
    }
}

struct TransparentBackgroundStyle: ViewModifier {
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    func body(content: Content) -> some View {
        if transparency == .normal {
            content.background(.background)
        } else if transparency == .more {
            content.background(TransparentVisualEffect().ignoresSafeArea())
        }
    }
}

extension View {
    func transparentBackgroundStyle() -> some View {
        modifier(TransparentBackgroundStyle())
    }
}

struct TransparentVisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
    func updateNSView(_ nsView: NSView, context: Context) { }
}
