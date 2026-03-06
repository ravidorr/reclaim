import Foundation
import Combine

@MainActor
public final class DownloadsViewModel: ObservableObject {
    @Published public var allFiles: [DownloadFile] = []
    @Published public var selectedCategory: FileCategory = .images
    @Published public var selection: Set<DownloadFile> = []
    @Published public var isScanning = false
    @Published public var showDeleteConfirmation = false

    public init() {}

    public var filteredFiles: [DownloadFile] {
        allFiles.filter { $0.category == selectedCategory }
    }

    public var selectedFiles: [DownloadFile] {
        selection.filter { $0.category == selectedCategory }
    }

    public var selectionSize: String {
        let total = selection.reduce(0) { $0 + $1.size }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    public func scan() async {
        isScanning = true
        selection = []
        allFiles = await DownloadsScanner.shared.scan()
        isScanning = false
    }

    public func deleteSelected(recordFreed: (Int64) -> Void) async {
        let urls = selection.map(\.url)
        let selectedIDs = Set(selection.map(\.id))
        do {
            let freed = try await FileDeletionService.shared.moveToTrash(urls)
            allFiles.removeAll { selectedIDs.contains($0.id) }
            selection = []
            recordFreed(freed)
        } catch {
            print("Delete failed: \(error)")
        }
    }

    public func toggleSelection(_ file: DownloadFile) {
        if selection.contains(file) {
            selection.remove(file)
        } else {
            selection.insert(file)
        }
    }

    public func selectAll() {
        selection = Set(filteredFiles)
    }

    public func deselectAll() {
        selection = selection.filter { $0.category != selectedCategory }
    }

    public func selectExtractedArchives() {
        let extracted = filteredFiles.filter { $0.hasExtractedSibling }
        selection.formUnion(extracted)
    }
}
