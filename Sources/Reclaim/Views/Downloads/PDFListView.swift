import SwiftUI
import PDFKit

struct PDFListView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    @State private var selectedFile: DownloadFile?

    var body: some View {
        HSplitView {
            // Left: file list
            List(vm.filteredFiles) { file in
                FileRowView(
                    file: file,
                    isSelected: vm.selection.contains(file),
                    onToggle: { vm.toggleSelection(file) }
                )
                .contentShape(Rectangle())
                .onTapGesture { selectedFile = file }
                .listRowBackground(
                    selectedFile?.id == file.id
                        ? Color.accentColor.opacity(0.12)
                        : Color.clear
                )
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .frame(minWidth: 260, idealWidth: 320)
            .overlay {
                if vm.filteredFiles.isEmpty { emptyState }
            }

            // Right: PDF preview using PDFKit (works without a bundle)
            Group {
                if let file = selectedFile {
                    PDFKitView(url: file.url)
                        .id(file.id) // recreate view when file changes
                } else {
                    placeholderPanel
                }
            }
            .frame(minWidth: 400)
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

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No PDFs in Downloads")
                .foregroundStyle(.secondary)
        }
    }

    private var placeholderPanel: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("Select a PDF to preview")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - PDFKit view (reliable, no bundle required)

private struct PDFKitView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displaysPageBreaks = true
        view.document = PDFDocument(url: url)
        return view
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        if nsView.document?.documentURL != url {
            nsView.document = PDFDocument(url: url)
        }
    }
}
