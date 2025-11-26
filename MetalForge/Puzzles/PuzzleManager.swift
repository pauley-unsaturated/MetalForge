import Foundation

/// Manages puzzle definitions and progress
@MainActor
final class PuzzleManager {
    static let shared = PuzzleManager()

    private var worlds: [World] = []
    private var puzzleCache: [PuzzleID: Puzzle] = [:]

    private init() {
        loadPuzzles()
    }

    var allWorlds: [World] {
        worlds
    }

    func puzzle(for id: PuzzleID) -> Puzzle? {
        puzzleCache[id]
    }

    func puzzles(forWorld worldNumber: Int) -> [Puzzle] {
        worlds.first { $0.number == worldNumber }?.puzzles ?? []
    }

    func nextPuzzle(after id: PuzzleID) -> Puzzle? {
        let worldPuzzles = puzzles(forWorld: id.world)

        // Try next puzzle in same world
        if let currentIndex = worldPuzzles.firstIndex(where: { $0.id == id }),
           currentIndex + 1 < worldPuzzles.count {
            return worldPuzzles[currentIndex + 1]
        }

        // Try first puzzle of next world
        let nextWorldPuzzles = puzzles(forWorld: id.world + 1)
        return nextWorldPuzzles.first
    }

    private func loadPuzzles() {
        worlds = [
            createWorld1(),
            createWorld2(),
        ]

        // Build cache
        for world in worlds {
            for puzzle in world.puzzles {
                puzzleCache[puzzle.id] = puzzle
            }
        }
    }

    // MARK: - World 1: First Light

    private func createWorld1() -> World {
        World(
            number: 1,
            title: "First Light",
            description: "Metal Fundamentals - colors, coordinates, and your first shaders",
            puzzles: [
                puzzle1_1(),
                puzzle1_2(),
                puzzle1_3(),
                puzzle1_4(),
                puzzle1_5(),
            ]
        )
    }

