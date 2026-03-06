import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedPanel: Panel = .dashboard
    @AppStorage("totalFreedBytes") var totalFreedBytes: Double = 0

    var totalFreedFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalFreedBytes), countStyle: .file)
    }

    func recordFreed(_ bytes: Int64) {
        totalFreedBytes += Double(bytes)
    }
}

enum Panel: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case caches    = "System Caches"
    case downloads = "Downloads"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "gauge.medium"
        case .caches:    return "trash.circle"
        case .downloads: return "arrow.down.circle"
        }
    }
}
