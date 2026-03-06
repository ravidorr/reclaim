import XCTest
@testable import ReclaimCore

@MainActor
final class DownloadsViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeFile(
        category: FileCategory,
        size: Int64 = 1_000,
        hasExtractedSibling: Bool = false
    ) -> DownloadFile {
        var file = DownloadFile(
            url: URL(fileURLWithPath: "/tmp/test.\(category.rawValue.lowercased())"),
            name: "test",
            size: size,
            modifiedDate: Date(),
            category: category
        )
        file.hasExtractedSibling = hasExtractedSibling
        return file
    }

    // MARK: - filteredFiles

    func testFilteredFilesReturnsOnlySelectedCategory() {
        let vm = DownloadsViewModel()
        vm.allFiles = [
            makeFile(category: .images),
            makeFile(category: .pdfs),
            makeFile(category: .images),
        ]
        vm.selectedCategory = .images
        XCTAssertEqual(vm.filteredFiles.count, 2)
    }

    func testFilteredFilesIsEmptyWhenNoCategoryMatch() {
        let vm = DownloadsViewModel()
        vm.allFiles = [makeFile(category: .images)]
        vm.selectedCategory = .pdfs
        XCTAssertTrue(vm.filteredFiles.isEmpty)
    }

    // MARK: - toggleSelection

    func testToggleSelectionAddsFile() {
        let vm = DownloadsViewModel()
        let file = makeFile(category: .pdfs)
        vm.allFiles = [file]
        vm.selectedCategory = .pdfs

        vm.toggleSelection(file)
        XCTAssertTrue(vm.selection.contains(file))
    }

    func testToggleSelectionRemovesAlreadySelectedFile() {
        let vm = DownloadsViewModel()
        let file = makeFile(category: .pdfs)
        vm.allFiles = [file]
        vm.selectedCategory = .pdfs
        vm.selection = [file]

        vm.toggleSelection(file)
        XCTAssertFalse(vm.selection.contains(file))
    }

    // MARK: - selectAll / deselectAll

    func testSelectAllSelectsOnlyCurrentCategoryFiles() {
        let vm = DownloadsViewModel()
        let pdf1 = makeFile(category: .pdfs)
        let pdf2 = makeFile(category: .pdfs)
        let img  = makeFile(category: .images)
        vm.allFiles = [pdf1, pdf2, img]
        vm.selectedCategory = .pdfs

        vm.selectAll()

        XCTAssertTrue(vm.selection.contains(pdf1))
        XCTAssertTrue(vm.selection.contains(pdf2))
        XCTAssertFalse(vm.selection.contains(img))
    }

    func testDeselectAllOnlyDeselectsCurrentCategory() {
        let vm = DownloadsViewModel()
        let pdf = makeFile(category: .pdfs)
        let img = makeFile(category: .images)
        vm.allFiles = [pdf, img]
        vm.selection = [pdf, img]
        vm.selectedCategory = .pdfs

        vm.deselectAll()

        XCTAssertFalse(vm.selection.contains(pdf), "PDF should be deselected")
        XCTAssertTrue(vm.selection.contains(img),  "Image should remain selected")
    }

    // MARK: - selectExtractedArchives

    func testSelectExtractedArchivesOnlySelectsFilesWithSibling() {
        let vm = DownloadsViewModel()
        let extracted    = makeFile(category: .archives, hasExtractedSibling: true)
        let notExtracted = makeFile(category: .archives, hasExtractedSibling: false)
        vm.allFiles = [extracted, notExtracted]
        vm.selectedCategory = .archives

        vm.selectExtractedArchives()

        XCTAssertTrue(vm.selection.contains(extracted))
        XCTAssertFalse(vm.selection.contains(notExtracted))
    }

    func testSelectExtractedArchivesAddsToExistingSelection() {
        let vm = DownloadsViewModel()
        let alreadySelected = makeFile(category: .archives, hasExtractedSibling: false)
        let extracted       = makeFile(category: .archives, hasExtractedSibling: true)
        vm.allFiles = [alreadySelected, extracted]
        vm.selectedCategory = .archives
        vm.selection = [alreadySelected]

        vm.selectExtractedArchives()

        XCTAssertTrue(vm.selection.contains(alreadySelected), "Pre-selected file should remain")
        XCTAssertTrue(vm.selection.contains(extracted),       "Extracted sibling should be added")
    }

    // MARK: - selectionSize

    func testSelectionSizeIsNeverEmpty() {
        let vm = DownloadsViewModel()
        vm.selection = [makeFile(category: .pdfs, size: 1_000_000)]
        XCTAssertFalse(vm.selectionSize.isEmpty)
    }

    func testSelectionSizeReflectsMegabytes() {
        let vm = DownloadsViewModel()
        vm.selection = [
            makeFile(category: .pdfs, size: 3_000_000),
            makeFile(category: .pdfs, size: 2_000_000),
        ]
        XCTAssertTrue(vm.selectionSize.contains("MB"),
                      "5 MB total should display in MB, got: \(vm.selectionSize)")
    }

    func testEmptySelectionSizeIsZeroBytes() {
        let vm = DownloadsViewModel()
        vm.selection = []
        XCTAssertFalse(vm.selectionSize.isEmpty)
    }
}
