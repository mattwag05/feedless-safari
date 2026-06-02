# Spec: FeedlessSafari Feature Expansion (2026-06)

**Status:** Draft
**Author:** Matthew Wagner
**Inspiration:** [jordwest/news-feed-eradicator](https://github.com/jordwest/news-feed-eradicator) — features observed, **not copied**
**License posture:** MIT (this project), clean-room reimplementation throughout

---

## 1. Goals

1. Add **three new platforms**: Hacker News, GitHub (logged-in home feed), Threads.
2. Add a **Quote Widget** — replace the hidden feed area with a rotating curated quote instead of empty space.
3. Maintain MIT licensing by **never lifting code** from `news-feed-eradicator` (which is AGPL-3.0 from v3.0 onward). All new behavior is observed-from-live-sites and written from scratch.

## 2. Non-Goals

- Not contributing changes upstream to `ZMensRain/Feedless`. The user wants these features owned and shipped by this project alone.
- Not changing existing 11-platform behavior.
- Not adopting any code, CSS, quote text, or selectors from `news-feed-eradicator` v3+.

## 3. Architectural Background (important — settles the "Swift vs TS" question)

The brief asked to do this in Swift not TypeScript. The reality is a **hybrid is necessary**, but the copyright concern is fully addressed regardless of language:

- **Safari Web Extension content scripts MUST be JavaScript.** Safari only executes JS in the content-script sandbox for both macOS and iOS. Swift code never runs inside a webpage. So feed-blocking selectors and the quote widget's in-page rendering have to be JS.
- **The native app shell IS Swift** — `Shared (App)/`, `macOS (App)/`, `iOS (App)/`. Settings model, settings UI, persistence, app delegates, and the quote library data file can all be Swift.
- **Copyright safety doesn't come from language choice; it comes from clean-room implementation.** Even if we wrote everything in Swift, copying NFE's logic and translating it line-by-line would still be a derivative work. Conversely, JS code written by us based on independent observation of live sites is fully MIT-clean.

**Concrete language split:**

| Concern | Language | Why |
|---|---|---|
| Feed selectors + hide logic | TypeScript / JS | Required by Safari Web Extension model |
| Quote widget DOM rendering | TypeScript / JS | Same — has to run inside the page |
| Settings model + persistence | Swift | Already lives in `Shared (App)/SettingsModel.swift` |
| Settings UI (toggles, sections) | SwiftUI | Already SwiftUI elsewhere in the app |
| Quote library (data) | Swift + JSON | Curated quote data ships as a Swift-side resource; bridge.js reads it via the extension message bus |
| Quote rotation policy | Swift | App settings drive the JS-side behavior over the message bridge |

**Build pipeline consideration.** `scripts/rebuild.sh` currently does:

```
rsync -a --delete /tmp/feedless-convert/.../Resources/ "$PROJECT_DIR/Shared (Extension)/Resources/"
```

That `--delete` will nuke any custom files we put in `Resources/` directly. The spec assumes we **add a layering step** to `rebuild.sh` that, after the rsync, overlays our own platform scripts and quote widget from a parallel directory we control. See §7 for the file layout.

## 4. Clean-Room Protocol (read this before writing any code)

To keep the project MIT-licensed despite drawing inspiration from AGPL-3.0 `news-feed-eradicator`, every contributor working on these features MUST follow this protocol:

1. **Look at the live target site.** Open hackernews.com / github.com / threads.net in Safari, use Web Inspector, identify the DOM nodes that constitute the feed. Note class names, IDs, and structure **from the live site**, not from NFE source.
2. **Do not open NFE's source files** while writing platform scripts. The selectors are simple enough to derive from inspection.
3. **Write the platform handler from scratch** in the project's existing style (see `Shared (Extension)/Resources/content-scripts/` for the upstream Feedless patterns we're already shipping).
4. **Quote text:** sourced from **public domain** (pre-1929 authors — Marcus Aurelius, Seneca, Emerson, Thoreau, etc.) OR written fresh. **Do not copy NFE's quotes.json** even though many of its quotes are themselves public-domain — the curated *selection* is plausibly protected as a compilation.
5. **Commit messages and PR descriptions** should reference this spec, never NFE's source files or line numbers.

