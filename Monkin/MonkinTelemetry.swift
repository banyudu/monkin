import Foundation
import os

/// Local-only, one-record-per-line telemetry for debugging Monkin behavior.
final class MonkinTelemetry {
    static let shared = MonkinTelemetry()

    private let logger = Logger(subsystem: "com.banyudu.monkin", category: "motion")
    private let queue = DispatchQueue(label: "com.banyudu.monkin.telemetry")
    private let fileURL: URL
    private let rotatedFileURL: URL
    private let maxFileBytes = 2_000_000

    private init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Monkin", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("motion-logs.jsonl")
        rotatedFileURL = directory.appendingPathComponent("motion-logs.1.jsonl")
    }

    func record(_ event: String, attributes: [String: String] = [:]) {
        let payload: [String: Any] = [
            "time_unix_nano": Int64(Date().timeIntervalSince1970 * 1_000_000_000),
            "severity_text": "INFO",
            "body": event,
            "resource": ["service.name": "monkin"],
            "attributes": attributes
        ]
        queue.async { [fileURL = self.fileURL,
                       rotatedFileURL = self.rotatedFileURL,
                       maxFileBytes = self.maxFileBytes,
                       logger = self.logger] in
            guard let data = try? JSONSerialization.data(withJSONObject: payload),
                  let line = String(data: data, encoding: .utf8)?.appending("\n") else { return }
            if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? NSNumber,
               fileSize.intValue + line.utf8.count > maxFileBytes {
                try? FileManager.default.removeItem(at: rotatedFileURL)
                try? FileManager.default.moveItem(at: fileURL, to: rotatedFileURL)
            }
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }
            guard let handle = try? FileHandle(forWritingTo: fileURL) else { return }
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8)!)
            try? handle.close()
            logger.debug("\(event, privacy: .public)")
        }
    }
}
