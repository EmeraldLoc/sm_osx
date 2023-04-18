
import SwiftUI

struct TransparentListStyle: ViewModifier {
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    @AppStorage("transparencyDuringNotSelected") var transparencyDuringNotSelected = false
    func body(content: Content) -> some View {
        if transparency == .normal {
            content
        } else if transparency == .more {
            if transparencyDuringNotSelected {
                content
                    .scrollContentBackground(.hidden)
                    .background(TransparentWhenNotSelectedVisualEffect().ignoresSafeArea())
            } else {
                content
                    .scrollContentBackground(.hidden)
                    .background(TransparentWhenSelectedVisualEffect().ignoresSafeArea())
            }
        }
    }
}

struct TransparentBackgroundStyle: ViewModifier {
    @AppStorage("transparency") var transparency = TransparencyAppearence.normal
    @AppStorage("transparencyDuringNotSelected") var transparencyDuringNotSelected = false
    func body(content: Content) -> some View {
        if transparency == .normal {
            content
        } else if transparency == .more {
            if transparencyDuringNotSelected {
                content.background(TransparentWhenNotSelectedVisualEffect().ignoresSafeArea())
            } else {
                content.background(TransparentWhenSelectedVisualEffect().ignoresSafeArea())
            }
        }
    }
}

extension View {
    func transparentBackgroundStyle() -> some View {
        modifier(TransparentBackgroundStyle())
    }
    
    func transparentListStyle() -> some View {
        modifier(TransparentListStyle())
    }
}

struct TransparentWhenNotSelectedVisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView {
        let view = NSVisualEffectView()
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) { }
}

struct TransparentWhenSelectedVisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
    func updateNSView(_ nsView: NSView, context: Context) { }
}

