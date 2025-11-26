import simd

/// Shader uniforms passed to Metal
struct ShaderUniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var mouse: SIMD2<Float>

    init(time: Float = 0, resolution: SIMD2<Float> = .init(512, 512), mouse: SIMD2<Float> = .init(0.5, 0.5)) {
        self.time = time
        self.resolution = resolution
        self.mouse = mouse
    }

    /// Size in bytes for buffer allocation
    static var size: Int {
        MemoryLayout<ShaderUniforms>.stride
    }
}