    private func puzzle1_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 1, index: 1),
            title: "Blank Canvas",
            subtitle: "Return a solid color",
            description: """
                Welcome to MetalForge! Your first task is simple: fill the entire canvas with a solid cornflower blue color.

                In Metal shaders, colors are represented as `float4` values with components (red, green, blue, alpha).
                Each component ranges from 0.0 (none) to 1.0 (full intensity).

                Cornflower blue is approximately: red=0.4, green=0.6, blue=0.9
                """,
            reference: .animation(
                shader: "return float4(0.4, 0.6, 0.9, 1.0);",
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: [],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "A float4 has four components: (r, g, b, a)"),
                Hint(cost: 0, text: "Alpha should be 1.0 for fully opaque"),
                Hint(cost: 1, text: "return float4(0.4, 0.6, 0.9, 1.0);"),
            ],
            starterCode: """
                // Fill the canvas with cornflower blue
                // Hint: return a float4 with (red, green, blue, alpha)
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
                """,
            solution: "return float4(0.4, 0.6, 0.9, 1.0);"
        )
    }

    private func puzzle1_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 1, index: 2),
            title: "Red Alert",
            subtitle: "Understanding float4 colors",
            description: """
                Now let's explore color components. Create a pure red color.

                Remember:
                - Red channel is the first component
                - Full intensity is 1.0
                - Other color channels should be 0.0
                """,
            reference: .animation(
                shader: "return float4(1.0, 0.0, 0.0, 1.0);",
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: [],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "Pure red means only the red channel has value"),
                Hint(cost: 1, text: "return float4(1.0, 0.0, 0.0, 1.0);"),
            ],
            starterCode: """
                // Create a pure red color
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
                """,
            solution: "return float4(1.0, 0.0, 0.0, 1.0);"
        )
    }

    private func puzzle1_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 1, index: 3),
            title: "RGB Mix",
            subtitle: "Mixing color components",
            description: """
                Colors get interesting when you mix components! Create a purple color by combining red and blue.

                Purple = Red + Blue (no green)

                Try: red=0.8, green=0.0, blue=0.8
                """,
            reference: .animation(
                shader: "return float4(0.8, 0.0, 0.8, 1.0);",
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: [],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "Purple is made by mixing red and blue"),
                Hint(cost: 0, text: "Keep green at 0.0"),
                Hint(cost: 1, text: "return float4(0.8, 0.0, 0.8, 1.0);"),
            ],
            starterCode: """
                // Mix red and blue to create purple
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
                """,
            solution: "return float4(0.8, 0.0, 0.8, 1.0);"
        )
    }

    private func puzzle1_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 1, index: 4),
            title: "Where Am I?",
            subtitle: "UV coordinates introduction",
            description: """
                Now for the magic! The `uv` parameter tells you WHERE on the canvas each pixel is.

                - uv.x goes from 0.0 (left) to 1.0 (right)
                - uv.y goes from 0.0 (bottom) to 1.0 (top)

                Create a gradient that shows the UV coordinates as colors:
                - Red channel = uv.x
                - Green channel = uv.y
                - Blue channel = 0.0
                """,
            reference: .animation(
                shader: "return float4(uv.x, uv.y, 0.0, 1.0);",
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: [],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "uv.x and uv.y are already available to you"),
                Hint(cost: 0, text: "Map position directly to color"),
                Hint(cost: 1, text: "return float4(uv.x, uv.y, 0.0, 1.0);"),
            ],
            starterCode: """
                // Visualize UV coordinates as colors
                // Red = horizontal position, Green = vertical position
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
                """,
            solution: "return float4(uv.x, uv.y, 0.0, 1.0);"
        )
    }

    private func puzzle1_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 1, index: 5),
            title: "Gradient Day",
            subtitle: "Horizontal gradient",
            description: """
                Create a smooth horizontal gradient from black (left) to white (right).

                This means:
                - At uv.x = 0.0, output black (0, 0, 0)
                - At uv.x = 1.0, output white (1, 1, 1)
                - In between, smoothly interpolate

                Tip: Use the same value for R, G, and B to get grayscale.
                """,
            reference: .animation(
                shader: "return float4(uv.x, uv.x, uv.x, 1.0);",
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: [],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "Grayscale means R = G = B"),
                Hint(cost: 0, text: "The horizontal position (uv.x) should control brightness"),
                Hint(cost: 1, text: "return float4(uv.x, uv.x, uv.x, 1.0);"),
            ],
            starterCode: """
                // Create a horizontal gradient from black to white
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
                """,
            solution: "return float4(uv.x, uv.x, uv.x, 1.0);"
        )
    }

    // MARK: - World 2: Shape Language

    private func createWorld2() -> World {
        World(
            number: 2,
            title: "Shape Language",
            description: "2D SDF Foundations - circles, boxes, and boolean operations",
            puzzles: [
                puzzle2_1(),
            ]
        )
    }

    private func puzzle2_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 1),
            title: "Perfect Circle",
            subtitle: "Your first signed distance function",
            description: """
                Welcome to the world of Signed Distance Functions (SDFs)!

                An SDF tells you how far any point is from a shape:
                - Negative = inside the shape
                - Zero = on the edge
                - Positive = outside the shape

                For a circle centered at the origin:
                    distance = length(point) - radius

                Create a white circle (radius 0.3) centered on screen.
                Use `step()` to create a hard edge.
                """,
            reference: .animation(
                shader: """
                    float d = length(uv - 0.5) - 0.3;
                    float c = 1.0 - step(0.0, d);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: [],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "sdCircle",
                signature: "float sdCircle(float2 p, float r)",
                implementation: "return length(p) - r;",
                documentation: "Returns the signed distance from point p to a circle of radius r centered at origin."
            ),
            hints: [
                Hint(cost: 0, text: "Center is at (0.5, 0.5), so subtract that from uv"),
                Hint(cost: 0, text: "length() gives you the distance from origin"),
                Hint(cost: 1, text: "float d = length(uv - 0.5) - 0.3;"),
                Hint(cost: 2, text: "Use step(0.0, d) to get 0 inside, 1 outside"),
            ],
            starterCode: """
                // Draw a white circle centered on screen
                // Radius should be 0.3
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Calculate distance to circle
                    // Hint: center the coordinates first

                    return float4(0.0, 0.0, 0.0, 1.0);
                }
                """,
            solution: """
                float d = length(uv - 0.5) - 0.3;
                float c = 1.0 - step(0.0, d);
                return float4(c, c, c, 1.0);
                """
        )
    }
}
