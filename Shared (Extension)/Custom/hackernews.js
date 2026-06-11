// Feedless Safari — Hacker News (news.ycombinator.com).
// Server-rendered static HTML; page-path is still maintained by lib so the
// CSS can gate to front-page paths only.
(function () {
  const lib = window.__feedlessCustom;
  if (!lib) return;
  lib.trackPagePath();
  lib.watch({
    "local:hackernews-hide-feed": "true",
  });
})();
