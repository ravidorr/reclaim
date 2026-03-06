import Foundation
import Combine

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public var diskUsage: DiskUsage = .zero
    @Published public var isRefreshing = false

    public init() {}

    public func refresh() {
        isRefreshing = true
        diskUsage = DiskUsageService.currentUsage()
        isRefreshing = false
    }
}
