import Foundation

@MainActor
final class CachesViewModel: ObservableObject {
    @Published var targets: [ManagedCacheTarget] = CacheTarget.all.map { ManagedCacheTarget(target: $0) }
    @Published var isMeasuringAll = false

    var totalMeasured: Int64 {
        targets.compactMap(\.measuredSize).reduce(0, +)
    }

    func measureAll() async {
        isMeasuringAll = true
        await withTaskGroup(of: Void.self) { group in
            for target in targets {
                group.addTask { await target.measure() }
            }
        }
        isMeasuringAll = false
    }

    func cleanAll(recordFreed: (Int64) -> Void) async {
        for target in targets where target.state == .idle || {
            if case .done = target.state { return false }
            return true
        }() {
            await target.clean(recordFreed: recordFreed)
        }
    }
}

@MainActor
final class ManagedCacheTarget: ObservableObject, Identifiable {
    let id = UUID()
    let target: CacheTarget

    @Published var measuredSize: Int64?
    @Published var state: State = .idle

    enum State: Equatable {
        case idle, measuring, cleaning, done(freed: Int64), failed(String)
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.measuring, .measuring), (.cleaning, .cleaning): return true
            case (.done(let a), .done(let b)): return a == b
            case (.failed(let a), .failed(let b)): return a == b
            default: return false
            }
        }
    }

    init(target: CacheTarget) {
        self.target = target
    }

    func measure() async {
        state = .measuring
        switch target.kind {
        case .directory(let path):
            measuredSize = await FileSizeScanner.shared.size(of: path)
        case .directories(let paths):
            var total: Int64 = 0
            for p in paths { total += await FileSizeScanner.shared.size(of: p) }
            measuredSize = total
        case .command:
            measuredSize = nil // Can't pre-measure shell commands
        }
        state = .idle
    }

    func clean(recordFreed: (Int64) -> Void) async {
        state = .cleaning
        do {
            var freed: Int64 = 0
            switch target.kind {
            case .directory(let path):
                freed = try await FileDeletionService.shared.deleteDirectory(at: path)
            case .directories(let paths):
                for p in paths {
                    freed += (try? await FileDeletionService.shared.deleteDirectory(at: p)) ?? 0
                }
            case .command(let args):
                _ = try await ShellRunner.shared.run(args)
                freed = measuredSize ?? 0
            }
            state = .done(freed: freed)
            recordFreed(freed)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
