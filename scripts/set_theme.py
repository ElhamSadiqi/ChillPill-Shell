#!/usr/bin/env python3
"""Persist the chosen chillpill-shell theme to config.jsonc.

Usage: set_theme.py <theme-name>
  theme-name can be empty to clear the theme (restore built-in defaults).
"""
import os, json, sys

HOME = os.environ.get("HOME", "")
if not HOME:
    print("HOME not set", file=sys.stderr)
    sys.exit(1)


def strip_jsonc_comments(src: str) -> str:
    out, i, n = [], 0, len(src)
    in_str = False
    while i < n:
        c = src[i]
        if in_str:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(src[i + 1]); i += 2; continue
            if c == '"':
                in_str = False
            i += 1
        elif c == '"':
            in_str = True; out.append(c); i += 1
        elif src.startswith("//", i):
            while i < n and src[i] != "\n":
                i += 1
        elif src.startswith("/*", i):
            i = src.find("*/", i + 2)
            i = n if i == -1 else i + 2
        else:
            out.append(c); i += 1
    return "".join(out)

cfg = os.path.join(HOME, ".config", "chillpill-shell", "config.jsonc")
theme = sys.argv[1] if len(sys.argv) > 1 else ""

data = {}
if os.path.isfile(cfg):
    try:
        with open(cfg, "r") as f:
            # config.jsonc allows comments, plain json.load does not; strip them
            # (skipping string contents) so a commented config survives the rewrite
            data = json.loads(strip_jsonc_comments(f.read()))
    except Exception:
        data = {}

data["theme"] = theme

os.makedirs(os.path.dirname(cfg), exist_ok=True)
with open(cfg, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

# cache marker for fast theme detection without parsing config.jsonc
cache_dir = os.path.join(HOME, ".cache", "chillpill-shell")
os.makedirs(cache_dir, exist_ok=True)
marker = os.path.join(cache_dir, "active-theme")
try:
    if theme:
        with open(marker, "w") as f:
            f.write(theme)
    elif os.path.isfile(marker):
        os.remove(marker)
except OSError:
    pass

print("theme:", theme or "<default>")
