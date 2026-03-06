import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(Panel.allCases, selection: $appState.selectedPanel) { panel in
            Label(panel.rawValue, systemImage: panel.icon)
                .tag(panel)
        }
        .listStyle(.sidebar)
        .navigationTitle("Reclaim")
        .safeAreaInset(edge: .bottom) {
            if appState.totalFreedBytes > 0 {
                VStack(spacing: 2) {
                    Text("Total Freed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(appState.totalFreedFormatted)
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.bar)
            }
        }
    }
}
