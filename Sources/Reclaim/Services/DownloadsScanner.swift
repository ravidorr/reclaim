import Foundation

actor DownloadsScanner {
    static let shared = DownloadsScanner()

    private let downloadsURL: URL = {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    }()

    func scan() async -> [DownloadFile] {
        await Task.detached(priority: .utility) { [downloadsURL] in
            Self.scanDirectory(downloadsURL)
        }.value
    }

    private static func scanDirectory(_ root: URL) -> [DownloadFile] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: root,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey, .isHiddenKey],
            options: [.skipsPackageDescendants]
        ) else { return [] }

        var files: [DownloadFile] = []

        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [
                .fileSizeKey, .contentModificationDateKey, .isRegularFileKey, .isHiddenKey
            ]) else { continue }

            guard values.isRegularFile == true,
                  values.isHidden != true,
                  url.lastPathComponent != ".DS_Store"
            else { continue }

            let size     = Int64(values.fileSize ?? 0)
            let modified = values.contentModificationDate ?? Date.distantPast
            let category = FileCategory.category(for: url)

            var file = DownloadFile(
                url: url,
                name: url.lastPathComponent,
                size: size,
                modifiedDate: modified,
                category: category
            )

            // Check for extracted siblings (e.g. foo.zip → foo/ folder exists)
            if category == .archives {
                let siblingName = url.deletingPathExtension().lastPathComponent
                let siblingURL  = url.deletingLastPathComponent().appendingPathComponent(siblingName)
                file.hasExtractedSibling = fm.fileExists(atPath: siblingURL.path)
            }

            files.append(file)
        }

        return files.sorted { $0.modifiedDate > $1.modifiedDate }
    }
}
