import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct PixelImage {
    var width: Int
    var height: Int
    var pixels: [UInt8]

    static func load(_ data: Data) throws -> PixelImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int,
              width > 0, height > 0 else {
            throw PhotoError.cannotRead
        }

        // Keep the original size. Limit very large photos to avoid running out of memory.
        guard width <= 25_000_000 / height else {
            throw PhotoError.tooLarge
        }

        // Apply the photo's orientation without making it smaller.
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(width, height),
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary),
              let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: image.width, height: image.height,
                                      bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                      space: space, bitmapInfo: bitmapInfo) else {
            throw PhotoError.cannotRead
        }

        let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(rect)
        context.interpolationQuality = .none
        context.draw(image, in: rect)
        guard let memory = context.data else { throw PhotoError.cannotRead }

        let count = image.width * image.height * 4
        let bytes = memory.assumingMemoryBound(to: UInt8.self)
        var pixels = Array(UnsafeBufferPointer(start: bytes, count: count))
        // Each pixel has red, green, blue, and an unused opaque byte.
        for index in stride(from: 3, to: pixels.count, by: 4) {
            pixels[index] = 255
        }
        return PixelImage(width: image.width, height: image.height, pixels: pixels)
    }

    func moved(restore: Bool) -> PixelImage {
        var result = [UInt8](repeating: 255, count: pixels.count)

        for y in 0..<height {
            for x in 0..<width {
                var newX = x
                var newY = y

                // Use the same rule three times for every photo.
                //reference: https://github.com/zhanxw/cat/blob/master/cat.py
                //reference: https://molab.marimo.io/gallery/l/arnold-s-cat-map
                for _ in 0..<3 {
                    if restore {
                        // Undo the column first, then the row.
                        let column = (newX * newX * 11 + newX * 29 + 23) % height
                        newY = (newY + height - column) % height
                        let row = (newY * newY * 7 + newY * 31 + 17) % width
                        newX = (newX + width - row) % width
                    } else {
                        let row = (newY * newY * 7 + newY * 31 + 17) % width
                        newX = (newX + row) % width
                        let column = (newX * newX * 11 + newX * 29 + 23) % height
                        newY = (newY + column) % height
                    }
                }

                let oldIndex = (y * width + x) * 4
                let newIndex = (newY * width + newX) * 4
                for channel in 0..<4 {
                    result[newIndex + channel] = pixels[oldIndex + channel]
                }
            }
        }
        return PixelImage(width: width, height: height, pixels: result)
    }

    func makeImage() -> CGImage? {
        let data = Data(pixels)
        guard let provider = CGDataProvider(data: data as CFData),
              let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        return CGImage(width: width, height: height, bitsPerComponent: 8,
                       bitsPerPixel: 32, bytesPerRow: width * 4, space: space,
                       bitmapInfo: CGBitmapInfo(rawValue: Self.bitmapInfo),
                       provider: provider, decode: nil, shouldInterpolate: false,
                       intent: .defaultIntent)
    }

    func pngData() throws -> Data {
        let data = NSMutableData()
        guard let image = makeImage(),
              let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            throw PhotoError.cannotSave
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw PhotoError.cannotSave }
        return data as Data
    }

    static let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
}

enum PhotoError: LocalizedError {
    case cannotRead
    case tooLarge
    case cannotSave

    var errorDescription: String? {
        switch self {
        case .cannotRead: return "Could not read this photo. Choose a different image."
        case .tooLarge: return "Choose a photo up to 25 megapixels."
        case .cannotSave: return "Could not create the PNG file."
        }
    }
}
