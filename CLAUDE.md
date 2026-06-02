# CLAUDE.md — feedless-safari

Safari Web Extension (macOS + iOS) that hides feeds on 11 social platforms. Port of the upstream Feedless Chrome extension. SwiftUI host app + JS/CSS content scripts.

## Build & regenerate flow

`project.yml` is the source of truth, **not** `FeedlessSafari.xcodeproj/project.pbxproj`. Workflow:

```bash
/opt/homebrew/bin/xcodegen generate   # rewrites project.pbxproj + Info.plists
# then build in Xcode (BuildProject MCP tool, or scheme "FeedlessSafari macOS")
```

Never hand-edit `project.pbxproj` or the extension `Info.plist` files — xcodegen overwrites them.

## Non-obvious gotchas

### Extension Info.plist is generated from `project.yml`
`NSExtension` (and `CFBundlePackageType: XPC!`) live in `info.properties` under each Extension target in `project.yml`. Editing the plist directly works once, then gets clobbered on the next `xcodegen generate`. The Extension Info.plist **must** declare:
- `NSExtensionPointIdentifier = com.apple.Safari.web-extension`
- `NSExtensionPrincipalClass = $(PRODUCT_MODULE_NAME).SafariWebExtensionHandler`

Without these, Safari does not discover the extension at all (no error, just absent from Settings → Extensions).

### Resource layout must preserve subdirectory structure
`manifest.json` references `icons/16.png`, `content-scripts/bsky.js`, `chunks/...js`, `assets/...css` — these paths must exist inside the built `.appex/Contents/Resources/`. The xcodegen patterns that work:

- Top-level files (`manifest.json`, `background.js`, `bridge.js`, `popup.html`, `options.html`, `icon.svg`): listed individually as `sources` entries with `buildPhase: resources`.
- Subdirectories (`icons/`, `content-scripts/`, `chunks/`, `assets/`): listed as `sources` with `type: folder` + `buildPhase: resources` so Xcode adds them as **folder references** (blue folder), preserving structure on copy.

Pitfalls that bit me:
- A single `resources:` block with `type: folder` pointing at the whole `Resources/` directory **flattens** everything in the bundle (xcodegen 2.45 expands it to individual files).
- A single `sources:` folder reference to `Resources/` **nests** under an extra `Resources/Resources/` because folder refs copy the folder itself, not its contents.

### App ↔ Extension settings sync uses an App Group
Both targets share `UserDefaults` via app group `group.com.mattwagner.feedless-safari`. Always go through `SharedDefaults.store`, never `UserDefaults.standard`. The constant lives in `Shared (App)/SharedDefaults.swift` and is compiled into **both** the app and extension targets (the extension targets explicitly list this file in `project.yml > sources`). If you move or rename it, update both extension `sources:` lists.

The handshake: app writes `local:*` keys to the shared suite → `bridge.js` in each content script calls `browser.runtime.sendMessage({action: "getSettings"})` → `SafariWebExtensionHandler` returns all `local:`-prefixed keys → bridge writes them to `browser.storage.local` → per-platform content scripts read from `browser.storage.local`.

### Entitlements and signing
- `macOS (App)/FeedlessSafari.entitlements` and `macOS (Extension)/FeedlessSafariExtension.entitlements` both grant App Sandbox + the app group. They are byte-identical today but kept separate intentionally — Xcode resolves `CODE_SIGN_ENTITLEMENTS` per target and the extension is likely to grow its own entries (e.g. network client) before the app does.
- `DEVELOPMENT_TEAM: PFT954M73N` is baked into `project.yml`. A different developer will need to swap it.
- iOS Extension entitlements aren't wired yet — only macOS targets have `CODE_SIGN_ENTITLEMENTS` set. Add iOS entitlements files + wire them in `project.yml` if the iOS app actually needs to share settings with its extension (the App Group requires the entitlement on both sides).

### scripts/rebuild.sh is aspirational
The `git clone https://github.com/your-org/feedless.git` URL in `scripts/rebuild.sh` is a placeholder and will fail. In practice, `Shared (Extension)/Resources/` is sync'd by hand from a separate local Feedless WXT build. Update the URL when wiring this back up.

## Task tracking

No `.beads/` in this repo. The global "use bd" rule does not apply here. Either set up beads or use plain commits.

## Quick reference

| What | Where |
|------|-------|
| Project spec | `project.yml` |
| Settings schema | `Shared (App)/SettingsModel.swift` (`PlatformConfig.all`) |
| Shared store | `Shared (App)/SharedDefaults.swift` |
| Toggle helpers | `Shared (App)/SettingsBindings.swift` (`PlatformConfig.seedDefaults`, `SettingKey.toggleBinding`) |
| Native bridge | `Shared (Extension)/SafariWebExtensionHandler.swift` |
| JS bridge | `Shared (Extension)/Resources/bridge.js` |
| Manifest | `Shared (Extension)/Resources/manifest.json` |
| Content scripts | `Shared (Extension)/Resources/content-scripts/<platform>.{js,css}` |
