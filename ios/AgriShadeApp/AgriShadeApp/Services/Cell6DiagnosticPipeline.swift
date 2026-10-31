import UIKit
import CoreImage
import Accelerate

public struct Cell6PipelineOutput: Sendable {
    public let sensorFrameWithHUD: UIImage
    public let zoomedFoliarBlade: UIImage
    public let claheNormalized: UIImage
    public let lesionAttentionOverlay: UIImage
    public let zoomFactor: Double
    public let frameDimensions: (width: Int, height: Int)
    public let bladeDimensions: (width: Int, height: Int)
}

public enum Cell6DiagnosticPipeline {

    /// Generates the exact 4 diagnostic views from Cell 6:
    /// (a) Sensor Frame [Target Frame HUD & Bounding Box]
    /// (b) Zoomed Foliar Blade [Primary leaf blade cropped]
    /// (c) CIE-LAB CLAHE [Illumination shadows & glare normalized]
    /// (d) Lesion Attention Overlay [Alpha-masked translucent heatmap on natural leaf]
    public static func process(
        image: UIImage,
        topLabel: String,
        confidencePct: Double,
        isGated: Bool
    ) -> Cell6PipelineOutput {
        let normalizedImage = image.fixOrientation()
        let wOrig = Int(normalizedImage.size.width)
        let hOrig = Int(normalizedImage.size.height)

        // Step A: Smart Foliar Auto-Zoom (Central leaf blade ROI crop)
        let (cropRect, zoomFactor) = detectFoliarBladeROI(width: wOrig, height: hOrig)
        let zoomedBlade = cropImage(normalizedImage, toRect: cropRect)
        let lw = Int(zoomedBlade.size.width)
        let lh = Int(zoomedBlade.size.height)

        // Draw HUD Bounding Box on Sensor Frame (matching (a))
        let sensorWithHUD = drawTargetFrameHUD(
            on: normalizedImage,
            rect: cropRect,
            zoomFactor: zoomFactor
        )

        // Step B: Illumination Decoupling (CIE-LAB CLAHE approximation) (matching (c))
        let claheImage = applyIlluminationDecoupling(to: zoomedBlade)

        // Step C & D: Advanced Lesion Attention Overlay (matching (d))
        let lesionOverlay = generateClinicalLesionOverlay(
            baseBlade: zoomedBlade,
            topLabel: topLabel,
            confidencePct: confidencePct,
            isGated: isGated
        )

        return Cell6PipelineOutput(
            sensorFrameWithHUD: sensorWithHUD,
            zoomedFoliarBlade: zoomedBlade,
            claheNormalized: claheImage,
            lesionAttentionOverlay: lesionOverlay,
            zoomFactor: zoomFactor,
            frameDimensions: (wOrig, hOrig),
            bladeDimensions: (lw, lh)
        )
    }

    // MARK: - Central Foliar Blade ROI Detection
    private static func detectFoliarBladeROI(width: Int, height: Int) -> (CGRect, Double) {
        // GrabCut center-prior simulation: leaf blade covers central 75% to 85% area
        let marginX = CGFloat(width) * 0.12
        let marginY = CGFloat(height) * 0.10
        let cropW = CGFloat(width) - 2.0 * marginX
        let cropH = CGFloat(height) - 2.0 * marginY

        let rect = CGRect(x: marginX, y: marginY, width: cropW, height: cropH)
        let zoomFactor = Double(width * height) / Double(max(1.0, cropW * cropH))
        return (rect, zoomFactor)
    }

    private static func cropImage(_ image: UIImage, toRect rect: CGRect) -> UIImage {
        guard let cg = image.cgImage,
              let cropped = cg.cropping(to: rect) else {
            return image
        }
        return UIImage(cgImage: cropped)
    }

    // MARK: - Draw (a) Sensor Frame HUD with Green Target Frame
    private static func drawTargetFrameHUD(on image: UIImage, rect: CGRect, zoomFactor: Double) -> UIImage {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(at: .zero)

        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }

        // Draw green target box
        let neonGreen = UIColor(red: 0.0, green: 1.0, blue: 0.23, alpha: 0.95)
        ctx.setStrokeColor(neonGreen.cgColor)
        ctx.setLineWidth(max(3.0, size.width * 0.007))
        ctx.stroke(rect)

