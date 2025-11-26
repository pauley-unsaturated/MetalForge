import SwiftUI

/// Free-form shader creation environment
struct StudioView: View {
    @Environment(AppState.self) private var appState

    @State private var renderer: MetalRenderer?
    @State private var showExportSheet = false
    @State private var exportSettings = ImageExporter.ExportSettings()

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                studioHeader

                // Main content
                HSplitView {
                    // Left: Preview
                    previewPane
                        .frame(minWidth: 400)

                    // Right: Editor
                    editorPane
                        .frame(minWidth: 500)
                }
            }
        }
        .foregroundColor(.white)
        .onAppear {
            setupRenderer()
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(
                settings: $exportSettings,
                renderer: renderer,
                isPresented: $showExportSheet
            )
        }
    }

    // MARK: - Header

    private var studioHeader: some View {
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

            Text("Studio Mode")
                .font(.headline)

            Spacer()

            HStack(spacing: 12) {
                Button(action: { showExportSheet = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Preview Pane

    private var previewPane: some View {
        VStack(spacing: 16) {
            // Large preview
            ShaderPreviewView(renderer: $renderer, size: CGSize(width: 512, height: 512))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

            // Playback controls
            HStack(spacing: 16) {
                Button(action: { appState.isPlaying.toggle() }) {
                    Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                Button(action: { renderer?.resetTime() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                Spacer()

                // Resolution info
                Text("512 × 512")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.black.opacity(0.2))
    }

    // MARK: - Editor Pane

    private var editorPane: some View {
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

            // Toolbar
            editorToolbar
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
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
    }

    private var editorToolbar: some View {
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

            // Compile
            Button(action: compileShader) {
                Label("Compile", systemImage: "hammer")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .keyboardShortcut("b", modifiers: .command)
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Actions

    private func setupRenderer() {
        renderer = MetalRenderer()
        compileShader()
    }

    private func compileShader() {
        guard let renderer = renderer else { return }

        let availablePrimitives = Array(appState.unlockedPrimitives)
        let result = renderer.compileShader(appState.userCode, primitives: availablePrimitives)
        appState.lastCompilationResult = result
    }
}

/// Export dialog sheet
struct ExportSheet: View {
    @Binding var settings: ImageExporter.ExportSettings
    var renderer: MetalRenderer?
    @Binding var isPresented: Bool

    @State private var selectedPreset = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Image")
                .font(.title2.bold())

            Form {
                Section("Size") {
                    Picker("Preset", selection: $selectedPreset) {
                        ForEach(0..<ImageExporter.ExportSettings.presets.count, id: \.self) { index in
                            Text(ImageExporter.ExportSettings.presets[index].0)
                                .tag(index)
                        }
                        Text("Custom").tag(-1)
                    }
                    .onChange(of: selectedPreset) { _, newValue in
                        if newValue >= 0 && newValue < ImageExporter.ExportSettings.presets.count {
                            let preset = ImageExporter.ExportSettings.presets[newValue].1
                            settings.width = preset.width
                            settings.height = preset.height
                        }
                    }

                    if selectedPreset == -1 {
                        HStack {
                            TextField("Width", value: $settings.width, format: .number)
                                .textFieldStyle(.roundedBorder)
                            Text("×")
                            TextField("Height", value: $settings.height, format: .number)
                                .textFieldStyle(.roundedBorder)
                        }
                    } else {
                        Text("\(settings.width) × \(settings.height)")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Format") {
                    Picker("Format", selection: $settings.format) {
                        ForEach(ImageExporter.ExportFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)

                    if settings.format == .jpeg {
                        HStack {
                            Text("Quality")
                            Slider(value: $settings.jpegQuality, in: 0.1...1.0)
                            Text("\(Int(settings.jpegQuality * 100))%")
                                .frame(width: 40)
                        }
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Export...") {
                    exportImage()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400)
    }

    private func exportImage() {
        guard let renderer = renderer else { return }

        let exporter = ImageExporter(device: renderer.device)
        exporter.exportWithDialog(renderer: renderer, settings: settings)
        isPresented = false
    }
}

#Preview {
    StudioView()
        .environment(AppState())
        .frame(width: 1200, height: 800)
}
