import SwiftUI
import WebKit
import Quartz

struct DocumentListView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    @State private var selectedFile: DownloadFile?
    @State private var previewText: String = ""
    @State private var isLoadingPreview = false

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
                .onTapGesture {
                    guard selectedFile?.id != file.id else { return }
                    selectedFile = file
                    loadTextPreview(for: file)
                }
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

            // Right: preview panel (type-specific)
            Group {
                if let file = selectedFile {
                    previewPanel(for: file)
                        .id(file.id) // force recreation on file change
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

    // MARK: - Preview routing

    @ViewBuilder
    private func previewPanel(for file: DownloadFile) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar
            HStack {
                Label(file.name, systemImage: iconName(for: file))
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Spacer()
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([file.url])
                }
                .buttonStyle(.link)
                .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)

            Divider()

            // Body
            let ext = file.url.pathExtension.lowercased()
            if ["html", "htm"].contains(ext) {
                WebPreviewView(url: file.url)
            } else if isTextRenderable(ext) {
                textPreview
            } else {
                // DOCX, XLSX, PPTX, Pages, Numbers, etc. — use QLPreviewView
                QLPreviewPanel(url: file.url)
            }
        }
    }

    // MARK: - Text preview

    @ViewBuilder
    private var textPreview: some View {
        if isLoadingPreview {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                Text(previewText.isEmpty ? "(empty file)" : previewText)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
        }
    }

    private func loadTextPreview(for file: DownloadFile) {
        let ext = file.url.pathExtension.lowercased()
        guard isTextRenderable(ext) else { previewText = ""; return }
        isLoadingPreview = true
        previewText = ""
        Task.detached(priority: .userInitiated) {
            let raw = (try? String(contentsOf: file.url, encoding: .utf8))
                   ?? (try? String(contentsOf: file.url, encoding: .isoLatin1))
                   ?? "(binary or unreadable content)"
            let truncated = raw.count > 60_000
                ? String(raw.prefix(60_000)) + "\n\n… (truncated)"
                : raw
            await MainActor.run {
                self.previewText = truncated
                self.isLoadingPreview = false
            }
        }
    }

    private func isTextRenderable(_ ext: String) -> Bool {
        ["txt", "md", "csv", "json", "xml", "yaml", "yml",
         "log", "sh", "py", "js", "ts", "css"].contains(ext)
    }

    private func iconName(for file: DownloadFile) -> String {
        switch file.url.pathExtension.lowercased() {
        case "csv":               return "tablecells"
        case "json":              return "curlybraces"
        case "md":                return "text.badge.star"
        case "html", "htm":       return "globe"
        case "docx", "doc":       return "doc.richtext"
        default:                  return "doc.text"
        }
    }

    // MARK: - Empty / placeholder states

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No documents in Downloads")
                .foregroundStyle(.secondary)
        }
    }

    private var placeholderPanel: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("Select a document to preview")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - WKWebView for HTML files

private struct WebPreviewView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}

// MARK: - QLPreviewView for binary formats (DOCX, XLSX, PPTX, etc.)

private struct QLPreviewPanel: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .normal)!
        view.autostarts = true
        view.previewItem = url as NSURL
        return view
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        // .id(file.id) on parent forces full recreation; this is a safety net
        nsView.previewItem = url as NSURL
    }
}
