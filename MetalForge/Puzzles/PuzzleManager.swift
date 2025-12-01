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
}
