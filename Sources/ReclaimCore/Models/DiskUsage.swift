import Foundation

public struct DiskUsage {
    public let totalBytes: Int64
    public let usedBytes: Int64
    public let freeBytes: Int64

    public init(totalBytes: Int64, usedBytes: Int64, freeBytes: Int64) {
        self.totalBytes = totalBytes
        self.usedBytes = usedBytes
        self.freeBytes = freeBytes
    }

    public var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    public var formattedTotal: String { ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file) }
    public var formattedUsed: String  { ByteCountFormatter.string(fromByteCount: usedBytes,  countStyle: .file) }
    public var formattedFree: String  { ByteCountFormatter.string(fromByteCount: freeBytes,  countStyle: .file) }

    public static let zero = DiskUsage(totalBytes: 0, usedBytes: 0, freeBytes: 0)
}
