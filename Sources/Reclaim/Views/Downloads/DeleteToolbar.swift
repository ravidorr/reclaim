import SwiftUI

struct DeleteToolbar: ToolbarContent {
    let selectionCount: Int
    let selectionSize: String
    let onSelectAll: () -> Void
    let onDeselectAll: () -> Void
    let onDelete: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if selectionCount > 0 {
                Text("\(selectionCount) selected · \(selectionSize)")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                Button("Deselect All", action: onDeselectAll)

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Selected", systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                Button("Select All", action: onSelectAll)
            }
        }
    }
}
