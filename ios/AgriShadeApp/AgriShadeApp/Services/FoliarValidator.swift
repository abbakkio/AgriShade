import UIKit
import CoreImage

public struct FoliarCoverageCheck: Sendable {
    public let isFoliageDetected: Bool
    public let foliageRatio: Float // 0.0 to 1.0 (portion of image that is plant leaf)
    public let dominantHue: Float
    public let rejectionReason: String?
}

public enum FoliarValidator {
    /// Validates whether the incoming photo actually contains plant foliage / leaf tissue
    /// before feeding it into the disease neural classifier.
    /// Uses HSV foliar color-distribution + saturation analysis.
    public static func validate(image: UIImage) -> FoliarCoverageCheck {
        guard let cg = image.cgImage else {
            return FoliarCoverageCheck(
                isFoliageDetected: false,
                foliageRatio: 0.0,
                dominantHue: 0.0,
                rejectionReason: "Invalid image data."
            )
        }

        // Downsample to 128x128 for ultra-fast real-time foliar tissue histogram analysis
        let targetSize = 128
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * targetSize
        var rawData = [UInt8](repeating: 0, count: targetSize * targetSize * bytesPerPixel)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(
            data: &rawData,
            width: targetSize,
            height: targetSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return FoliarCoverageCheck(
                isFoliageDetected: true, // fallback to allow inference if context fails
                foliageRatio: 1.0,
                dominantHue: 120.0,
                rejectionReason: nil
            )
        }

        context.draw(cg, in: CGRect(x: 0, y: 0, width: targetSize, height: targetSize))

        var foliarPixelCount = 0
        let totalPixels = targetSize * targetSize
        var sumHue: Float = 0.0

        for i in 0..<totalPixels {
            let offset = i * bytesPerPixel
            let r = Float(rawData[offset]) / 255.0
            let g = Float(rawData[offset + 1]) / 255.0
            let b = Float(rawData[offset + 2]) / 255.0

            let maxVal = max(r, max(g, b))
            let minVal = min(r, min(g, b))
            let delta = maxVal - minVal

            // Calculate Saturation (0..1)
            let saturation = maxVal > 0 ? (delta / maxVal) : 0.0

            // Calculate Hue (0..360)
            var hue: Float = 0.0
            if delta > 1e-4 {
                if maxVal == r {
                    hue = 60.0 * fmod(((g - b) / delta), 6.0)
                } else if maxVal == g {
                    hue = 60.0 * (((b - r) / delta) + 2.0)
                } else {
                    hue = 60.0 * (((r - g) / delta) + 4.0)
                }
                if hue < 0 { hue += 360.0 }
            }

            // Biological foliar criteria:
            // 1. Plant green leaf tissue (Hue ~ 45° to 170°, Saturation > 0.15, Value > 0.12)
            // 2. Necrotic lesion/desiccated brown foliar tissue (Hue ~ 20° to 45°, Saturation > 0.20, Red >= Green)
            let isGreenLeaf = (hue >= 45.0 && hue <= 170.0) && (saturation >= 0.14) && (maxVal >= 0.12)
            let isNecroticFoliarTissue = (hue >= 18.0 && hue < 45.0) && (saturation >= 0.18) && (r >= g * 0.90) && (maxVal >= 0.12)

            if isGreenLeaf || isNecroticFoliarTissue {
                foliarPixelCount += 1
                sumHue += hue
            }
        }

        let foliarRatio = Float(foliarPixelCount) / Float(totalPixels)
        let avgHue = foliarPixelCount > 0 ? (sumHue / Float(foliarPixelCount)) : 0.0

        // Minimum foliar threshold: at least 22% of viewfinder must contain botanical leaf tissue
        let MIN_FOLIAR_COVERAGE: Float = 0.22

        if foliarRatio < MIN_FOLIAR_COVERAGE {
            let pct = String(format: "%.1f%%", foliarRatio * 100.0)
            return FoliarCoverageCheck(
                isFoliageDetected: false,
                foliageRatio: foliarRatio,
                dominantHue: avgHue,
                rejectionReason: "No botanical leaf specimen detected (\(pct) foliar coverage). Please point the camera directly at a crop leaf blade."
            )
        }

        return FoliarCoverageCheck(
            isFoliageDetected: true,
            foliageRatio: foliarRatio,
            dominantHue: avgHue,
            rejectionReason: nil
        )
    }
}
