import SwiftUI

struct OtherFilesListView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    var body: some View {
        List(vm.filteredFiles) { file in
            FileRowView(
                file: file,
                isSelected: vm.selection.contains(file),
                onToggle: { vm.toggleSelection(file) }
            )
            .onTapGesture { vm.toggleSelection(file) }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .overlay {
            if vm.filteredFiles.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("No other files in Downloads")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .toolbar {
            DeleteToolbar(
                selectionCount: vm.selectedFiles.count,
                selectionSize: vm.selectionSize,
                onSelectAll: vm.selectAll,
                onDeselectAll: vm.deselectAll,
                onDelete: { Task { await vm.deleteSelected(recordFreed: recordFreed) } }
            )
        }
    }
}
