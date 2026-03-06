import Foundation

@MainActor
public final class CachesViewModel: ObservableObject {
    @Published public var targets: [ManagedCacheTarget] = CacheTarget.all.map { ManagedCacheTarget(target: $0) }
    @Published public var isMeasuringAll = false

    public init() {}

    public var totalMeasured: Int64 {
        targets.compactMap(\.measuredSize).reduce(0, +)
    }

    public func measureAll() async {
        isMeasuringAll = true
        await withTaskGroup(of: Void.self) { group in
            for target in targets {
                group.addTask { await target.measure() }
            }
        }
        isMeasuringAll = false
    }

    public func cleanAll(recordFreed: (Int64) -> Void) async {
        for target in targets where target.state == .idle || {
            if case .done = target.state { return false }
            return true
        }() {
            await target.clean(recordFreed: recordFreed)
        }
    }
}

@MainActor
public final class ManagedCacheTarget: ObservableObject, Identifiable {
    public let id = UUID()
    public let target: CacheTarget

    @Published public var measuredSize: Int64?
    @Published public var state: State = .idle

    public enum State: Equatable {
        case idle, measuring, cleaning, done(freed: Int64), failed(String)
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.measuring, .measuring), (.cleaning, .cleaning): return true
            case (.done(let a), .done(let b)): return a == b
            case (.failed(let a), .failed(let b)): return a == b
            default: return false
            }
        }
    }

    public init(target: CacheTarget) {
        self.target = target
    }

    public func measure() async {
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

    public func clean(recordFreed: (Int64) -> Void) async {
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
