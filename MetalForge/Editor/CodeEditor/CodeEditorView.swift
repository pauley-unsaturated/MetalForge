import SwiftUI
import AppKit

/// Metal shader code editor with syntax highlighting
struct CodeEditorView: View {
    @Binding var code: String
    let errors: [ShaderError]
    let fontSize: CGFloat
    let showLineNumbers: Bool
    var onCompile: (() -> Void)?

    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)

    var body: some View {
        MetalCodeEditor(
            code: $code,
            errors: errors,
            fontSize: fontSize,
            showLineNumbers: showLineNumbers,
            onCompile: onCompile
        )
    }
}

/// NSViewRepresentable wrapper for NSTextView-based editor
struct MetalCodeEditor: NSViewRepresentable {
    @Binding var code: String
    let errors: [ShaderError]
    let fontSize: CGFloat
    let showLineNumbers: Bool
    var onCompile: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true

        let textView = CodeTextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        textView.textColor = NSColor.white
        textView.insertionPointColor = NSColor.orange
        textView.selectedTextAttributes = [
            .backgroundColor: NSColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        ]

        // Line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        textView.defaultParagraphStyle = paragraphStyle

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false

        // Text container setup
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = false
        textView.isHorizontallyResizable = true
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        scrollView.documentView = textView

        context.coordinator.textView = textView
        context.coordinator.applyHighlighting()

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CodeTextView else { return }

        // Update font if changed
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

        // Update code if changed externally
        if textView.string != code {
            let selectedRange = textView.selectedRange()
            textView.string = code
            textView.setSelectedRange(selectedRange)
            context.coordinator.applyHighlighting()
        }

        // Update error annotations
        context.coordinator.errors = errors
        context.coordinator.updateErrorAnnotations()
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MetalCodeEditor
        weak var textView: CodeTextView?
        var errors: [ShaderError] = []
        private var isUpdating = false

        init(_ parent: MetalCodeEditor) {
            self.parent = parent
            self.errors = parent.errors
        }

        func textDidChange(_ notification: Notification) {
            guard !isUpdating, let textView = textView else { return }
            parent.code = textView.string
            applyHighlighting()
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // Handle Cmd+Return to compile
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if NSEvent.modifierFlags.contains(.command) {
                    parent.onCompile?()
                    return true
                }
            }
            return false
        }

        func applyHighlighting() {
            guard let textView = textView else { return }

            isUpdating = true
            defer { isUpdating = false }

            let text = textView.string
            let fullRange = NSRange(location: 0, length: text.utf16.count)

            // Store selection
            let selectedRange = textView.selectedRange()

            // Reset to default color
            textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.white, range: fullRange)

            // Apply syntax highlighting
            SyntaxHighlighter.highlight(textView.textStorage!, in: text)

            // Restore selection
            textView.setSelectedRange(selectedRange)
        }

        func updateErrorAnnotations() {
            guard let textView = textView else { return }

            // Clear existing error attributes
            let fullRange = NSRange(location: 0, length: textView.string.utf16.count)
            textView.textStorage?.removeAttribute(.underlineStyle, range: fullRange)
            textView.textStorage?.removeAttribute(.underlineColor, range: fullRange)

            // Add error underlines
            let lines = textView.string.components(separatedBy: "\n")
            var lineStart = 0

            for (index, line) in lines.enumerated() {
                let lineNumber = index + 1
                let lineRange = NSRange(location: lineStart, length: line.utf16.count)

                if let error = errors.first(where: { $0.line == lineNumber && !$0.isWarning }) {
                    textView.textStorage?.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: lineRange)
                    textView.textStorage?.addAttribute(.underlineColor, value: NSColor.red, range: lineRange)
                } else if let warning = errors.first(where: { $0.line == lineNumber && $0.isWarning }) {
                    textView.textStorage?.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: lineRange)
                    textView.textStorage?.addAttribute(.underlineColor, value: NSColor.orange, range: lineRange)
                }

                lineStart += line.utf16.count + 1 // +1 for newline
            }
        }
    }
}

/// Custom NSTextView with line numbers
class CodeTextView: NSTextView {
    // Could add line number gutter here in future
}

