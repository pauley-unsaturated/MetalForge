import MetalKit
import Observation
import simd

/// Core Metal renderer for shader preview
@Observable
@MainActor
final class MetalRenderer: NSObject {
    // MARK: - Metal Objects
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    private var pipelineState: MTLRenderPipelineState?
    private var vertexBuffer: MTLBuffer?
    private var uniformBuffer: MTLBuffer?

    // MARK: - State
    var isReady = false
    var lastError: ShaderError?

    private(set) var currentTexture: MTLTexture?
    private var startTime: CFTimeInterval = 0
    var isPlaying = true

    // MARK: - Uniforms
    struct Uniforms {
        var time: Float
        var resolution: SIMD2<Float>
        var mouse: SIMD2<Float>
    }

    private var uniforms = Uniforms(
        time: 0,
        resolution: SIMD2<Float>(512, 512),
        mouse: SIMD2<Float>(0.5, 0.5)
    )

    // MARK: - Initialization

    override init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create command queue")
        }

        self.device = device
        self.commandQueue = commandQueue

        super.init()

        setupVertexBuffer()
        setupUniformBuffer()
        startTime = CACurrentMediaTime()
    }

    private func setupVertexBuffer() {
        // Full-screen quad vertices (position + uv)
        let vertices: [Float] = [
            // Position      // UV
            -1.0, -1.0,     0.0, 0.0,
             1.0, -1.0,     1.0, 0.0,
            -1.0,  1.0,     0.0, 1.0,
             1.0,  1.0,     1.0, 1.0,
        ]

        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Float>.stride,
            options: .storageModeShared
        )
    }

    private func setupUniformBuffer() {
        uniformBuffer = device.makeBuffer(
            length: MemoryLayout<Uniforms>.stride,
            options: .storageModeShared
        )
    }

    // MARK: - Shader Compilation

    func compileShader(_ userCode: String, primitives: [String] = []) -> CompilationResult {
        let startCompile = CACurrentMediaTime()

        let fullSource = ShaderTemplate.buildFullShader(
            userCode: userCode,
            primitives: primitives
        )

        let options = MTLCompileOptions()
        options.languageVersion = .version2_4

        do {
            let library = try device.makeLibrary(source: fullSource, options: options)

            guard let vertexFunction = library.makeFunction(name: "vertexShader"),
                  let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
                return CompilationResult(
                    success: false,
                    errors: [ShaderError(line: 0, column: 0, message: "Function not found in shader", isWarning: false)],
                    warnings: [],
                    compilationTime: CACurrentMediaTime() - startCompile
                )
            }

            // Create pipeline
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            // Vertex descriptor
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].format = .float2
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[1].format = .float2
            vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.stride * 2
            vertexDescriptor.attributes[1].bufferIndex = 0
            vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 4
            pipelineDescriptor.vertexDescriptor = vertexDescriptor

            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            isReady = true
            lastError = nil

            return CompilationResult(
                success: true,
                errors: [],
                warnings: [],
                compilationTime: CACurrentMediaTime() - startCompile
            )

        } catch let error as NSError {
            let errors = parseCompilationErrors(error, userCodeOffset: ShaderTemplate.userCodeLineOffset)
            return CompilationResult(
                success: false,
                errors: errors,
                warnings: [],
                compilationTime: CACurrentMediaTime() - startCompile
            )
        }
    }

    private func parseCompilationErrors(_ error: NSError, userCodeOffset: Int) -> [ShaderError] {
        var errors: [ShaderError] = []

        let errorString = error.localizedDescription

        // Parse Metal shader compiler errors
        // Format: "program_source:LINE:COL: error: MESSAGE"
        let pattern = #"program_source:(\d+):(\d+): (error|warning): (.+)"#
        let regex = try? NSRegularExpression(pattern: pattern)

        let range = NSRange(errorString.startIndex..., in: errorString)
        let matches = regex?.matches(in: errorString, range: range) ?? []

        for match in matches {
            guard match.numberOfRanges >= 5 else { continue }

            let lineRange = Range(match.range(at: 1), in: errorString)!
            let colRange = Range(match.range(at: 2), in: errorString)!
            let typeRange = Range(match.range(at: 3), in: errorString)!
            let msgRange = Range(match.range(at: 4), in: errorString)!

            let line = Int(errorString[lineRange]) ?? 0
            let col = Int(errorString[colRange]) ?? 0
            let isWarning = errorString[typeRange] == "warning"
            let message = String(errorString[msgRange])

            // Adjust line number to user code
            let adjustedLine = max(1, line - userCodeOffset)

            errors.append(ShaderError(
                line: adjustedLine,
                column: col,
                message: message,
                isWarning: isWarning
            ))
        }

        // If no structured errors found, add the raw message
        if errors.isEmpty {
            errors.append(ShaderError(
                line: 1,
                column: 1,
                message: errorString,
                isWarning: false
            ))
        }

        return errors
    }

    // MARK: - Rendering

    func render(to texture: MTLTexture) {
        guard let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        // Update uniforms
        if isPlaying {
            uniforms.time = Float(CACurrentMediaTime() - startTime)
        }
        uniforms.resolution = SIMD2<Float>(Float(texture.width), Float(texture.height))

        uniformBuffer?.contents().copyMemory(
            from: &uniforms,
            byteCount: MemoryLayout<Uniforms>.stride
        )

        // Create render pass
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        currentTexture = texture
    }

    /// Render to a drawable and present it (for MTKView usage)
    func render(to drawable: any CAMetalDrawable) {
        guard let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let texture = drawable.texture

        // Update uniforms
        if isPlaying {
            uniforms.time = Float(CACurrentMediaTime() - startTime)
        }
        uniforms.resolution = SIMD2<Float>(Float(texture.width), Float(texture.height))

        uniformBuffer?.contents().copyMemory(
            from: &uniforms,
            byteCount: MemoryLayout<Uniforms>.stride
        )

        // Create render pass
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()

        currentTexture = texture
    }

    func createRenderTexture(width: Int, height: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget, .shaderRead]
        descriptor.storageMode = .private

        return device.makeTexture(descriptor: descriptor)
    }

    func createReadableTexture(width: Int, height: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget, .shaderRead]
        descriptor.storageMode = .managed

        return device.makeTexture(descriptor: descriptor)
    }

    // MARK: - Time Control

    func resetTime() {
        startTime = CACurrentMediaTime()
        uniforms.time = 0
    }

    func setTime(_ time: Float) {
        uniforms.time = time
        startTime = CACurrentMediaTime() - Double(time)
    }

    func updateMouse(_ position: SIMD2<Float>) {
        uniforms.mouse = position
    }
}
