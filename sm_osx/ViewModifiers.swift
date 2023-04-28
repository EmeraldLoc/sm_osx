
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

struct BetterTextEditor: NSViewRepresentable {
    
    @Binding var text: String
    
    var textView = NSTextView.scrollableTextView()
    var isEditable: Bool = true
    var autoScroll: Bool = false
    
    func makeNSView(context: Context) -> NSScrollView {
        let documentView = (textView.documentView as! NSTextView)
        
        documentView.backgroundColor = .clear
        documentView.delegate = context.coordinator
        documentView.isEditable = isEditable
        
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.documentView = documentView
        scroll.drawsBackground = false
        
        return scroll
    }

    func updateNSView(_ view: NSScrollView, context: Context) {
        let documentView = (view.documentView as? NSTextView)
        
        documentView?.string = text
        
        if autoScroll {
            documentView?.scrollToEndOfDocument(nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate{
        
        var parent: BetterTextEditor
        
        init(_ parent: BetterTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool { return true }
    }
}
