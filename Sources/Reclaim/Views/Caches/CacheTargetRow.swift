import SwiftUI

struct CacheTargetRow: View {
    @ObservedObject var item: ManagedCacheTarget
    let onClean: () async -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.target.icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.target.name)
                    .fontWeight(.medium)
                Text(item.target.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            sizeLabel

            cleanButton
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var sizeLabel: some View {
        switch item.state {
        case .idle:
            if let size = item.measuredSize {
                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        case .measuring:
            ProgressView().scaleEffect(0.6)
        case .cleaning:
            Text("Cleaning…")
                .font(.callout)
                .foregroundStyle(.secondary)
        case .done(let freed):
            Label(ByteCountFormatter.string(fromByteCount: freed, countStyle: .file) + " freed",
                  systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.callout)
        case .failed(let msg):
            Label(msg, systemImage: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var cleanButton: some View {
        switch item.state {
        case .done, .cleaning, .measuring:
            EmptyView()
        default:
            Button("Clean") {
                Task { await onClean() }
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .controlSize(.small)
        }
    }
}
