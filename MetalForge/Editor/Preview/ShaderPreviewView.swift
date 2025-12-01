import SwiftUI
import MetalKit

/// Displays live shader output using Metal
struct ShaderPreviewView: View {
    @Binding var renderer: MetalRenderer?
    let size: CGSize

    var body: some View {
        MetalView(renderer: $renderer, size: size)
            .aspectRatio(1.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

/// NSViewRepresentable wrapper for MTKView
struct MetalView: NSViewRepresentable {
    @Binding var renderer: MetalRenderer?
    let size: CGSize

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> MTKView {
        // Create MTKView with explicit frame
        let frame = CGRect(origin: .zero, size: size)
        let mtkView = MTKView(frame: frame)

        // Use the coordinator's device (coordinator owns its own Metal device)
        mtkView.device = context.coordinator.device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.delegate = context.coordinator
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.preferredFramesPerSecond = 60

        // Sync with external renderer if already available
        if let renderer = renderer {
            context.coordinator.renderer = renderer
        }

        return mtkView
    }

    func updateNSView(_ mtkView: MTKView, context: Context) {
        // Sync coordinator's renderer with the binding when it changes
        if let renderer = renderer {
            context.coordinator.renderer = renderer
        }
    }

    class Coordinator: NSObject, MTKViewDelegate {
        // Coordinator owns a Metal device for MTKView setup
        let device: MTLDevice
        var renderer: MetalRenderer?

        override init() {
            self.device = MTLCreateSystemDefaultDevice()!
            super.init()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle resize if needed
        }

        func draw(in view: MTKView) {
            guard let renderer = renderer,
                  let drawable = view.currentDrawable else {
                return
            }

            // MTKViewDelegate is called on the main thread
            MainActor.assumeIsolated {
                renderer.render(to: drawable)
            }
        }
    }
}

/// Split view comparing user output to target
struct SplitCompareView: View {
    @Binding var userRenderer: MetalRenderer?
    @Binding var targetRenderer: MetalRenderer?
    let size: CGSize

    @State private var compareMode: CompareMode = .sideBySide
    @State private var splitPosition: CGFloat = 0.5

    enum CompareMode: String, CaseIterable {
        case sideBySide = "Side by Side"
        case overlay = "Overlay"
        case diff = "Difference"
        case split = "Split"
    }

    var body: some View {
        VStack(spacing: 12) {
            // Mode selector
            Picker("Compare Mode", selection: $compareMode) {
                ForEach(CompareMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)

            // Preview area
            Group {
                switch compareMode {
                case .sideBySide:
                    sideBySideView
                case .overlay:
                    overlayView
                case .diff:
                    diffView
                case .split:
                    splitView
                }
            }
            .frame(height: size.height)
        }
    }

    private var sideBySideView: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("YOUR OUTPUT")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                ShaderPreviewView(renderer: $userRenderer, size: CGSize(width: size.width / 2 - 20, height: size.height - 30))
            }

            VStack(spacing: 8) {
                Text("TARGET")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                ShaderPreviewView(renderer: $targetRenderer, size: CGSize(width: size.width / 2 - 20, height: size.height - 30))
            }
        }
    }

    private var overlayView: some View {
        ZStack {
            ShaderPreviewView(renderer: $targetRenderer, size: size)
                .opacity(0.5)
            ShaderPreviewView(renderer: $userRenderer, size: size)
                .opacity(0.5)
        }
    }

    private var diffView: some View {
        // In a full implementation, this would use a compute shader to show differences
        ZStack {
            ShaderPreviewView(renderer: $userRenderer, size: size)
            Text("Diff mode - requires compute shader")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
        }
    }

    private var splitView: some View {
        GeometryReader { geo in
            ZStack {
                ShaderPreviewView(renderer: $targetRenderer, size: size)

                ShaderPreviewView(renderer: $userRenderer, size: size)
                    .mask(
                        Rectangle()
                            .frame(width: geo.size.width * splitPosition)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )

                // Split line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2)
                    .position(x: geo.size.width * splitPosition, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                splitPosition = max(0.1, min(0.9, value.location.x / geo.size.width))
                            }
                    )
            }
        }
    }
}

#Preview {
    VStack {
        ShaderPreviewView(renderer: .constant(nil), size: CGSize(width: 400, height: 400))
    }
    .frame(width: 500, height: 500)
    .background(Color.black)
}
