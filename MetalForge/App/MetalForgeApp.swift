import SwiftUI

/// MetalForge - A Shader Puzzle Game & Creative Tool
/// Teaches Metal shader programming through progressively challenging puzzles
@main
struct MetalForgeApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1400, height: 900)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Shader") {
                    appState.createNewShader()
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(after: .saveItem) {
                Button("Export Image...") {
                    appState.showExportDialog = true
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
