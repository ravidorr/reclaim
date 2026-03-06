import Foundation

public struct DownloadFile: Identifiable, Hashable {
    public let id = UUID()
    public let url: URL
    public let name: String
    public let size: Int64
    public let modifiedDate: Date
    public let category: FileCategory

    /// For archives: whether a matching extracted folder exists next to the archive
    public var hasExtractedSibling: Bool = false

    public init(url: URL, name: String, size: Int64, modifiedDate: Date, category: FileCategory) {
        self.url = url
        self.name = name
        self.size = size
        self.modifiedDate = modifiedDate
        self.category = category
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: modifiedDate)
    }
}