A `LICENSE-NOTICES.md` file at the project root will document this protocol publicly and credit `jordwest/news-feed-eradicator` as conceptual inspiration only.

## 5. Features

### 5.1 Hacker News (new platform)

**Domain:** `news.ycombinator.com`

**Target nodes to hide (verify against live site at implementation time):**
- The main story table on `/` and `/news` (typically `table.itemlist` or similar — verify).
- The "more" link at the bottom of the front page.
- Leave `/newcomments`, `/ask`, `/show`, `/jobs`, `/submit`, user profiles, and individual story pages ALONE. Hiding the homepage feed is the goal; users still want to read specific stories they came for.

**Settings keys (Swift):**
- `local:hackernews-hide-feed` (default `true`) — Hide front page story list.

**Status label:** "Hacker News stories"

### 5.2 GitHub Home Feed (new platform)

**Domain:** `github.com`

**Target nodes:**
- The activity feed on the logged-in homepage at `github.com/` — typically a `<feed-container>` element or main panel labelled "For you" / "Following".
- Do NOT touch any other GitHub page (repos, issues, PRs, settings, profile pages). The trigger is path === `/` only.

**Settings keys:**
- `local:github-hide-home-feed` (default `true`)

**Status label:** "GitHub home feed"

**Edge case:** logged-out github.com shows marketing, not a feed. Detect logged-in state via DOM signature (e.g., presence of `<header>` user avatar) before hiding.

### 5.3 Threads (new platform)

**Domain:** `threads.net` (and `threads.com` if Meta is migrating)

**Target nodes:**
- For You feed.
- Following feed.
- Hide both by default; expose two separate toggles in Settings so users can keep one and hide the other.

**Settings keys:**
- `local:threads-hide-for-you` (default `true`)
- `local:threads-hide-following` (default `true`)

**Status label:** "Threads feeds"

### 5.4 Quote Widget (new shared feature)

When a feed is hidden on any of the 14 supported platforms, render a centered card in the hidden area showing a quote.

**Behavior:**
- Quote selection: deterministic per page-load by default, with a settings option for "new quote on every page load" vs "same quote per session" vs "same quote per day".
- Library: 50–100 quotes ship in the app. **Public-domain authors only** (Marcus Aurelius, Seneca, Epictetus, Emerson, Thoreau, Wendell Berry pre-1929 work, etc.), supplemented with fresh originals if we want.
- Each quote = `{text: String, attribution: String}`. Optional `source` field for fans of footnotes.
- User can add their own quotes via Settings → Quotes → Add. Stored locally, never synced (privacy).
- User can disable the widget entirely (toggle: "Show inspirational quote when feeds are hidden").

