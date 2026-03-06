// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Reclaim",
    platforms: [.macOS(.v13)],
    targets: [
        // Pure-Swift library: Models, Services, ViewModels.
        // No SwiftUI dependency — fully unit-testable.
        .target(
            name: "ReclaimCore",
            path: "Sources/ReclaimCore"
        ),

        // Main app executable: App entry point + all SwiftUI views.
        .executableTarget(
            name: "Reclaim",
            dependencies: ["ReclaimCore"],
            path: "Sources/Reclaim"
        ),

        // Unit tests — depend only on ReclaimCore, not the executable.
        .testTarget(
            name: "ReclaimTests",
            dependencies: ["ReclaimCore"],
            path: "Tests/ReclaimTests"
        ),
    ]
)
