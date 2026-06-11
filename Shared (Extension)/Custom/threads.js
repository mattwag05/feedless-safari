// Feedless Safari — Threads (threads.com).
// Feed surfaces are URL-addressed (/ = For You, /following = Following), so
// hiding is pure CSS keyed on the attributes mirrored here.
(function () {
  const lib = window.__feedlessCustom;
  if (!lib) return;
  lib.trackPagePath();
  lib.watch({
    "local:threads-hide-for-you": "true",
    "local:threads-hide-following": "true",
  });
})();
