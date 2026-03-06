import Foundation

public actor ShellRunner {
    public static let shared = ShellRunner()

    /// Runs a command and returns the combined stdout+stderr output.
    public func run(_ args: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            // Use /usr/bin/env so we pick up PATH-installed tools (brew, go, npm, etc.)
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = args
            process.environment = Self.loginEnvironment()

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError  = pipe

            process.terminationHandler = { _ in
                let data   = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                continuation.resume(returning: output)
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Builds a PATH-rich environment so tools installed via Homebrew/nvm/pyenv are found.
    private static func loginEnvironment() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        let extraPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin",
        ].joined(separator: ":")
        let existing = env["PATH"] ?? ""
        env["PATH"] = "\(extraPaths):\(existing)"
        return env
    }
}
