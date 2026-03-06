import SwiftUI
import AVKit

struct VideoGalleryView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    @State private var playerItem: (url: URL, player: AVPlayer)?
    private let columns = [GridItem(.adaptive(minimum: 200, maximum: 260), spacing: 10)]

    var body: some View {
        ScrollView {
            if vm.filteredFiles.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(vm.filteredFiles) { file in
                        VideoThumbnailCell(
                            file: file,
                            isSelected: vm.selection.contains(file),
                            onToggle: { vm.toggleSelection(file) },
                            onPlay: {
                                let player = AVPlayer(url: file.url)
                                playerItem = (url: file.url, player: player)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(item: Binding(
            get: { playerItem.map { VideoItem(url: $0.url, player: $0.player) } },
            set: { if $0 == nil { playerItem?.player.pause(); playerItem = nil } }
        )) { item in
            VStack(spacing: 0) {
                HStack {
                    Text(item.url.lastPathComponent)
                        .font(.callout)
                        .lineLimit(1)
                    Spacer()
                    Button("Done") {
                        item.player.pause()
                        playerItem = nil
                    }
                }
                .padding()
                VideoPlayer(player: item.player)
                    .frame(minWidth: 640, minHeight: 400)
            }
            .onAppear { item.player.play() }
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
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No videos in Downloads")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(60)
    }
}

private struct VideoItem: Identifiable {
    let id = UUID()
    let url: URL
    let player: AVPlayer
}

struct VideoThumbnailCell: View {
    let file: DownloadFile
    let isSelected: Bool
    let onToggle: () -> Void
    let onPlay: () -> Void

    @State private var thumbnail: NSImage?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: onPlay) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)

                    if let thumb = thumbnail {
                        Image(nsImage: thumb)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    }

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 4)
                }
                .aspectRatio(16/9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
                )
                .overlay(alignment: .bottom) {
                    HStack {
                        Text(file.name)
                            .font(.caption2)
                            .lineLimit(1)
                        Spacer()
                        Text(file.formattedSize)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(UnevenRoundedRectangle(
                        bottomLeadingRadius: 10, bottomTrailingRadius: 10
                    ))
                }
            }
            .buttonStyle(.plain)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle.fill")
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .background(isSelected ? Color.accentColor : Color.black.opacity(0.3), in: Circle())
                .font(.title3)
                .padding(6)
                .onTapGesture { onToggle() }
        }
        .task {
            thumbnail = await generateVideoThumbnail(for: file.url)
        }
    }

    private func generateVideoThumbnail(for url: URL) async -> NSImage? {
        await Task.detached(priority: .utility) {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 520, height: 320)
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }
            return NSImage(cgImage: cgImage, size: .zero)
        }.value
    }
}
