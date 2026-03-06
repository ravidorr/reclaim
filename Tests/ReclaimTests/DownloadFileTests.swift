import XCTest
@testable import ReclaimCore

final class DownloadFileTests: XCTestCase {

    // MARK: - Helpers

    private func makeFile(size: Int64, date: Date = Date()) -> DownloadFile {
        DownloadFile(
            url: URL(fileURLWithPath: "/tmp/test.pdf"),
            name: "test.pdf",
            size: size,
            modifiedDate: date,
            category: .pdfs
        )
    }

    // MARK: - formattedSize

    func testFormattedSizeIsNeverEmpty() {
        XCTAssertFalse(makeFile(size: 0).formattedSize.isEmpty)
        XCTAssertFalse(makeFile(size: 1).formattedSize.isEmpty)
        XCTAssertFalse(makeFile(size: Int64.max).formattedSize.isEmpty)
    }

    func testFormattedSizeMegabytes() {
        let file = makeFile(size: 5_000_000)
        XCTAssertTrue(file.formattedSize.contains("MB"),
                      "5 MB file should display in MB, got: \(file.formattedSize)")
    }

    func testFormattedSizeGigabytes() {
        let file = makeFile(size: 2_000_000_000)
        XCTAssertTrue(file.formattedSize.contains("GB"),
                      "2 GB file should display in GB, got: \(file.formattedSize)")
    }

    // MARK: - formattedDate

    func testFormattedDateIsNeverEmpty() {
        XCTAssertFalse(makeFile(size: 0).formattedDate.isEmpty)
    }

    func testFormattedDateContainsYear() {
        let components = DateComponents(year: 2023, month: 1, day: 15)
        let date = Calendar.current.date(from: components)!
        let file = makeFile(size: 100, date: date)
        XCTAssertTrue(file.formattedDate.contains("2023"),
                      "Formatted date should contain the year, got: \(file.formattedDate)")
    }

    // MARK: - Category assignment

    func testCategoryIsStoredCorrectly() {
        let file = DownloadFile(
            url: URL(fileURLWithPath: "/tmp/video.mp4"),
            name: "video.mp4",
            size: 0,
            modifiedDate: Date(),
            category: .videos
        )
        XCTAssertEqual(file.category, .videos)
    }

    // MARK: - hasExtractedSibling default

    func testHasExtractedSiblingDefaultsFalse() {
        XCTAssertFalse(makeFile(size: 0).hasExtractedSibling)
    }
}
