import XCTest
@testable import ReclaimCore

final class FileCategoryTests: XCTestCase {

    private func url(_ filename: String) -> URL {
        URL(fileURLWithPath: "/tmp/\(filename)")
    }

    // MARK: - Images

    func testImageExtensions() {
        let extensions = ["png", "jpg", "jpeg", "gif", "svg", "webp", "bmp", "tiff", "tif", "heic"]
        for ext in extensions {
            XCTAssertEqual(FileCategory.category(for: url("file.\(ext)")), .images,
                           "Expected .images for .\(ext)")
        }
    }

    // MARK: - Videos

    func testVideoExtensions() {
        let extensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v"]
        for ext in extensions {
            XCTAssertEqual(FileCategory.category(for: url("file.\(ext)")), .videos,
                           "Expected .videos for .\(ext)")
        }
    }

    // MARK: - PDFs

    func testPDFExtension() {
        XCTAssertEqual(FileCategory.category(for: url("report.pdf")), .pdfs)
    }

    // MARK: - Documents

    func testDocumentExtensions() {
        let extensions = [
            "docx", "doc", "csv", "txt", "md", "json",
            "xlsx", "xls", "pptx", "numbers", "pages",
            "html", "htm", "xml", "yaml", "yml",
        ]
        for ext in extensions {
            XCTAssertEqual(FileCategory.category(for: url("file.\(ext)")), .documents,
                           "Expected .documents for .\(ext)")
        }
    }

    // MARK: - Audio

    func testAudioExtensions() {
        let extensions = ["mp3", "m4a", "wav", "aac", "flac", "ogg", "aiff"]
        for ext in extensions {
            XCTAssertEqual(FileCategory.category(for: url("file.\(ext)")), .audio,
                           "Expected .audio for .\(ext)")
        }
    }

    // MARK: - Archives

    func testArchiveExtensions() {
        let extensions = ["zip", "tar", "gz", "tgz", "rar", "7z", "bz2"]
        for ext in extensions {
            XCTAssertEqual(FileCategory.category(for: url("file.\(ext)")), .archives,
                           "Expected .archives for .\(ext)")
        }
    }

    // MARK: - Other / edge cases

    func testUnknownExtensionFallsToOther() {
        XCTAssertEqual(FileCategory.category(for: url("file.xyz")), .other)
        XCTAssertEqual(FileCategory.category(for: url("file.dmg")), .other)
        XCTAssertEqual(FileCategory.category(for: url("file.bin")), .other)
    }

    func testNoExtensionFallsToOther() {
        XCTAssertEqual(FileCategory.category(for: url("Makefile")), .other)
        XCTAssertEqual(FileCategory.category(for: url("Dockerfile")), .other)
    }

    func testExtensionMatchingIsCaseInsensitive() {
        XCTAssertEqual(FileCategory.category(for: url("file.PDF")),  .pdfs)
        XCTAssertEqual(FileCategory.category(for: url("file.JPG")),  .images)
        XCTAssertEqual(FileCategory.category(for: url("file.ZIP")),  .archives)
        XCTAssertEqual(FileCategory.category(for: url("file.Mp4")),  .videos)
        XCTAssertEqual(FileCategory.category(for: url("file.HTML")), .documents)
    }
}
