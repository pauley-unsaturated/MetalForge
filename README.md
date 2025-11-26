# MetalForge

A shader puzzle game that teaches Metal Shading Language through progressively challenging puzzles.

## Overview

MetalForge is a macOS application that teaches GPU programming through Metal Shading Language (MSL). Players write fragment shaders to match target images, learning concepts from basic colors to raymarching and compute shaders.

## Features

- **Puzzle Mode**: Learn shader programming through 80+ puzzles across 9 worlds
- **Studio Mode**: Free-form shader creation with full primitive library
- **Earn Your Primitives**: Build helper functions from scratch, then unlock them for future use
- **Export**: Save your creations as PNG, JPEG, or TIFF images
- **Real MSL**: Write actual Metal Shading Language that transfers to production work

## Requirements

- macOS 14.0+ (Sonoma)
- Metal-capable GPU
- 4 GB RAM minimum

## Building

```bash
# Clone the repository
git clone https://github.com/your-username/MetalForge.git
cd MetalForge

# Build with Swift Package Manager
swift build

# Run
swift run MetalForge
```

Or open in Xcode:
1. Open `Package.swift` in Xcode
2. Select the MetalForge scheme
3. Build and run (⌘R)

## Curriculum

### World 1: First Light (Metal Fundamentals)
- Colors, UV coordinates, gradients, animation basics

### World 2: Shape Language (2D SDF)
- Signed distance functions, boolean operations, repetition

### World 3: Color Theory
- HSV, palettes, blend modes, anti-aliasing

### World 4: Noise & Randomness
- Hash functions, Perlin noise, FBM, Voronoi

### World 5-6: Raymarching
- 3D SDFs, lighting, shadows, materials

### World 7: Compute Shaders
- Kernels, image processing, particle systems

### World 8: Metal 3
- Mesh shaders, ray tracing (Apple Silicon)

## Architecture

```
MetalForge/
├── App/           # Main app entry and state
├── Core/
│   ├── Renderer/  # Metal rendering engine
│   ├── Verification/ # Puzzle solution checking
│   ├── Primitives/   # Unlockable shader functions
│   └── Export/    # Image export
├── Editor/        # Code editor with syntax highlighting
├── Puzzles/       # Puzzle definitions
├── Studio/        # Free creation mode
└── Resources/     # Assets
```

## License

MIT License - see LICENSE file for details.
