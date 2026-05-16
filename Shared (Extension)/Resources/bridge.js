// Feedless Safari — Settings Bridge
// Syncs UserDefaults (Swift app) → browser.storage.local (content scripts)
(function() {
  const B = typeof browser !== 'undefined' ? browser : typeof chrome !== 'undefined' ? chrome : null;
  if (!B?.runtime?.sendMessage) return;

  async function sync() {
    try {
      const resp = await B.runtime.sendMessage({ action: "getSettings" });
      if (resp?.settings && Object.keys(resp.settings).length > 0) {
        await B.storage.local.set(resp.settings);
      }
    } catch (e) {
      console.debug("Feedless bridge: sync failed (Safari handler not ready yet)", e);
    }
  }

  // Sync on load
  sync();

  // Re-sync when app broadcasts changes
  B.runtime.onMessage.addListener((msg, sender, sendResponse) => {
    if (msg?.settings) {
      B.storage.local.set(msg.settings).then(() => sendResponse({ ok: true }));
      return true; // async
    }
  });
})();
