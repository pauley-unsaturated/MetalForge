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
            createWorld3(),
            createWorld4(),
            createWorld5(),
            createWorld6(),
            createWorld7(),
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
                puzzle2_2(),
                puzzle2_3(),
                puzzle2_4(),
                puzzle2_5(),
                puzzle2_6(),
                puzzle2_7(),
                puzzle2_8(),
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

    private func puzzle2_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 2),
            title: "Soft Edges",
            subtitle: "Anti-aliasing with smoothstep",
            description: """
                That hard edge looks a bit jagged! Let's fix it with anti-aliasing.

                The [`smoothstep(edge0, edge1, x)`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80) function returns:
                - 0.0 when x < edge0
                - 1.0 when x > edge1
                - A smooth transition in between

                Replace `step()` with `smoothstep()` to create a soft edge on your circle. Use a small range like 0.01 for subtle anti-aliasing.
                """,
            reference: .animation(
                shader: """
                    float d = length(uv - 0.5) - 0.3;
                    float c = 1.0 - smoothstep(-0.01, 0.01, d);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "smoothEdge",
                signature: "float smoothEdge(float d, float w)",
                implementation: "return 1.0 - smoothstep(-w, w, d);",
                documentation: "Returns a smooth anti-aliased edge from an SDF distance. w controls edge softness."
            ),
            hints: [
                Hint(cost: 0, text: "smoothstep creates a gradual transition instead of a hard cutoff"),
                Hint(cost: 0, text: "For anti-aliasing, use a small transition range centered on 0 (the edge)"),
                Hint(cost: 1, text: "Try: smoothstep(-0.01, 0.01, d) - this creates a 0.02 pixel soft edge"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float d = length(uv - 0.5) - 0.3;
                    float c = 1.0 - smoothstep(0.0, 0.02, d);  // ERROR: Should be centered on 0: smoothstep(-0.01, 0.01, d)
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float c = 1.0 - smoothstep(-0.01, 0.01, d);"),
            ],
            starterCode: """
                // Add anti-aliasing to the circle edge
                // Replace step() with smoothstep() for a soft edge
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float d = length(uv - 0.5) - 0.3;
                    float c = 1.0 - step(0.0, d);  // Hard edge - make it soft!
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float d = length(uv - 0.5) - 0.3;
                float c = 1.0 - smoothstep(-0.01, 0.01, d);
                return float4(c, c, c, 1.0);
                """
        )
    }

    private func puzzle2_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 3),
            title: "Box It Up",
            subtitle: "Your first rectangle SDF",
            description: """
                Circles are great, but rectangles are everywhere in UI! Let's learn the box SDF.

                For a box centered at origin with half-extents b:
                1. Use [`abs(p)`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) to fold space into one quadrant
                2. Subtract the box size to get the distance to edges
                3. Use [`max()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80) to handle corners correctly

                Create a white rectangle (0.3 × 0.2) centered on screen.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float2 d = abs(p) - float2(0.3, 0.2);
                    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "sdBox",
                signature: "float sdBox(float2 p, float2 b)",
                implementation: """
                    float2 d = abs(p) - b;
                    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
                    """,
                documentation: "Returns signed distance from point p to a box with half-extents b."
            ),
            hints: [
                Hint(cost: 0, text: "abs(p) folds the coordinate space so you only need to handle one corner"),
                Hint(cost: 0, text: "The distance is made of two parts: outside corners use length(), inside uses max()"),
                Hint(cost: 1, text: "float2 d = abs(p) - b; gives you distance to each edge"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float2 d = abs(p) - float2(0.3, 0.2);
                    float dist = length(d);  // ERROR: Should be length(max(d, 0.0)) + min(max(d.x, d.y), 0.0)
                    float c = 1.0 - step(0.0, dist);  // ERROR: Use smoothstep for anti-aliasing
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);"),
            ],
            starterCode: """
                // Draw a white rectangle (0.3 × 0.2) centered on screen
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;  // Center coordinates
                    float2 b = float2(0.3, 0.2);  // Box half-extents

                    // Calculate distance to box edge
                    // Hint: Use abs(p) - b, then combine with length() and max()
                    float dist = 0.0;  // TODO: Calculate box SDF

                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float2 d = abs(p) - float2(0.3, 0.2);
                float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
                float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                return float4(c, c, c, 1.0);
                """
        )
    }

    private func puzzle2_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 4),
            title: "Rounded Corners",
            subtitle: "Adding corner radius to boxes",
            description: """
                Sharp corners are so last decade! Let's add rounded corners to our rectangle.

                The trick is simple: shrink the box by the corner radius, then expand the result by that same radius. This effectively rounds the corners!

                Create a rounded rectangle with corner radius 0.05.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float r = 0.05;
                    float2 d = abs(p) - float2(0.3, 0.2) + r;
                    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "sdRoundedBox",
                signature: "float sdRoundedBox(float2 p, float2 b, float r)",
                implementation: """
                    float2 d = abs(p) - b + r;
                    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
                    """,
                documentation: "Returns signed distance from point p to a rounded box with half-extents b and corner radius r."
            ),
            hints: [
                Hint(cost: 0, text: "Start with the box SDF from the previous puzzle"),
                Hint(cost: 0, text: "Add r to the box half-extents calculation, then subtract r from the final distance"),
                Hint(cost: 1, text: "Change: abs(p) - b becomes abs(p) - b + r, and subtract r at the end"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float r = 0.05;
                    float2 d = abs(p) - float2(0.3, 0.2);  // ERROR: Should be abs(p) - float2(0.3, 0.2) + r
                    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);  // ERROR: Subtract r at end
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float2 d = abs(p) - float2(0.3, 0.2) + r; ... - r;"),
            ],
            starterCode: """
                // Add rounded corners (radius 0.05) to the rectangle
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;
                    float r = 0.05;  // Corner radius

                    // Modify the box SDF to include rounding
                    float2 d = abs(p) - float2(0.3, 0.2);
                    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);

                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float r = 0.05;
                float2 d = abs(p) - float2(0.3, 0.2) + r;
                float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
                float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                return float4(c, c, c, 1.0);
                """
        )
    }

    private func puzzle2_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 5),
            title: "Two Become One",
            subtitle: "Union operation",
            description: """
                Now for the magic of SDFs: combining shapes!

                The **union** of two shapes shows wherever *either* shape exists. Since SDFs return negative values inside shapes, we want the minimum of both distances.

                Use [`min(d1, d2)`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80) to combine a circle and a box into one shape.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float circle = length(p - float2(-0.15, 0.0)) - 0.15;
                    float box = length(max(abs(p - float2(0.15, 0.0)) - float2(0.12, 0.12), 0.0));
                    float dist = min(circle, box);
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "opUnion",
                signature: "float opUnion(float d1, float d2)",
                implementation: "return min(d1, d2);",
                documentation: "Combines two SDFs using union (returns the closer surface)."
            ),
            hints: [
                Hint(cost: 0, text: "Union means 'show both shapes' - use min() to find the closest surface"),
                Hint(cost: 0, text: "Calculate each shape's SDF separately, then combine with min()"),
                Hint(cost: 1, text: "float dist = min(circle, box);"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float2 p = uv - 0.5;
                    float circle = length(p - float2(-0.15, 0.0)) - 0.15;
                    float box = length(max(abs(p - float2(0.15, 0.0)) - float2(0.12, 0.12), 0.0));
                    float dist = circle + box;  // ERROR: Should use min(circle, box) for union
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float dist = min(circle, box);"),
            ],
            starterCode: """
                // Combine a circle and box using union (min)
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;

                    // Circle on the left
                    float circle = length(p - float2(-0.15, 0.0)) - 0.15;

                    // Box on the right (simplified SDF)
                    float box = length(max(abs(p - float2(0.15, 0.0)) - float2(0.12, 0.12), 0.0));

                    // TODO: Combine with union (min)
                    float dist = circle;

                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float circle = length(p - float2(-0.15, 0.0)) - 0.15;
                float box = length(max(abs(p - float2(0.15, 0.0)) - float2(0.12, 0.12), 0.0));
                float dist = min(circle, box);
                float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                return float4(c, c, c, 1.0);
                """
        )
    }

    private func puzzle2_6() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 6),
            title: "Cut It Out",
            subtitle: "Subtraction operation",
            description: """
                Sometimes you want to carve one shape out of another. This is **subtraction**.

                The trick: we want to be inside shape A but *outside* shape B. Flip the sign of B's SDF and use [`max()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80):

                `max(d1, -d2)` subtracts shape 2 from shape 1.

                Cut a circular hole out of a box!
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float box = length(max(abs(p) - float2(0.25, 0.25), 0.0)) + min(max(abs(p).x - 0.25, abs(p).y - 0.25), 0.0);
                    float circle = length(p) - 0.15;
                    float dist = max(box, -circle);
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "opSubtract",
                signature: "float opSubtract(float d1, float d2)",
                implementation: "return max(d1, -d2);",
                documentation: "Subtracts d2 from d1 (carves out the second shape from the first)."
            ),
            hints: [
                Hint(cost: 0, text: "Negating an SDF flips inside/outside - now 'inside' becomes positive"),
                Hint(cost: 0, text: "max(d1, -d2) keeps only where you're inside d1 AND outside d2"),
                Hint(cost: 1, text: "The subtraction formula is: max(box, -circle)"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float2 p = uv - 0.5;
                    float2 d = abs(p) - float2(0.25, 0.25);
                    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
                    float circle = length(p) - 0.15;
                    float dist = max(box, circle);  // ERROR: Should be max(box, -circle) to subtract
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float dist = max(box, -circle);"),
            ],
            starterCode: """
                // Cut a circular hole out of a box
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;

                    // Box SDF
                    float2 d = abs(p) - float2(0.25, 0.25);
                    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);

                    // Circle SDF (the hole)
                    float circle = length(p) - 0.15;

                    // TODO: Subtract circle from box
                    float dist = box;

                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float2 d = abs(p) - float2(0.25, 0.25);
                float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
                float circle = length(p) - 0.15;
                float dist = max(box, -circle);
                float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                return float4(c, c, c, 1.0);
                """
        )
    }

    private func puzzle2_7() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 7),
            title: "Smooth Blend",
            subtitle: "Organic shape blending",
            description: """
                Union with `min()` creates hard intersections. What if we want shapes to *blend* together smoothly, like liquid metal?

                The **smooth union** uses interpolation to create organic-looking blends:

                ```
                float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
                return mix(d2, d1, h) - k*h*(1.0-h);
                ```

                Blend two circles together with k=0.1 for a smooth, organic shape.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float c1 = length(p - float2(-0.1, 0.0)) - 0.15;
                    float c2 = length(p - float2(0.1, 0.0)) - 0.15;
                    float k = 0.1;
                    float h = clamp(0.5 + 0.5*(c2-c1)/k, 0.0, 1.0);
                    float dist = mix(c2, c1, h) - k*h*(1.0-h);
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "opSmoothUnion",
                signature: "float opSmoothUnion(float d1, float d2, float k)",
                implementation: """
                    float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
                    return mix(d2, d1, h) - k*h*(1.0-h);
                    """,
                documentation: "Smoothly blends two SDFs together with blend radius k."
            ),
            hints: [
                Hint(cost: 0, text: "The parameter k controls blend smoothness - larger k = softer blend"),
                Hint(cost: 0, text: "h is a blend factor: 0 near d1, 1 near d2, smooth transition between"),
                Hint(cost: 1, text: "Use clamp() and mix() - both take the same 0-1 range for h"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float c1 = length(p - float2(-0.1, 0.0)) - 0.15;
                    float c2 = length(p - float2(0.1, 0.0)) - 0.15;
                    float k = 0.1;
                    float h = clamp(0.5 + 0.5*(c2-c1)/k, 0.0, 1.0);
                    float dist = mix(c2, c1, h);  // ERROR: Missing the blend subtraction: - k*h*(1.0-h)
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float dist = mix(c2, c1, h) - k*h*(1.0-h);"),
            ],
            starterCode: """
                // Blend two circles with smooth union
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;

                    // Two overlapping circles
                    float c1 = length(p - float2(-0.1, 0.0)) - 0.15;
                    float c2 = length(p - float2(0.1, 0.0)) - 0.15;

                    float k = 0.1;  // Blend smoothness

                    // TODO: Implement smooth union
                    // Hint: Calculate h with clamp, then use mix and subtract the blend term
                    float dist = min(c1, c2);  // Hard union - make it smooth!

                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float c1 = length(p - float2(-0.1, 0.0)) - 0.15;
                float c2 = length(p - float2(0.1, 0.0)) - 0.15;
                float k = 0.1;
                float h = clamp(0.5 + 0.5*(c2-c1)/k, 0.0, 1.0);
                float dist = mix(c2, c1, h) - k*h*(1.0-h);
                float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                return float4(c, c, c, 1.0);
                """
        )
    }

    private func puzzle2_8() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 2, index: 8),
            title: "Line Segment",
            subtitle: "Distance to a line",
            description: """
                Not everything is circles and boxes! Line segments are essential for drawing paths, arrows, and more.

                The line segment SDF finds the closest point on the line, then measures distance to it:
                1. Project point p onto the line direction
                2. Use [`clamp()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80) to stay within segment bounds
                3. Measure distance to that closest point

                Draw a white line from (-0.2, -0.1) to (0.2, 0.1).
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float2 a = float2(-0.2, -0.1);
                    float2 b = float2(0.2, 0.1);
                    float2 pa = p - a;
                    float2 ba = b - a;
                    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                    float dist = length(pa - ba * h) - 0.02;
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf2d,
                functionName: "sdSegment",
                signature: "float sdSegment(float2 p, float2 a, float2 b)",
                implementation: """
                    float2 pa = p - a;
                    float2 ba = b - a;
                    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                    return length(pa - ba * h);
                    """,
                documentation: "Returns distance from point p to line segment from a to b."
            ),
            hints: [
                Hint(cost: 0, text: "Project the point onto the line using dot product: dot(pa, ba) / dot(ba, ba)"),
                Hint(cost: 0, text: "clamp the projection to 0-1 to stay within the segment (not infinite line)"),
                Hint(cost: 1, text: "The closest point on segment is: a + ba * h, where h is the clamped projection"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float2 a = float2(-0.2, -0.1);
                    float2 b = float2(0.2, 0.1);
                    float2 pa = p - a;
                    float2 ba = b - a;
                    float h = dot(pa, ba) / dot(ba, ba);  // ERROR: Needs clamp(h, 0.0, 1.0)
                    float dist = length(pa - ba * h);  // ERROR: Subtract thickness (- 0.02) for visible line
                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                    """),
                Hint(cost: 3, text: "float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);"),
            ],
            starterCode: """
                // Draw a line segment from (-0.2, -0.1) to (0.2, 0.1)
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;
                    float2 a = float2(-0.2, -0.1);  // Start point
                    float2 b = float2(0.2, 0.1);    // End point

                    // TODO: Calculate line segment SDF
                    // Hint: Project p onto the line, clamp to segment, measure distance
                    float dist = length(p);  // Wrong! Calculate proper segment distance

                    // Subtract thickness to make the line visible
                    dist = dist - 0.02;

                    float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                    return float4(c, c, c, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float2 a = float2(-0.2, -0.1);
                float2 b = float2(0.2, 0.1);
                float2 pa = p - a;
                float2 ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                float dist = length(pa - ba * h) - 0.02;
                float c = 1.0 - smoothstep(-0.01, 0.01, dist);
                return float4(c, c, c, 1.0);
                """
        )
    }

    // MARK: - World 3: Color Theory

    private func createWorld3() -> World {
        World(
            number: 3,
            title: "Color Theory",
            description: "Procedural colors, palettes, and color space transformations",
            puzzles: [
                puzzle3_1(),
                puzzle3_2(),
                puzzle3_3(),
                puzzle3_4(),
                puzzle3_5(),
            ]
        )
    }

    private func puzzle3_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 3, index: 1),
            title: "Rainbow Road",
            subtitle: "Procedural color palettes",
            description: """
                Welcome to color theory! Instead of hard-coding colors, let's generate them mathematically.

                Inigo Quilez's **cosine palette** is a beautiful technique that creates smooth color gradients using just 4 parameters:

                ```
                color = a + b * cos(2π * (c * t + d))
                ```

                Where `t` is your input value (0-1), and a, b, c, d are float3 color vectors.

                Create a horizontal rainbow gradient using:
                - a = (0.5, 0.5, 0.5) - brightness offset
                - b = (0.5, 0.5, 0.5) - amplitude
                - c = (1.0, 1.0, 1.0) - frequency
                - d = (0.0, 0.33, 0.67) - phase offset per channel
                """,
            reference: .animation(
                shader: """
                    float3 a = float3(0.5, 0.5, 0.5);
                    float3 b = float3(0.5, 0.5, 0.5);
                    float3 c = float3(1.0, 1.0, 1.0);
                    float3 d = float3(0.0, 0.33, 0.67);
                    float3 col = a + b * cos(6.28318 * (c * uv.x + d));
                    return float4(col, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .color,
                functionName: "palette",
                signature: "float3 palette(float t, float3 a, float3 b, float3 c, float3 d)",
                implementation: "return a + b * cos(6.28318 * (c * t + d));",
                documentation: "Inigo Quilez's cosine palette function for procedural coloring."
            ),
            hints: [
                Hint(cost: 0, text: "The formula uses cos() which oscillates between -1 and 1, scaled and offset by a and b"),
                Hint(cost: 0, text: "Use uv.x as your t value to create a horizontal gradient"),
                Hint(cost: 1, text: "6.28318 is 2π - this makes cos() complete one full cycle as t goes 0→1"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float3 a = float3(0.5, 0.5, 0.5);
                    float3 b = float3(0.5, 0.5, 0.5);
                    float3 c = float3(1.0, 1.0, 1.0);
                    float3 d = float3(0.0, 0.33, 0.67);
                    float3 col = a + b * cos(c * uv.x + d);  // ERROR: Missing 6.28318 * before (c * uv.x + d)
                    return float4(col, 1.0);
                    """),
                Hint(cost: 3, text: "float3 col = a + b * cos(6.28318 * (c * uv.x + d));"),
            ],
            starterCode: """
                // Create a rainbow gradient using the cosine palette formula
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Palette parameters
                    float3 a = float3(0.5, 0.5, 0.5);  // Brightness
                    float3 b = float3(0.5, 0.5, 0.5);  // Contrast
                    float3 c = float3(1.0, 1.0, 1.0);  // Frequency
                    float3 d = float3(0.0, 0.33, 0.67);  // Phase

                    // TODO: Apply the cosine palette formula
                    // color = a + b * cos(2π * (c * t + d))
                    float3 col = float3(uv.x);  // Replace with palette formula

                    return float4(col, 1.0);
                }
                """,
            solution: """
                float3 a = float3(0.5, 0.5, 0.5);
                float3 b = float3(0.5, 0.5, 0.5);
                float3 c = float3(1.0, 1.0, 1.0);
                float3 d = float3(0.0, 0.33, 0.67);
                float3 col = a + b * cos(6.28318 * (c * uv.x + d));
                return float4(col, 1.0);
                """
        )
    }

    private func puzzle3_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 3, index: 2),
            title: "Hue Shift",
            subtitle: "RGB to HSV conversion",
            description: """
                RGB is great for displays, but terrible for color manipulation. Want to make something "more red" or "shift the hue"? You need **HSV** (Hue, Saturation, Value).

                - **Hue** (0-1): The color itself, cycling through the rainbow
                - **Saturation** (0-1): Color intensity (0 = gray, 1 = vivid)
                - **Value** (0-1): Brightness (0 = black, 1 = bright)

                Convert the UV gradient to HSV, shift the hue by 0.5 (180°), then convert back to RGB.

                The conversion formulas are complex, so we'll provide helper functions.
                """,
            reference: .animation(
                shader: """
                    // Simplified: create HSV from position, shift hue
                    float3 hsv = float3(uv.x + 0.5, 0.8, 0.9);
                    // HSV to RGB conversion
                    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                    float3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                    float3 rgb = hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
                    return float4(rgb, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .color,
                functionName: "hsv2rgb",
                signature: "float3 hsv2rgb(float3 c)",
                implementation: """
                    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
                    """,
                documentation: "Converts HSV color to RGB color space."
            ),
            hints: [
                Hint(cost: 0, text: "Create an HSV color where hue = uv.x + 0.5 (the shift)"),
                Hint(cost: 0, text: "Use saturation ~0.8 and value ~0.9 for vivid colors"),
                Hint(cost: 1, text: "The HSV→RGB formula uses fract() to wrap hue values > 1"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float3 hsv = float3(uv.x, 0.8, 0.9);  // ERROR: Hue should be uv.x + 0.5 to shift
                    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                    float3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                    float3 rgb = hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
                    return float4(rgb, 1.0);
                    """),
                Hint(cost: 3, text: "float3 hsv = float3(uv.x + 0.5, 0.8, 0.9);"),
            ],
            starterCode: """
                // Create a hue-shifted gradient using HSV
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Create HSV color: (hue, saturation, value)
                    // Shift hue by 0.5 (180 degrees)
                    float3 hsv = float3(uv.x, 0.8, 0.9);  // TODO: Add hue shift

                    // HSV to RGB conversion (magic formula)
                    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                    float3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                    float3 rgb = hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);

                    return float4(rgb, 1.0);
                }
                """,
            solution: """
                float3 hsv = float3(uv.x + 0.5, 0.8, 0.9);
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                float3 rgb = hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
                return float4(rgb, 1.0);
                """
        )
    }

    private func puzzle3_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 3, index: 3),
            title: "Color Wheel",
            subtitle: "Polar coordinates meet color",
            description: """
                Let's create a classic color wheel! This combines two concepts:

                1. **Polar coordinates**: Convert (x, y) to (angle, distance) using [`atan2()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70)
                2. **HSV color**: Map angle → hue, distance → saturation

                The angle from `atan2(y, x)` ranges from -π to π. Normalize it to 0-1 for hue.

                Create a color wheel where:
                - Hue follows the angle around the center
                - Saturation increases from center to edge
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float angle = atan2(p.y, p.x);
                    float hue = angle / 6.28318 + 0.5;
                    float sat = length(p) * 2.0;
                    float3 hsv = float3(hue, clamp(sat, 0.0, 1.0), 1.0);
                    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                    float3 rgb_p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                    float3 rgb = hsv.z * mix(K.xxx, clamp(rgb_p - K.xxx, 0.0, 1.0), hsv.y);
                    return float4(rgb, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb"],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "atan2(y, x) returns angle in radians (-π to π)"),
                Hint(cost: 0, text: "Divide by 2π and add 0.5 to normalize angle to 0-1 range"),
                Hint(cost: 1, text: "Use length(p) for distance from center - multiply by 2 so edge = 1.0"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float angle = atan2(p.y, p.x);
                    float hue = angle;  // ERROR: Needs normalization: angle / 6.28318 + 0.5
                    float sat = length(p);  // ERROR: Multiply by 2.0 for full saturation at edge
                    float3 hsv = float3(hue, clamp(sat, 0.0, 1.0), 1.0);
                    // ... HSV to RGB conversion ...
                    """),
                Hint(cost: 3, text: "float hue = angle / 6.28318 + 0.5; float sat = length(p) * 2.0;"),
            ],
            starterCode: """
                // Create a color wheel using polar coordinates
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;  // Center coordinates

                    // Convert to polar coordinates
                    float angle = atan2(p.y, p.x);  // -π to π
                    float dist = length(p);  // 0 to ~0.7

                    // TODO: Map to HSV
                    // Hue = normalized angle (0-1)
                    // Saturation = distance from center
                    float hue = 0.0;  // Calculate from angle
                    float sat = 0.0;  // Calculate from distance

                    float3 hsv = float3(hue, clamp(sat, 0.0, 1.0), 1.0);

                    // HSV to RGB
                    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                    float3 rgb_p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                    float3 rgb = hsv.z * mix(K.xxx, clamp(rgb_p - K.xxx, 0.0, 1.0), hsv.y);

                    return float4(rgb, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float angle = atan2(p.y, p.x);
                float hue = angle / 6.28318 + 0.5;
                float sat = length(p) * 2.0;
                float3 hsv = float3(hue, clamp(sat, 0.0, 1.0), 1.0);
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 rgb_p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
                float3 rgb = hsv.z * mix(K.xxx, clamp(rgb_p - K.xxx, 0.0, 1.0), hsv.y);
                return float4(rgb, 1.0);
                """
        )
    }

    private func puzzle3_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 3, index: 4),
            title: "Gradient Mapping",
            subtitle: "Color SDFs by distance",
            description: """
                Here's a powerful technique: use SDF distance to look up colors from a gradient!

                Instead of just white/black shapes, we can create beautiful glowing effects by mapping distance to color using [`mix()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80).

                Create a circle with:
                - Hot core (yellow/white at center)
                - Orange glow transitioning outward
                - Dark red edge fading to black
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float d = length(p);
                    float3 col1 = float3(1.0, 1.0, 0.8);  // Hot core
                    float3 col2 = float3(1.0, 0.4, 0.0);  // Orange
                    float3 col3 = float3(0.2, 0.0, 0.0);  // Dark red
                    float t = clamp(d * 3.0, 0.0, 1.0);
                    float3 col = t < 0.5 ? mix(col1, col2, t * 2.0) : mix(col2, col3, (t - 0.5) * 2.0);
                    col *= 1.0 - smoothstep(0.3, 0.5, d);
                    return float4(col, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .color,
                functionName: "colorRamp",
                signature: "float3 colorRamp(float t, float3 c1, float3 c2, float3 c3)",
                implementation: "return t < 0.5 ? mix(c1, c2, t * 2.0) : mix(c2, c3, (t - 0.5) * 2.0);",
                documentation: "Maps value t (0-1) to a 3-color gradient: c1 → c2 → c3."
            ),
            hints: [
                Hint(cost: 0, text: "Use distance from center as your t value for the gradient"),
                Hint(cost: 0, text: "Scale and clamp distance to get t in 0-1 range"),
                Hint(cost: 1, text: "Use two mix() calls: one for t<0.5 (col1→col2), one for t>=0.5 (col2→col3)"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float d = length(p);
                    float3 col1 = float3(1.0, 1.0, 0.8);
                    float3 col2 = float3(1.0, 0.4, 0.0);
                    float3 col3 = float3(0.2, 0.0, 0.0);
                    float t = d * 3.0;  // ERROR: Needs clamp(d * 3.0, 0.0, 1.0)
                    float3 col = mix(col1, col3, t);  // ERROR: Should use 3-color ramp with col2 in middle
                    col *= 1.0 - smoothstep(0.3, 0.5, d);
                    return float4(col, 1.0);
                    """),
                Hint(cost: 3, text: "float3 col = t < 0.5 ? mix(col1, col2, t * 2.0) : mix(col2, col3, (t - 0.5) * 2.0);"),
            ],
            starterCode: """
                // Create a glowing orb with gradient mapping
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;
                    float d = length(p);

                    // Define gradient colors
                    float3 col1 = float3(1.0, 1.0, 0.8);  // Hot core (yellow-white)
                    float3 col2 = float3(1.0, 0.4, 0.0);  // Middle (orange)
                    float3 col3 = float3(0.2, 0.0, 0.0);  // Edge (dark red)

                    // TODO: Map distance to gradient
                    // Scale d to useful range, clamp to 0-1
                    float t = d;  // Adjust this

                    // TODO: Create 3-color gradient
                    float3 col = float3(1.0);  // Replace with gradient lookup

                    // Fade out at edge
                    col *= 1.0 - smoothstep(0.3, 0.5, d);

                    return float4(col, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float d = length(p);
                float3 col1 = float3(1.0, 1.0, 0.8);
                float3 col2 = float3(1.0, 0.4, 0.0);
                float3 col3 = float3(0.2, 0.0, 0.0);
                float t = clamp(d * 3.0, 0.0, 1.0);
                float3 col = t < 0.5 ? mix(col1, col2, t * 2.0) : mix(col2, col3, (t - 0.5) * 2.0);
                col *= 1.0 - smoothstep(0.3, 0.5, d);
                return float4(col, 1.0);
                """
        )
    }

    private func puzzle3_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 3, index: 5),
            title: "Blend Modes",
            subtitle: "Photoshop-style color blending",
            description: """
                Ever wonder how Photoshop blend modes work? They're just math!

                Common blend modes:
                - **Multiply**: `a * b` - darkens, great for shadows
                - **Screen**: `1 - (1-a) * (1-b)` - lightens, great for glows
                - **Overlay**: Combines both based on brightness

                Create a pattern by blending a horizontal gradient with a vertical gradient using **screen** blend mode.
                """,
            reference: .animation(
                shader: """
                    float3 a = float3(uv.x, uv.x * 0.5, 0.2);
                    float3 b = float3(0.2, uv.y * 0.8, uv.y);
                    float3 col = 1.0 - (1.0 - a) * (1.0 - b);
                    return float4(col, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .color,
                functionName: "blendScreen",
                signature: "float3 blendScreen(float3 a, float3 b)",
                implementation: "return 1.0 - (1.0 - a) * (1.0 - b);",
                documentation: "Screen blend mode - lightens colors, useful for glows and highlights."
            ),
            hints: [
                Hint(cost: 0, text: "Screen blend inverts both colors, multiplies, then inverts the result"),
                Hint(cost: 0, text: "Create two different color gradients based on uv.x and uv.y"),
                Hint(cost: 1, text: "The screen formula is: 1 - (1-a) * (1-b)"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float3 a = float3(uv.x, uv.x * 0.5, 0.2);
                    float3 b = float3(0.2, uv.y * 0.8, uv.y);
                    float3 col = a * b;  // ERROR: This is multiply, use screen: 1.0 - (1.0 - a) * (1.0 - b)
                    return float4(col, 1.0);
                    """),
                Hint(cost: 3, text: "float3 col = 1.0 - (1.0 - a) * (1.0 - b);"),
            ],
            starterCode: """
                // Blend two gradients using screen blend mode
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Horizontal gradient (warm colors)
                    float3 a = float3(uv.x, uv.x * 0.5, 0.2);

                    // Vertical gradient (cool colors)
                    float3 b = float3(0.2, uv.y * 0.8, uv.y);

                    // TODO: Apply screen blend mode
                    // Screen: 1 - (1-a) * (1-b)
                    float3 col = a;  // Replace with screen blend

                    return float4(col, 1.0);
                }
                """,
            solution: """
                float3 a = float3(uv.x, uv.x * 0.5, 0.2);
                float3 b = float3(0.2, uv.y * 0.8, uv.y);
                float3 col = 1.0 - (1.0 - a) * (1.0 - b);
                return float4(col, 1.0);
                """
        )
    }

    // MARK: - World 4: Noise & Patterns

    private func createWorld4() -> World {
        World(
            number: 4,
            title: "Noise & Patterns",
            description: "Procedural textures, hash functions, and noise algorithms",
            puzzles: [
                puzzle4_1(),
                puzzle4_2(),
                puzzle4_3(),
                puzzle4_4(),
                puzzle4_5(),
                puzzle4_6(),
            ]
        )
    }

    private func puzzle4_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 4, index: 1),
            title: "Static",
            subtitle: "The hash function",
            description: """
                Welcome to procedural noise! The foundation of all procedural textures is the **hash function** - a way to generate pseudo-random numbers from coordinates.

                A good hash function:
                - Always returns the same value for the same input
                - Looks random (no visible patterns)
                - Is fast to compute

                The classic shader hash uses [`sin()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) and [`fract()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70):

                ```
                fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453)
                ```

                Create TV static by hashing the pixel coordinates!
                """,
            reference: .animation(
                shader: """
                    float2 p = floor(uv * 100.0);
                    float n = fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
                    return float4(n, n, n, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .noise,
                functionName: "hash",
                signature: "float hash(float2 p)",
                implementation: "return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);",
                documentation: "Simple hash function for pseudo-random values from 2D coordinates."
            ),
            hints: [
                Hint(cost: 0, text: "dot() combines x and y into a single value, sin() scrambles it, fract() keeps just the decimal"),
                Hint(cost: 0, text: "floor(uv * 100.0) creates a grid of 100×100 cells, each with its own random value"),
                Hint(cost: 1, text: "The magic numbers (127.1, 311.7, 43758.5453) are chosen to minimize visible patterns"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float2 p = floor(uv * 100.0);
                    float n = sin(dot(p, float2(127.1, 311.7))) * 43758.5453;  // ERROR: Missing fract() wrapper
                    return float4(n, n, n, 1.0);
                    """),
                Hint(cost: 3, text: "float n = fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);"),
            ],
            starterCode: """
                // Create TV static using a hash function
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Create a grid of cells
                    float2 p = floor(uv * 100.0);  // 100x100 grid

                    // TODO: Hash the cell coordinates to get random value 0-1
                    // Formula: fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453)
                    float n = 0.5;  // Replace with hash

                    return float4(n, n, n, 1.0);
                }
                """,
            solution: """
                float2 p = floor(uv * 100.0);
                float n = fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
                return float4(n, n, n, 1.0);
                """
        )
    }

    private func puzzle4_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 4, index: 2),
            title: "Smooth Static",
            subtitle: "Value noise interpolation",
            description: """
                Raw hash looks like TV static - too harsh for organic textures. **Value noise** fixes this by:

                1. Hashing corner values of each grid cell
                2. Smoothly interpolating between them using [`mix()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80)

                The key insight: use `fract(p)` for interpolation weights, but apply **smoothstep** to avoid linear interpolation artifacts:

                ```
                f = f * f * (3.0 - 2.0 * f)  // Smooth interpolation curve
                ```

                Create smooth, cloud-like noise!
                """,
            reference: .animation(
                shader: """
                    float2 p = uv * 8.0;
                    float2 i = floor(p);
                    float2 f = fract(p);
                    f = f * f * (3.0 - 2.0 * f);
                    float a = fract(sin(dot(i, float2(127.1, 311.7))) * 43758.5453);
                    float b = fract(sin(dot(i + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                    float c = fract(sin(dot(i + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float d = fract(sin(dot(i + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float n = mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
                    return float4(n, n, n, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .noise,
                functionName: "valueNoise",
                signature: "float valueNoise(float2 p)",
                implementation: """
                    float2 i = floor(p); float2 f = fract(p);
                    f = f * f * (3.0 - 2.0 * f);
                    float a = fract(sin(dot(i, float2(127.1, 311.7))) * 43758.5453);
                    float b = fract(sin(dot(i + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                    float c = fract(sin(dot(i + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float d = fract(sin(dot(i + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
                    """,
                documentation: "Value noise with smooth interpolation."
            ),
            hints: [
                Hint(cost: 0, text: "i = floor(p) gives the cell corner, f = fract(p) gives position within cell"),
                Hint(cost: 0, text: "Hash all four corners: (i), (i+1,0), (i+0,1), (i+1,1)"),
                Hint(cost: 1, text: "Use nested mix(): mix(mix(a,b,f.x), mix(c,d,f.x), f.y) for bilinear interpolation"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv * 8.0;
                    float2 i = floor(p);
                    float2 f = fract(p);
                    // f = f * f * (3.0 - 2.0 * f);  // ERROR: This smoothing line is missing!
                    float a = fract(sin(dot(i, float2(127.1, 311.7))) * 43758.5453);
                    float b = fract(sin(dot(i + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                    float c = fract(sin(dot(i + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float d = fract(sin(dot(i + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float n = mix(a, d, f.x);  // ERROR: Need proper bilinear: mix(mix(a,b,f.x), mix(c,d,f.x), f.y)
                    return float4(n, n, n, 1.0);
                    """),
                Hint(cost: 3, text: "f = f * f * (3.0 - 2.0 * f); ... float n = mix(mix(a, b, f.x), mix(c, d, f.x), f.y);"),
            ],
            starterCode: """
                // Create smooth value noise
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv * 8.0;  // Scale up for visible cells

                    // Separate integer and fractional parts
                    float2 i = floor(p);
                    float2 f = fract(p);

                    // TODO: Apply smoothing curve to f
                    // f = f * f * (3.0 - 2.0 * f);

                    // Hash the four corners
                    float a = fract(sin(dot(i, float2(127.1, 311.7))) * 43758.5453);
                    float b = fract(sin(dot(i + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                    float c = fract(sin(dot(i + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float d = fract(sin(dot(i + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);

                    // TODO: Bilinear interpolation
                    float n = a;  // Replace with proper interpolation

                    return float4(n, n, n, 1.0);
                }
                """,
            solution: """
                float2 p = uv * 8.0;
                float2 i = floor(p);
                float2 f = fract(p);
                f = f * f * (3.0 - 2.0 * f);
                float a = fract(sin(dot(i, float2(127.1, 311.7))) * 43758.5453);
                float b = fract(sin(dot(i + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                float c = fract(sin(dot(i + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                float d = fract(sin(dot(i + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                float n = mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
                return float4(n, n, n, 1.0);
                """
        )
    }

    private func puzzle4_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 4, index: 3),
            title: "Voronoi Cells",
            subtitle: "Cellular noise",
            description: """
                **Voronoi noise** (also called cellular noise) creates organic cell patterns. The algorithm:

                1. Scatter random points across a grid
                2. For each pixel, find the distance to the nearest point
                3. That distance becomes the output value

                This creates patterns like:
                - Stone tiles
                - Giraffe spots
                - Cracked earth
                - Cell structures

                Generate a basic Voronoi pattern with distance visualization!
                """,
            reference: .animation(
                shader: """
                    float2 p = uv * 5.0;
                    float2 i = floor(p);
                    float2 f = fract(p);
                    float minDist = 1.0;
                    for (int y = -1; y <= 1; y++) {
                        for (int x = -1; x <= 1; x++) {
                            float2 neighbor = float2(float(x), float(y));
                            float2 cellPos = i + neighbor;
                            float2 point = fract(sin(float2(dot(cellPos, float2(127.1, 311.7)), dot(cellPos, float2(269.5, 183.3)))) * 43758.5453);
                            float2 diff = neighbor + point - f;
                            float dist = length(diff);
                            minDist = min(minDist, dist);
                        }
                    }
                    return float4(minDist, minDist, minDist, 1.0);
                    """,
                duration: 0
            ),
            verification: VerificationSettings(mode: .threshold(0.97), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .noise,
                functionName: "voronoi",
                signature: "float voronoi(float2 p)",
                implementation: """
                    float2 i = floor(p); float2 f = fract(p); float minDist = 1.0;
                    for (int y = -1; y <= 1; y++) { for (int x = -1; x <= 1; x++) {
                        float2 neighbor = float2(float(x), float(y));
                        float2 cellPos = i + neighbor;
                        float2 point = fract(sin(float2(dot(cellPos, float2(127.1, 311.7)), dot(cellPos, float2(269.5, 183.3)))) * 43758.5453);
                        minDist = min(minDist, length(neighbor + point - f));
                    }} return minDist;
                    """,
                documentation: "Returns distance to nearest Voronoi cell center."
            ),
            hints: [
                Hint(cost: 0, text: "Check all 9 neighboring cells (3×3 grid) to find the nearest point"),
                Hint(cost: 0, text: "Each cell has a random point position: hash the cell coordinates to get it"),
                Hint(cost: 1, text: "diff = neighbor + point - f gives vector from current position to the point"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float2 p = uv * 5.0;
                    float2 i = floor(p);
                    float2 f = fract(p);
                    float minDist = 1.0;
                    for (int y = -1; y <= 1; y++) {
                        for (int x = -1; x <= 1; x++) {
                            float2 neighbor = float2(float(x), float(y));
                            float2 cellPos = i + neighbor;
                            float2 point = fract(sin(float2(dot(cellPos, float2(127.1, 311.7)), dot(cellPos, float2(269.5, 183.3)))) * 43758.5453);
                            float2 diff = neighbor + point - f;
                            float dist = length(diff);
                            minDist = dist;  // ERROR: Should be min(minDist, dist)
                        }
                    }
                    return float4(minDist, minDist, minDist, 1.0);
                    """),
                Hint(cost: 3, text: "minDist = min(minDist, dist);"),
            ],
            starterCode: """
                // Create Voronoi cellular noise
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv * 5.0;  // Scale for visible cells
                    float2 i = floor(p);
                    float2 f = fract(p);

                    float minDist = 1.0;

                    // Check 3x3 neighborhood
                    for (int y = -1; y <= 1; y++) {
                        for (int x = -1; x <= 1; x++) {
                            float2 neighbor = float2(float(x), float(y));
                            float2 cellPos = i + neighbor;

                            // Random point in cell (hash cell position)
                            float2 point = fract(sin(float2(
                                dot(cellPos, float2(127.1, 311.7)),
                                dot(cellPos, float2(269.5, 183.3))
                            )) * 43758.5453);

                            // Distance to this point
                            float2 diff = neighbor + point - f;
                            float dist = length(diff);

                            // TODO: Track minimum distance
                            // minDist = ???
                        }
                    }

                    return float4(minDist, minDist, minDist, 1.0);
                }
                """,
            solution: """
                float2 p = uv * 5.0;
                float2 i = floor(p);
                float2 f = fract(p);
                float minDist = 1.0;
                for (int y = -1; y <= 1; y++) {
                    for (int x = -1; x <= 1; x++) {
                        float2 neighbor = float2(float(x), float(y));
                        float2 cellPos = i + neighbor;
                        float2 point = fract(sin(float2(dot(cellPos, float2(127.1, 311.7)), dot(cellPos, float2(269.5, 183.3)))) * 43758.5453);
                        float2 diff = neighbor + point - f;
                        float dist = length(diff);
                        minDist = min(minDist, dist);
                    }
                }
                return float4(minDist, minDist, minDist, 1.0);
                """
        )
    }

    private func puzzle4_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 4, index: 4),
            title: "Layered Noise",
            subtitle: "Fractal Brownian Motion",
            description: """
                Single-frequency noise looks artificial. Nature has detail at every scale! **Fractal Brownian Motion (FBM)** fixes this by layering multiple **octaves** of noise:

                Each octave:
                - **Doubles the frequency** (smaller features)
                - **Halves the amplitude** (less influence)

                ```
                for (int i = 0; i < octaves; i++) {
                    value += amplitude * noise(p);
                    p *= 2.0;        // Double frequency
                    amplitude *= 0.5; // Halve amplitude
                }
                ```

                Create rich, cloud-like textures with 5 octaves!
                """,
            reference: .animation(
                shader: """
                    float2 p = uv * 4.0;
                    float value = 0.0;
                    float amplitude = 0.5;
                    for (int i = 0; i < 5; i++) {
                        float2 ip = floor(p); float2 fp = fract(p);
                        fp = fp * fp * (3.0 - 2.0 * fp);
                        float a = fract(sin(dot(ip, float2(127.1, 311.7))) * 43758.5453);
                        float b = fract(sin(dot(ip + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                        float c = fract(sin(dot(ip + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                        float d = fract(sin(dot(ip + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                        float n = mix(mix(a, b, fp.x), mix(c, d, fp.x), fp.y);
                        value += amplitude * n;
                        p *= 2.0;
                        amplitude *= 0.5;
                    }
                    return float4(value, value, value, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .noise,
                functionName: "fbm",
                signature: "float fbm(float2 p, int octaves)",
                implementation: """
                    float value = 0.0; float amplitude = 0.5;
                    for (int i = 0; i < octaves; i++) {
                        float2 ip = floor(p); float2 fp = fract(p);
                        fp = fp * fp * (3.0 - 2.0 * fp);
                        float a = fract(sin(dot(ip, float2(127.1, 311.7))) * 43758.5453);
                        float b = fract(sin(dot(ip + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                        float c = fract(sin(dot(ip + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                        float d = fract(sin(dot(ip + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                        value += amplitude * mix(mix(a, b, fp.x), mix(c, d, fp.x), fp.y);
                        p *= 2.0; amplitude *= 0.5;
                    } return value;
                    """,
                documentation: "Fractal Brownian Motion - layered noise with decreasing amplitude."
            ),
            hints: [
                Hint(cost: 0, text: "Start with amplitude 0.5, then halve it each octave: 0.5, 0.25, 0.125..."),
                Hint(cost: 0, text: "Double the frequency by multiplying p by 2.0 each iteration"),
                Hint(cost: 1, text: "Accumulate: value += amplitude * noise(p); then update p and amplitude"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv * 4.0;
                    float value = 0.0;
                    float amplitude = 0.5;
                    for (int i = 0; i < 5; i++) {
                        // ... noise calculation gives 'n' ...
                        value += n;  // ERROR: Should be value += amplitude * n
                        p += 2.0;    // ERROR: Should MULTIPLY: p *= 2.0
                        amplitude *= 0.5;
                    }
                    return float4(value, value, value, 1.0);
                    """),
                Hint(cost: 3, text: "value += amplitude * n; p *= 2.0;"),
            ],
            starterCode: """
                // Create FBM with 5 octaves of noise
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv * 4.0;
                    float value = 0.0;
                    float amplitude = 0.5;

                    for (int i = 0; i < 5; i++) {
                        // Value noise calculation
                        float2 ip = floor(p); float2 fp = fract(p);
                        fp = fp * fp * (3.0 - 2.0 * fp);
                        float a = fract(sin(dot(ip, float2(127.1, 311.7))) * 43758.5453);
                        float b = fract(sin(dot(ip + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                        float c = fract(sin(dot(ip + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                        float d = fract(sin(dot(ip + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                        float n = mix(mix(a, b, fp.x), mix(c, d, fp.x), fp.y);

                        // TODO: Accumulate with amplitude, update p and amplitude
                        value += n;  // Fix this line
                        // Update frequency and amplitude for next octave
                    }

                    return float4(value, value, value, 1.0);
                }
                """,
            solution: """
                float2 p = uv * 4.0;
                float value = 0.0;
                float amplitude = 0.5;
                for (int i = 0; i < 5; i++) {
                    float2 ip = floor(p); float2 fp = fract(p);
                    fp = fp * fp * (3.0 - 2.0 * fp);
                    float a = fract(sin(dot(ip, float2(127.1, 311.7))) * 43758.5453);
                    float b = fract(sin(dot(ip + float2(1.0, 0.0), float2(127.1, 311.7))) * 43758.5453);
                    float c = fract(sin(dot(ip + float2(0.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float d = fract(sin(dot(ip + float2(1.0, 1.0), float2(127.1, 311.7))) * 43758.5453);
                    float n = mix(mix(a, b, fp.x), mix(c, d, fp.x), fp.y);
                    value += amplitude * n;
                    p *= 2.0;
                    amplitude *= 0.5;
                }
                return float4(value, value, value, 1.0);
                """
        )
    }

    private func puzzle4_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 4, index: 5),
            title: "Checkerboard",
            subtitle: "Mathematical patterns",
            description: """
                Let's take a break from noise for a classic pattern: the **checkerboard**.

                The key insight: `floor(x) + floor(y)` alternates between even and odd values. Use [`fract()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) to turn this into 0 or 0.5:

                ```
                fract((floor(x) + floor(y)) * 0.5) * 2.0
                ```

                This returns 0 for even squares, 1 for odd squares!

                Create an 8×8 checkerboard.
                """,
            reference: .animation(
                shader: """
                    float2 p = floor(uv * 8.0);
                    float checker = fract((p.x + p.y) * 0.5) * 2.0;
                    return float4(checker, checker, checker, 1.0);
                    """,
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .noise,
                functionName: "checker",
                signature: "float checker(float2 p, float scale)",
                implementation: "float2 q = floor(p * scale); return fract((q.x + q.y) * 0.5) * 2.0;",
                documentation: "Returns 0 or 1 in a checkerboard pattern at the given scale."
            ),
            hints: [
                Hint(cost: 0, text: "floor(uv * 8.0) gives you integer cell coordinates"),
                Hint(cost: 0, text: "Adding x + y gives alternating even/odd pattern"),
                Hint(cost: 1, text: "Multiply by 0.5, take fract(), then multiply by 2.0 to get clean 0 or 1"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float2 p = floor(uv * 8.0);
                    float checker = fract(p.x + p.y) * 2.0;  // ERROR: Should be fract((p.x + p.y) * 0.5) * 2.0
                    return float4(checker, checker, checker, 1.0);
                    """),
                Hint(cost: 3, text: "float checker = fract((p.x + p.y) * 0.5) * 2.0;"),
            ],
            starterCode: """
                // Create an 8x8 checkerboard pattern
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Get cell coordinates
                    float2 p = floor(uv * 8.0);

                    // TODO: Calculate checker pattern (0 or 1)
                    // Hint: Use fract((p.x + p.y) * 0.5) * 2.0
                    float checker = 0.0;  // Replace with formula

                    return float4(checker, checker, checker, 1.0);
                }
                """,
            solution: """
                float2 p = floor(uv * 8.0);
                float checker = fract((p.x + p.y) * 0.5) * 2.0;
                return float4(checker, checker, checker, 1.0);
                """
        )
    }

    private func puzzle4_6() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 4, index: 6),
            title: "Brick Wall",
            subtitle: "Offset patterns",
            description: """
                Checkerboards are nice, but real patterns often have **offset rows**. A brick wall pattern offsets every other row by half a brick width.

                The trick: shift x by 0.5 for odd rows:

                ```
                if (fract(floor(y) * 0.5) > 0.25) {
                    x += 0.5;
                }
                ```

                Or more elegantly: `x += fract(floor(y) * 0.5)`

                Create a brick pattern with highlighted mortar lines!
                """,
            reference: .animation(
                shader: """
                    float2 p = uv * float2(8.0, 4.0);
                    p.x += fract(floor(p.y) * 0.5);
                    float2 f = fract(p);
                    float mortar = 0.05;
                    float brick = step(mortar, f.x) * step(mortar, f.y);
                    float3 col = mix(float3(0.3, 0.3, 0.3), float3(0.6, 0.25, 0.15), brick);
                    return float4(col, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker"],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "Use different scales for x and y to get rectangular bricks (wider than tall)"),
                Hint(cost: 0, text: "fract(floor(y) * 0.5) is 0 for even rows, 0.5 for odd rows"),
                Hint(cost: 1, text: "Use step() with a small threshold to create mortar lines at edges"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv * float2(8.0, 4.0);
                    // p.x += ???;  // ERROR: Missing row offset: fract(floor(p.y) * 0.5)
                    float2 f = fract(p);
                    float mortar = 0.05;
                    float brick = step(mortar, f.x);  // ERROR: Also need step(mortar, f.y)
                    float3 col = mix(float3(0.3, 0.3, 0.3), float3(0.6, 0.25, 0.15), brick);
                    return float4(col, 1.0);
                    """),
                Hint(cost: 3, text: "p.x += fract(floor(p.y) * 0.5); ... float brick = step(mortar, f.x) * step(mortar, f.y);"),
            ],
            starterCode: """
                // Create a brick wall pattern
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Scale: 8 bricks wide, 4 high (bricks are 2:1 ratio)
                    float2 p = uv * float2(8.0, 4.0);

                    // TODO: Offset every other row by half a brick
                    // Hint: p.x += fract(floor(p.y) * 0.5)

                    // Get position within brick
                    float2 f = fract(p);

                    // Mortar is visible at edges
                    float mortar = 0.05;
                    float brick = 1.0;  // TODO: Use step() to create mortar lines

                    // Color: gray mortar, red-brown brick
                    float3 col = mix(float3(0.3, 0.3, 0.3), float3(0.6, 0.25, 0.15), brick);

                    return float4(col, 1.0);
                }
                """,
            solution: """
                float2 p = uv * float2(8.0, 4.0);
                p.x += fract(floor(p.y) * 0.5);
                float2 f = fract(p);
                float mortar = 0.05;
                float brick = step(mortar, f.x) * step(mortar, f.y);
                float3 col = mix(float3(0.3, 0.3, 0.3), float3(0.6, 0.25, 0.15), brick);
                return float4(col, 1.0);
                """
        )
    }

    // MARK: - World 5: Motion & Time

    private func createWorld5() -> World {
        World(
            number: 5,
            title: "Motion & Time",
            description: "Bring your shaders to life with animation! Learn to use time-based functions for pulsing, oscillation, easing, and circular motion.",
            puzzles: [
                puzzle5_1(),
                puzzle5_2(),
                puzzle5_3(),
                puzzle5_4(),
                puzzle5_5(),
            ]
        )
    }

    private func puzzle5_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 5, index: 1),
            title: "Pulse",
            subtitle: "The heartbeat of animation",
            description: """
                Welcome to **Motion & Time**! Everything so far has been static—time to bring your shaders to life!

                The [`sin()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) function oscillates between -1 and 1. Combined with time, it creates smooth animation:

                ```
                float pulse = sin(u.time);  // Oscillates -1 to 1
                pulse = pulse * 0.5 + 0.5;  // Remap to 0 to 1
                ```

                The `u.time` uniform increases continuously. Multiplying it changes speed—`sin(u.time * 2.0)` pulses twice as fast!

                Create a pulsing brightness effect where the screen smoothly fades between black and white.
                """,
            reference: .animation(
                shader: """
                    float brightness = sin(u.time) * 0.5 + 0.5;
                    return float4(brightness, brightness, brightness, 1.0);
                    """,
                duration: 6.28
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 30, threshold: 0.98), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker"],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "sin() outputs values from -1 to 1, but brightness needs 0 to 1"),
                Hint(cost: 0, text: "To remap -1...1 to 0...1: multiply by 0.5, then add 0.5"),
                Hint(cost: 1, text: "Use sin(u.time) for the oscillation, then remap the result"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float brightness = sin(u.time);  // ERROR: This gives -1 to 1, need 0 to 1
                    // Add: brightness = brightness * 0.5 + 0.5;
                    return float4(brightness, brightness, brightness, 1.0);
                    """),
                Hint(cost: 3, text: "float brightness = sin(u.time) * 0.5 + 0.5;"),
            ],
            starterCode: """
                // Create a pulsing brightness animation
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Use sin(u.time) to create oscillation
                    // Remember to remap from -1...1 to 0...1

                    float brightness = 0.5;  // TODO: Make this pulse over time

                    return float4(brightness, brightness, brightness, 1.0);
                }
                """,
            solution: """
                float brightness = sin(u.time) * 0.5 + 0.5;
                return float4(brightness, brightness, brightness, 1.0);
                """
        )
    }

    private func puzzle5_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 5, index: 2),
            title: "Breathing Circle",
            subtitle: "Animated shapes",
            description: """
                Now let's animate a shape! We'll make a circle that "breathes"—smoothly expanding and contracting.

                Combine your SDF knowledge with time-based animation:

                ```
                float radius = 0.2 + sin(u.time) * 0.1;  // Radius oscillates 0.1 to 0.3
                float d = length(p) - radius;            // Circle SDF with animated radius
                ```

                You can also use [`mix()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80) to interpolate between min and max radius:

                ```
                float t = sin(u.time) * 0.5 + 0.5;  // 0 to 1
                float radius = mix(0.1, 0.3, t);    // Interpolate between 0.1 and 0.3
                ```

                Create a white circle on black background that smoothly breathes between radius 0.15 and 0.35.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float t = sin(u.time) * 0.5 + 0.5;
                    float radius = mix(0.15, 0.35, t);
                    float d = length(p) - radius;
                    float circle = 1.0 - step(0.0, d);
                    return float4(circle, circle, circle, 1.0);
                    """,
                duration: 6.28
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 30, threshold: 0.97), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker"],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "First center your coordinates: p = uv - 0.5"),
                Hint(cost: 0, text: "mix(a, b, t) smoothly interpolates between a and b when t goes from 0 to 1"),
                Hint(cost: 1, text: "Use sin(u.time) * 0.5 + 0.5 to get a 0-1 oscillation for the mix() function"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float t = sin(u.time);  // ERROR: Need to remap to 0-1 with * 0.5 + 0.5
                    float radius = 0.25;    // ERROR: Should be mix(0.15, 0.35, t)
                    float d = length(p) - radius;
                    float circle = 1.0 - step(0.0, d);
                    return float4(circle, circle, circle, 1.0);
                    """),
                Hint(cost: 3, text: "float t = sin(u.time) * 0.5 + 0.5; float radius = mix(0.15, 0.35, t);"),
            ],
            starterCode: """
                // Create a breathing circle animation
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Center coordinates
                    float2 p = uv - 0.5;

                    // TODO: Animate radius between 0.15 and 0.35
                    // Hint: Use sin(u.time) * 0.5 + 0.5 for t, then mix(0.15, 0.35, t)
                    float radius = 0.25;

                    // Circle SDF
                    float d = length(p) - radius;
                    float circle = 1.0 - step(0.0, d);

                    return float4(circle, circle, circle, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float t = sin(u.time) * 0.5 + 0.5;
                float radius = mix(0.15, 0.35, t);
                float d = length(p) - radius;
                float circle = 1.0 - step(0.0, d);
                return float4(circle, circle, circle, 1.0);
                """
        )
    }

    private func puzzle5_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 5, index: 3),
            title: "Ease In, Ease Out",
            subtitle: "Natural motion curves",
            description: """
                Linear motion feels robotic. Real objects **ease in** (accelerate) and **ease out** (decelerate).

                The smoothstep function we used for anti-aliasing is actually an **easing function**! It provides smooth acceleration and deceleration:

                ```
                float t = fract(u.time * 0.5);         // 0→1 repeating
                float eased = smoothstep(0.0, 1.0, t); // Ease in and out
                ```

                For more dramatic easing, try polynomial curves:
                - **Ease in**: `t * t` (starts slow)
                - **Ease out**: `1.0 - (1.0 - t) * (1.0 - t)` (ends slow)
                - **Ease in-out**: `t < 0.5 ? 2*t*t : 1-pow(-2*t+2,2)/2`

                Create a circle that moves left-to-right with smooth ease-in-out motion, pausing briefly at each side.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float t = fract(u.time * 0.3);
                    float eased = smoothstep(0.0, 1.0, t);
                    float x = mix(-0.3, 0.3, eased);
                    float d = length(p - float2(x, 0.0)) - 0.1;
                    float circle = 1.0 - smoothstep(0.0, 0.01, d);
                    return float4(circle, circle, circle, 1.0);
                    """,
                duration: 10.5
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 30, threshold: 0.96), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .animation,
                functionName: "easeInOut",
                signature: "float easeInOut(float t)",
                implementation: "return t < 0.5 ? 2.0 * t * t : 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0;",
                documentation: "Eases in and out using quadratic curves. Input t should be 0 to 1."
            ),
            hints: [
                Hint(cost: 0, text: "fract(u.time * speed) creates a repeating 0→1 animation cycle"),
                Hint(cost: 0, text: "smoothstep(0, 1, t) naturally provides ease-in and ease-out"),
                Hint(cost: 1, text: "Use the eased value with mix(-0.3, 0.3, eased) for x position"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv - 0.5;
                    float t = fract(u.time * 0.3);
                    float eased = t;  // ERROR: Should be smoothstep(0.0, 1.0, t) for easing
                    float x = eased;  // ERROR: Should be mix(-0.3, 0.3, eased)
                    float d = length(p - float2(x, 0.0)) - 0.1;
                    float circle = 1.0 - smoothstep(0.0, 0.01, d);
                    return float4(circle, circle, circle, 1.0);
                    """),
                Hint(cost: 3, text: "float eased = smoothstep(0.0, 1.0, t); float x = mix(-0.3, 0.3, eased);"),
            ],
            starterCode: """
                // Create eased left-right motion
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;

                    // Create repeating 0→1 time
                    float t = fract(u.time * 0.3);

                    // TODO: Apply easing with smoothstep
                    float eased = t;  // Replace with smoothstep

                    // TODO: Calculate x position from -0.3 to 0.3
                    float x = 0.0;  // Replace with mix

                    // Draw circle at position
                    float d = length(p - float2(x, 0.0)) - 0.1;
                    float circle = 1.0 - smoothstep(0.0, 0.01, d);

                    return float4(circle, circle, circle, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float t = fract(u.time * 0.3);
                float eased = smoothstep(0.0, 1.0, t);
                float x = mix(-0.3, 0.3, eased);
                float d = length(p - float2(x, 0.0)) - 0.1;
                float circle = 1.0 - smoothstep(0.0, 0.01, d);
                return float4(circle, circle, circle, 1.0);
                """
        )
    }

    private func puzzle5_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 5, index: 4),
            title: "Orbit",
            subtitle: "Circular motion",
            description: """
                Time for **circular motion**! An orbiting point traces a circle using sine and cosine:

                ```
                float angle = u.time;
                float x = cos(angle) * radius;
                float y = sin(angle) * radius;
                ```

                [`cos()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) gives the x-component, [`sin()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) gives the y-component. Together they trace a circle!

                - Speed: multiply angle (`u.time * 2.0` = twice as fast)
                - Radius: multiply the result (`cos(angle) * 0.3` = larger orbit)
                - Starting angle: add offset (`cos(angle + 1.57)` = start at different position)

                Create a small circle orbiting around the center with radius 0.25.
                """,
            reference: .animation(
                shader: """
                    float2 p = uv - 0.5;
                    float angle = u.time;
                    float2 orbitPos = float2(cos(angle), sin(angle)) * 0.25;
                    float d = length(p - orbitPos) - 0.05;
                    float circle = 1.0 - smoothstep(0.0, 0.01, d);
                    return float4(circle, circle, circle, 1.0);
                    """,
                duration: 6.28
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 30, threshold: 0.96), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .animation,
                functionName: "orbit2d",
                signature: "float2 orbit2d(float angle, float radius)",
                implementation: "return float2(cos(angle), sin(angle)) * radius;",
                documentation: "Returns a point on a circle at the given angle and radius."
            ),
            hints: [
                Hint(cost: 0, text: "cos(angle) gives x, sin(angle) gives y for circular motion"),
                Hint(cost: 0, text: "Multiply both cos and sin by the orbit radius (0.25)"),
                Hint(cost: 1, text: "float2 orbitPos = float2(cos(u.time), sin(u.time)) * 0.25;"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float2 p = uv - 0.5;
                    float angle = u.time;
                    float2 orbitPos = float2(cos(angle), sin(angle));  // ERROR: Missing * 0.25 for radius
                    float d = length(p - orbitPos) - 0.05;
                    float circle = 1.0 - smoothstep(0.0, 0.01, d);
                    return float4(circle, circle, circle, 1.0);
                    """),
                Hint(cost: 3, text: "float2 orbitPos = float2(cos(angle), sin(angle)) * 0.25;"),
            ],
            starterCode: """
                // Create an orbiting circle
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv - 0.5;

                    // Calculate orbit position
                    float angle = u.time;

                    // TODO: Create orbit position using cos/sin
                    // Orbit radius should be 0.25
                    float2 orbitPos = float2(0.0, 0.0);  // Replace with orbit calculation

                    // Draw small circle at orbit position
                    float d = length(p - orbitPos) - 0.05;
                    float circle = 1.0 - smoothstep(0.0, 0.01, d);

                    return float4(circle, circle, circle, 1.0);
                }
                """,
            solution: """
                float2 p = uv - 0.5;
                float angle = u.time;
                float2 orbitPos = float2(cos(angle), sin(angle)) * 0.25;
                float d = length(p - orbitPos) - 0.05;
                float circle = 1.0 - smoothstep(0.0, 0.01, d);
                return float4(circle, circle, circle, 1.0);
                """
        )
    }

    private func puzzle5_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 5, index: 5),
            title: "Wave",
            subtitle: "Animated distortion",
            description: """
                Let's combine everything to create a **wave effect**! Waves are created by offsetting position based on sine:

                ```
                float wave = sin(uv.x * frequency + u.time * speed) * amplitude;
                uv.y += wave;  // Distort y based on x position and time
                ```

                - **Frequency**: How many waves (`uv.x * 10.0` = 10 waves across screen)
                - **Speed**: How fast they move (`u.time * 2.0` = faster)
                - **Amplitude**: How tall (`* 0.1` = 10% of screen height)

                Create a horizontal stripe pattern with animated wave distortion. The stripes should undulate like a flag!
                """,
            reference: .animation(
                shader: """
                    float2 p = uv;
                    float wave = sin(p.x * 10.0 + u.time * 3.0) * 0.05;
                    p.y += wave;
                    float stripes = step(0.5, fract(p.y * 8.0));
                    return float4(stripes, stripes, stripes, 1.0);
                    """,
                duration: 6.28
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 30, threshold: 0.95), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .animation,
                functionName: "wave",
                signature: "float wave(float x, float time, float freq, float speed, float amp)",
                implementation: "return sin(x * freq + time * speed) * amp;",
                documentation: "Returns a wave value for animated distortion effects."
            ),
            hints: [
                Hint(cost: 0, text: "sin(x * frequency + time * speed) creates a moving wave"),
                Hint(cost: 0, text: "Add the wave to uv.y to create vertical distortion"),
                Hint(cost: 1, text: "Use fract(p.y * 8.0) and step(0.5, ...) for stripe pattern"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float2 p = uv;
                    float wave = sin(p.x * 10.0);  // ERROR: Missing + u.time * 3.0 for animation
                    p.y += wave;  // ERROR: wave amplitude too large, should be wave * 0.05 or similar
                    float stripes = fract(p.y * 8.0);  // ERROR: Should be step(0.5, fract(...))
                    return float4(stripes, stripes, stripes, 1.0);
                    """),
                Hint(cost: 3, text: "float wave = sin(p.x * 10.0 + u.time * 3.0) * 0.05; p.y += wave; float stripes = step(0.5, fract(p.y * 8.0));"),
            ],
            starterCode: """
                // Create animated wave distortion
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float2 p = uv;

                    // TODO: Calculate wave offset
                    // Use sin(p.x * freq + u.time * speed) * amplitude
                    float wave = 0.0;

                    // Apply wave distortion
                    p.y += wave;

                    // TODO: Create horizontal stripe pattern
                    // Use step(0.5, fract(p.y * 8.0))
                    float stripes = 0.5;

                    return float4(stripes, stripes, stripes, 1.0);
                }
                """,
            solution: """
                float2 p = uv;
                float wave = sin(p.x * 10.0 + u.time * 3.0) * 0.05;
                p.y += wave;
                float stripes = step(0.5, fract(p.y * 8.0));
                return float4(stripes, stripes, stripes, 1.0);
                """
        )
    }

    // MARK: - World 6: Into the Third Dimension

    private func createWorld6() -> World {
        World(
            number: 6,
            title: "Into the Third Dimension",
            description: "Enter the world of 3D! Learn to define shapes in three dimensions using signed distance functions. We provide the rendering—you write the shapes.",
            puzzles: [
                puzzle6_1(),
                puzzle6_2(),
                puzzle6_3(),
                puzzle6_4(),
                puzzle6_5(),
                puzzle6_6(),
            ]
        )
    }

    // Shared 3D rendering helper that's included in all World 6 starter code
    private var world6RenderHelper: String {
        """
        // === PROVIDED RENDERING CODE (do not modify) ===
        float3 calcNormal(float3 p) {
            float2 e = float2(0.001, 0.0);
            return normalize(float3(
                sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
            ));
        }

        float4 userFragment(float2 uv, constant Uniforms& u) {
            // Camera setup
            float3 ro = float3(0.0, 0.0, 3.0);  // Ray origin (camera position)
            float3 rd = normalize(float3(uv - 0.5, -1.0));  // Ray direction

            // Rotate camera around scene
            float angle = u.time * 0.5;
            float c = cos(angle);
            float s = sin(angle);
            ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
            rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

            // Raymarch
            float t = 0.0;
            for (int i = 0; i < 64; i++) {
                float3 p = ro + rd * t;
                float d = sceneSDF(p);
                if (d < 0.001) break;
                t += d;
                if (t > 20.0) break;
            }

            // Shade
            if (t < 20.0) {
                float3 p = ro + rd * t;
                float3 n = calcNormal(p);
                float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                float diff = max(dot(n, lightDir), 0.0);
                float amb = 0.2;
                float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                return float4(col, 1.0);
            }

            return float4(0.1, 0.1, 0.15, 1.0);  // Background
        }
        // === END PROVIDED CODE ===
        """
    }

    private func puzzle6_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 6, index: 1),
            title: "Sphere",
            subtitle: "The simplest 3D shape",
            description: """
                Welcome to **3D**! You're about to write your first 3D signed distance function.

                Just like in 2D, an SDF returns the distance from a point to the nearest surface. The 3D sphere SDF is beautifully simple:

                ```
                float sdSphere(float3 p, float radius) {
                    return length(p) - radius;
                }
                ```

                That's it! The [`length()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=85) function works the same in 3D—it measures distance from the origin.

                We've provided the rendering code (raymarching + lighting). Your job: write `sceneSDF(float3 p)` that returns a sphere with radius 0.8.

                Watch it spin! 🎉
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        return length(p) - 0.8;
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.97), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf3d,
                functionName: "sdSphere",
                signature: "float sdSphere(float3 p, float r)",
                implementation: "return length(p) - r;",
                documentation: "Returns signed distance from point p to a sphere of radius r centered at origin."
            ),
            hints: [
                Hint(cost: 0, text: "A sphere is all points at distance r from center. SDF = actual_distance - radius"),
                Hint(cost: 0, text: "length(p) gives the distance from p to the origin in 3D"),
                Hint(cost: 1, text: "return length(p) - radius; is the complete sphere SDF"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float sceneSDF(float3 p) {
                        return length(p);  // ERROR: Missing - 0.8 for the radius
                    }
                    """),
                Hint(cost: 3, text: "float sceneSDF(float3 p) { return length(p) - 0.8; }"),
            ],
            starterCode: """
                // Write your 3D sphere SDF here
                float sceneSDF(float3 p) {
                    // TODO: Return distance to a sphere with radius 0.8
                    // Hint: length(p) - radius

                    return 1.0;  // Replace with sphere SDF
                }

                \(world6RenderHelper)
                """,
            solution: """
                return length(p) - 0.8;
                """
        )
    }

    private func puzzle6_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 6, index: 2),
            title: "Box in Space",
            subtitle: "Cubes and cuboids",
            description: """
                Now let's make a **3D box**! The formula is similar to 2D, but extended to 3D:

                ```
                float sdBox(float3 p, float3 b) {
                    float3 d = abs(p) - b;
                    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
                }
                ```

                Where `b` is the **half-extents** (half the box's size in each dimension).

                The [`abs()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) function folds space into the positive quadrant, letting us define the box once and have it work for all 8 corners!

                Create a box with dimensions 0.6 × 0.4 × 0.8 (half-extents: 0.3, 0.2, 0.4).
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float3 b = float3(0.3, 0.2, 0.4);
                        float3 d = abs(p) - b;
                        return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.97), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf3d,
                functionName: "sdBox3d",
                signature: "float sdBox3d(float3 p, float3 b)",
                implementation: "float3 d = abs(p) - b; return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);",
                documentation: "Returns signed distance from point p to a box with half-extents b."
            ),
            hints: [
                Hint(cost: 0, text: "abs(p) folds all coordinates to positive, so we only need to compute one corner"),
                Hint(cost: 0, text: "half-extents means the box extends from -b to +b in each axis"),
                Hint(cost: 1, text: "float3 d = abs(p) - b; then combine the components with length() and min/max"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float sceneSDF(float3 p) {
                        float3 b = float3(0.3, 0.2, 0.4);
                        float3 d = abs(p) - b;
                        return length(d);  // ERROR: Should be length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0)
                    }
                    """),
                Hint(cost: 3, text: "float3 d = abs(p) - b; return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);"),
            ],
            starterCode: """
                // Write your 3D box SDF here
                float sceneSDF(float3 p) {
                    // Box half-extents (half the full size)
                    float3 b = float3(0.3, 0.2, 0.4);

                    // TODO: Implement box SDF
                    // Step 1: float3 d = abs(p) - b;
                    // Step 2: Combine with length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0)

                    return 1.0;  // Replace with box SDF
                }

                \(world6RenderHelper)
                """,
            solution: """
                float3 b = float3(0.3, 0.2, 0.4);
                float3 d = abs(p) - b;
                return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
                """
        )
    }

    private func puzzle6_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 6, index: 3),
            title: "The Floor",
            subtitle: "Infinite planes",
            description: """
                Let's add a **floor** to our scene! An infinite horizontal plane is the simplest SDF:

                ```
                float sdPlane(float3 p, float height) {
                    return p.y - height;
                }
                ```

                The distance to a horizontal plane at y=height is just how far above or below it you are!

                Now you can **combine** multiple SDFs using the same operations from 2D:
                - [`min()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) for union
                - `max()` for intersection

                Create a scene with a sphere (radius 0.5 at y=0.5) sitting on a floor at y=0.
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float sphere = length(p - float3(0.0, 0.5, 0.0)) - 0.5;
                        float plane = p.y;
                        return min(sphere, plane);
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 1.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.96), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf3d,
                functionName: "sdPlane",
                signature: "float sdPlane(float3 p, float3 n, float h)",
                implementation: "return dot(p, normalize(n)) + h;",
                documentation: "Returns signed distance from point p to plane with normal n at height h."
            ),
            hints: [
                Hint(cost: 0, text: "A horizontal floor at y=0 is just: p.y (distance above the floor)"),
                Hint(cost: 0, text: "To place the sphere ON the floor, offset its center up by its radius"),
                Hint(cost: 1, text: "Use min(sphereSDF, planeSDF) to combine them"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float sceneSDF(float3 p) {
                        float sphere = length(p) - 0.5;  // ERROR: Sphere center should be at float3(0.0, 0.5, 0.0)
                        float plane = p.y;
                        return sphere;  // ERROR: Should be min(sphere, plane)
                    }
                    """),
                Hint(cost: 3, text: "float sphere = length(p - float3(0.0, 0.5, 0.0)) - 0.5; float plane = p.y; return min(sphere, plane);"),
            ],
            starterCode: """
                // Create a sphere sitting on a floor
                float sceneSDF(float3 p) {
                    // TODO: Sphere at y=0.5 with radius 0.5
                    // Hint: length(p - center) - radius
                    float sphere = 1.0;

                    // TODO: Floor at y=0
                    // Hint: p.y for a horizontal plane at y=0
                    float plane = 1.0;

                    // TODO: Combine with min()
                    return 1.0;
                }

                // Modified render helper with camera at y=1.0
                float3 calcNormal(float3 p) {
                    float2 e = float2(0.001, 0.0);
                    return normalize(float3(
                        sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                        sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                        sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                    ));
                }

                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float3 ro = float3(0.0, 1.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                }
                """,
            solution: """
                float sphere = length(p - float3(0.0, 0.5, 0.0)) - 0.5;
                float plane = p.y;
                return min(sphere, plane);
                """
        )
    }

    private func puzzle6_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 6, index: 4),
            title: "Torus",
            subtitle: "Donuts in 3D",
            description: """
                Time for a more interesting shape: the **torus** (donut)!

                A torus is defined by two radii:
                - **R**: distance from center to the tube center (the "big" radius)
                - **r**: radius of the tube itself (the "small" radius)

                ```
                float sdTorus(float3 p, float R, float r) {
                    float2 q = float2(length(p.xz) - R, p.y);
                    return length(q) - r;
                }
                ```

                The trick: first find distance to the ring (in xz plane), then find distance to the tube surface.

                Create a torus with R=0.5 (ring radius) and r=0.2 (tube radius).
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float2 q = float2(length(p.xz) - 0.5, p.y);
                        return length(q) - 0.2;
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.97), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf3d,
                functionName: "sdTorus",
                signature: "float sdTorus(float3 p, float R, float r)",
                implementation: "float2 q = float2(length(p.xz) - R, p.y); return length(q) - r;",
                documentation: "Returns signed distance from point p to a torus with ring radius R and tube radius r."
            ),
            hints: [
                Hint(cost: 0, text: "p.xz gives the horizontal position. length(p.xz) is the distance from the vertical axis"),
                Hint(cost: 0, text: "Subtracting R gives the distance to the ring centerline"),
                Hint(cost: 1, text: "float2 q = float2(length(p.xz) - R, p.y); then length(q) - r gives the tube distance"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float sceneSDF(float3 p) {
                        float2 q = float2(length(p.xz), p.y);  // ERROR: Missing - 0.5 after length(p.xz)
                        return length(q) - 0.2;
                    }
                    """),
                Hint(cost: 3, text: "float2 q = float2(length(p.xz) - 0.5, p.y); return length(q) - 0.2;"),
            ],
            starterCode: """
                // Write your torus SDF here
                float sceneSDF(float3 p) {
                    // Torus parameters
                    float R = 0.5;  // Ring radius (big)
                    float r = 0.2;  // Tube radius (small)

                    // TODO: Step 1 - Project to ring plane
                    // float2 q = float2(length(p.xz) - R, p.y);

                    // TODO: Step 2 - Distance to tube
                    // return length(q) - r;

                    return 1.0;  // Replace with torus SDF
                }

                \(world6RenderHelper)
                """,
            solution: """
                float2 q = float2(length(p.xz) - 0.5, p.y);
                return length(q) - 0.2;
                """
        )
    }

    private func puzzle6_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 6, index: 5),
            title: "Capsule",
            subtitle: "Pills and tubes",
            description: """
                A **capsule** (also called a "stadium" in 2D or "pill" shape) is a cylinder with hemispherical caps. It's defined by two endpoints and a radius.

                The SDF finds the closest point on the line segment, then measures distance to that point:

                ```
                float sdCapsule(float3 p, float3 a, float3 b, float r) {
                    float3 pa = p - a;
                    float3 ba = b - a;
                    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                    return length(pa - ba * h) - r;
                }
                ```

                The [`clamp()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=80) ensures we stay between the endpoints. The [`dot()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=85) projects the point onto the line.

                Create a vertical capsule from (0, -0.5, 0) to (0, 0.5, 0) with radius 0.3.
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float3 a = float3(0.0, -0.5, 0.0);
                        float3 b = float3(0.0, 0.5, 0.0);
                        float r = 0.3;
                        float3 pa = p - a;
                        float3 ba = b - a;
                        float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                        return length(pa - ba * h) - r;
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.97), tolerance: 0.02),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .sdf3d,
                functionName: "sdCapsule",
                signature: "float sdCapsule(float3 p, float3 a, float3 b, float r)",
                implementation: "float3 pa = p - a; float3 ba = b - a; float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0); return length(pa - ba * h) - r;",
                documentation: "Returns signed distance from point p to a capsule from a to b with radius r."
            ),
            hints: [
                Hint(cost: 0, text: "dot(pa, ba) / dot(ba, ba) projects point p onto line ab (as parameter 0-1)"),
                Hint(cost: 0, text: "clamp() keeps the projection between the endpoints"),
                Hint(cost: 1, text: "pa - ba * h gives the vector from the closest line point to p"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float sceneSDF(float3 p) {
                        float3 a = float3(0.0, -0.5, 0.0);
                        float3 b = float3(0.0, 0.5, 0.0);
                        float r = 0.3;
                        float3 pa = p - a;
                        float3 ba = b - a;
                        float h = dot(pa, ba) / dot(ba, ba);  // ERROR: Missing clamp(..., 0.0, 1.0)
                        return length(pa - ba * h) - r;
                    }
                    """),
                Hint(cost: 3, text: "float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0); return length(pa - ba * h) - r;"),
            ],
            starterCode: """
                // Write your capsule SDF here
                float sceneSDF(float3 p) {
                    // Capsule endpoints and radius
                    float3 a = float3(0.0, -0.5, 0.0);  // Bottom
                    float3 b = float3(0.0, 0.5, 0.0);   // Top
                    float r = 0.3;                      // Radius

                    // TODO: Implement capsule SDF
                    // Step 1: float3 pa = p - a;
                    // Step 2: float3 ba = b - a;
                    // Step 3: float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                    // Step 4: return length(pa - ba * h) - r;

                    return 1.0;  // Replace with capsule SDF
                }

                \(world6RenderHelper)
                """,
            solution: """
                float3 a = float3(0.0, -0.5, 0.0);
                float3 b = float3(0.0, 0.5, 0.0);
                float r = 0.3;
                float3 pa = p - a;
                float3 ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h) - r;
                """
        )
    }

    private func puzzle6_6() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 6, index: 6),
            title: "3D Operations",
            subtitle: "Combining shapes",
            description: """
                Now let's combine 3D shapes using the same operations from 2D!

                ```
                float opUnion(float d1, float d2) { return min(d1, d2); }
                float opSubtract(float d1, float d2) { return max(d1, -d2); }
                float opIntersect(float d1, float d2) { return max(d1, d2); }
                ```

                **Your challenge**: Create a sphere with a cylindrical hole through it!

                - Sphere: radius 0.6, centered at origin
                - Cylinder: use a 2D circle SDF on xz plane (infinite cylinder along y)
                - Subtract the cylinder from the sphere

                ```
                float cylinder = length(p.xz) - 0.25;  // Infinite cylinder along y-axis
                ```
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float sphere = length(p) - 0.6;
                        float cylinder = length(p.xz) - 0.25;
                        return max(sphere, -cylinder);
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float angle = u.time * 0.5;
                    float c = cos(angle);
                    float s = sin(angle);
                    ro = float3(ro.x * c - ro.z * s, ro.y, ro.x * s + ro.z * c);
                    rd = float3(rd.x * c - rd.z * s, rd.y, rd.x * s + rd.z * c);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0);
                        float amb = 0.2;
                        float3 col = float3(0.8, 0.6, 0.4) * (diff + amb);
                        return float4(col, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.96), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule"],
            unlocksPrimitive: nil,  // Reusing 2D operations concept
            hints: [
                Hint(cost: 0, text: "length(p.xz) creates an infinite cylinder along the y-axis"),
                Hint(cost: 0, text: "Subtraction is max(d1, -d2) - negate the shape you're cutting away"),
                Hint(cost: 1, text: "sphere = length(p) - 0.6; cylinder = length(p.xz) - 0.25; return max(sphere, -cylinder);"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float sceneSDF(float3 p) {
                        float sphere = length(p) - 0.6;
                        float cylinder = length(p.xz) - 0.25;
                        return min(sphere, cylinder);  // ERROR: Should be max(sphere, -cylinder) for subtraction
                    }
                    """),
                Hint(cost: 3, text: "float sphere = length(p) - 0.6; float cylinder = length(p.xz) - 0.25; return max(sphere, -cylinder);"),
            ],
            starterCode: """
                // Create a sphere with a cylindrical hole
                float sceneSDF(float3 p) {
                    // TODO: Sphere (radius 0.6)
                    float sphere = 1.0;

                    // TODO: Infinite cylinder along y-axis (radius 0.25)
                    // Hint: length(p.xz) - radius
                    float cylinder = 1.0;

                    // TODO: Subtract cylinder from sphere
                    // Hint: max(d1, -d2)
                    return 1.0;
                }

                \(world6RenderHelper)
                """,
            solution: """
                float sphere = length(p) - 0.6;
                float cylinder = length(p.xz) - 0.25;
                return max(sphere, -cylinder);
                """
        )
    }

    // MARK: - World 7: The Ray Marcher

    private func createWorld7() -> World {
        World(
            number: 7,
            title: "The Ray Marcher",
            description: "Master the art of sphere tracing! Learn how rays are cast, how the marching loop works, and how to build complete 3D scenes from scratch.",
            puzzles: [
                puzzle7_1(),
                puzzle7_2(),
                puzzle7_3(),
                puzzle7_4(),
                puzzle7_5(),
                puzzle7_6(),
            ]
        )
    }

    private func puzzle7_1() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 7, index: 1),
            title: "First Ray",
            subtitle: "Setting up ray origin and direction",
            description: """
                Time to understand what's been happening behind the scenes! **Raymarching** (or sphere tracing) renders 3D scenes by shooting rays from a camera.

                Every ray needs:
                - **Origin (ro)**: Where the camera is located
                - **Direction (rd)**: Which way the ray points

                ```
                float3 ro = float3(0.0, 0.0, 3.0);  // Camera at z=3
                float3 rd = normalize(float3(uv - 0.5, -1.0));  // Look toward -z
                ```

                The ray direction is derived from UV coordinates:
                - `uv - 0.5` centers the screen
                - The z component (-1.0) points into the scene
                - [`normalize()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=85) makes it a unit vector

                Visualize the ray direction as a color! Red = x, Green = y, Blue = -z (we flip z so forward is blue).
                """,
            reference: .animation(
                shader: """
                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float3 col = rd * 0.5 + 0.5;
                    col.z = -rd.z * 0.5 + 0.5;
                    return float4(col, 1.0);
                    """,
                duration: 0
            ),
            verification: .pixelPerfect,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .raymarching,
                functionName: "getRayDirection",
                signature: "float3 getRayDirection(float2 uv, float fov)",
                implementation: "return normalize(float3((uv - 0.5) * fov, -1.0));",
                documentation: "Returns normalized ray direction for given UV and field of view."
            ),
            hints: [
                Hint(cost: 0, text: "Ray direction comes from the UV: center it with (uv - 0.5)"),
                Hint(cost: 0, text: "normalize() makes the direction a unit vector"),
                Hint(cost: 1, text: "Visualize: col = rd * 0.5 + 0.5 (but flip z for the blue channel)"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = float3(uv - 0.5, -1.0);  // ERROR: Missing normalize()
                    float3 col = rd * 0.5 + 0.5;
                    col.z = -rd.z * 0.5 + 0.5;
                    return float4(col, 1.0);
                    """),
                Hint(cost: 3, text: "float3 rd = normalize(float3(uv - 0.5, -1.0)); float3 col = rd * 0.5 + 0.5; col.z = -rd.z * 0.5 + 0.5;"),
            ],
            starterCode: """
                // Visualize ray directions
                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Camera position (not used yet, just for setup)
                    float3 ro = float3(0.0, 0.0, 3.0);

                    // TODO: Calculate ray direction
                    // Step 1: float3 rd = normalize(float3(uv - 0.5, -1.0));
                    float3 rd = float3(0.0, 0.0, -1.0);  // Replace with proper calculation

                    // Visualize the direction as color
                    // Map from [-1,1] to [0,1] for display
                    float3 col = rd * 0.5 + 0.5;
                    col.z = -rd.z * 0.5 + 0.5;  // Flip z so "forward" is blue

                    return float4(col, 1.0);
                }
                """,
            solution: """
                float3 ro = float3(0.0, 0.0, 3.0);
                float3 rd = normalize(float3(uv - 0.5, -1.0));
                float3 col = rd * 0.5 + 0.5;
                col.z = -rd.z * 0.5 + 0.5;
                return float4(col, 1.0);
                """
        )
    }

    private func puzzle7_2() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 7, index: 2),
            title: "March Forward",
            subtitle: "The sphere tracing loop",
            description: """
                Now for the magic: **sphere tracing**!

                The key insight: an SDF tells us the safe distance to march. At any point, we can step forward by the SDF value without missing any surfaces.

                ```
                float t = 0.0;  // Distance traveled along ray
                for (int i = 0; i < 64; i++) {
                    float3 p = ro + rd * t;     // Current position
                    float d = sceneSDF(p);      // Distance to nearest surface
                    if (d < 0.001) break;       // Hit something!
                    t += d;                     // March forward
                    if (t > 20.0) break;        // Too far, stop
                }
                ```

                Write the complete raymarch loop! Color the sphere white, background black.
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        return length(p) - 0.8;
                    }

                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    float col = t < 20.0 ? 1.0 : 0.0;
                    return float4(col, col, col, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule", "getRayDirection"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .raymarching,
                functionName: "raymarch",
                signature: "float raymarch(float3 ro, float3 rd, int maxSteps, float maxDist)",
                implementation: "float t = 0.0; for (int i = 0; i < maxSteps; i++) { float d = sceneSDF(ro + rd * t); if (d < 0.001) return t; t += d; if (t > maxDist) break; } return -1.0;",
                documentation: "Raymarches the scene, returns hit distance or -1.0 if no hit."
            ),
            hints: [
                Hint(cost: 0, text: "The raymarch loop: calculate position (ro + rd * t), get SDF, step forward by SDF value"),
                Hint(cost: 0, text: "Stop when d < 0.001 (hit) or t > 20.0 (miss)"),
                Hint(cost: 1, text: "After the loop, t < 20.0 means we hit something"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += 1.0;  // ERROR: Should be t += d (step by SDF value, not constant!)
                        if (t > 20.0) break;
                    }
                    """),
                Hint(cost: 3, text: "t += d; (step by SDF value) ... float col = t < 20.0 ? 1.0 : 0.0;"),
            ],
            starterCode: """
                // Scene: sphere at origin
                float sceneSDF(float3 p) {
                    return length(p) - 0.8;
                }

                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Ray setup
                    float3 ro = float3(0.0, 0.0, 3.0);
                    float3 rd = normalize(float3(uv - 0.5, -1.0));

                    // TODO: Implement raymarch loop
                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);

                        // TODO: Check for hit (d < 0.001)

                        // TODO: Step forward by d

                        // TODO: Check for miss (t > 20.0)
                    }

                    // Color based on hit/miss
                    float col = 0.0;  // TODO: Set to 1.0 if hit (t < 20.0)

                    return float4(col, col, col, 1.0);
                }
                """,
            solution: """
                float t = 0.0;
                for (int i = 0; i < 64; i++) {
                    float3 p = ro + rd * t;
                    float d = sceneSDF(p);
                    if (d < 0.001) break;
                    t += d;
                    if (t > 20.0) break;
                }
                float col = t < 20.0 ? 1.0 : 0.0;
                return float4(col, col, col, 1.0);
                """
        )
    }

    private func puzzle7_3() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 7, index: 3),
            title: "Camera Control",
            subtitle: "The look-at matrix",
            description: """
                So far our camera points straight down -Z. Let's aim it anywhere with a **look-at matrix**!

                ```
                float3 lookAt(float3 ro, float3 target, float2 uv) {
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0,1,0), forward));
                    float3 up = cross(forward, right);
                    return normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);
                }
                ```

                The [`cross()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=85) product gives us perpendicular vectors:
                - **forward**: direction from camera to target
                - **right**: perpendicular to forward and world up
                - **up**: perpendicular to forward and right

                Create a scene where the camera orbits around a sphere, always looking at the center!
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        return length(p) - 0.8;
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    // Orbit camera
                    float angle = u.time * 0.5;
                    float3 ro = float3(sin(angle) * 3.0, 1.0, cos(angle) * 3.0);
                    float3 target = float3(0.0);

                    // Look-at camera
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0) * 0.8 + 0.2;
                        return float4(diff, diff, diff, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 12.56
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.96), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule", "getRayDirection", "raymarch"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .raymarching,
                functionName: "lookAt",
                signature: "float3x3 lookAt(float3 ro, float3 target)",
                implementation: "float3 f = normalize(target - ro); float3 r = normalize(cross(float3(0,1,0), f)); float3 u = cross(f, r); return float3x3(r, u, f);",
                documentation: "Creates a look-at camera matrix pointing from ro toward target."
            ),
            hints: [
                Hint(cost: 0, text: "forward = normalize(target - ro) points the camera at the target"),
                Hint(cost: 0, text: "cross(up, forward) gives right; cross(forward, right) gives the camera's up"),
                Hint(cost: 1, text: "rd = normalize(right * (uv.x-0.5) + up * (uv.y-0.5) + forward)"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float3 forward = normalize(target - ro);
                    float3 right = cross(float3(0.0, 1.0, 0.0), forward);  // ERROR: Missing normalize()
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);
                    """),
                Hint(cost: 3, text: "float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));"),
            ],
            starterCode: """
                float sceneSDF(float3 p) {
                    return length(p) - 0.8;
                }

                float3 calcNormal(float3 p) {
                    float2 e = float2(0.001, 0.0);
                    return normalize(float3(
                        sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                        sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                        sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                    ));
                }

                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Orbiting camera position
                    float angle = u.time * 0.5;
                    float3 ro = float3(sin(angle) * 3.0, 1.0, cos(angle) * 3.0);
                    float3 target = float3(0.0);

                    // TODO: Build look-at camera
                    // Step 1: forward = normalize(target - ro)
                    // Step 2: right = normalize(cross(float3(0,1,0), forward))
                    // Step 3: up = cross(forward, right)
                    // Step 4: rd = normalize(right*(uv.x-0.5) + up*(uv.y-0.5) + forward)
                    float3 rd = normalize(float3(uv - 0.5, -1.0));  // Replace with look-at

                    // Raymarch
                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    // Shade
                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0) * 0.8 + 0.2;
                        return float4(diff, diff, diff, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                }
                """,
            solution: """
                float3 forward = normalize(target - ro);
                float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                float3 up = cross(forward, right);
                float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);
                """
        )
    }

    private func puzzle7_4() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 7, index: 4),
            title: "Surface Normal",
            subtitle: "Gradient-based normals",
            description: """
                Lighting needs **surface normals** - vectors perpendicular to the surface. With SDFs, we compute them using the **gradient**!

                The gradient points in the direction of steepest increase. For an SDF, that's away from the surface - exactly what we need.

                ```
                float3 calcNormal(float3 p) {
                    float2 e = float2(0.001, 0.0);
                    return normalize(float3(
                        sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                        sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                        sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                    ));
                }
                ```

                We sample the SDF at 6 points around p and compute the difference. The pattern `e.xyy` means `(0.001, 0, 0)`.

                Implement the normal calculation and visualize it as color!
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float sphere = length(p) - 0.8;
                        float3 bp = abs(p) - float3(0.4);
                        float box = length(max(bp, 0.0)) + min(max(bp.x, max(bp.y, bp.z)), 0.0);
                        return min(sphere, box);
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float angle = u.time * 0.3;
                    float3 ro = float3(sin(angle) * 3.0, 0.5, cos(angle) * 3.0);
                    float3 target = float3(0.0);
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        return float4(n * 0.5 + 0.5, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                    """,
                duration: 20.94
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.96), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule", "getRayDirection", "raymarch", "lookAt"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .raymarching,
                functionName: "calcNormal",
                signature: "float3 calcNormal(float3 p)",
                implementation: "float2 e = float2(0.001, 0.0); return normalize(float3(sceneSDF(p+e.xyy)-sceneSDF(p-e.xyy), sceneSDF(p+e.yxy)-sceneSDF(p-e.yxy), sceneSDF(p+e.yyx)-sceneSDF(p-e.yyx)));",
                documentation: "Calculates surface normal at point p using gradient of SDF."
            ),
            hints: [
                Hint(cost: 0, text: "e.xyy = (0.001, 0, 0), e.yxy = (0, 0.001, 0), e.yyx = (0, 0, 0.001)"),
                Hint(cost: 0, text: "Sample SDF at p+e and p-e for each axis, subtract to get gradient"),
                Hint(cost: 1, text: "Visualize normal as color: n * 0.5 + 0.5 maps [-1,1] to [0,1]"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return float3(  // ERROR: Missing normalize()
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        );
                    }
                    """),
                Hint(cost: 3, text: "return normalize(float3(sceneSDF(p+e.xyy)-sceneSDF(p-e.xyy), ...));"),
            ],
            starterCode: """
                // Scene: sphere + box union
                float sceneSDF(float3 p) {
                    float sphere = length(p) - 0.8;
                    float3 bp = abs(p) - float3(0.4);
                    float box = length(max(bp, 0.0)) + min(max(bp.x, max(bp.y, bp.z)), 0.0);
                    return min(sphere, box);
                }

                // TODO: Implement calcNormal using gradient
                float3 calcNormal(float3 p) {
                    float2 e = float2(0.001, 0.0);

                    // TODO: Return normalized gradient
                    // Sample SDF at p+e.xyy, p-e.xyy, etc.
                    return float3(0.0, 1.0, 0.0);  // Replace with gradient calculation
                }

                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float angle = u.time * 0.3;
                    float3 ro = float3(sin(angle) * 3.0, 0.5, cos(angle) * 3.0);
                    float3 target = float3(0.0);
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        // Visualize normal as color
                        return float4(n * 0.5 + 0.5, 1.0);
                    }
                    return float4(0.1, 0.1, 0.15, 1.0);
                }
                """,
            solution: """
                return normalize(float3(
                    sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                    sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                    sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                ));
                """
        )
    }

    private func puzzle7_5() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 7, index: 5),
            title: "Depth Fog",
            subtitle: "Atmospheric effects",
            description: """
                Add **atmospheric fog** that fades objects based on distance! This creates depth and hides the far clipping plane.

                The simplest fog formula uses exponential falloff:

                ```
                float fog = exp(-t * density);           // Exponential fog
                color = mix(fogColor, color, fog);       // Blend with fog color
                ```

                A higher `density` means thicker fog. The [`exp()`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf#page=70) function ensures smooth falloff.

                Add fog to the scene with density 0.15 and a blue-gray fog color (0.5, 0.6, 0.7).
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float sphere = length(p - float3(0.0, 0.0, 0.0)) - 0.8;
                        float sphere2 = length(p - float3(2.0, 0.0, -2.0)) - 0.6;
                        float sphere3 = length(p - float3(-1.5, 0.0, -3.0)) - 0.5;
                        float plane = p.y + 0.8;
                        return min(min(min(sphere, sphere2), sphere3), plane);
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float3 ro = float3(0.0, 1.0, 4.0);
                    float3 target = float3(0.0, 0.0, -1.0);
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    float3 fogColor = float3(0.5, 0.6, 0.7);

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0) * 0.8 + 0.2;
                        float3 col = float3(0.9, 0.8, 0.7) * diff;
                        float fog = exp(-t * 0.15);
                        col = mix(fogColor, col, fog);
                        return float4(col, 1.0);
                    }
                    return float4(fogColor, 1.0);
                    """,
                duration: 0
            ),
            verification: .standard,
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule", "getRayDirection", "raymarch", "lookAt", "calcNormal"],
            unlocksPrimitive: PrimitiveUnlock(
                category: .raymarching,
                functionName: "applyFog",
                signature: "float3 applyFog(float3 col, float3 fogCol, float dist, float density)",
                implementation: "float fog = exp(-dist * density); return mix(fogCol, col, fog);",
                documentation: "Applies exponential distance fog to a color."
            ),
            hints: [
                Hint(cost: 0, text: "exp(-t * density) gives fog factor: 1 at t=0, approaching 0 as t increases"),
                Hint(cost: 0, text: "mix(fogColor, objectColor, fog) blends based on fog factor"),
                Hint(cost: 1, text: "Also set background color to fogColor so distant objects blend seamlessly"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked errors
                    float fog = t * 0.15;  // ERROR: Should be exp(-t * 0.15)
                    col = mix(col, fogColor, fog);  // ERROR: Arguments in wrong order - should be mix(fogColor, col, fog)
                    """),
                Hint(cost: 3, text: "float fog = exp(-t * 0.15); col = mix(fogColor, col, fog);"),
            ],
            starterCode: """
                float sceneSDF(float3 p) {
                    float sphere = length(p - float3(0.0, 0.0, 0.0)) - 0.8;
                    float sphere2 = length(p - float3(2.0, 0.0, -2.0)) - 0.6;
                    float sphere3 = length(p - float3(-1.5, 0.0, -3.0)) - 0.5;
                    float plane = p.y + 0.8;
                    return min(min(min(sphere, sphere2), sphere3), plane);
                }

                float3 calcNormal(float3 p) {
                    float2 e = float2(0.001, 0.0);
                    return normalize(float3(
                        sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                        sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                        sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                    ));
                }

                float4 userFragment(float2 uv, constant Uniforms& u) {
                    float3 ro = float3(0.0, 1.0, 4.0);
                    float3 target = float3(0.0, 0.0, -1.0);
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 20.0) break;
                    }

                    float3 fogColor = float3(0.5, 0.6, 0.7);

                    if (t < 20.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0) * 0.8 + 0.2;
                        float3 col = float3(0.9, 0.8, 0.7) * diff;

                        // TODO: Apply fog
                        // Step 1: float fog = exp(-t * 0.15);
                        // Step 2: col = mix(fogColor, col, fog);

                        return float4(col, 1.0);
                    }
                    return float4(fogColor, 1.0);  // Background matches fog color
                }
                """,
            solution: """
                float fog = exp(-t * 0.15);
                col = mix(fogColor, col, fog);
                """
        )
    }

    private func puzzle7_6() -> Puzzle {
        Puzzle(
            id: PuzzleID(world: 7, index: 6),
            title: "Infinite Floor",
            subtitle: "A complete scene",
            description: """
                Let's build a complete scene! Combine everything:
                - Orbiting camera with look-at
                - Multiple objects
                - Surface normals for lighting
                - Depth fog

                Create a scene with:
                - A sphere at the origin (radius 0.8)
                - An infinite floor at y = -0.8
                - A checkerboard pattern on the floor

                For the checkerboard, use position to determine color:
                ```
                float check = step(0.5, fract(floor(p.x) + floor(p.z)) * 0.5) * 0.5 + 0.5;
                ```
                """,
            reference: .animation(
                shader: """
                    float sceneSDF(float3 p) {
                        float sphere = length(p) - 0.8;
                        float plane = p.y + 0.8;
                        return min(sphere, plane);
                    }

                    float3 calcNormal(float3 p) {
                        float2 e = float2(0.001, 0.0);
                        return normalize(float3(
                            sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                            sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                            sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                        ));
                    }

                    float angle = u.time * 0.3;
                    float3 ro = float3(sin(angle) * 4.0, 2.0, cos(angle) * 4.0);
                    float3 target = float3(0.0);
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 30.0) break;
                    }

                    float3 fogColor = float3(0.5, 0.6, 0.7);

                    if (t < 30.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0) * 0.8 + 0.2;

                        float3 col;
                        if (p.y < -0.79) {
                            float check = step(0.5, fract((floor(p.x) + floor(p.z)) * 0.5)) * 0.5 + 0.5;
                            col = float3(check) * diff;
                        } else {
                            col = float3(0.9, 0.6, 0.4) * diff;
                        }

                        float fog = exp(-t * 0.05);
                        col = mix(fogColor, col, fog);
                        return float4(col, 1.0);
                    }
                    return float4(fogColor, 1.0);
                    """,
                duration: 20.94
            ),
            verification: VerificationSettings(mode: .animation(frameCount: 20, threshold: 0.95), tolerance: 0.03),
            availablePrimitives: ["sdCircle", "smoothEdge", "sdBox", "sdRoundedBox", "opUnion", "opSubtract", "opSmoothUnion", "sdSegment", "palette", "hsv2rgb", "colorRamp", "blendScreen", "hash", "valueNoise", "voronoi", "fbm", "checker", "easeInOut", "orbit2d", "wave", "sdSphere", "sdBox3d", "sdPlane", "sdTorus", "sdCapsule", "getRayDirection", "raymarch", "lookAt", "calcNormal", "applyFog"],
            unlocksPrimitive: nil,
            hints: [
                Hint(cost: 0, text: "Check if p.y is near the floor (< -0.79) to apply checkerboard"),
                Hint(cost: 0, text: "Use floor(p.x) + floor(p.z) to create the checker pattern"),
                Hint(cost: 1, text: "float check = step(0.5, fract((floor(p.x) + floor(p.z)) * 0.5)) * 0.5 + 0.5;"),
                Hint(cost: 2, text: """
                    // GUIDED SOLUTION - Fix the marked error
                    if (p.y < -0.79) {
                        float check = fract((p.x + p.z) * 0.5);  // ERROR: Should use floor(p.x) + floor(p.z) for crisp squares
                        col = float3(check) * diff;
                    }
                    """),
                Hint(cost: 3, text: "float check = step(0.5, fract((floor(p.x) + floor(p.z)) * 0.5)) * 0.5 + 0.5; col = float3(check) * diff;"),
            ],
            starterCode: """
                float sceneSDF(float3 p) {
                    float sphere = length(p) - 0.8;
                    float plane = p.y + 0.8;
                    return min(sphere, plane);
                }

                float3 calcNormal(float3 p) {
                    float2 e = float2(0.001, 0.0);
                    return normalize(float3(
                        sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
                        sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
                        sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
                    ));
                }

                float4 userFragment(float2 uv, constant Uniforms& u) {
                    // Orbiting camera
                    float angle = u.time * 0.3;
                    float3 ro = float3(sin(angle) * 4.0, 2.0, cos(angle) * 4.0);
                    float3 target = float3(0.0);
                    float3 forward = normalize(target - ro);
                    float3 right = normalize(cross(float3(0.0, 1.0, 0.0), forward));
                    float3 up = cross(forward, right);
                    float3 rd = normalize(right * (uv.x - 0.5) + up * (uv.y - 0.5) + forward);

                    // Raymarch
                    float t = 0.0;
                    for (int i = 0; i < 64; i++) {
                        float3 p = ro + rd * t;
                        float d = sceneSDF(p);
                        if (d < 0.001) break;
                        t += d;
                        if (t > 30.0) break;
                    }

                    float3 fogColor = float3(0.5, 0.6, 0.7);

                    if (t < 30.0) {
                        float3 p = ro + rd * t;
                        float3 n = calcNormal(p);
                        float3 lightDir = normalize(float3(1.0, 1.0, 1.0));
                        float diff = max(dot(n, lightDir), 0.0) * 0.8 + 0.2;

                        float3 col;
                        // TODO: If on floor (p.y < -0.79), apply checkerboard
                        // Else apply orange sphere color
                        if (p.y < -0.79) {
                            // TODO: Checkerboard pattern
                            col = float3(0.5) * diff;  // Replace with checker
                        } else {
                            col = float3(0.9, 0.6, 0.4) * diff;
                        }

                        // Fog
                        float fog = exp(-t * 0.05);
                        col = mix(fogColor, col, fog);
                        return float4(col, 1.0);
                    }
                    return float4(fogColor, 1.0);
                }
                """,
            solution: """
                float check = step(0.5, fract((floor(p.x) + floor(p.z)) * 0.5)) * 0.5 + 0.5;
                col = float3(check) * diff;
                """
        )
    }
}
