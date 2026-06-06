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
                call.resolve(["text": ""])
                return
            }
            // Top-to-bottom line order, one candidate per observation.
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            let text = lines.joined(separator: "\n")
            call.resolve(["text": text])
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
