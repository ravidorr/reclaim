import SwiftUI

struct DownloadsBrowserView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = DownloadsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Category picker
            categoryPicker
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)

            Divider()

            // Category content
            if vm.isScanning {
                ProgressView("Scanning Downloads…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                categoryView
            }
        }
        .navigationTitle("Downloads")
        .task { await vm.scan() }
    }

    // MARK: - Category picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(FileCategory.allCases) { category in
                    let count = vm.allFiles.filter { $0.category == category }.count
                    CategoryChip(
                        category: category,
                        count: count,
                        isSelected: vm.selectedCategory == category
                    )
                    .onTapGesture {
                        vm.deselectAll()
                        vm.selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Content per category

    @ViewBuilder
    private var categoryView: some View {
        switch vm.selectedCategory {
        case .images:
            ImageGalleryView(vm: vm, recordFreed: appState.recordFreed)
        case .videos:
            VideoGalleryView(vm: vm, recordFreed: appState.recordFreed)
        case .pdfs:
            PDFListView(vm: vm, recordFreed: appState.recordFreed)
        case .documents:
            DocumentListView(vm: vm, recordFreed: appState.recordFreed)
        case .audio:
            AudioListView(vm: vm, recordFreed: appState.recordFreed)
        case .archives:
            ArchiveListView(vm: vm, recordFreed: appState.recordFreed)
        case .other:
            OtherFilesListView(vm: vm, recordFreed: appState.recordFreed)
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: FileCategory
    let count: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.systemImage)
                .font(.caption.weight(.semibold))
            Text(category.displayName)
                .font(.caption.weight(.semibold))
            if count > 0 {
                Text("\(count)")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
        .foregroundStyle(isSelected ? .white : .primary)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
