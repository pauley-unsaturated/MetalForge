import SwiftUI

/// Main puzzle solving interface
struct PuzzleView: View {
    @Environment(AppState.self) private var appState
    let puzzleID: PuzzleID

    @State private var userRenderer: MetalRenderer?
    @State private var targetRenderer: MetalRenderer?
    @State private var comparator: PixelComparator?

    @State private var isCompiling = false
    @State private var showingSolution = false

    var puzzle: Puzzle? {
        PuzzleManager.shared.puzzle(for: puzzleID)
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.08, green: 0.08, blue: 0.1)
                .ignoresSafeArea()

            if let puzzle = puzzle {
                VStack(spacing: 0) {
                    // Header
                    puzzleHeader(puzzle)

                    // Main content
                    HSplitView {
                        // Left: Previews
                        previewPane(puzzle)
                            .frame(minWidth: 400)

                        // Right: Code editor
                        editorPane(puzzle)
                            .frame(minWidth: 500)
                    }
                }
            } else {
                Text("Puzzle not found")
                    .foregroundColor(.gray)
            }
        }
        .foregroundColor(.white)
        .onAppear {
            setupRenderers()
            loadPuzzle()
        }
        .onChange(of: puzzleID) { _, _ in
            loadPuzzle()
        }
    }

    private func loadPuzzle() {
        if let puzzle = puzzle {
            appState.userCode = puzzle.starterCode
            appState.verificationResult = nil
            appState.lastCompilationResult = nil
            appState.currentHintIndex = 0
            compileShader()
            compileReference()
        }
    }

    // MARK: - Header

    private var worldPuzzles: [Puzzle] {
        PuzzleManager.shared.puzzles(forWorld: puzzleID.world)
    }

    private func isPuzzleAccessible(_ puzzle: Puzzle) -> Bool {
        // Can access if: completed, or is the first unsolved puzzle
        if appState.completedPuzzles.contains(puzzle.id) {
            return true
        }
        // First unsolved puzzle is accessible
        let firstUnsolved = worldPuzzles.first { !appState.completedPuzzles.contains($0.id) }
        return puzzle.id == firstUnsolved?.id
    }

    private func puzzleHeader(_ puzzle: Puzzle) -> some View {
        HStack {
            // Back button
            Button(action: { appState.navigateBack() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.orange)

            Spacer()

            // Puzzle selector
            Menu {
                ForEach(worldPuzzles) { p in
                    Button(action: {
                        if isPuzzleAccessible(p) {
                            appState.loadPuzzle(p.id)
                        }
                    }) {
                        HStack {
                            Text("\(p.id.index). \(p.title)")
                            Spacer()
                            if appState.completedPuzzles.contains(p.id) {
                                Image(systemName: "checkmark.circle.fill")
                            } else if p.id == puzzleID {
                                Image(systemName: "circle.fill")
                            }
                        }
                    }
                    .disabled(!isPuzzleAccessible(p))
                }
            } label: {
                HStack(spacing: 6) {
                    VStack(spacing: 2) {
                        Text("World \(puzzleID.world): \(worldTitle)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 4) {
                            Text(puzzle.title)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .menuStyle(.borderlessButton)

            Spacer()

            // Progress indicator
            HStack(spacing: 8) {
                if appState.completedPuzzles.contains(puzzleID) {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                // Puzzle progress in world
                Text("\(worldPuzzles.filter { appState.completedPuzzles.contains($0.id) }.count)/\(worldPuzzles.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }

    private var worldTitle: String {
        switch puzzleID.world {
        case 1: return "First Light"
        case 2: return "Shape Language"
        default: return "World \(puzzleID.world)"
        }
    }

    // MARK: - Preview Pane

    private func previewPane(_ puzzle: Puzzle) -> some View {
        VStack(spacing: 16) {
            // Preview comparison
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("YOUR OUTPUT")
                        .font(.caption.bold())
                        .foregroundColor(.gray)

                    ShaderPreviewView(renderer: $userRenderer, size: CGSize(width: 256, height: 256))
                        .frame(width: 256, height: 256)
                }

                VStack(spacing: 8) {
                    Text("TARGET")
                        .font(.caption.bold())
                        .foregroundColor(.gray)

                    ShaderPreviewView(renderer: $targetRenderer, size: CGSize(width: 256, height: 256))
                        .frame(width: 256, height: 256)
                }
            }
            .padding(.top, 20)

            // Playback controls
            HStack(spacing: 16) {
                Button(action: { appState.isPlaying.toggle() }) {
                    Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.plain)

                Button(action: { userRenderer?.resetTime(); targetRenderer?.resetTime() }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.plain)

                Text(String(format: "Time: %.2f", userRenderer?.isPlaying == true ? appState.currentTime : 0))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.gray)
            }

            // Verification result
            verificationStatus

            Divider()
                .background(Color.white.opacity(0.1))

            // Puzzle description
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)

                    Text(puzzle.description)
                        .font(.body)
                        .foregroundColor(.gray)

                    // Hints
                    if !puzzle.hints.isEmpty {
                        hintsSection(puzzle)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.2))
    }

    @ViewBuilder
    private var verificationStatus: some View {
        if let result = appState.verificationResult {
            HStack(spacing: 12) {
                if result.passed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text("Solved!")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("\(Int(result.percentage))% match")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text("Not quite...")
                            .font(.headline)
                        Text("\(Int(result.percentage))% match")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if result.passed {
                    Button("Next Puzzle") {
                        goToNextPuzzle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(result.passed ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
        } else {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
                Text("Make changes and submit to verify")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }

    private func hintsSection(_ puzzle: Puzzle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hints")
                    .font(.headline)

                Spacer()

                if appState.currentHintIndex < puzzle.hints.count - 1 {
                    Button("Next Hint") {
                        appState.nextHint()
                    }
                    .font(.caption)
                }
            }

            ForEach(0...min(appState.currentHintIndex, puzzle.hints.count - 1), id: \.self) { index in
                let hint = puzzle.hints[index]
                HStack(alignment: .top, spacing: 8) {
                    Text("💡")
                    Text(hint.text)
                        .font(.callout)
                        .foregroundColor(.orange.opacity(0.9))
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Editor Pane

    private func editorPane(_ puzzle: Puzzle) -> some View {
        VStack(spacing: 0) {
            // Error display
            if let result = appState.lastCompilationResult, !result.success {
                errorDisplay(result.errors)
            }

            // Code editor
            CodeEditorView(
                code: Binding(
                    get: { appState.userCode },
                    set: { appState.userCode = $0 }
                ),
                errors: appState.lastCompilationResult?.errors ?? [],
                fontSize: appState.editorFontSize,
                showLineNumbers: appState.showLineNumbers,
                onCompile: compileShader
            )

            // Bottom toolbar
            editorToolbar(puzzle)
        }
    }

    private func errorDisplay(_ errors: [ShaderError]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(errors.prefix(3)) { error in
                HStack(spacing: 8) {
                    Image(systemName: error.isWarning ? "exclamationmark.triangle.fill" : "xmark.circle.fill")
                        .foregroundColor(error.isWarning ? .orange : .red)

                    Text("Line \(error.line): \(error.message)")
                        .font(.caption)
                        .lineLimit(1)
                }
            }

            if errors.count > 3 {
                Text("... and \(errors.count - 3) more errors")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
    }

    private func editorToolbar(_ puzzle: Puzzle) -> some View {
        HStack(spacing: 12) {
            // Documentation
            Button(action: { /* Show docs */ }) {
                Label("Docs", systemImage: "book")
            }
            .buttonStyle(.plain)

            // Primitives library
            Button(action: { /* Show primitives */ }) {
                Label("Primitives", systemImage: "cube")
            }
            .buttonStyle(.plain)

            Spacer()

            // Reset
            Button(action: { appState.resetPuzzle() }) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.plain)

            // Compile
            Button(action: compileShader) {
                Label("Compile", systemImage: "hammer")
            }
            .buttonStyle(.plain)
            .keyboardShortcut("b", modifiers: .command)

            // Submit
            Button(action: submitSolution) {
                Label("Submit", systemImage: "checkmark.circle")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Actions

    private func setupRenderers() {
        userRenderer = MetalRenderer()
        targetRenderer = MetalRenderer()

        if let device = userRenderer?.device {
            comparator = PixelComparator(device: device)
        }
    }

    private func compileShader() {
        guard let renderer = userRenderer else { return }

        isCompiling = true

        // Get available primitives based on progress
        let availablePrimitives = Array(appState.unlockedPrimitives)

        let result = renderer.compileShader(appState.userCode, primitives: availablePrimitives)
        appState.lastCompilationResult = result

        isCompiling = false
    }

    private func compileReference() {
        guard let renderer = targetRenderer,
              let puzzle = puzzle else { return }

        let referenceCode = """
            float4 userFragment(float2 uv, constant Uniforms& u) {
                \(puzzle.solution)
            }
            """

        _ = renderer.compileShader(referenceCode)
    }

    private func submitSolution() {
        compileShader()

        guard let result = appState.lastCompilationResult, result.success else {
            return
        }

        // Create textures and compare
        guard let userRenderer = userRenderer,
              let targetRenderer = targetRenderer,
              let comparator = comparator else {
            return
        }

        // Render both to textures
        guard let userTexture = userRenderer.createReadableTexture(width: 512, height: 512),
              let targetTexture = targetRenderer.createReadableTexture(width: 512, height: 512) else {
            return
        }

        userRenderer.render(to: userTexture)
        targetRenderer.render(to: targetTexture)

        // Compare
        let verifyResult = comparator.compare(
            userTexture: userTexture,
            referenceTexture: targetTexture
        )

        appState.verificationResult = verifyResult

        if verifyResult.passed {
            appState.completePuzzle(puzzleID)
        }
    }

    private func goToNextPuzzle() {
        if let nextPuzzle = PuzzleManager.shared.nextPuzzle(after: puzzleID) {
            appState.loadPuzzle(nextPuzzle.id)
        } else {
            appState.navigateTo(.worldSelect)
        }
    }
}

#Preview {
    PuzzleView(puzzleID: PuzzleID(world: 1, index: 1))
        .environment(AppState())
        .frame(width: 1200, height: 800)
}