        // Draw HUD Tag text: "LEAF ROI BLADE (X.XXx ZOOM)"
        let text = "LEAF ROI BLADE (\(String(format: "%.2f", zoomFactor))x ZOOM)"
        let fontSize = max(13.0, size.width * 0.035)
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: neonGreen
        ]

        let textPoint = CGPoint(x: rect.origin.x + 8.0, y: max(20.0, rect.origin.y - fontSize - 6.0))
        (text as NSString).draw(at: textPoint, withAttributes: attrs)

        let result = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return result
    }

    // MARK: - Apply (c) CIE-LAB CLAHE Illumination Normalization
    private static func applyIlluminationDecoupling(to image: UIImage) -> UIImage {
        guard let ci = CIImage(image: image) else { return image }

        // Boost local contrast and shadow brightness to reveal veiled pathology in shadows
        let context = CIContext()
        var output = ci

        if let highlightShadow = CIFilter(name: "CIHighlightShadowAdjust") {
            highlightShadow.setValue(output, forKey: kCIInputImageKey)
            highlightShadow.setValue(1.15, forKey: "inputShadowAmount")
            highlightShadow.setValue(0.85, forKey: "inputHighlightAmount")
            if let res = highlightShadow.outputImage { output = res }
        }

        if let exposure = CIFilter(name: "CIExposureAdjust") {
            exposure.setValue(output, forKey: kCIInputImageKey)
            exposure.setValue(0.20, forKey: kCIInputEVKey)
            if let res = exposure.outputImage { output = res }
        }

        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(output, forKey: kCIInputImageKey)
            colorControls.setValue(1.25, forKey: kCIInputContrastKey)
            colorControls.setValue(1.10, forKey: kCIInputSaturationKey)
            if let res = colorControls.outputImage { output = res }
        }

        if let cg = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cg)
        }
        return image
    }

    // MARK: - Generate (d) Clinical Lesion Attention Overlay
    private static func generateClinicalLesionOverlay(
        baseBlade: UIImage,
        topLabel: String,
        confidencePct: Double,
        isGated: Bool
    ) -> UIImage {
        guard let cg = baseBlade.cgImage else { return baseBlade }
        let width = cg.width
        let height = cg.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return baseBlade }

        context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Multi-Scale Lesion Attention (Necrosis Index + Foliar Hue Gate)
        // Replicating Step C, D, E from Cell 6:
        // Healthy green leaf stays completely natural (zero blue tint)
        // Necrotic lesions glow with fiery red/orange heat!
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let r = Float(rawData[offset])
                let g = Float(rawData[offset + 1])
                let b = Float(rawData[offset + 2])

                // Foliar mask: green foliage or brown/purple fungal lesions
                let isPlantTissue = (g > 30.0 || (r > 40.0 && r > b))

                if isPlantTissue {
                    // Necrosis index: desiccation / fungal spot (Red >= Green)
                    let necrosisIdx = max(0.0, (r - g) / (r + g + 14.0))

                    // Center-weighted focal lesion energy
                    let dx = Float(x - width / 2) / Float(width / 2)
                    let dy = Float(y - height / 2) / Float(height / 2)
                    let dist = sqrt(dx * dx + dy * dy)
                    let centerWeight = max(0.0, 1.0 - 0.7 * dist)

                    let lesionEnergy = (necrosisIdx * 0.75 + (1.0 - g / 255.0) * 0.25) * centerWeight

                    if lesionEnergy > 0.12 {
                        // Blend jet fiery colormap on lesion sites
                        let alpha = min(0.85, pow((lesionEnergy - 0.12) / 0.88, 0.75) * 0.85)

                        // Fiery orange/red thermal attention
                        let heatR: Float = 255.0
                        let heatG: Float = min(220.0, max(40.0, (1.0 - lesionEnergy) * 255.0))
                        let heatB: Float = 10.0

                        rawData[offset] = UInt8(min(255.0, (1.0 - alpha) * r + alpha * heatR))
                        rawData[offset + 1] = UInt8(min(255.0, (1.0 - alpha) * g + alpha * heatG))
                        rawData[offset + 2] = UInt8(min(255.0, (1.0 - alpha) * b + alpha * heatB))
                    }
                }
            }
        }

        guard let outputCG = context.makeImage() else { return baseBlade }
        return UIImage(cgImage: outputCG)
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalized
    }
}
