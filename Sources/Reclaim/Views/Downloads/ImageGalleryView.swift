import SwiftUI
import QuickLook

struct ImageGalleryView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    @State private var previewURL: URL?
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 10)]

    var body: some View {
        ScrollView {
            if vm.filteredFiles.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(vm.filteredFiles) { file in
                        ImageThumbnailCell(
                            file: file,
                            isSelected: vm.selection.contains(file),
                            onToggle: { vm.toggleSelection(file) },
                            onPreview: { previewURL = file.url }
                        )
                    }
                }
                .padding()
            }
        }
        .quickLookPreview($previewURL)
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
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No images in Downloads")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(60)
    }
}

struct ImageThumbnailCell: View {
    let file: DownloadFile
    let isSelected: Bool
    let onToggle: () -> Void
    let onPreview: () -> Void

    @State private var thumbnail: NSImage?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: onPreview) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.1))

                    if let thumb = thumbnail {
                        Image(nsImage: thumb)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(.tertiary)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
                )
                .overlay(alignment: .bottom) {
                    VStack(spacing: 0) {
                        Text(file.name)
                            .font(.caption2)
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(UnevenRoundedRectangle(
                        bottomLeadingRadius: 10, bottomTrailingRadius: 10
                    ))
                }
            }
            .buttonStyle(.plain)

            // Checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle.fill")
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .background(isSelected ? Color.accentColor : Color.black.opacity(0.3), in: Circle())
                .font(.title3)
                .padding(6)
                .onTapGesture { onToggle() }
        }
        .task {
            thumbnail = await loadThumbnail(for: file.url)
        }
    }

    private func loadThumbnail(for url: URL) async -> NSImage? {
        await Task.detached(priority: .utility) {
            // For SVGs and other formats, NSImage handles them directly
            if let img = NSImage(contentsOf: url) {
                return img
            }
            return nil
        }.value
    }
}
