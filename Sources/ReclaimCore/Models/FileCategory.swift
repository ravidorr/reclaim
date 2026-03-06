import Foundation

public enum FileCategory: String, CaseIterable, Identifiable {
    case images    = "Images"
    case videos    = "Videos"
    case pdfs      = "PDFs"
    case documents = "Documents"
    case audio     = "Audio"
    case archives  = "Archives"
    case other     = "Other"

    public var id: String { rawValue }

    public var icon: String { systemImage }

    public var systemImage: String {
        switch self {
        case .images:    return "photo.on.rectangle"
        case .videos:    return "film"
        case .pdfs:      return "doc.richtext"
        case .documents: return "doc.text"
        case .audio:     return "waveform"
        case .archives:  return "archivebox"
        case .other:     return "doc"
        }
    }

    public var displayName: String { rawValue }

    public static func category(for url: URL) -> FileCategory {
        switch url.pathExtension.lowercased() {
        case "png", "jpg", "jpeg", "gif", "svg", "webp", "bmp", "tiff", "tif", "heic":
            return .images
        case "mp4", "mov", "avi", "mkv", "webm", "m4v":
            return .videos
        case "pdf":
            return .pdfs
        case "docx", "doc", "csv", "txt", "md", "json", "xlsx", "xls", "pptx", "numbers", "pages",
             "html", "htm", "xml", "yaml", "yml":
            return .documents
        case "mp3", "m4a", "wav", "aac", "flac", "ogg", "aiff":
            return .audio
        case "zip", "tar", "gz", "tgz", "rar", "7z", "bz2":
            return .archives
        default:
            return .other
        }
    }
}
