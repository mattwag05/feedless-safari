// Feedless Safari custom-overlay helper.
// Clean-room implementation: mirrors `local:*` keys from browser.storage.local
// onto :root attributes so plain CSS can react, the same contract the upstream
// Feedless content scripts use. Loaded first in every Custom/ manifest entry;
// idempotent so multiple entries on one page are safe.
(function () {
  if (window.__feedlessCustom) return;
  const B = typeof browser !== "undefined" ? browser : typeof chrome !== "undefined" ? chrome : null;
  if (!B?.storage?.local) return;
  const root = document.documentElement;

  function setAttr(rawKey, value, fallback) {
    const name = rawKey.replace(/^local:/, "");
    root.setAttribute(name, String(value ?? fallback));
  }

  // defaults: { "local:<key>": "<fallback value>", ... }
  function watch(defaults) {
    const keys = Object.keys(defaults);
    B.storage.local.get(keys).then((stored) => {
      for (const k of keys) setAttr(k, stored?.[k], defaults[k]);
    }).catch(() => {
      for (const k of keys) setAttr(k, null, defaults[k]);
    });
    B.storage.onChanged.addListener((changes, area) => {
      if (area !== "local") return;
      for (const k of keys) {
        if (k in changes) setAttr(k, changes[k].newValue, defaults[k]);
      }
    });
  }

  // Maintains a `page-path` attribute on :root, normalized with a trailing
  // slash ("/", "/following/", ...) to match the upstream convention. Content
  // scripts run in an isolated world, so SPA navigations are detected by
  // polling + popstate rather than patching history.
  let tracking = false;
  function trackPagePath() {
    if (tracking) return;
    tracking = true;
    let last = null;
    const update = () => {
      const p = location.pathname.endsWith("/") ? location.pathname : location.pathname + "/";
      if (p !== last) {
        last = p;
        root.setAttribute("page-path", p);
      }
    };
    update();
    window.addEventListener("popstate", update);
    setInterval(update, 300);
  }

  window.__feedlessCustom = { watch, trackPagePath };
})();
