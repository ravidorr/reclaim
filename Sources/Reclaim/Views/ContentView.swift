import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            switch appState.selectedPanel {
            case .dashboard: DashboardView()
            case .caches:    CachesView()
            case .downloads: DownloadsBrowserView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
