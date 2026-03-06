import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var diskUsage: DiskUsage = .zero
    @Published var isRefreshing = false

    func refresh() {
        isRefreshing = true
        diskUsage = DiskUsageService.currentUsage()
        isRefreshing = false
    }
}
