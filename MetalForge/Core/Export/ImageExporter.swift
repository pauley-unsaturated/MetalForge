import Foundation
import Metal
import AppKit
import UniformTypeIdentifiers

/// Exports shader output to various image formats
@MainActor
final class ImageExporter {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
    }

    /// Export formats supported
    enum ExportFormat: String, CaseIterable, Identifiable {
        case png = "PNG"
        case jpeg = "JPEG"
        case tiff = "TIFF"

        var id: String { rawValue }

        var utType: UTType {
            switch self {
            case .png: return .png
            case .jpeg: return .jpeg
            case .tiff: return .tiff
            }
        }

        var fileExtension: String {
            switch self {
            case .png: return "png"
            case .jpeg: return "jpg"
            case .tiff: return "tiff"
            }
        }
    }

    /// Export settings
    struct ExportSettings {
        var width: Int = 1024
        var height: Int = 1024
        var format: ExportFormat = .png
        var jpegQuality: Float = 0.9

        static let presets: [(String, ExportSettings)] = [
            ("1080p (1920×1080)", ExportSettings(width: 1920, height: 1080)),
            ("4K (3840×2160)", ExportSettings(width: 3840, height: 2160)),
            ("Square 1K (1024×1024)", ExportSettings(width: 1024, height: 1024)),
            ("Square 2K (2048×2048)", ExportSettings(width: 2048, height: 2048)),
            ("Instagram (1080×1080)", ExportSettings(width: 1080, height: 1080)),
            ("Twitter Header (1500×500)", ExportSettings(width: 1500, height: 500)),
        ]
    }

    /// Export a shader to an image file
    func export(
        renderer: MetalRenderer,
        settings: ExportSettings,
        to url: URL
    ) throws {
        // Create render texture
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: settings.width,
            height: settings.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.storageMode = .managed

        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            throw ExportError.textureCreationFailed
        }

        // Render
        renderer.render(to: texture)

        // Synchronize for reading
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw ExportError.commandBufferFailed
        }

        blitEncoder.synchronize(resource: texture)
        blitEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Read pixels
        let bytesPerPixel = 4
        let bytesPerRow = settings.width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: settings.height * bytesPerRow)

        texture.getBytes(
            &pixelData,
            bytesPerRow: bytesPerRow,
            from: MTLRegion(
                origin: MTLOrigin(x: 0, y: 0, z: 0),
                size: MTLSize(width: settings.width, height: settings.height, depth: 1)
            ),
            mipmapLevel: 0
        )

        // Convert BGRA to RGBA
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let b = pixelData[i]
            pixelData[i] = pixelData[i + 2]
            pixelData[i + 2] = b
        }

        // Create CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: &pixelData,
            width: settings.width,
            height: settings.height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ),
              let cgImage = context.makeImage() else {
            throw ExportError.imageCreationFailed
        }

        // Flip vertically (Metal textures are upside down relative to CGImage)
        let flippedImage = flipImageVertically(cgImage)

        // Save to file
        try saveImage(flippedImage, format: settings.format, quality: settings.jpegQuality, to: url)
    }

    private func flipImageVertically(_ image: CGImage) -> CGImage {
        let width = image.width
        let height = image.height

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }

        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage() ?? image
    }

    private func saveImage(_ image: CGImage, format: ExportFormat, quality: Float, to url: URL) throws {
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))

        guard let tiffData = nsImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            throw ExportError.imageCreationFailed
        }

        let data: Data?

        switch format {
        case .png:
            data = bitmapRep.representation(using: .png, properties: [:])
        case .jpeg:
            data = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: NSNumber(value: quality)])
        case .tiff:
            data = bitmapRep.representation(using: .tiff, properties: [:])
        }

        guard let imageData = data else {
            throw ExportError.encodingFailed
        }

        try imageData.write(to: url)
    }

    /// Show save panel and export
    func exportWithDialog(renderer: MetalRenderer, settings: ExportSettings) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [settings.format.utType]
        panel.nameFieldStringValue = "shader_export.\(settings.format.fileExtension)"

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    try self.export(renderer: renderer, settings: settings, to: url)
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                } catch {
                    let alert = NSAlert()
                    alert.messageText = "Export Failed"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .critical
                    alert.runModal()
                }
            }
        }
    }
}

/// Export errors
enum ExportError: LocalizedError {
    case textureCreationFailed
    case commandBufferFailed
    case imageCreationFailed
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .textureCreationFailed:
            return "Failed to create render texture"
        case .commandBufferFailed:
            return "Failed to create command buffer"
        case .imageCreationFailed:
            return "Failed to create image from texture"
        case .encodingFailed:
            return "Failed to encode image data"
        }
    }
}
