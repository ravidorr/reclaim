import AppKit
import Foundation

actor FileDeletionService {
    static let shared = FileDeletionService()

    /// Moves files to Trash. Returns total bytes freed.
    func moveToTrash(_ urls: [URL]) async throws -> Int64 {
        var totalFreed: Int64 = 0
        for url in urls {
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                NSWorkspace.shared.recycle([url]) { trashedURLs, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
            totalFreed += size
        }
        return totalFreed
    }

    /// Deletes a directory permanently (used for caches). Returns bytes freed.
    func deleteDirectory(at path: String) async throws -> Int64 {
        let url  = URL(fileURLWithPath: path)
        let size = await FileSizeScanner.shared.size(of: path)
        try FileManager.default.removeItem(at: url)
        return size
    }
}
