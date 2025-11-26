import SwiftUI

/// Main content view that handles navigation between screens
struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .mainMenu:
                MainMenuView()
            case .worldSelect:
                WorldSelectView()
            case .puzzle(let id):
                PuzzleView(puzzleID: id)
            case .studio:
                StudioView()
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .onAppear {
            appState.loadProgress()
        }
    }
}

/// Main menu screen
struct MainMenuView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Text("METALFORGE")
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Learn Metal Shaders Through Puzzles")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Menu buttons
                VStack(spacing: 16) {
                    MenuButton(title: "Start Journey", icon: "play.fill") {
                        appState.navigateTo(.worldSelect)
                    }

                    MenuButton(title: "Studio Mode", icon: "paintbrush.fill") {
                        appState.createNewShader()
                    }

                    MenuButton(title: "Primitive Library", icon: "books.vertical.fill") {
                        // TODO: Show primitive library
                    }
                }

                Spacer()

                // Progress summary
                if !appState.completedPuzzles.isEmpty {
                    HStack(spacing: 20) {
                        ProgressBadge(
                            value: appState.completedPuzzles.count,
                            label: "Puzzles Solved"
                        )
                        ProgressBadge(
                            value: appState.unlockedPrimitives.count,
                            label: "Primitives Unlocked"
                        )
                    }
                    .padding(.bottom, 40)
                }
            }
            .padding(60)
        }
    }
}

/// Styled menu button
struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title2.bold())
            }
            .frame(width: 280, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.white)
    }
}

/// Progress badge for menu
struct ProgressBadge: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

/// World selection screen
struct WorldSelectView: View {
    @Environment(AppState.self) private var appState

    let worlds = PuzzleManager.shared.allWorlds

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { appState.navigateBack() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.orange)

                    Spacer()

                    Text("Select World")
                        .font(.title.bold())

                    Spacer()

                    // Balance the back button
                    Color.clear.frame(width: 60)
                }
                .padding()
                .background(Color.black.opacity(0.3))

                // World grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
                    ], spacing: 20) {
                        ForEach(worlds) { world in
                            WorldCard(world: world)
                        }
                    }
                    .padding(30)
                }
            }
        }
        .foregroundColor(.white)
    }
}

/// Card representing a world
struct WorldCard: View {
    @Environment(AppState.self) private var appState
    let world: World

    var isUnlocked: Bool {
        appState.unlockedWorlds.contains(world.number)
    }

    var completedCount: Int {
        world.puzzles.filter { appState.completedPuzzles.contains($0.id) }.count
    }

    var body: some View {
        Button(action: {
            if isUnlocked, let firstPuzzle = world.puzzles.first {
                appState.loadPuzzle(firstPuzzle.id)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("World \(world.number)")
                        .font(.caption.bold())
                        .foregroundColor(.orange)

                    Spacer()

                    if isUnlocked {
                        Text("\(completedCount)/\(world.puzzles.count)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }

                Text(world.title)
                    .font(.title2.bold())
                    .foregroundColor(isUnlocked ? .white : .gray)

                Text(world.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                // Progress bar
                if isUnlocked {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * CGFloat(completedCount) / CGFloat(max(1, world.puzzles.count)))
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding(20)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isUnlocked ? 0.05 : 0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(isUnlocked ? 0.1 : 0.05), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

/// Settings view
struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section("Editor") {
                Picker("Font Size", selection: Binding(
                    get: { appState.editorFontSize },
                    set: { appState.editorFontSize = $0 }
                )) {
                    Text("Small (12)").tag(CGFloat(12))
                    Text("Medium (14)").tag(CGFloat(14))
                    Text("Large (16)").tag(CGFloat(16))
                    Text("Extra Large (18)").tag(CGFloat(18))
                }

                Toggle("Show Line Numbers", isOn: Binding(
                    get: { appState.showLineNumbers },
                    set: { appState.showLineNumbers = $0 }
                ))
            }

            Section("Progress") {
                LabeledContent("Puzzles Completed") {
                    Text("\(appState.completedPuzzles.count)")
                }

                LabeledContent("Primitives Unlocked") {
                    Text("\(appState.unlockedPrimitives.count)")
                }

                Button("Reset All Progress", role: .destructive) {
                    appState.completedPuzzles.removeAll()
                    appState.unlockedPrimitives.removeAll()
                    appState.unlockedWorlds = [1]
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
