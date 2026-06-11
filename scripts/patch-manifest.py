#!/usr/bin/env python3
"""Re-apply Feedless Safari's custom overlay entries to the extension manifest.

The upstream resync (scripts/rebuild.sh) rsync --deletes everything under
"Shared (Extension)/Resources/", including manifest.json. Our own content
scripts live outside that blast radius in "Shared (Extension)/Custom/", but
the manifest entries that reference them get wiped. This script re-adds them
idempotently: run it after every resync (rebuild.sh calls it automatically),
or any time manifest-additions.json changes. Running it twice is a no-op.

Entries that must run on every platform (the settings bridge, the quote
widget) declare "matches": "all-platforms"; the union of upstream + custom
match patterns is computed here so an upstream resync that adds a host can't
silently strip settings sync from it.
"""

import json
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
MANIFEST = PROJECT_DIR / "Shared (Extension)" / "Resources" / "manifest.json"
ADDITIONS = PROJECT_DIR / "Shared (Extension)" / "Custom" / "manifest-additions.json"

ALL_PLATFORMS = "all-platforms"


def is_custom(entry: dict) -> bool:
    paths = entry.get("js", []) + entry.get("css", [])
    return any(p.startswith("Custom/") for p in paths)


def main() -> int:
    manifest = json.loads(MANIFEST.read_text())
    additions = json.loads(ADDITIONS.read_text())

    upstream = [e for e in manifest.get("content_scripts", []) if not is_custom(e)]
    custom = [additions["bridge"]] + additions["content_scripts"]

    all_matches = sorted({
        m
        for e in upstream + custom
        if isinstance(e.get("matches"), list)
        for m in e["matches"]
    })
    for e in custom:
        if e.get("matches") == ALL_PLATFORMS:
            e["matches"] = all_matches

    # Bridge first so settings sync starts before any platform script runs
    # (all entries are document_start; same-stage order follows manifest order).
    manifest["content_scripts"] = [custom[0]] + upstream + custom[1:]

    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"patched {MANIFEST.relative_to(PROJECT_DIR)}: "
          f"{len(upstream)} upstream + bridge + {len(custom) - 1} custom entries "
          f"({len(all_matches)} host patterns)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
