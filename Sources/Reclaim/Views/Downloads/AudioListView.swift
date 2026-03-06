import SwiftUI
import AVFoundation

struct AudioListView: View {
    @ObservedObject var vm: DownloadsViewModel
    let recordFreed: (Int64) -> Void

    @StateObject private var player = AudioPlayerController()

    var body: some View {
        List(vm.filteredFiles) { file in
            AudioRow(
                file: file,
                isSelected: vm.selection.contains(file),
                isPlaying: player.currentURL == file.url && player.isPlaying,
                onToggle: { vm.toggleSelection(file) },
                onPlayPause: { player.togglePlayback(url: file.url) }
            )
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .overlay {
            if vm.filteredFiles.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("No audio files in Downloads")
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
        .onDisappear {
            player.stop()
        }
    }
}

// MARK: - Audio Row

private struct AudioRow: View {
    let file: DownloadFile
    let isSelected: Bool
    let isPlaying: Bool
    let onToggle: () -> Void
    let onPlayPause: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                .font(.title3)
                .onTapGesture { onToggle() }

            // Play/pause button
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(isPlaying ? Color.accentColor : Color.secondary)
                    .scaleEffect(isPlaying ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: isPlaying)
            }
            .buttonStyle(.plain)

            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.body)
                    .lineLimit(1)
                Text(file.formattedSize + " · " + file.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Waveform animation when playing
            if isPlaying {
                WaveformIndicator()
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { onPlayPause() }
    }
}

// MARK: - Animated waveform indicator

private struct WaveformIndicator: View {
    @State private var phase = false

    let heights: [CGFloat] = [8, 14, 20, 14, 8, 18, 12]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(heights.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(width: 3, height: phase ? heights[i] : heights[(i + 3) % heights.count])
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.07),
                        value: phase
                    )
            }
        }
        .onAppear { phase = true }
        .frame(height: 24)
    }
}

// MARK: - Audio Player Controller

@MainActor
final class AudioPlayerController: ObservableObject {
    @Published var isPlaying = false
    @Published var currentURL: URL?

    private var player: AVAudioPlayer?

    func togglePlayback(url: URL) {
        if currentURL == url {
            if isPlaying {
                player?.pause()
                isPlaying = false
            } else {
                player?.play()
                isPlaying = true
            }
        } else {
            stop()
            do {
                let p = try AVAudioPlayer(contentsOf: url)
                p.prepareToPlay()
                p.play()
                player = p
                currentURL = url
                isPlaying = true
            } catch {
                print("Audio playback error: \(error)")
            }
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentURL = nil
    }
}