/// Metal Shading Language syntax highlighter
enum SyntaxHighlighter {
    // Colors
    static let keywordColor = NSColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1.0)     // Purple
    static let typeColor = NSColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0)        // Blue
    static let functionColor = NSColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)    // Yellow
    static let numberColor = NSColor(red: 0.7, green: 0.9, blue: 0.6, alpha: 1.0)      // Green
    static let stringColor = NSColor(red: 0.9, green: 0.6, blue: 0.5, alpha: 1.0)      // Orange
    static let commentColor = NSColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)    // Gray
    static let preprocessorColor = NSColor(red: 0.6, green: 0.8, blue: 0.6, alpha: 1.0) // Light green

    // Patterns
    static let keywords = [
        "if", "else", "for", "while", "do", "switch", "case", "default",
        "break", "continue", "return", "discard",
        "struct", "constant", "device", "thread", "threadgroup",
        "kernel", "vertex", "fragment",
        "using", "namespace", "true", "false"
    ]

    static let types = [
        "void", "bool", "int", "uint", "float", "half", "double",
        "float2", "float3", "float4",
        "float2x2", "float3x3", "float4x4",
        "int2", "int3", "int4",
        "uint2", "uint3", "uint4",
        "half2", "half3", "half4",
        "bool2", "bool3", "bool4",
        "sampler", "texture1d", "texture2d", "texture3d",
        "Uniforms", "VertexIn", "VertexOut"
    ]

    static let builtinFunctions = [
        "sin", "cos", "tan", "asin", "acos", "atan", "atan2",
        "pow", "exp", "exp2", "log", "log2", "sqrt", "rsqrt",
        "abs", "sign", "floor", "ceil", "round", "trunc", "fract", "fmod",
        "min", "max", "clamp", "saturate", "mix", "step", "smoothstep",
        "length", "distance", "dot", "cross", "normalize", "reflect", "refract",
        "fwidth", "dfdx", "dfdy"
    ]

    static func highlight(_ textStorage: NSTextStorage, in text: String) {
        // Comments (single line)
        highlightPattern(#"//.*$"#, in: text, storage: textStorage, color: commentColor, options: .anchorsMatchLines)

        // Comments (multi-line)
        highlightPattern(#"/\*[\s\S]*?\*/"#, in: text, storage: textStorage, color: commentColor)

        // Preprocessor
        highlightPattern(#"#\w+"#, in: text, storage: textStorage, color: preprocessorColor)

        // Strings
        highlightPattern(#""[^"]*""#, in: text, storage: textStorage, color: stringColor)

        // Numbers
        highlightPattern(#"\b\d+\.?\d*[fh]?\b"#, in: text, storage: textStorage, color: numberColor)

        // Keywords
        for keyword in keywords {
            highlightPattern("\\b\(keyword)\\b", in: text, storage: textStorage, color: keywordColor)
        }

        // Types
        for type in types {
            highlightPattern("\\b\(type)\\b", in: text, storage: textStorage, color: typeColor)
        }

        // Built-in functions
        for function in builtinFunctions {
            highlightPattern("\\b\(function)\\s*(?=\\()", in: text, storage: textStorage, color: functionColor)
        }

        // User-defined functions (identifiers followed by parentheses)
        highlightPattern(#"\b([a-zA-Z_]\w*)\s*(?=\()"#, in: text, storage: textStorage, color: functionColor)
    }

    private static func highlightPattern(
        _ pattern: String,
        in text: String,
        storage: NSTextStorage,
        color: NSColor,
        options: NSRegularExpression.Options = []
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }

        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, range: range)

        for match in matches {
            storage.addAttribute(.foregroundColor, value: color, range: match.range)
        }
    }
}

#Preview {
    CodeEditorView(
        code: .constant("""
            // Sample shader
            float4 userFragment(float2 uv, constant Uniforms& u) {
                float d = length(uv - 0.5);
                return float4(d, d, d, 1.0);
            }
            """),
        errors: [],
        fontSize: 14,
        showLineNumbers: true
    )
    .frame(width: 600, height: 400)
}
