#!/usr/bin/env python3
"""Compare a machine's live settings with settings.shared.json.

Usage: drift-check.py <settings.shared.json> <~/.claude/settings.json>
Prints one line that names every drifted key and exits 1. Prints nothing and
exits 0 when the machine carries everything the shared file asks for.

The shared file is a BASELINE. A machine may add its own allows, plugins,
marketplaces and hooks. Drift means a shared value is missing or changed.
Nothing is changed here; sync.sh and doctor.sh only report the result.
"""
from __future__ import annotations

import json
import sys


def find_drift(shared: dict, live: dict) -> list[str]:
    drift = []

    if "effortLevel" in shared and shared["effortLevel"] != live.get("effortLevel"):
        drift.append("effortLevel")

    # Marketplaces: every shared one must be present and identical.
    live_markets = live.get("extraKnownMarketplaces", {})
    for name, want in shared.get("extraKnownMarketplaces", {}).items():
        if live_markets.get(name) != want:
            drift.append(f"extraKnownMarketplaces.{name}")

    # Permissions: deny rules and mode must match exactly. Shared allows must
    # be present; a machine may add more. Any other extra key is drift.
    sp, lp = shared.get("permissions", {}), live.get("permissions", {})
    for key, want in sp.items():
        if key == "allow":
            if not set(want) <= set(lp.get("allow", [])):
                drift.append("permissions.allow")
        elif lp.get(key) != want:
            drift.append(f"permissions.{key}")
    for key in lp:
        if key not in sp and key != "allow":
            drift.append(f"permissions.{key}")

    # Skill overrides and plugins: each shared entry must match, including an
    # explicit "off" or false. Extra entries on the machine are fine.
    live_overrides = live.get("skillOverrides", {})
    for name, want in shared.get("skillOverrides", {}).items():
        if live_overrides.get(name) != want:
            drift.append(f"skillOverrides.{name}")
    live_plugins = live.get("enabledPlugins", {})
    for name, want in shared.get("enabledPlugins", {}).items():
        if live_plugins.get(name, False) != want:
            drift.append(f"enabledPlugins.{name}")

    # Hooks: every shared hook command must still be on its event.
    live_hooks = live.get("hooks", {})
    for event, groups in shared.get("hooks", {}).items():
        live_cmds = {h.get("command") for g in live_hooks.get(event, []) for h in g.get("hooks", [])}
        if any(h.get("command") not in live_cmds for g in groups for h in g.get("hooks", [])):
            drift.append(f"hooks.{event}")

    return drift


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    try:
        shared = json.load(open(sys.argv[1]))
        live = json.load(open(sys.argv[2]))
    except (OSError, ValueError) as exc:
        print(f"drift-check: cannot read settings: {exc}")
        return 2
    drift = find_drift(shared, live)
    if drift:
        print("DRIFT between settings.shared.json and ~/.claude/settings.json in: " + ", ".join(drift))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
