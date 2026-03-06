# Reclaim

A native macOS app for reclaiming disk space. Browse and delete files from your Downloads folder by category, measure and clean system caches, and track how much space you've freed — all without touching the terminal.

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
![Architecture](https://img.shields.io/badge/arch-arm64%20%7C%20x86__64-green)

---

## Features

### Dashboard
- Disk usage ring chart showing used vs. free space
- Cumulative "total freed" counter, persisted across sessions

### System Caches
Measure and clean caches for:
- Homebrew (`brew cleanup --prune=all`)
- npm (`npm cache clean --force`)
- Go (`go clean -cache -testcache -fuzzcache`)
- uv (`uv cache clean`)
- Xcode Simulators (`xcrun simctl delete unavailable`)
- macOS system logs (`~/Library/Logs`)

### Downloads Browser
Seven category tabs, each with a tailored UI:

| Tab | View | Preview |
|-----|------|---------|
| Images | Thumbnail grid | QuickLook |
| Videos | Thumbnail grid | Inline AVPlayer |
| PDFs | File list | Inline PDFKit |
| Documents | File list | Text / HTML / QuickLook |
| Audio | File list | Play/pause per row |
| Archives | File list | Extracted-folder warnings |
| Other | File list | — |

Files are moved to **Trash** (not permanently deleted), so mistakes are recoverable.

---

## Requirements

- macOS 13 Ventura or later
- Swift 5.9+ (`xcode-select --install`)

---

## Build & Install

Clone the repo and run the build script:

```bash
git clone https://github.com/ravidorr/reclaim.git
cd reclaim
./make_app.sh --install
```

This will:
1. Compile a **universal binary** (arm64 + x86_64)
2. Package it as `Reclaim.app`
3. Copy it to `/Applications`

You can then launch Reclaim from Spotlight (`⌘Space → Reclaim`) or from `/Applications`.

To build without installing:
```bash
./make_app.sh        # produces Reclaim.app in the repo folder
open Reclaim.app     # run it directly
```

---

## Auto-launch on the 1st of every month

Create a launchd agent so Reclaim opens automatically as a monthly reminder:

```bash
cat > ~/Library/LaunchAgents/com.ravidor.reclaim.monthly.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ravidor.reclaim.monthly</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>/Applications/Reclaim.app</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Day</key>    <integer>1</integer>
        <key>Hour</key>   <integer>9</integer>
        <key>Minute</key> <integer>0</integer>
    </dict>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.ravidor.reclaim.monthly.plist
```

---

## Project Structure

```
reclaim/
├── Package.swift          # Swift Package Manager manifest
├── Info.plist             # App bundle metadata
├── AppIcon.icns           # App icon (all sizes)
├── make_app.sh            # Build + package script
└── Sources/Reclaim/
    ├── App/               # Entry point, global state
    ├── Models/            # Data types
    ├── Services/          # File scanning, shell runner, deletion
    ├── ViewModels/        # Observable state for each section
    └── Views/             # SwiftUI views
        ├── Dashboard/
        ├── Caches/
        └── Downloads/
```

---

## Tech Stack

- **SwiftUI** — UI, no storyboards
- **Swift Package Manager** — no Xcode project required
- **PDFKit** — inline PDF preview
- **AVKit** — video thumbnails and playback
- **WebKit** — HTML file preview
- **Foundation.Process** — shell command execution
- **NSWorkspace.recycle** — safe Trash-based deletion

No third-party dependencies.

---

## Sharing

The build script produces an ad-hoc signed universal binary. Recipients on Apple Silicon or Intel Macs will need to right-click → Open the first time to bypass Gatekeeper (standard for apps not distributed through the App Store).
