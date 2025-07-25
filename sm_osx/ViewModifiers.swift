
import SwiftUI

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
        scroll.hasVerticalScroller = false
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
