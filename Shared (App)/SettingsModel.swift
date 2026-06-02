import Foundation

struct PlatformConfig: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let systemImage: String
    let settings: [SettingKey]
}

struct SettingKey: Identifiable, Equatable, Hashable {
    let id: String
    let rawKey: String
    let label: String
    let defaultValue: Bool
}

extension PlatformConfig {
    static let all: [PlatformConfig] = [
        PlatformConfig(id: "youtube", name: "YouTube", systemImage: "play.rectangle",
            settings: [
                SettingKey(id: "yt-feed",  rawKey: "local:youtube-hide-feed",               label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "yt-next",  rawKey: "local:youtube-hide-up-next-feed",       label: "Hide Up Next", defaultValue: true),
                SettingKey(id: "yt-sub",   rawKey: "local:youtube-hide-subscription-feed",  label: "Hide Sub Feed", defaultValue: true),
                SettingKey(id: "yt-short", rawKey: "local:youtube-shortform",               label: "Handle Shorts", defaultValue: true),
                SettingKey(id: "yt-more",  rawKey: "local:youtube-hide-more-from-youtube",  label: "Hide More", defaultValue: true),
                SettingKey(id: "yt-exp",   rawKey: "local:youtube-hide-explore",            label: "Hide Explore", defaultValue: true),
                SettingKey(id: "yt-you",   rawKey: "local:youtube-hide-you-section",        label: "Hide You", defaultValue: false),
                SettingKey(id: "yt-end",   rawKey: "local:youtube-hide-end-screen",         label: "Hide End Screen", defaultValue: true),
            ]
        ),
        PlatformConfig(id: "twitter", name: "Twitter / X", systemImage: "bird",
            settings: [
                SettingKey(id: "tw-feed", rawKey: "local:twitter-hide-feed",    label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "tw-prem", rawKey: "local:twitter-hide-premium", label: "Hide Premium",   defaultValue: true),
            ]
        ),
        PlatformConfig(id: "facebook", name: "Facebook", systemImage: "person.2",
            settings: [
                SettingKey(id: "fb-feed",  rawKey: "local:facebook-hide-feed",   label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "fb-short", rawKey: "local:facebook-shortform", label: "Handle Shorts",  defaultValue: true),
            ]
        ),
        PlatformConfig(id: "instagram", name: "Instagram", systemImage: "camera.aperture",
            settings: [
                SettingKey(id: "ig-feed",  rawKey: "local:instagram-hide-feed",    label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "ig-short", rawKey: "local:instagram-shortform",    label: "Handle Shorts",  defaultValue: true),
            ]
        ),
        PlatformConfig(id: "tiktok", name: "TikTok", systemImage: "music.note",
            settings: [
                SettingKey(id: "tt-feed",  rawKey: "local:tiktok-hide-feed",    label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "tt-short", rawKey: "local:tiktok-shortform", label: "Handle Shorts",  defaultValue: true),
            ]
        ),
        PlatformConfig(id: "reddit", name: "Reddit", systemImage: "bubble.left.and.bubble.right",
            settings: [
                SettingKey(id: "rd-feed", rawKey: "local:reddit-hide-feed", label: "Hide Home Feed", defaultValue: true),
            ]
        ),
        PlatformConfig(id: "linkedin", name: "LinkedIn", systemImage: "briefcase",
            settings: [
                SettingKey(id: "li-feed", rawKey: "local:linkedin-hide-feed",           label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "li-prem", rawKey: "local:linkedin-hide-premium-upsells", label: "Hide Premium",    defaultValue: true),
            ]
        ),
        PlatformConfig(id: "pinterest", name: "Pinterest", systemImage: "pin", settings: [
            SettingKey(id: "pt-feed", rawKey: "local:pinterest-hide-feed", label: "Hide Home Feed", defaultValue: true),
        ]),
        PlatformConfig(id: "bsky", name: "Bluesky", systemImage: "cloud.bolt", settings: [
            SettingKey(id: "bs-feed", rawKey: "local:bsky-hide-feed", label: "Hide Home Feed", defaultValue: true),
        ]),
        PlatformConfig(id: "substack", name: "Substack", systemImage: "newspaper", settings: [
            SettingKey(id: "ss-feed", rawKey: "local:substack-hide-feed", label: "Hide Home Feed", defaultValue: true),
        ]),
        PlatformConfig(id: "youtube_music", name: "YouTube Music", systemImage: "music.note.tv",
            settings: [
                SettingKey(id: "ym-feed", rawKey: "local:youtube_music-hide-feed",    label: "Hide Home Feed", defaultValue: true),
                SettingKey(id: "ym-rel",  rawKey: "local:youtube_music-hide-related", label: "Hide Related",     defaultValue: true),
            ]
        ),
    ]
}
