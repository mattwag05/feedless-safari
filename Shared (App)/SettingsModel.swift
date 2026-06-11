import Foundation

enum SettingGroup: String, CaseIterable {
    case feeds = "Feeds"
    case discovery = "Discovery"
    case other = "Other"
}

enum SettingKind: Equatable, Hashable {
    case toggle
    /// Tri-state string setting (`block` / `hide` / `show`) used by the upstream
    /// `*-shortform` keys. Writing a Bool to these keys matches no CSS rule.
    case shortform
}

struct PlatformConfig: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let systemImage: String
    let settings: [SettingKey]

    /// Settings bucketed by group in fixed group order, empty groups dropped.
    var groupedSettings: [(SettingGroup, [SettingKey])] {
        SettingGroup.allCases.compactMap { group in
            let keys = settings.filter { $0.group == group }
            return keys.isEmpty ? nil : (group, keys)
        }
    }

    var showsGroupHeaders: Bool { settings.count >= 4 }
}

struct SettingKey: Identifiable, Equatable, Hashable {
    let id: String
    let rawKey: String
    let label: String
    let defaultValue: Bool
    var group: SettingGroup = .feeds
    var kind: SettingKind = .toggle
}

extension PlatformConfig {
    static let all: [PlatformConfig] = [
        PlatformConfig(id: "youtube", name: "YouTube", systemImage: "play.rectangle",
            settings: [
                SettingKey(id: "yt-feed",  rawKey: "local:youtube-hide-feed",               label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "yt-sub",   rawKey: "local:youtube-hide-subscription-feed",  label: "Hide Sub Feed", defaultValue: true),
                SettingKey(id: "yt-next",  rawKey: "local:youtube-hide-up-next-feed",       label: "Hide Up Next", defaultValue: true, group: .discovery),
                SettingKey(id: "yt-more",  rawKey: "local:youtube-hide-more-from-youtube",  label: "Hide More From YouTube", defaultValue: true, group: .discovery),
                SettingKey(id: "yt-exp",   rawKey: "local:youtube-hide-explore",            label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "yt-short", rawKey: "local:youtube-shortform",               label: "Shorts", defaultValue: true, group: .other, kind: .shortform),
                SettingKey(id: "yt-you",   rawKey: "local:youtube-hide-you-section",        label: "Hide You Section", defaultValue: false, group: .other),
                SettingKey(id: "yt-end",   rawKey: "local:youtube-hide-end-screen",         label: "Hide End Screen", defaultValue: true, group: .other),
            ]
        ),
        PlatformConfig(id: "twitter", name: "Twitter / X", systemImage: "bird",
            settings: [
                SettingKey(id: "tw-feed",  rawKey: "local:twitter-hide-feed",                label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "tw-trend", rawKey: "local:twitter-hide-trending-feed",       label: "Hide Trending", defaultValue: true, group: .discovery),
                SettingKey(id: "tw-wtf",   rawKey: "local:twitter-hide-who-to-follow-feed",  label: "Hide Who to Follow", defaultValue: true, group: .discovery),
                SettingKey(id: "tw-news",  rawKey: "local:twitter-hide-whats-new-feed",      label: "Hide What's Happening", defaultValue: true, group: .discovery),
                SettingKey(id: "tw-exp",   rawKey: "local:twitter-hide-explore-feed",        label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "tw-prem",  rawKey: "local:twitter-hide-premium",             label: "Hide Premium", defaultValue: true, group: .other),
            ]
        ),
        PlatformConfig(id: "facebook", name: "Facebook", systemImage: "person.2",
            settings: [
                SettingKey(id: "fb-feed",  rawKey: "local:facebook-hide-feed",              label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "fb-games", rawKey: "local:facebook-hide-games-feed",        label: "Hide Gaming", defaultValue: true, group: .discovery),
                SettingKey(id: "fb-short", rawKey: "local:facebook-shortform",              label: "Reels", defaultValue: true, group: .other, kind: .shortform),
                SettingKey(id: "fb-mkt",   rawKey: "local:facebook-hide-marketplace-feed",  label: "Hide Marketplace", defaultValue: false, group: .other),
                SettingKey(id: "fb-vid",   rawKey: "local:facebook-hide-videos-feed",       label: "Hide Watch", defaultValue: false, group: .other),
            ]
        ),
        PlatformConfig(id: "instagram", name: "Instagram", systemImage: "camera.aperture",
            settings: [
                SettingKey(id: "ig-feed",  rawKey: "local:instagram-hide-feed",             label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "ig-exp",   rawKey: "local:instagram-hide-explore-feed",     label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "ig-more",  rawKey: "local:instagram-hide-more-from-feed",   label: "Hide Suggested Posts", defaultValue: true, group: .discovery),
                SettingKey(id: "ig-short", rawKey: "local:instagram-shortform",             label: "Reels", defaultValue: true, group: .other, kind: .shortform),
            ]
        ),
        PlatformConfig(id: "threads", name: "Threads", systemImage: "text.bubble",
            settings: [
                SettingKey(id: "th-foryou", rawKey: "local:threads-hide-for-you",   label: "Hide For You", defaultValue: true),
                SettingKey(id: "th-follow", rawKey: "local:threads-hide-following", label: "Hide Following", defaultValue: true),
            ]
        ),
        PlatformConfig(id: "tiktok", name: "TikTok", systemImage: "music.note",
            settings: [
                SettingKey(id: "tt-feed",   rawKey: "local:tiktok-hide-feed",            label: "Hide For You Feed", defaultValue: true),
                SettingKey(id: "tt-follow", rawKey: "local:tiktok-hide-following-feed",  label: "Hide Following", defaultValue: false),
                SettingKey(id: "tt-exp",    rawKey: "local:tiktok-hide-explore-feed",    label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "tt-short",  rawKey: "local:tiktok-shortform",            label: "Video Pages", defaultValue: true, group: .other, kind: .shortform),
                SettingKey(id: "tt-live",   rawKey: "local:tiktok-hide-live-feed",       label: "Hide Live", defaultValue: false, group: .other),
                SettingKey(id: "tt-search", rawKey: "local:tiktok-hide-search-feed",     label: "Hide Search Results", defaultValue: false, group: .other),
            ]
        ),
        PlatformConfig(id: "reddit", name: "Reddit", systemImage: "bubble.left.and.bubble.right",
            settings: [
                SettingKey(id: "rd-feed", rawKey: "local:reddit-hide-feed",               label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "rd-exp",  rawKey: "local:reddit-hide-explore-feed",       label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "rd-rel",  rawKey: "local:reddit-hide-related-posts-feed", label: "Hide Related Posts", defaultValue: true, group: .discovery),
            ]
        ),
        PlatformConfig(id: "linkedin", name: "LinkedIn", systemImage: "briefcase",
            settings: [
                SettingKey(id: "li-feed", rawKey: "local:linkedin-hide-feed",             label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "li-add",  rawKey: "local:linkedin-hide-add-to-your-feed", label: "Hide \"Add to Your Feed\"", defaultValue: true, group: .discovery),
                SettingKey(id: "li-prem", rawKey: "local:linkedin-hide-premium-upsells",  label: "Hide Premium", defaultValue: true, group: .other),
            ]
        ),
        PlatformConfig(id: "pinterest", name: "Pinterest", systemImage: "pin",
            settings: [
                SettingKey(id: "pt-feed",   rawKey: "local:pinterest-hide-feed",               label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "pt-exp",    rawKey: "local:pinterest-hide-explore-feed",       label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "pt-rel",    rawKey: "local:pinterest-hide-related-pins-feed",  label: "Hide Related Pins", defaultValue: true, group: .discovery),
                SettingKey(id: "pt-search", rawKey: "local:pinterest-hide-search-feed",        label: "Hide Search Results", defaultValue: false, group: .other),
                SettingKey(id: "pt-board",  rawKey: "local:pinterest-hide-board-feed",         label: "Hide Board Feeds", defaultValue: false, group: .other),
            ]
        ),
        PlatformConfig(id: "bsky", name: "Bluesky", systemImage: "cloud.bolt",
            settings: [
                SettingKey(id: "bs-feed",  rawKey: "local:bsky-hide-feed",     label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "bs-trend", rawKey: "local:bsky-hide-trending", label: "Hide Trending", defaultValue: true, group: .discovery),
            ]
        ),
        PlatformConfig(id: "substack", name: "Substack", systemImage: "newspaper",
            settings: [
                SettingKey(id: "ss-feed", rawKey: "local:substack-hide-feed",                 label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "ss-exp",  rawKey: "local:substack-hide-explore-feed",         label: "Hide Explore", defaultValue: true, group: .discovery),
                SettingKey(id: "ss-next", rawKey: "local:substack-hide-up-next-feed",         label: "Hide Up Next", defaultValue: true, group: .discovery),
                SettingKey(id: "ss-best", rawKey: "local:substack-hide-new-bestsellers-feed", label: "Hide New Bestsellers", defaultValue: true, group: .discovery),
                SettingKey(id: "ss-rel",  rawKey: "local:substack-hide-related",              label: "Hide Related", defaultValue: true, group: .discovery),
            ]
        ),
        PlatformConfig(id: "youtube_music", name: "YouTube Music", systemImage: "music.note.tv",
            settings: [
                SettingKey(id: "ym-feed", rawKey: "local:youtube_music-hide-feed",         label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "ym-rel",  rawKey: "local:youtube_music-hide-related",      label: "Hide Related", defaultValue: true, group: .discovery),
                SettingKey(id: "ym-exp",  rawKey: "local:youtube_music-hide-explore-feed", label: "Hide Explore", defaultValue: true, group: .discovery),
            ]
        ),
    ]
}
