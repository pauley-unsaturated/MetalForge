import Foundation

/// Builds complete Metal shader source from user code and primitives
enum ShaderTemplate {
    /// Line offset where user code begins in the full shader
    static let userCodeLineOffset = 35

    /// Builds a complete shader source from user code and available primitives
    static func buildFullShader(userCode: String, primitives: [String] = []) -> String {
        var source = """
        // ================================================
        // MetalForge - Generated Shader
        // ================================================
        #include <metal_stdlib>
        using namespace metal;

        // ================================================
        // Vertex Structures
        // ================================================
        struct VertexIn {
            float2 position [[attribute(0)]];
            float2 uv [[attribute(1)]];
        };

        struct VertexOut {
            float4 position [[position]];
            float2 uv;
        };

        // ================================================
        // Uniforms
        // ================================================
        struct Uniforms {
            float time;
            float2 resolution;
            float2 mouse;
        };

        // ================================================
        // Earned Primitives
        // ================================================

        """

        // Insert earned primitives
        for primitive in primitives {
            if let code = PrimitiveLibrary.shared.implementation(for: primitive) {
                source += "// \(primitive)\n"
                source += code + "\n\n"
            }
        }

        source += """
        // ================================================
        // User Code
        // ================================================

        """

        // Insert user code
        source += userCode

        source += """


        // ================================================
        // System Shaders (Do Not Modify)
        // ================================================
        vertex VertexOut vertexShader(VertexIn in [[stage_in]]) {
            VertexOut out;
            out.position = float4(in.position, 0.0, 1.0);
            out.uv = in.uv;
            return out;
        }

        fragment float4 fragmentShader(VertexOut in [[stage_in]],
                                       constant Uniforms& u [[buffer(0)]]) {
            return userFragment(in.uv, u);
        }
        """

        return source
    }

    /// Default starter code for new shaders
    static let defaultUserCode = """
        // Your shader code here
        float4 userFragment(float2 uv, constant Uniforms& u) {
            return float4(uv.x, uv.y, 0.0, 1.0);
        }
        """

    /// Generates reference shader for a puzzle
    static func buildReferenceShader(solution: String) -> String {
        let userCode = """
            float4 userFragment(float2 uv, constant Uniforms& u) {
                \(solution)
            }
            """
        return buildFullShader(userCode: userCode)
    }
}
