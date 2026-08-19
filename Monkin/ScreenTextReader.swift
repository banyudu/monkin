import AppKit
import Vision

struct ScreenText {
    let text: String
    let confidence: VNConfidence
    let screenRect: CGRect
}

final class ScreenTextReader {
    private let workQueue = DispatchQueue(label: "com.banyudu.monkin.screen-ocr")

    func requestScreenRecordingAccess() {
        _ = CGRequestScreenCaptureAccess()
    }

    /// Captures and recognizes the main display once. Vision recognition is
    /// local to the Mac; no image or text leaves the process.
    func readMainDisplay(completion: @escaping ([ScreenText]) -> Void) {
        guard let screen = NSScreen.main else {
            completion([])
            return
        }
        if !CGPreflightScreenCaptureAccess() {
            CGRequestScreenCaptureAccess()
            completion([])
            return
        }

        let screenFrame = screen.frame
        guard let image = CGWindowListCreateImage(
            screenFrame,
            [.optionOnScreenOnly],
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        ) else {
            completion([])
            return
        }

        workQueue.async {
            let request = VNRecognizeTextRequest { request, _ in
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                let items = observations.compactMap { observation -> ScreenText? in
                    guard let candidate = observation.topCandidates(1).first,
                          !candidate.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
                    let box = observation.boundingBox
                    let rect = CGRect(x: screenFrame.minX + box.minX * screenFrame.width,
                                      y: screenFrame.minY + (1 - box.maxY) * screenFrame.height,
                                      width: box.width * screenFrame.width,
                                      height: box.height * screenFrame.height)
                    return ScreenText(text: candidate.string,
                                      confidence: candidate.confidence,
                                      screenRect: rect)
                }
                DispatchQueue.main.async { completion(items) }
            }
            request.recognitionLevel = .fast
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
            request.minimumTextHeight = 0.012
            do {
                try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
}
