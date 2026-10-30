import CoreImage
import CoreVideo

class VideoFilter {
    let context = CIContext()

    func image(from buffer: CVPixelBuffer, blackAndWhite: Bool, contrast: Double) -> CGImage? {
        var image = CIImage(cvPixelBuffer: buffer)
        if blackAndWhite {
            // Zero saturation removes color from each video frame.
            image = image.applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 0.0,
                "inputContrast": contrast
            ])
        }
        return context.createCGImage(image, from: image.extent)
    }
}
