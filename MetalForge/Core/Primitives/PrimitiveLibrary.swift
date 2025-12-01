import Foundation

/// Manages the library of earned shader primitives
@MainActor
final class PrimitiveLibrary {
    static let shared = PrimitiveLibrary()

    /// All available primitives (unlocked via puzzle completion)
    private var primitives: [String: PrimitiveDefinition] = [:]

    /// Built-in primitives that are always available (empty initially)
    private let builtInPrimitives: [String: PrimitiveDefinition] = [:]

    private init() {
        registerAllPrimitives()
    }

    /// Get implementation code for a primitive
    func implementation(for name: String) -> String? {
        primitives[name]?.implementation ?? builtInPrimitives[name]?.implementation
    }

    /// Get all primitives in a category
    func primitives(in category: PrimitiveCategory) -> [PrimitiveDefinition] {
        primitives.values.filter { $0.category == category }
    }

    /// Get primitive definition by name
    func primitive(named name: String) -> PrimitiveDefinition? {
        primitives[name] ?? builtInPrimitives[name]
    }

    /// All registered primitives
    var allPrimitives: [PrimitiveDefinition] {
        Array(primitives.values) + Array(builtInPrimitives.values)
    }

    /// Register all primitives from puzzle unlocks
    private func registerAllPrimitives() {
        // SDF 2D
        register(PrimitiveDefinition(
            name: "sdCircle",
            category: .sdf2d,
            signature: "float sdCircle(float2 p, float r)",
            implementation: """
                float sdCircle(float2 p, float r) {
                    return length(p) - r;
                }
                """,
            documentation: "Returns signed distance from point p to a circle of radius r centered at origin.",
            unlockedBy: PuzzleID(world: 2, index: 1)
        ))

        register(PrimitiveDefinition(
            name: "smoothEdge",
            category: .sdf2d,
            signature: "float smoothEdge(float d, float w)",
            implementation: """
                float smoothEdge(float d, float w) {
                    return 1.0 - smoothstep(-w, w, d);
                }
                """,
            documentation: "Returns a smooth anti-aliased edge from an SDF distance. w controls the edge softness.",
            unlockedBy: PuzzleID(world: 2, index: 2)
        ))

        register(PrimitiveDefinition(
            name: "sdBox",
            category: .sdf2d,
            signature: "float sdBox(float2 p, float2 b)",
            implementation: """
                float sdBox(float2 p, float2 b) {
                    float2 d = abs(p) - b;
                    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
                }
                """,
            documentation: "Returns signed distance from point p to a box with half-extents b.",
            unlockedBy: PuzzleID(world: 2, index: 3)
        ))

        register(PrimitiveDefinition(
            name: "sdRoundedBox",
            category: .sdf2d,
            signature: "float sdRoundedBox(float2 p, float2 b, float r)",
            implementation: """
                float sdRoundedBox(float2 p, float2 b, float r) {
                    float2 d = abs(p) - b + r;
                    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
                }
                """,
            documentation: "Returns signed distance from point p to a rounded box with half-extents b and corner radius r.",
            unlockedBy: PuzzleID(world: 2, index: 4)
        ))

        register(PrimitiveDefinition(
            name: "opUnion",
            category: .sdf2d,
            signature: "float opUnion(float d1, float d2)",
            implementation: """
                float opUnion(float d1, float d2) {
                    return min(d1, d2);
                }
                """,
            documentation: "Combines two SDFs using union (returns the closer surface).",
            unlockedBy: PuzzleID(world: 2, index: 5)
        ))

        register(PrimitiveDefinition(
            name: "opSubtract",
            category: .sdf2d,
            signature: "float opSubtract(float d1, float d2)",
            implementation: """
                float opSubtract(float d1, float d2) {
                    return max(d1, -d2);
                }
                """,
            documentation: "Subtracts d2 from d1 (carves out the second shape from the first).",
            unlockedBy: PuzzleID(world: 2, index: 6)
        ))

        register(PrimitiveDefinition(
            name: "opIntersect",
            category: .sdf2d,
            signature: "float opIntersect(float d1, float d2)",
            implementation: """
                float opIntersect(float d1, float d2) {
                    return max(d1, d2);
                }
                """,
            documentation: "Returns the intersection of two SDFs (only where both shapes overlap).",
            unlockedBy: PuzzleID(world: 2, index: 7)
        ))

        register(PrimitiveDefinition(
            name: "opSmoothUnion",
            category: .sdf2d,
            signature: "float opSmoothUnion(float d1, float d2, float k)",
            implementation: """
                float opSmoothUnion(float d1, float d2, float k) {
                    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
                    return mix(d2, d1, h) - k * h * (1.0 - h);
                }
                """,
            documentation: "Smoothly blends two SDFs together with blend radius k.",
            unlockedBy: PuzzleID(world: 2, index: 7)
        ))

        register(PrimitiveDefinition(
            name: "sdSegment",
            category: .sdf2d,
            signature: "float sdSegment(float2 p, float2 a, float2 b)",
            implementation: """
                float sdSegment(float2 p, float2 a, float2 b) {
                    float2 pa = p - a;
                    float2 ba = b - a;
                    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                    return length(pa - ba * h);
                }
                """,
            documentation: "Returns distance from point p to line segment from a to b.",
            unlockedBy: PuzzleID(world: 2, index: 8)
        ))

        register(PrimitiveDefinition(
            name: "rotate2d",
            category: .sdf2d,
            signature: "float2x2 rotate2d(float angle)",
            implementation: """
                float2x2 rotate2d(float angle) {
                    float c = cos(angle);
                    float s = sin(angle);
                    return float2x2(c, -s, s, c);
                }
                """,
            documentation: "Returns a 2D rotation matrix for the given angle in radians.",
            unlockedBy: PuzzleID(world: 2, index: 9)
        ))

        // Basics
        register(PrimitiveDefinition(
            name: "remap",
            category: .basics,
            signature: "float remap(float value, float inMin, float inMax, float outMin, float outMax)",
            implementation: """
                float remap(float value, float inMin, float inMax, float outMin, float outMax) {
                    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin);
                }
                """,
            documentation: "Remaps a value from one range to another.",
            unlockedBy: PuzzleID(world: 1, index: 10)
        ))

        // Color
        register(PrimitiveDefinition(
            name: "rgb2hsv",
            category: .color,
            signature: "float3 rgb2hsv(float3 c)",
            implementation: """
                float3 rgb2hsv(float3 c) {
                    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                    float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                    float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                    float d = q.x - min(q.w, q.y);
                    float e = 1.0e-10;
                    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
                }
                """,
            documentation: "Converts RGB color to HSV color space.",
            unlockedBy: PuzzleID(world: 3, index: 2)
        ))

        register(PrimitiveDefinition(
            name: "hsv2rgb",
            category: .color,
            signature: "float3 hsv2rgb(float3 c)",
            implementation: """
                float3 hsv2rgb(float3 c) {
                    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
                }
                """,
            documentation: "Converts HSV color to RGB color space.",
            unlockedBy: PuzzleID(world: 3, index: 2)
        ))

        register(PrimitiveDefinition(
            name: "palette",
            category: .color,
            signature: "float3 palette(float t, float3 a, float3 b, float3 c, float3 d)",
            implementation: """
                float3 palette(float t, float3 a, float3 b, float3 c, float3 d) {
                    return a + b * cos(6.28318 * (c * t + d));
                }
                """,
            documentation: "Inigo Quilez's cosine palette function for procedural coloring.",
            unlockedBy: PuzzleID(world: 3, index: 1)
        ))

        register(PrimitiveDefinition(
            name: "colorRamp",
            category: .color,
            signature: "float3 colorRamp(float t, float3 c1, float3 c2, float3 c3)",
            implementation: """
                float3 colorRamp(float t, float3 c1, float3 c2, float3 c3) {
                    return t < 0.5 ? mix(c1, c2, t * 2.0) : mix(c2, c3, (t - 0.5) * 2.0);
                }
                """,
            documentation: "Maps value t (0-1) to a 3-color gradient: c1 → c2 → c3.",
            unlockedBy: PuzzleID(world: 3, index: 4)
        ))

        register(PrimitiveDefinition(
            name: "blendScreen",
            category: .color,
            signature: "float3 blendScreen(float3 a, float3 b)",
            implementation: """
                float3 blendScreen(float3 a, float3 b) {
                    return 1.0 - (1.0 - a) * (1.0 - b);
                }
                """,
            documentation: "Screen blend mode - lightens colors, useful for glows and highlights.",
            unlockedBy: PuzzleID(world: 3, index: 5)
        ))

        // Noise
        register(PrimitiveDefinition(
            name: "hash",
            category: .noise,
            signature: "float hash(float2 p)",
            implementation: """
                float hash(float2 p) {
                    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
                }
                """,
            documentation: "Simple hash function for pseudo-random values from 2D coordinates.",
            unlockedBy: PuzzleID(world: 4, index: 1)
        ))

        register(PrimitiveDefinition(
            name: "valueNoise",
            category: .noise,
            signature: "float valueNoise(float2 p)",
            implementation: """
                float _vnHash(float2 p) {
                    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
                }

                float valueNoise(float2 p) {
                    float2 i = floor(p);
                    float2 f = fract(p);
                    f = f * f * (3.0 - 2.0 * f);
                    float a = _vnHash(i);
                    float b = _vnHash(i + float2(1.0, 0.0));
                    float c = _vnHash(i + float2(0.0, 1.0));
                    float d = _vnHash(i + float2(1.0, 1.0));
                    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
                }
                """,
            documentation: "Value noise with smooth interpolation.",
            unlockedBy: PuzzleID(world: 4, index: 2)
        ))

        register(PrimitiveDefinition(
            name: "voronoi",
            category: .noise,
            signature: "float voronoi(float2 p)",
            implementation: """
                float voronoi(float2 p) {
                    float2 i = floor(p);
                    float2 f = fract(p);
                    float minDist = 1.0;
                    for (int y = -1; y <= 1; y++) {
                        for (int x = -1; x <= 1; x++) {
                            float2 neighbor = float2(float(x), float(y));
                            float2 cellPos = i + neighbor;
                            float2 point = fract(sin(float2(dot(cellPos, float2(127.1, 311.7)), dot(cellPos, float2(269.5, 183.3)))) * 43758.5453);
                            minDist = min(minDist, length(neighbor + point - f));
                        }
                    }
                    return minDist;
                }
                """,
            documentation: "Returns distance to nearest Voronoi cell center.",
            unlockedBy: PuzzleID(world: 4, index: 3)
        ))

        register(PrimitiveDefinition(
            name: "fbm",
            category: .noise,
            signature: "float fbm(float2 p, int octaves)",
            implementation: """
                float _fbmHash(float2 p) {
                    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
                }

                float _fbmNoise(float2 p) {
                    float2 i = floor(p);
                    float2 f = fract(p);
                    f = f * f * (3.0 - 2.0 * f);
                    float a = _fbmHash(i);
                    float b = _fbmHash(i + float2(1.0, 0.0));
                    float c = _fbmHash(i + float2(0.0, 1.0));
                    float d = _fbmHash(i + float2(1.0, 1.0));
                    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
                }

                float fbm(float2 p, int octaves) {
                    float value = 0.0;
                    float amplitude = 0.5;
                    for (int i = 0; i < octaves; i++) {
                        value += amplitude * _fbmNoise(p);
                        p *= 2.0;
                        amplitude *= 0.5;
                    }
                    return value;
                }
                """,
            documentation: "Fractal Brownian Motion - layered noise with decreasing amplitude.",
            unlockedBy: PuzzleID(world: 4, index: 4)
        ))

        register(PrimitiveDefinition(
            name: "checker",
            category: .noise,
            signature: "float checker(float2 p, float scale)",
            implementation: """
                float checker(float2 p, float scale) {
                    float2 q = floor(p * scale);
                    return fract((q.x + q.y) * 0.5) * 2.0;
                }
                """,
            documentation: "Returns 0 or 1 in a checkerboard pattern at the given scale.",
            unlockedBy: PuzzleID(world: 4, index: 5)
        ))

        // Animation
        register(PrimitiveDefinition(
            name: "easeInOut",
            category: .animation,
            signature: "float easeInOut(float t)",
            implementation: """
                float easeInOut(float t) {
                    return t < 0.5 ? 2.0 * t * t : 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0;
                }
                """,
            documentation: "Eases in and out using quadratic curves. Input t should be 0 to 1.",
            unlockedBy: PuzzleID(world: 5, index: 3)
        ))

        register(PrimitiveDefinition(
            name: "orbit2d",
            category: .animation,
            signature: "float2 orbit2d(float angle, float radius)",
            implementation: """
                float2 orbit2d(float angle, float radius) {
                    return float2(cos(angle), sin(angle)) * radius;
                }
                """,
            documentation: "Returns a point on a circle at the given angle and radius.",
            unlockedBy: PuzzleID(world: 5, index: 4)
        ))

        register(PrimitiveDefinition(
            name: "wave",
            category: .animation,
            signature: "float wave(float x, float time, float freq, float speed, float amp)",
            implementation: """
                float wave(float x, float time, float freq, float speed, float amp) {
                    return sin(x * freq + time * speed) * amp;
                }
                """,
            documentation: "Returns a wave value for animated distortion effects.",
            unlockedBy: PuzzleID(world: 5, index: 5)
        ))
    }

    private func register(_ primitive: PrimitiveDefinition) {
        primitives[primitive.name] = primitive
    }
}

/// Definition of a shader primitive
struct PrimitiveDefinition: Identifiable {
    let name: String
    let category: PrimitiveCategory
    let signature: String
    let implementation: String
    let documentation: String
    let unlockedBy: PuzzleID

    var id: String { name }
}
