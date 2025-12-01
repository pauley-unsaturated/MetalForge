# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Build
swift build

# Run
swift run MetalForge

# Test
swift test

# Open in Xcode
open Package.swift
```

## Architecture

MetalForge is a macOS SwiftUI application that teaches Metal Shading Language through puzzles. Users write fragment shaders to match target images, earning primitives (helper functions) as they progress.

### Core Flow

1. **AppState** (`App/AppState.swift`) - Observable singleton managing navigation, puzzle state, and player progress
2. **PuzzleManager** (`Puzzles/PuzzleManager.swift`) - Singleton with all puzzle definitions, organized into Worlds
3. **MetalRenderer** (`Core/Renderer/MetalRenderer.swift`) - Compiles user MSL code and renders to textures
4. **PixelComparator** (`Core/Verification/PixelComparator.swift`) - GPU compute shader that compares user output against reference

### Shader Compilation Pipeline

User code is wrapped by `ShaderTemplate.buildFullShader()` which:
1. Adds Metal stdlib includes and struct definitions
2. Inserts any unlocked primitives from `PrimitiveLibrary`
3. Appends user code (must define `float4 userFragment(float2 uv, constant Uniforms& u)`)
4. Adds system vertex/fragment shaders that call `userFragment`

Error line numbers are adjusted by `ShaderTemplate.userCodeLineOffset` to map back to user code.

### Key Data Types

- **PuzzleID**: `(world: Int, index: Int)` - unique puzzle identifier
- **Puzzle**: Contains starter code, solution, hints, and optional `PrimitiveUnlock`
- **PrimitiveDefinition**: Shader helper function earned by completing puzzles (stored in `PrimitiveLibrary`)
- **VerificationResult**: Pixel comparison result with similarity percentage

### Modes

- **Puzzle Mode**: Split view with target preview, user output preview, and code editor
- **Studio Mode**: Free-form shader creation with full primitive library access

## Metal Shading Language Notes

- All user shaders must implement: `float4 userFragment(float2 uv, constant Uniforms& u)`
- Uniforms struct provides: `time`, `resolution`, `mouse`
- Pixel format is BGRA8Unorm
- Verification uses 512x512 texture comparison with 99% match threshold

## Testing

Tests use Swift Testing framework (`@Test`, `#expect`). Key test suites:
- PuzzleTests: Validates puzzle definitions have unique IDs, hints, and solutions
- ShaderTemplateTests: Ensures shader template builds correctly
- PrimitiveLibraryTests: Verifies primitive implementations exist
