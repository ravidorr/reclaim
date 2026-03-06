import SwiftUI

struct CachesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = CachesViewModel()

    var body: some View {
        List {
            Section {
                ForEach(vm.targets) { item in
                    CacheTargetRow(item: item) {
                        await item.clean { appState.recordFreed($0) }
                    }
                }
            } header: {
                HStack {
                    Text("Cleanable Caches")
                    Spacer()
                    if vm.totalMeasured > 0 {
                        Text(ByteCountFormatter.string(fromByteCount: vm.totalMeasured, countStyle: .file) + " measured")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("System Caches")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task { await vm.measureAll() }
                } label: {
                    Label("Measure All", systemImage: "ruler")
                }
                .disabled(vm.isMeasuringAll)

                Button {
                    Task { await vm.cleanAll { appState.recordFreed($0) } }
                } label: {
                    Label("Clean All", systemImage: "trash")
                }
                .tint(.orange)
            }
        }
    }
}
