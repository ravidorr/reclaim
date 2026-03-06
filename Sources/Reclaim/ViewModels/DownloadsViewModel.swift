import Foundation
import SwiftUI

@MainActor
final class DownloadsViewModel: ObservableObject {
    @Published var allFiles: [DownloadFile] = []
    @Published var selectedCategory: FileCategory = .images
    @Published var selection: Set<DownloadFile> = []
    @Published var isScanning = false
    @Published var showDeleteConfirmation = false

    var filteredFiles: [DownloadFile] {
        allFiles.filter { $0.category == selectedCategory }
    }

    var selectedFiles: [DownloadFile] {
        selection.filter { $0.category == selectedCategory }
    }

    var selectionSize: String {
        let total = selection.reduce(0) { $0 + $1.size }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    func scan() async {
        isScanning = true
        selection = []
        allFiles = await DownloadsScanner.shared.scan()
        isScanning = false
    }

    func deleteSelected(recordFreed: (Int64) -> Void) async {
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

    func toggleSelection(_ file: DownloadFile) {
        if selection.contains(file) {
            selection.remove(file)
        } else {
            selection.insert(file)
        }
    }

    func selectAll() {
        selection = Set(filteredFiles)
    }

    func deselectAll() {
        selection = selection.filter { $0.category != selectedCategory }
    }

    func selectExtractedArchives() {
        let extracted = filteredFiles.filter { $0.hasExtractedSibling }
        selection.formUnion(extracted)
    }
}
