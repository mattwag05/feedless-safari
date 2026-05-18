# FeedlessSafari 🚫📰

Safari Web Extension that hides distracting feed content on 11 social media platforms. A port of the [Feedless](https://github.com/your-org/feedless) Chrome extension for macOS and iOS.

## Supported Platforms

| Platform | Feeds Blocked |
|----------|--------------|
| YouTube | Home, Up Next, Subscriptions, Shorts, More, Explore, End Screen |
| YouTube Music | Home, Related |
| Twitter / X | Home, Premium |
| Facebook | Home, Shorts |
| Instagram | Home, Shorts |
| TikTok | Home, Shorts |
| Reddit | Home |
| LinkedIn | Home, Premium |
| Pinterest | Home |
| Bluesky | Home |
| Substack | Home |

## Prerequisites

- **macOS 13+** (for macOS app) or **iOS 15+** (for iOS app)
- **Xcode 15+** with command line tools
- **xcodegen** — `brew install xcodegen`

## Build & Run

```bash
# Generate Xcode project from spec
xcodegen generate

# Open in Xcode
open FeedlessSafari.xcodeproj

# Select scheme (macOS or iOS) and run
```

### macOS

1. Run the app from Xcode (scheme: `FeedlessSafari macOS`)
2. Open **Safari → Settings → Extensions**
3. Enable **FeedlessSafari Extension**
4. Grant permission on any site you visit
5. Browse normally — feeds are hidden on supported platforms

### iOS

1. Run the app from Xcode on your device (scheme: `FeedlessSafari iOS`)
2. Open **Settings → Safari → Extensions**
3. Enable **FeedlessSafari**
4. Grant permission on any supported platform

## Settings

Toggles for each platform are in the app's settings UI:

- **macOS:** Cmd + , or app menu → Settings
- **iOS:** Open the app and use the settings view

Changes sync automatically to the extension.

## Rebuilding from Upstream

```bash
./scripts/rebuild.sh
```

This clones the latest Feedless Chrome extension, builds it, converts to Safari, and regenerates the Xcode project.

## Project Structure

```
FeedlessSafari/
├── project.yml                    # xcodegen spec (source of truth)
├── Shared (App)/                  # Shared app code
│   ├── SettingsModel.swift        # Platform config & toggle keys
│   └── Assets.xcassets/           # App icons
├── macOS (App)/                   # macOS app
│   ├── AppDelegate.swift
│   └── SettingsView.swift         # NavigationSplitView settings UI
├── iOS (App)/                     # iOS app
│   ├── AppDelegate.swift
│   └── SettingsView.swift         # NavigationView settings UI
├── Shared (Extension)/            # Safari extension
│   ├── SafariWebExtensionHandler.swift  # Native → JS bridge
│   └── Resources/                 # Content scripts, CSS, icons
│       ├── manifest.json
│       ├── background.js
│       ├── bridge.js              # UserDefaults → storage.local sync
│       ├── content-scripts/       # Per-platform feed blockers
│       └── chunks/                # WXT build output
├── macOS (Extension)/             # macOS extension target
├── iOS (Extension)/               # iOS extension target
└── scripts/
    └── rebuild.sh                     # Full rebuild from upstream
```

## License

[MIT](LICENSE)