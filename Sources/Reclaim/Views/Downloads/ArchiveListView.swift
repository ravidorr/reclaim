import SwiftUI

struct ArchiveListView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    var body: some View {
        List(vm.filteredFiles) { file in
            ArchiveRow(
                file: file,
                isSelected: vm.selection.contains(file),
                onToggle: { vm.toggleSelection(file) }
            )
            .onTapGesture { vm.toggleSelection(file) }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .overlay {
            if vm.filteredFiles.isEmpty {
                emptyState
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Select Duplicates") {
                    vm.selectExtractedArchives()
                }
                .help("Select archives that have an extracted folder alongside them")
            }
            DeleteToolbar(
                selectionCount: vm.selectedFiles.count,
                selectionSize: vm.selectionSize,
                onSelectAll: vm.selectAll,
                onDeselectAll: vm.deselectAll,
                onDelete: { Task { await vm.deleteSelected(recordFreed: recordFreed) } }
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "archivebox")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No archives in Downloads")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Archive Row

private struct ArchiveRow: View {
    let file: DownloadFile
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        FileRowView(
            file: file,
            isSelected: isSelected,
            onToggle: onToggle
        )
        .overlay(alignment: .trailing) {
            if file.hasExtractedSibling {
                Label("Extracted folder found", systemImage: "folder.badge.minus")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.trailing, 8)
            }
        }
    }
}
