#!/usr/bin/env python3
"""Re-apply Feedless Safari's custom overlay entries to the extension manifest.

The upstream resync (scripts/rebuild.sh) rsync --deletes everything under
"Shared (Extension)/Resources/", including manifest.json. Our own content
scripts live outside that blast radius in "Shared (Extension)/Custom/", but
the manifest entries that reference them get wiped. This script re-adds them
idempotently: run it after every resync (rebuild.sh calls it automatically),
or any time manifest-additions.json changes. Running it twice is a no-op.
"""

import json
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
MANIFEST = PROJECT_DIR / "Shared (Extension)" / "Resources" / "manifest.json"
ADDITIONS = PROJECT_DIR / "Shared (Extension)" / "Custom" / "manifest-additions.json"


def is_custom(entry: dict) -> bool:
    paths = entry.get("js", []) + entry.get("css", [])
    return any(p.startswith("Custom/") for p in paths)


def is_legacy_bridge(entry: dict) -> bool:
    return entry.get("js") == ["bridge.js"]


def main() -> int:
    manifest = json.loads(MANIFEST.read_text())
    additions = json.loads(ADDITIONS.read_text())

    upstream = [
        e for e in manifest.get("content_scripts", [])
        if not is_custom(e) and not is_legacy_bridge(e)
    ]

    # Bridge first so settings sync starts before any platform script runs
    # (all entries are document_start; same-stage order follows manifest order).
    manifest["content_scripts"] = [additions["bridge"]] + upstream + additions["content_scripts"]

    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"patched {MANIFEST.relative_to(PROJECT_DIR)}: "
          f"{len(upstream)} upstream + bridge + {len(additions['content_scripts'])} custom entries")
    return 0


if __name__ == "__main__":
    sys.exit(main())
