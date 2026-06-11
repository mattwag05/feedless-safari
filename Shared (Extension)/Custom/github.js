// Feedless Safari — GitHub (github.com).
// GitHub navigates with Turbo (SPA-style), so page-path tracking stays live.
// Only the logged-in dashboard feed is targeted; the logged-out marketing
// homepage has no matching container, so the CSS no-ops there.
(function () {
  const lib = window.__feedlessCustom;
  if (!lib) return;
  lib.trackPagePath();
  lib.watch({
    "local:github-hide-home-feed": "true",
  });
})();
