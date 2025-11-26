import SwiftUI
import Observation

/// Central application state manager
@Observable
@MainActor
final class AppState {
    // MARK: - Navigation
    enum Screen: Hashable {
        case mainMenu
        case worldSelect
        case puzzle(PuzzleID)
        case studio
    }

    var currentScreen: Screen = .mainMenu
    var navigationPath: [Screen] = []

    // MARK: - Puzzle State
    var currentPuzzle: Puzzle?
    var userCode: String = ""
    var lastCompilationResult: CompilationResult?
    var verificationResult: VerificationResult?

    // MARK: - Progress
    var unlockedWorlds: Set<Int> = [1]
    var completedPuzzles: Set<PuzzleID> = []
    var unlockedPrimitives: Set<String> = []

    // MARK: - UI State
    var showExportDialog = false
    var showHint = false
    var currentHintIndex = 0
    var isPlaying = true
    var currentTime: Float = 0

    // MARK: - Editor State
    var editorFontSize: CGFloat = 14
    var showLineNumbers = true

    // MARK: - Actions

    func navigateTo(_ screen: Screen) {
        navigationPath.append(screen)
        currentScreen = screen
    }

    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
            currentScreen = navigationPath.last ?? .mainMenu
        }
    }

    func loadPuzzle(_ id: PuzzleID) {
        if let puzzle = PuzzleManager.shared.puzzle(for: id) {
            currentPuzzle = puzzle
            userCode = puzzle.starterCode
            lastCompilationResult = nil
            verificationResult = nil
            showHint = false
            currentHintIndex = 0
            currentTime = 0
            navigateTo(.puzzle(id))
        }
    }

    func completePuzzle(_ id: PuzzleID) {
        completedPuzzles.insert(id)

        // Unlock primitive if puzzle awards one
        if let puzzle = PuzzleManager.shared.puzzle(for: id),
           let primitive = puzzle.unlocksPrimitive {
            unlockedPrimitives.insert(primitive.functionName)
        }

        // Check if world is complete and unlock next
        let worldPuzzles = PuzzleManager.shared.puzzles(forWorld: id.world)
        let worldComplete = worldPuzzles.allSatisfy { completedPuzzles.contains($0.id) }
        if worldComplete {
            unlockedWorlds.insert(id.world + 1)
        }

        saveProgress()
    }

    func createNewShader() {
        currentPuzzle = nil
        userCode = Puzzle.defaultStarterCode
        lastCompilationResult = nil
        verificationResult = nil
        navigateTo(.studio)
    }

    func resetPuzzle() {
        if let puzzle = currentPuzzle {
            userCode = puzzle.starterCode
            lastCompilationResult = nil
            verificationResult = nil
        }
    }

    func nextHint() {
        guard let puzzle = currentPuzzle else { return }
        if currentHintIndex < puzzle.hints.count - 1 {
            currentHintIndex += 1
        }
        showHint = true
    }

    // MARK: - Persistence

    private func saveProgress() {
        let progress = PlayerProgress(
            completedPuzzles: completedPuzzles,
            unlockedPrimitives: unlockedPrimitives,
            unlockedWorlds: unlockedWorlds
        )
        PlayerProgress.save(progress)
    }

    func loadProgress() {
        if let progress = PlayerProgress.load() {
            completedPuzzles = progress.completedPuzzles
            unlockedPrimitives = progress.unlockedPrimitives
            unlockedWorlds = progress.unlockedWorlds
        }
    }
}

/// Player progress data for persistence
struct PlayerProgress: Codable {
    var completedPuzzles: Set<PuzzleID>
    var unlockedPrimitives: Set<String>
    var unlockedWorlds: Set<Int>

    static func save(_ progress: PlayerProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: "playerProgress")
        }
    }

    static func load() -> PlayerProgress? {
        guard let data = UserDefaults.standard.data(forKey: "playerProgress"),
              let progress = try? JSONDecoder().decode(PlayerProgress.self, from: data) else {
            return nil
        }
        return progress
    }
}

/// Result of shader compilation
struct CompilationResult {
    let success: Bool
    let errors: [ShaderError]
    let warnings: [ShaderError]
    let compilationTime: TimeInterval
}

/// Shader compilation error with location info
struct ShaderError: Identifiable {
    let id = UUID()
    let line: Int
    let column: Int
    let message: String
    let isWarning: Bool
}
