import Foundation

struct CacheTarget: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let kind: Kind

    enum Kind {
        /// Clean by removing a directory
        case directory(path: String)
        /// Clean by running a shell command
        case command(args: [String])
        /// Multiple directories to remove
        case directories(paths: [String])
    }

    // MARK: – Presets

    static let all: [CacheTarget] = [
        CacheTarget(
            name: "User Caches",
            icon: "folder.badge.gear",
            description: "~/Library/Caches",
            kind: .directory(path: ("~/Library/Caches" as NSString).expandingTildeInPath)
        ),
        CacheTarget(
            name: "Homebrew",
            icon: "shippingbox",
            description: "brew cleanup --prune=all",
            kind: .command(args: ["brew", "cleanup", "--prune=all"])
        ),
        CacheTarget(
            name: "npm Cache",
            icon: "cube",
            description: "~/.npm",
            kind: .directory(path: ("~/.npm" as NSString).expandingTildeInPath)
        ),
        CacheTarget(
            name: "Go Build Cache",
            icon: "chevron.left.forwardslash.chevron.right",
            description: "go clean -cache",
            kind: .command(args: ["go", "clean", "-cache", "-testcache", "-fuzzcache"])
        ),
        CacheTarget(
            name: "uv Python Cache",
            icon: "snake",
            description: "uv cache clean",
            kind: .command(args: ["uv", "cache", "clean"])
        ),
        CacheTarget(
            name: "Xcode Simulators",
            icon: "iphone",
            description: "xcrun simctl delete unavailable",
            kind: .command(args: ["xcrun", "simctl", "delete", "unavailable"])
        ),
        CacheTarget(
            name: "Log Files",
            icon: "doc.plaintext",
            description: "~/Library/Logs",
            kind: .directory(path: ("~/Library/Logs" as NSString).expandingTildeInPath)
        ),
    ]
}
