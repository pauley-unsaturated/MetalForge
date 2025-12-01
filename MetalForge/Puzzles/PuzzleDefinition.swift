import Foundation

/// Unique identifier for a puzzle
struct PuzzleID: Hashable, Codable, CustomStringConvertible {
    let world: Int
    let index: Int

    var description: String {
        "\(world).\(index)"
    }

    var stringID: String {
        "\(world)_\(index)"
    }
}

/// A world containing multiple puzzles
struct World: Identifiable {
    let number: Int
    let title: String
    let description: String
    let puzzles: [Puzzle]

    var id: Int { number }
}

/// Definition of a single puzzle
struct Puzzle: Identifiable {
    let id: PuzzleID
    let title: String
    let subtitle: String
    let description: String

    /// The reference output to match
    let reference: PuzzleReference

    /// Verification settings
    let verification: VerificationSettings

    /// Primitives available to use (from previous unlocks)
    let availablePrimitives: [String]

    /// Primitive unlocked upon completion
    let unlocksPrimitive: PrimitiveUnlock?

    /// Hints with associated costs
    let hints: [Hint]

    /// Starting code template
    let starterCode: String

    /// Reference solution (for verification generation)
    let solution: String

    static let defaultStarterCode = """
        // Your shader code here
        float4 userFragment(float2 uv, constant Uniforms& u) {
            return float4(uv.x, uv.y, 0.0, 1.0);
        }
        """
}

/// Reference output type
enum PuzzleReference {
    case staticImage(String)  // Resource name
    case animation(shader: String, duration: Float)  // Shader code to generate reference
    case compute(shader: String)  // For compute shader puzzles
}

/// Settings for puzzle verification
struct VerificationSettings {
    enum Mode {
        case pixelPerfect
        case threshold(Float)  // 0.0 - 1.0 similarity required
        case animation(frameCount: Int, threshold: Float)
    }

    let mode: Mode
    let tolerance: Float  // Per-pixel color tolerance

    static let pixelPerfect = VerificationSettings(mode: .pixelPerfect, tolerance: 0.001)
    static let standard = VerificationSettings(mode: .threshold(0.99), tolerance: 0.01)
}

/// Primitive that gets unlocked
struct PrimitiveUnlock {
    let category: PrimitiveCategory
    let functionName: String
    let signature: String
    let implementation: String
    let documentation: String
}

/// Categories of primitives
enum PrimitiveCategory: String, CaseIterable {
    case basics
    case sdf2d
    case color
    case noise
    case animation
    case sdf3d
    case raymarching
    case lighting
    case advanced

    var displayName: String {
        switch self {
        case .basics: return "Basics"
        case .sdf2d: return "SDF 2D"
        case .color: return "Color"
        case .noise: return "Noise"
        case .animation: return "Animation"
        case .sdf3d: return "SDF 3D"
        case .raymarching: return "Raymarching"
        case .lighting: return "Lighting"
        case .advanced: return "Advanced"
        }
    }

    var fileName: String {
        rawValue + ".metal"
    }
}

/// A hint for solving a puzzle
struct Hint: Identifiable {
    let id = UUID()
    let cost: Int  // 0 = free, 1+ = costs hint points
    let text: String
}

/// Result of verifying user output against reference
struct VerificationResult {
    let passed: Bool
    let similarity: Float  // 0.0 - 1.0
    let mismatchCount: Int
    let totalPixels: Int
    let maxDifference: Float

    var percentage: Float {
        similarity * 100
    }

    static let failed = VerificationResult(
        passed: false,
        similarity: 0,
        mismatchCount: 0,
        totalPixels: 0,
        maxDifference: 1
    )
}
