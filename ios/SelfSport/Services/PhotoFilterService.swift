import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum PhotoFilterType: String, CaseIterable {
    case original = "ORIGINAL"
    case blackAndWhite = "B&W"
    case dramatic = "DRAMATIC"
}

@MainActor
final class PhotoFilterService {
    private let ciContext: CIContext = {
        if let device = MTLCreateSystemDefaultDevice() {
            return CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        }
        return CIContext(options: [.cacheIntermediates: false])
    }()

    private var cache: [PhotoFilterType: UIImage] = [:]
    private var sourceImage: UIImage?

    func setSource(_ image: UIImage) {
        guard image !== sourceImage else { return }
        sourceImage = image
        cache.removeAll()
    }

    func apply(_ filter: PhotoFilterType, to image: UIImage) -> UIImage {
        if let cached = cache[filter] { return cached }
        let result = renderFilter(filter, on: image)
        cache[filter] = result
        return result
    }

    func invalidateCache() {
        cache.removeAll()
    }

    private func renderFilter(_ filter: PhotoFilterType, on image: UIImage) -> UIImage {
        guard filter != .original else { return image }
        guard let ciInput = CIImage(image: image) else { return image }

        let output: CIImage?

        switch filter {
        case .original:
            return image

        case .blackAndWhite:
            let noir = CIFilter.photoEffectNoir()
            noir.inputImage = ciInput
            output = noir.outputImage

        case .dramatic:
            let controls = CIFilter.colorControls()
            controls.inputImage = ciInput
            controls.contrast = 1.45
            controls.saturation = 0.75
            controls.brightness = -0.05

            guard let controlsOutput = controls.outputImage else {
                output = nil
                break
            }

            let highlights = CIFilter.highlightShadowAdjust()
            highlights.inputImage = controlsOutput
            highlights.highlightAmount = 0.6
            highlights.shadowAmount = -0.4

            guard let highlightsOutput = highlights.outputImage else {
                output = controlsOutput
                break
            }

            let vignette = CIFilter.vignette()
            vignette.inputImage = highlightsOutput
            vignette.radius = 2.0
            vignette.intensity = 0.6
            output = vignette.outputImage
        }

        guard let ciOutput = output,
              let cgImage = ciContext.createCGImage(ciOutput, from: ciInput.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
