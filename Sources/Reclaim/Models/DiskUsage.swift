import Foundation

struct DiskUsage {
    let totalBytes: Int64
    let usedBytes: Int64
    let freeBytes: Int64

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var formattedTotal: String { ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file) }
    var formattedUsed: String  { ByteCountFormatter.string(fromByteCount: usedBytes,  countStyle: .file) }
    var formattedFree: String  { ByteCountFormatter.string(fromByteCount: freeBytes,  countStyle: .file) }

    static let zero = DiskUsage(totalBytes: 0, usedBytes: 0, freeBytes: 0)
}
