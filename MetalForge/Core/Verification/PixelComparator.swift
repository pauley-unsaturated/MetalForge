import Metal
import MetalKit
import simd

/// Compares shader output against reference images
@MainActor
final class PixelComparator {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var computePipeline: MTLComputePipelineState?

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        setupComputePipeline()
    }

    private func setupComputePipeline() {
        let source = """
        #include <metal_stdlib>
        using namespace metal;

        struct CompareResult {
            atomic_uint mismatchCount;
            atomic_uint totalDifference;
        };

        kernel void compareTextures(
            texture2d<float, access::read> texture1 [[texture(0)]],
            texture2d<float, access::read> texture2 [[texture(1)]],
            device CompareResult& result [[buffer(0)]],
            constant float& tolerance [[buffer(1)]],
            uint2 gid [[thread_position_in_grid]]
        ) {
            if (gid.x >= texture1.get_width() || gid.y >= texture1.get_height()) {
                return;
            }

            float4 color1 = texture1.read(gid);
            float4 color2 = texture2.read(gid);

            float diff = length(color1.rgb - color2.rgb);

            if (diff > tolerance) {
                atomic_fetch_add_explicit(&result.mismatchCount, 1, memory_order_relaxed);
            }

            uint diffInt = uint(diff * 1000.0);
            atomic_fetch_add_explicit(&result.totalDifference, diffInt, memory_order_relaxed);
        }
        """

        do {
            let library = try device.makeLibrary(source: source, options: nil)
            guard let function = library.makeFunction(name: "compareTextures") else {
                print("Failed to create compare function")
                return
            }
            computePipeline = try device.makeComputePipelineState(function: function)
        } catch {
            print("Failed to create compute pipeline: \(error)")
        }
    }

    /// Compare two textures and return verification result
    func compare(
        userTexture: MTLTexture,
        referenceTexture: MTLTexture,
        tolerance: Float = 0.01
    ) -> VerificationResult {
        guard let pipeline = computePipeline,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            return .failed
        }

        // Ensure textures are same size
        guard userTexture.width == referenceTexture.width,
              userTexture.height == referenceTexture.height else {
            return VerificationResult(
                passed: false,
                similarity: 0,
                mismatchCount: userTexture.width * userTexture.height,
                totalPixels: userTexture.width * userTexture.height,
                maxDifference: 1.0
            )
        }

        // Result buffer
        struct CompareResult {
            var mismatchCount: UInt32
            var totalDifference: UInt32
        }

        var resultData = CompareResult(mismatchCount: 0, totalDifference: 0)
        guard let resultBuffer = device.makeBuffer(
            bytes: &resultData,
            length: MemoryLayout<CompareResult>.stride,
            options: .storageModeShared
        ) else {
            return .failed
        }

        var toleranceValue = tolerance
        guard let toleranceBuffer = device.makeBuffer(
            bytes: &toleranceValue,
            length: MemoryLayout<Float>.stride,
            options: .storageModeShared
        ) else {
            return .failed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(userTexture, index: 0)
        encoder.setTexture(referenceTexture, index: 1)
        encoder.setBuffer(resultBuffer, offset: 0, index: 0)
        encoder.setBuffer(toleranceBuffer, offset: 0, index: 1)

        let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadgroups = MTLSize(
            width: (userTexture.width + 15) / 16,
            height: (userTexture.height + 15) / 16,
            depth: 1
        )

        encoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Read results
        let resultPtr = resultBuffer.contents().bindMemory(to: CompareResult.self, capacity: 1)
        let mismatchCount = Int(resultPtr.pointee.mismatchCount)
        let totalDifference = Float(resultPtr.pointee.totalDifference) / 1000.0

        let totalPixels = userTexture.width * userTexture.height
        let matchingPixels = totalPixels - mismatchCount
        let similarity = Float(matchingPixels) / Float(totalPixels)
        let avgDifference = totalDifference / Float(totalPixels)

        // Determine pass/fail based on similarity threshold
        let passed = similarity >= 0.99

        return VerificationResult(
            passed: passed,
            similarity: similarity,
            mismatchCount: mismatchCount,
            totalPixels: totalPixels,
            maxDifference: avgDifference
        )
    }

    /// Generate reference texture from shader solution
    func generateReference(
        solution: String,
        size: Int = 512,
        renderer: MetalRenderer
    ) -> MTLTexture? {
        let referenceCode = """
            float4 userFragment(float2 uv, constant Uniforms& u) {
                \(solution)
            }
            """

        let result = renderer.compileShader(referenceCode)
        guard result.success else {
            print("Failed to compile reference shader: \(result.errors)")
            return nil
        }

        guard let texture = renderer.createReadableTexture(width: size, height: size) else {
            return nil
        }

        renderer.render(to: texture)
        return texture
    }
}

/// Verifies animated shaders across multiple frames
@MainActor
final class AnimationVerifier {
    private let comparator: PixelComparator
    private let renderer: MetalRenderer

    init(device: MTLDevice, renderer: MetalRenderer) {
        self.comparator = PixelComparator(device: device)
        self.renderer = renderer
    }

    /// Verify an animated shader across multiple frames
    func verify(
        userCode: String,
        referenceSolution: String,
        frameCount: Int = 30,
        duration: Float = 1.0,
        threshold: Float = 0.95
    ) -> VerificationResult {
        // Compile user shader
        let userResult = renderer.compileShader(userCode)
        guard userResult.success else {
            return .failed
        }

        var totalSimilarity: Float = 0
        var totalMismatch = 0
        var totalPixels = 0

        let frameTime = duration / Float(frameCount)

        for frame in 0..<frameCount {
            let time = Float(frame) * frameTime

            // Render user frame
            renderer.setTime(time)
            guard let userTexture = renderer.createReadableTexture(width: 512, height: 512) else {
                continue
            }
            renderer.render(to: userTexture)

            // Generate reference frame
            guard let refTexture = comparator.generateReference(
                solution: referenceSolution,
                renderer: renderer
            ) else {
                continue
            }

            // Compare
            let result = comparator.compare(userTexture: userTexture, referenceTexture: refTexture)
            totalSimilarity += result.similarity
            totalMismatch += result.mismatchCount
            totalPixels += result.totalPixels
        }

        let avgSimilarity = totalSimilarity / Float(frameCount)
        let passed = avgSimilarity >= threshold

        return VerificationResult(
            passed: passed,
            similarity: avgSimilarity,
            mismatchCount: totalMismatch / frameCount,
            totalPixels: totalPixels / frameCount,
            maxDifference: 1.0 - avgSimilarity
        )
    }
}
