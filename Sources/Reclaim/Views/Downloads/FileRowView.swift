import SwiftUI

struct FileRowView: View {
    let file: DownloadFile
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .font(.title3)
                .onTapGesture { onToggle() }

            // File type icon
            Image(systemName: iconName)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            // Name + path
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .lineLimit(1)
                if file.hasExtractedSibling {
                    Label("Extracted folder exists", systemImage: "arrow.down.doc")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            // Size + date
            VStack(alignment: .trailing, spacing: 2) {
                Text(file.formattedSize)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                Text(file.formattedDate)
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        // No whole-row tap here — the parent (PDFListView, DocumentListView, etc.)
        // attaches its own .onTapGesture to trigger preview.
        // Only the checkbox icon above handles selection toggling.
    }

    private var iconName: String {
        switch file.category {
        case .images:    return "photo"
        case .videos:    return "film"
        case .pdfs:      return "doc.richtext"
        case .documents: return "doc.text"
        case .audio:     return "waveform"
        case .archives:  return "archivebox"
        case .other:     return "doc"
        }
    }
}
