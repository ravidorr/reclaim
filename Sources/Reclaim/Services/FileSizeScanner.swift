import Foundation

actor FileSizeScanner {
    static let shared = FileSizeScanner()

    /// Returns the total size in bytes of a directory (or a single file).
    func size(of path: String) async -> Int64 {
        let url = URL(fileURLWithPath: path)
        return await Task.detached(priority: .utility) {
            Self.directorySize(url: url)
        }.value
    }

    private static func directorySize(url: URL) -> Int64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                  values.isRegularFile == true,
                  let size = values.fileSize
            else { continue }
            total += Int64(size)
        }
        return total
    }
}
