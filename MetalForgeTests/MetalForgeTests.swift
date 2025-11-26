import Testing
@testable import MetalForge

@Suite("Puzzle Tests")
struct PuzzleTests {
    @Test("Puzzle IDs are unique")
    func puzzleIDsAreUnique() async {
        let manager = await PuzzleManager.shared
        let worlds = await manager.allWorlds

        var seenIDs = Set<String>()
        for world in worlds {
            for puzzle in world.puzzles {
                let idString = puzzle.id.stringID
                #expect(!seenIDs.contains(idString), "Duplicate puzzle ID: \(idString)")
                seenIDs.insert(idString)
            }
        }
    }

    @Test("All puzzles have valid hints")
    func puzzlesHaveHints() async {
        let manager = await PuzzleManager.shared
        let worlds = await manager.allWorlds

        for world in worlds {
            for puzzle in world.puzzles {
                #expect(!puzzle.hints.isEmpty, "Puzzle \(puzzle.id) has no hints")
            }
        }
    }

    @Test("All puzzles have solutions")
    func puzzlesHaveSolutions() async {
        let manager = await PuzzleManager.shared
        let worlds = await manager.allWorlds

        for world in worlds {
            for puzzle in world.puzzles {
                #expect(!puzzle.solution.isEmpty, "Puzzle \(puzzle.id) has no solution")
            }
        }
    }
}

@Suite("Shader Template Tests")
struct ShaderTemplateTests {
    @Test("Default shader compiles")
    func defaultShaderCompiles() {
        let shader = ShaderTemplate.buildFullShader(userCode: ShaderTemplate.defaultUserCode)
        #expect(shader.contains("fragmentShader"))
        #expect(shader.contains("vertexShader"))
        #expect(shader.contains("userFragment"))
    }

    @Test("Reference shader builds correctly")
    func referenceShaderBuilds() {
        let solution = "return float4(1.0, 0.0, 0.0, 1.0);"
        let shader = ShaderTemplate.buildReferenceShader(solution: solution)
        #expect(shader.contains(solution))
    }
}

@Suite("Primitive Library Tests")
struct PrimitiveLibraryTests {
    @Test("Primitives are registered")
    func primitivesExist() async {
        let library = await PrimitiveLibrary.shared
        let primitives = await library.allPrimitives

        #expect(!primitives.isEmpty, "No primitives registered")
    }

    @Test("SDF primitives have implementations")
    func sdfPrimitivesHaveCode() async {
        let library = await PrimitiveLibrary.shared

        let sdCircle = await library.implementation(for: "sdCircle")
        #expect(sdCircle != nil, "sdCircle not found")
        #expect(sdCircle?.contains("length") == true)

        let sdBox = await library.implementation(for: "sdBox")
        #expect(sdBox != nil, "sdBox not found")
    }
}

@Suite("Verification Tests")
struct VerificationTests {
    @Test("Verification result percentage calculation")
    func verificationPercentage() {
        let result = VerificationResult(
            passed: true,
            similarity: 0.95,
            mismatchCount: 1000,
            totalPixels: 262144,
            maxDifference: 0.05
        )

        #expect(result.percentage == 95.0)
    }

    @Test("Failed result returns zero similarity")
    func failedResult() {
        let result = VerificationResult.failed
        #expect(result.passed == false)
        #expect(result.similarity == 0)
    }
}