**Visual design:**
- Centered card, max width ~600pt, ample white/black space.
- Serif font (system default — `New York` / `Georgia` fallback) for the quote, sans for the attribution.
- Respect `prefers-color-scheme` (system theme). Light card on light, dark card on dark.
- Subtle "↻" button in a corner to manually rotate to a new quote in the same session.
- No share buttons in v1 (NFE has these; we'll evaluate later if users ask).

**Settings keys (Swift):**
- `local:quote-widget-enabled` (default `true`)
- `local:quote-widget-rotation-policy` (enum: `page-load` | `session` | `day`, default `page-load`)
- `local:quote-widget-custom-quotes-json` (string, default `"[]"`)

**Data flow:**
1. App-side Swift owns the curated quote library (`Shared (App)/Resources/quotes.json`) and the user's custom quotes (UserDefaults).
2. On extension activation, `bridge.js` queries the Swift app for the merged quote pool + current rotation policy.
3. Content script picks a quote based on policy and renders the widget.

## 6. File-Level Changes

### 6.1 New JS / TypeScript files (clean-room)

```
Custom Resources/                                 ← new top-level directory we maintain
├── content-scripts/
│   ├── hackernews.ts
│   ├── github.ts
│   └── threads.ts
├── quote-widget/
│   ├── widget.ts                                 ← DOM injection + lifecycle
│   ├── widget.css                                ← scoped, prefixed `.feedless-quote-`
│   └── bridge.ts                                 ← messaging with Swift app
└── README.md                                     ← explains the layering
```

`Custom Resources/` is OUR territory. It does NOT get rsync'd over by `rebuild.sh`. A new step at the end of `rebuild.sh` overlays it into the final `Resources/`.

### 6.2 Modified files

| File | Change |
|---|---|
| `Shared (App)/SettingsModel.swift` | Append three new `PlatformConfig` entries (HN, GitHub, Threads) and a new `QuoteWidgetConfig` block. |
| `Shared (App)/Settings/SettingsView.swift` (or wherever the SwiftUI form lives) | Add toggles for the three new platforms; new section for Quote Widget settings. |
| `Shared (App)/Resources/quotes.json` | **NEW** — curated public-domain quote library. |
| `Shared (App)/QuoteLibrary.swift` | **NEW** — Codable struct, merges curated + user quotes, exposes to bridge. |
| `Shared (Extension)/Resources/manifest.json` | Add new content-script entries for HN, GitHub, Threads. The rebuild script regenerates this from upstream, so the layering step in `rebuild.sh` will need to patch it. |
| `scripts/rebuild.sh` | After the upstream rsync, overlay `Custom Resources/` into `Shared (Extension)/Resources/`. Patch `manifest.json` with three new content-script matches. Fix the placeholder upstream URL (`your-org/feedless` → `ZMensRain/Feedless`). |
| `project.yml` (xcodegen) | Include `Shared (App)/Resources/quotes.json` as a bundled resource. |
| `README.md` | Update platform table (11 → 14); add Quote Widget to feature list; expand Credits to reference jordwest/news-feed-eradicator. |
| `LICENSE-NOTICES.md` | **NEW** — document clean-room protocol. |
| `CHANGELOG.md` | Add a v(next) entry summarizing the additions. |

### 6.3 SettingsModel additions (concrete snippet)

```swift
// Append to PlatformConfig.all:
PlatformConfig(id: "hackernews", name: "Hacker News", systemImage: "flame",
    settings: [
        SettingKey(id: "hn-feed", rawKey: "local:hackernews-hide-feed",
                   label: "Hide Front Page Feed", defaultValue: true),
    ]
),
PlatformConfig(id: "github", name: "GitHub", systemImage: "chevron.left.forwardslash.chevron.right",
    settings: [
        SettingKey(id: "gh-home", rawKey: "local:github-hide-home-feed",
                   label: "Hide Home Activity Feed", defaultValue: true),
    ]
),
PlatformConfig(id: "threads", name: "Threads", systemImage: "text.bubble",
    settings: [
        SettingKey(id: "th-foryou", rawKey: "local:threads-hide-for-you",
                   label: "Hide For You", defaultValue: true),
        SettingKey(id: "th-follow", rawKey: "local:threads-hide-following",
                   label: "Hide Following", defaultValue: true),
    ]
),

// New struct + instance in SettingsModel.swift:
struct QuoteWidgetConfig {
    static let `default` = QuoteWidgetConfig()
    let enabledKey   = SettingKey(id: "qw-on",  rawKey: "local:quote-widget-enabled",
                                  label: "Show inspirational quote", defaultValue: true)
    let policyKey    = "local:quote-widget-rotation-policy"      // String enum
    let customKey    = "local:quote-widget-custom-quotes-json"   // String JSON
}
```

## 7. Build Pipeline (rebuild.sh changes)

Append after the existing rsync step:

```bash
echo "==> Overlaying custom content scripts and quote widget..."
CUSTOM_RES="$PROJECT_DIR/Custom Resources"
DEST="$PROJECT_DIR/Shared (Extension)/Resources"

# Copy custom content-scripts (clean-room, ours)
mkdir -p "$DEST/content-scripts"
cp "$CUSTOM_RES/content-scripts/"*.ts "$DEST/content-scripts/"

# Copy quote widget
mkdir -p "$DEST/quote-widget"
cp "$CUSTOM_RES/quote-widget/"*.{ts,css} "$DEST/quote-widget/"

# Patch manifest.json with custom content_script entries
python3 "$SCRIPT_DIR/patch_manifest.py" "$DEST/manifest.json"

echo "==> Custom resources merged."
```

And add a small `scripts/patch_manifest.py` helper that adds the three new platforms' `content_scripts` entries plus the quote-widget's bridge to the manifest's `content_scripts` array. Idempotent; safe to re-run.

Also: **fix the placeholder URL** in `rebuild.sh` line 11. `https://github.com/your-org/feedless.git` → `https://github.com/ZMensRain/Feedless.git`. (Same issue we just fixed in the README.)

## 8. Acceptance Criteria

A change is "done" when ALL of the following hold:

1. macOS Safari build runs clean from `xcodegen generate && xcodebuild` with no warnings on the new files.
2. iOS Safari build same.
3. On a logged-in macOS Safari profile, all 14 platforms have working feed-hide behavior. New platforms (HN/GitHub/Threads) verified by manual visit.
4. Quote widget appears in the hidden-feed area on all 14 platforms when enabled.
5. Quote widget respects `prefers-color-scheme`.
6. Settings UI exposes toggles for new platforms + quote widget section. Toggles persist across app restarts.
7. `rebuild.sh` runs end-to-end without errors and produces a working extension that includes the custom content scripts (verified by grep-ing the resulting `manifest.json` for new content-script entries).
8. `README.md` lists 14 platforms; `CHANGELOG.md` has a new entry; `LICENSE-NOTICES.md` exists and documents the clean-room protocol; Credits section references jordwest/news-feed-eradicator.
9. No file in the project contains any text that originated from `news-feed-eradicator` v3+ source. Grep `git log -p` for known NFE phrases as a sanity check.

## 9. Milestones / Effort

Rough time-of-effort, single-developer focused work:

| Milestone | Effort |
|---|---|
| 1. Project housekeeping: create `Custom Resources/`, write clean-room protocol doc, fix rebuild.sh placeholder | 1h |
| 2. Hacker News content script (clean-room) + Swift settings toggle | 2–3h |
| 3. GitHub home feed content script + toggle | 2–3h |
| 4. Threads content script + 2 toggles | 3–4h (Meta's class names rotate often; needs more inspection) |
| 5. Quote widget JS (DOM render, theme, settings bridge) | 4–6h |
| 6. Quote library curation (50 quotes, public domain only) | 2–3h |
| 7. Swift quote library type + bridge | 2h |
| 8. SwiftUI settings UI section for Quote Widget | 2h |
| 9. rebuild.sh layering step + patch_manifest.py | 2h |
| 10. Testing pass on macOS + iOS Safari | 3h |
| 11. README, CHANGELOG, LICENSE-NOTICES.md, Credits update | 1h |
| **Total** | **~25–30h** |

Suggested sequencing: milestones 1, 9 first (so the layering machinery is in place); then 2 (HN, simplest target) as the proof-of-concept that the pipeline works; then the rest in any order.

## 10. Open Questions

1. **Quote rotation default** — locked at `page-load` here. Confirm that's what you want; some folks prefer `session` so they get attached to one quote per coffee.
2. **iOS quote widget custom-quote add UI** — iOS Safari extensions have constrained settings UIs. Should custom-quote editing be macOS-only, or do we build an iOS sheet too?
3. **Threads domain** — Meta has been moving things between `threads.net` and `threads.com`. Match both; specifically verify which is currently the active host.
4. **GitHub Enterprise** — should the toggle also apply to `github.<company>.com` hosts? Probably out of scope but worth flagging.
5. **NFE's "Hacker News" detection** — they don't hide individual story discussion pages; they only hide the top stories list. Confirm that's what you want, vs. hiding the front-page link list more aggressively.
6. **Naming the third-party-platform script overlay** — `Custom Resources/` is functional; `App Resources/` or `Local Resources/` might read better. Bikeshed at implementation time.
7. **Credits update timing** — add jordwest now as "conceptual inspiration", or wait until features actually ship? My vote: add now in the spec's `LICENSE-NOTICES.md`, then promote to README Credits when features land.

## 11. Out of Scope

- Twitter-share button for the quote (NFE has it; we deliberately skip in v1).
- Time-saved counter (NFE doesn't have it either, just calling it out).
- Per-quote user ratings.
- Sync of user-added quotes via iCloud (privacy-by-default).
- Any additional platforms beyond HN / GitHub / Threads.
- Refactoring the existing 11-platform code paths.
