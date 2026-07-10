import Foundation
import Capacitor
import Vision
import UIKit

/// Apple Vision Framework OCR plugin.
///
/// Mirrors the Android `OcrPlugin.java` API so that the JS side can call
/// `Capacitor.Plugins.NativeOcr.recognize({ imageBase64 })` identically on
/// both platforms. No API key required — Vision Framework is built into
/// iOS 13+ and works fully offline.
@objc(NativeOcrPlugin)
public class NativeOcrPlugin: CAPPlugin {

    @objc func recognize(_ call: CAPPluginCall) {
        guard let imageData = call.getString("imageBase64"), !imageData.isEmpty else {
            call.reject("No image data")
            return
        }

        // Accept both "data:image/...;base64,XXXX" and raw base64.
        let base64: String
        if let commaIdx = imageData.firstIndex(of: ",") {
            base64 = String(imageData[imageData.index(after: commaIdx)...])
        } else {
            base64 = imageData
        }

        guard let bytes = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
              let uiImage = UIImage(data: bytes),
              let cgImage = uiImage.cgImage else {
            call.reject("Bitmap decode failed")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                call.reject("Vision OCR error: \(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                call.resolve(["text": "", "words": []])
                return
            }
            // Top-to-bottom line order, one candidate per observation.
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            let text = lines.joined(separator: "\n")

            // Per-word pixel coordinates (image coords, y grows downward) so the
            // JS spatial chart parser can reason about label positions.
            let W = CGFloat(cgImage.width), H = CGFloat(cgImage.height)
            var words: [[String: Any]] = []
            for obs in observations {
                guard let cand = obs.topCandidates(1).first else { continue }
                let full = cand.string
                var searchStart = full.startIndex
                for token in full.split(separator: " ") {
                    let w = String(token)
                    if let r = full.range(of: w, range: searchStart..<full.endIndex) {
                        if let box = try? cand.boundingBox(for: r) {
                            let bb = box.boundingBox   // normalized, origin bottom-left
                            words.append([
                                "text": w,
                                "x": Double(bb.midX * W),
                                "y": Double((1 - bb.midY) * H)
                            ])
                        }
                        searchStart = r.upperBound
                    }
                }
            }
            call.resolve(["text": text, "words": words])
        }

        // Chart fixes (e.g. MIBIB, ATVID) are not dictionary words, so disable
        // language correction. Accurate mode is slower but vital for small
        // plan-view labels.
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    call.reject("Vision handler error: \(error.localizedDescription)")
                }
            }
        }
    }
}
