import Foundation

public struct DiskUsageService {
    public static func currentUsage() -> DiskUsage {
        var stat = statfs()
        let root = ("/") as NSString
        guard statfs(root.fileSystemRepresentation, &stat) == 0 else {
            return .zero
        }
        let blockSize = Int64(stat.f_bsize)
        let total  = Int64(stat.f_blocks) * blockSize
        let free   = Int64(stat.f_bavail) * blockSize
        let used   = total - free
        return DiskUsage(totalBytes: total, usedBytes: used, freeBytes: free)
    }
}
