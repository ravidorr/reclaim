import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Disk ring + stats
                HStack(spacing: 40) {
                    DiskRingChart(usage: vm.diskUsage)

                    VStack(alignment: .leading, spacing: 14) {
                        statRow("Total",     vm.diskUsage.formattedTotal, .primary)
                        statRow("Used",      vm.diskUsage.formattedUsed,  .blue)
                        statRow("Available", vm.diskUsage.formattedFree,  .green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
                .background(.quinary, in: RoundedRectangle(cornerRadius: 16))

                // Total freed banner
                if appState.totalFreedBytes > 0 {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                        Text("You've freed **\(appState.totalFreedFormatted)** in this session.")
                            .font(.callout)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }

                // Quick-action cards
                HStack(spacing: 16) {
                    quickCard("System Caches", icon: "trash.circle.fill", color: .orange, panel: .caches)
                    quickCard("Downloads",     icon: "arrow.down.circle.fill", color: .blue,   panel: .downloads)
                }
            }
            .padding(24)
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem {
                Button {
                    vm.refresh()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(vm.isRefreshing)
            }
        }
        .onAppear { vm.refresh() }
    }

    // MARK: – Helpers

    private func statRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 75, alignment: .leading)
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .font(.callout)
    }

    private func quickCard(_ title: String, icon: String, color: Color, panel: Panel) -> some View {
        Button {
            appState.selectedPanel = panel
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
                Text(title)
                    .font(.callout.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.quinary, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
