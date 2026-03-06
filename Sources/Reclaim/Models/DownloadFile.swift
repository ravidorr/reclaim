import Foundation

struct DownloadFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let modifiedDate: Date
    let category: FileCategory

    /// For archives: whether a matching extracted folder exists next to the archive
    var hasExtractedSibling: Bool = false

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: modifiedDate)
    }
}
