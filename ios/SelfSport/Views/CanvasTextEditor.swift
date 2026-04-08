import SwiftUI
import UIKit

struct CanvasLiveTextView: UIViewRepresentable {
    @Binding var text: String
    var maxWidth: CGFloat
    var selectAllOnAppear: Bool = false
    var styleType: TextStyleType = .classic
    var styleColor: Color = .white
    var onCommit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.font = styleType.uiFont(size: 24)
        tv.textColor = UIColor(styleColor)
        tv.textAlignment = .center
        tv.tintColor = .white
        tv.backgroundColor = .clear
        tv.autocorrectionType = .no
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.returnKeyType = .done
        tv.delegate = context.coordinator

        applyLayerStyle(to: tv)

        tv.text = text
        context.coordinator.updateIntrinsicHeight(tv, maxWidth: maxWidth)

        let shouldSelectAll = selectAllOnAppear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            tv.becomeFirstResponder()
            if shouldSelectAll {
                tv.selectAll(nil)
            }
        }

        context.coordinator.observeKeyboardDismiss()

        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = UIColor(styleColor)
        uiView.font = styleType.uiFont(size: 24)
        uiView.textContainerInset = .zero
        applyLayerStyle(to: uiView)
        context.coordinator.updateIntrinsicHeight(uiView, maxWidth: maxWidth)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let w = min(proposal.width ?? maxWidth, maxWidth)
        let fitting = uiView.sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: w, height: max(fitting.height, 30))
    }

    private func applyLayerStyle(to tv: UITextView) {
        tv.layer.sublayers?.removeAll(where: { $0.name == "highlightBG" })
        tv.layer.shadowColor = UIColor.black.cgColor
        tv.layer.shadowOffset = CGSize(width: 0, height: 2)
        tv.layer.shadowRadius = 4
        tv.layer.shadowOpacity = 0.5
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CanvasLiveTextView
        private var keyboardObserver: Any?

        init(parent: CanvasLiveTextView) {
            self.parent = parent
        }

        deinit {
            if let observer = keyboardObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        func observeKeyboardDismiss() {
            keyboardObserver = NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.parent.onCommit()
                }
            }
        }

        func updateIntrinsicHeight(_ textView: UITextView, maxWidth: CGFloat) {
            let size = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            if textView.frame.size != CGSize(width: maxWidth, height: max(size.height, 30)) {
                textView.invalidateIntrinsicContentSize()
            }
        }

        @MainActor func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
            updateIntrinsicHeight(textView, maxWidth: parent.maxWidth)
        }

        nonisolated func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                Task { @MainActor in
                    parent.onCommit()
                }
                return false
            }
            return true
        }
    }
}
