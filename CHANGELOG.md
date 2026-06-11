# Changelog

## Unreleased

### Added
- **25 new per-surface toggles** for the existing platforms, surfacing controls
  the bundled upstream scripts already implement: Twitter/X (Trending, Who to
  Follow, What's Happening, Explore), Instagram (Explore, Suggested Posts),
  Reddit (Explore, Related Posts), Facebook (Gaming, Marketplace, Watch),
  TikTok (Following, Explore, Live, Search), Pinterest (Explore, Related Pins,
  Search, Boards), Substack (Explore, Up Next, New Bestsellers, Related),
  Bluesky (Trending), LinkedIn ("Add to Your Feed"), YouTube Music (Explore).
- **Threads (threads.com) support** — hide For You and Following feeds
  independently (clean-room overlay, not from upstream).
- **Hacker News support** — hide the ranked front-page story list (`/`,
  `/news`, `/front`); /newest, /ask, /show, /jobs and item pages stay visible.
- **GitHub support** — hide the logged-in home activity feed at `/` and
  `/dashboard`; repos, issues, PRs and the logged-out homepage are untouched.
- Settings UI group headers (Feeds / Discovery / Other) on platforms with 4+
  toggles.
- Custom overlay architecture (`Shared (Extension)/Custom/` +
  `scripts/patch-manifest.py`) so local additions survive upstream resyncs.

### Changed
- **Some previously hidden surfaces are now visible by default.** The upstream
  scripts hide every surface when a setting is missing; now that the app seeds
  all keys, deliberate destinations default to visible: Facebook Marketplace
  and Watch, TikTok Following / Live / Search, Pinterest Search / Boards. Turn
  the toggles on in the app to hide them again.
- Shorts/Reels controls are now three-way pickers (Block / Hide / Show). The
  old on/off toggles wrote values the extension never honored; existing
  settings are migrated (on → Block, off → Show).

### Fixed
- iOS app-group entitlements were missing, so settings never reached the iOS
  extension; toggles now work on iOS.
- Settings defaults are seeded at app launch, not only when the settings view
  appears.
