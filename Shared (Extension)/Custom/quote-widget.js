// Feedless Safari — quote widget.
// Mounts a quote card where a hidden home feed used to be. The card is always
// inserted as a SIBLING of the hidden node, never inside it: several upstream
// scripts hide via `opacity:0` / `visibility:hidden` on the container, and a
// child can never out-render an ancestor's opacity. For those platforms the
// card overlays the (invisible, space-occupying) container instead.
(function () {
  const B = typeof browser !== "undefined" ? browser : typeof chrome !== "undefined" ? chrome : null;
  if (!B?.storage?.local) return;

  const KEYS = {
    enabled: "local:quote-widget-enabled",
    rotation: "local:quote-widget-rotation-policy",
    custom: "local:quote-widget-custom-quotes-json",
  };
  const KEY_LIST = Object.values(KEYS);
  const CARD_ID = "feedless-quote-card";

  // rule = { attr: :root attribute the upstream/custom script maintains,
  //          paths: normalized page paths where the feed lives,
  //          anchor: selector (or anchorFn) for the hidden feed container,
  //          overlay: true when the container is hidden but still occupies space }
  const MOUNTS = [
    { hosts: ["www.youtube.com"], rules: [{ attr: "youtube-hide-feed", paths: ["/"], anchor: "ytd-rich-grid-renderer" }] },
    { hosts: ["m.youtube.com"], rules: [{ attr: "youtube-hide-feed", paths: ["/"], anchor: "ytm-rich-grid-renderer" }] },
    { hosts: ["music.youtube.com"], rules: [{ attr: "youtube_music-hide-feed", paths: ["/"], anchor: "ytmusic-browse-response" }] },
    { hosts: ["twitter.com", "x.com"], rules: [{ attr: "twitter-hide-feed", paths: ["/home/"], anchor: '[data-testid="primaryColumn"]', overlay: true }] },
    { hosts: ["facebook.com"], rules: [{ attr: "facebook-hide-feed", paths: ["/"], anchor: '[role="main"]' }] },
    { hosts: ["instagram.com"], rules: [{ attr: "instagram-hide-feed", paths: ["/"], anchor: '[role="main"]' }] },
    { hosts: ["threads.com"], rules: [
      { attr: "threads-hide-for-you", paths: ["/", "/for_you/"], anchor: '[role="region"]' },
      { attr: "threads-hide-following", paths: ["/following/"], anchor: '[role="region"]' },
    ] },
    { hosts: ["tiktok.com"], rules: [{ attr: "tiktok-hide-feed", paths: ["/"], anchor: "main article" }] },
    { hosts: ["www.reddit.com"], rules: [{ attr: "reddit-hide-feed", paths: ["/"], anchor: ".subgrid-container" }] },
    { hosts: ["linkedin.com"], rules: [{ attr: "linkedin-hide-feed", paths: ["/feed/"], anchor: "main" }] },
    { hosts: ["pinterest.com"], rules: [{ attr: "pinterest-hide-feed", paths: ["/"], anchor: '[role="main"]' }] },
    { hosts: ["bsky.app"], rules: [{ attr: "bsky-hide-feed", paths: ["/"], anchor: '[role="main"], main' }] },
    { hosts: ["substack.com"], rules: [{ attr: "substack-hide-feed", paths: ["/", "/home/"], anchor: "main", overlay: true }] },
    { hosts: ["news.ycombinator.com"], rules: [{
      attr: "hackernews-hide-feed", paths: ["/", "/news/", "/front/"],
      anchorFn: () => document.querySelector("tr.athing")?.closest("table"),
    }] },
    { hosts: ["github.com"], rules: [{ attr: "github-hide-home-feed", paths: ["/", "/dashboard/"], anchor: "#dashboard-feed, feed-container, #dashboard" }] },
  ];

  const entry = MOUNTS.find((m) =>
    m.hosts.some((h) => location.hostname === h || location.hostname.endsWith("." + h)));
  if (!entry) return;

  const settings = { enabled: true, rotation: "page-load", custom: [] };
  let quoteIndex = null;

  function pool() {
    const curated = window.__feedlessQuotes || [];
    const custom = settings.custom.filter((q) => q && typeof q.text === "string" && q.text.trim());
    return curated.concat(custom);
  }

  function pickIndex(n, fresh) {
    if (!n) return null;
    if (!fresh) {
      if (settings.rotation === "day") {
        const day = new Date().toISOString().slice(0, 10);
        let h = 0;
        for (const c of day) h = (h * 31 + c.charCodeAt(0)) >>> 0;
        return h % n;
      }
      if (settings.rotation === "session") {
        const saved = parseInt(sessionStorage.getItem("feedless-quote-index"), 10);
        if (!Number.isNaN(saved) && saved < n) return saved;
      }
    }
    const idx = Math.floor(Math.random() * n);
    if (settings.rotation === "session") sessionStorage.setItem("feedless-quote-index", String(idx));
    return idx;
  }

  function applySettings(stored) {
    settings.enabled = String(stored[KEYS.enabled] ?? "true") === "true";
    settings.rotation = ["page-load", "session", "day"].includes(stored[KEYS.rotation]) ? stored[KEYS.rotation] : "page-load";
    try {
      const parsed = JSON.parse(stored[KEYS.custom] || "[]");
      settings.custom = Array.isArray(parsed) ? parsed : [];
    } catch {
      settings.custom = [];
    }
  }

  function renderQuote(card) {
    const quotes = pool();
    if (quoteIndex === null || quoteIndex >= quotes.length) quoteIndex = pickIndex(quotes.length, false);
    const q = quotes[quoteIndex];
    if (!q) return;
    card.querySelector(".feedless-quote-text").textContent = "“" + q.text + "”";
    card.querySelector(".feedless-quote-attribution").textContent = "— " + (q.attribution || "Unknown");
  }

  function buildCard() {
    const card = document.createElement("div");
    card.id = CARD_ID;
    card.className = "feedless-quote-card";
    const text = document.createElement("blockquote");
    text.className = "feedless-quote-text";
    const attribution = document.createElement("div");
    attribution.className = "feedless-quote-attribution";
    const refresh = document.createElement("button");
    refresh.className = "feedless-quote-refresh";
    refresh.type = "button";
    refresh.title = "New quote";
    refresh.textContent = "↻";
    refresh.addEventListener("click", () => {
      quoteIndex = pickIndex(pool().length, true);
      renderQuote(card);
    });
    card.append(text, attribution, refresh);
    renderQuote(card);
    return card;
  }

  function activeRule() {
    if (!settings.enabled) return null;
    const p = location.pathname.endsWith("/") ? location.pathname : location.pathname + "/";
    const root = document.documentElement;
    return entry.rules.find((r) => r.paths.includes(p) && root.getAttribute(r.attr) === "true") || null;
  }

  function ensureMounted() {
    const rule = activeRule();
    let card = document.getElementById(CARD_ID);
    if (!rule) {
      if (card) card.remove();
      return;
    }
    const anchor = rule.anchorFn ? rule.anchorFn() : document.querySelector(rule.anchor);
    if (!anchor) {
      if (card) card.remove();
      return;
    }
    if (card && card.isConnected && card.previousElementSibling !== anchor && card.nextElementSibling !== anchor) {
      card.remove();
      card = null;
    }
    if (card) return;
    card = buildCard();
    if (rule.overlay) {
      const parent = anchor.parentElement;
      if (!parent) return;
      if (getComputedStyle(parent).position === "static") parent.style.position = "relative";
      card.classList.add("feedless-quote-overlay");
      parent.insertBefore(card, anchor);
    } else {
      anchor.insertAdjacentElement("beforebegin", card);
    }
  }

  // The re-mount poll only runs while the widget is enabled — a disabled
  // widget costs nothing beyond the initial storage read.
  let pollId = null;
  function syncPoll() {
    if (settings.enabled && pollId === null) {
      pollId = setInterval(ensureMounted, 700);
    } else if (!settings.enabled && pollId !== null) {
      clearInterval(pollId);
      pollId = null;
    }
  }

  let snapshot = {};
  B.storage.local.get(KEY_LIST).then((stored) => {
    snapshot = stored || {};
    applySettings(snapshot);
    ensureMounted();
    syncPoll();
  });

  B.storage.onChanged.addListener((changes, area) => {
    if (area !== "local") return;
    let touched = false;
    for (const k of KEY_LIST) {
      if (k in changes) {
        snapshot[k] = changes[k].newValue;
        touched = true;
      }
    }
    if (!touched) return;
    applySettings(snapshot);
    quoteIndex = null;
    document.getElementById(CARD_ID)?.remove();
    ensureMounted();
    syncPoll();
  });
})();
