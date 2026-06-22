# FeedlessSafari 🚫📰

Safari Web Extension that hides distracting feed content on 13 platforms (the manifest matches 14 hosts because Twitter/X is two domains for one platform). A port of the [Feedless](https://github.com/ZMensRain/Feedless) Chrome extension for macOS and iOS, plus clean-room platform support of its own (Threads, Hacker News, GitHub).

## Supported Platforms

| Platform | Surfaces Controlled |
|----------|--------------------|
| YouTube | Home, Subscriptions, Up Next, More From YouTube, Explore, Shorts (block/hide/show), You section, End Screen |
| YouTube Music | Home, Related, Explore |
| Twitter / X | Home, Trending, Who to Follow, What's Happening, Explore, Premium |
| Facebook | Home, Gaming, Reels (block/hide/show), Marketplace, Watch |
| Instagram | Home, Explore, Suggested Posts, Reels (block/hide/show) |
| Threads | For You, Following |
| TikTok | For You, Following, Explore, Video Pages (block/hide/show), Live, Search |
| Reddit | Home, Explore, Related Posts |
| LinkedIn | Home, "Add to Your Feed", Premium |
| Pinterest | Home, Explore, Related Pins, Search, Boards |
| Bluesky | Home, Trending |
| Substack | Home, Explore, Up Next, New Bestsellers, Related |
| Hacker News | Front page stories |
| GitHub | Home activity feed |

Suggestion/discovery surfaces are hidden by default; destinations you deliberately navigate to (Marketplace, Watch, search results, boards, Following, Live) are visible by default — flip any of them in the app's settings.

Where a home feed is hidden, a **quote widget** takes its place — public-domain quotes about attention and time, rotating per page load (or per session / daily), with your own custom quotes addable in the app.

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

This clones the latest Feedless Chrome extension, builds it, converts to Safari, re-applies the custom overlay manifest entries (`scripts/patch-manifest.py`), and regenerates the Xcode project.

Anything of ours that must survive a resync lives in `Shared (Extension)/Custom/` (outside the rsync `--delete` blast radius). After any manual hand-sync of `Resources/`, run `python3 scripts/patch-manifest.py` to restore the bridge + custom content-script entries in `manifest.json`.

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
│   ├── Custom/                    # Our overlay — survives upstream resyncs
│   │   ├── bridge.js              # UserDefaults → storage.local sync
│   │   ├── lib.js                 # storage → :root attribute mirror
│   │   ├── threads.{js,css}       # Clean-room Threads support
│   │   └── manifest-additions.json  # Input for patch-manifest.py
│   └── Resources/                 # Upstream content scripts, CSS, icons
│       ├── manifest.json          # Patched by patch-manifest.py
│       ├── background.js
│       ├── content-scripts/       # Per-platform feed blockers
│       └── chunks/                # WXT build output
├── macOS (Extension)/             # macOS extension target
├── iOS (Extension)/               # iOS extension target
└── scripts/
    ├── rebuild.sh                 # Full rebuild from upstream
    └── patch-manifest.py          # Re-applies Custom/ manifest entries
```

## License

[MIT](LICENSE)
## Credits

Built on top of [Feedless](https://github.com/ZMensRain/Feedless) by [ZMensRain](https://github.com/ZMensRain) — the original Chrome extension this Safari port wraps. All platform-blocking logic comes from upstream; this project handles the Safari Web Extension shell, macOS/iOS app wrapping, and the settings UI.
