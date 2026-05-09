"""
Scan the Godot project for duplicate UIDs across .import, .tres, .tscn,
and .gdshader.uid files. For each duplicate group, hash the underlying
source file(s) and report whether the duplicates are byte-identical.

Output: a JSON report grouped by UID with member paths + content hashes.
"""

import hashlib
import json
import os
import re
import sys
from collections import defaultdict
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
EXCLUDE_DIRS = {".godot", ".git", "scripts"}

UID_RE_TEXT = re.compile(r'uid="(uid://[a-z0-9]+)"')
UID_LINE_IMPORT = re.compile(r'^uid="(uid://[a-z0-9]+)"\s*$', re.MULTILINE)


def md5(p: Path) -> str:
    h = hashlib.md5()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def extract_uid_from_import(p: Path) -> str | None:
    try:
        text = p.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None
    m = UID_LINE_IMPORT.search(text)
    return m.group(1) if m else None


def extract_uid_from_resource_header(p: Path) -> str | None:
    try:
        with open(p, "r", encoding="utf-8", errors="replace") as f:
            head = f.read(2048)
    except Exception:
        return None
    m = UID_RE_TEXT.search(head)
    return m.group(1) if m else None


def extract_uid_from_uid_sidecar(p: Path) -> str | None:
    try:
        text = p.read_text(encoding="utf-8", errors="replace").strip()
    except Exception:
        return None
    if text.startswith("uid://"):
        return text
    return None


def source_for_import(import_file: Path) -> Path | None:
    return import_file.with_suffix("") if import_file.suffix == ".import" else None


def source_for_uid_sidecar(uid_file: Path) -> Path | None:
    return uid_file.with_suffix("") if uid_file.suffix == ".uid" else None


def main() -> int:
    uid_to_entries: dict[str, list[dict]] = defaultdict(list)
    scanned = 0

    for root, dirs, files in os.walk(PROJECT_ROOT):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for name in files:
            p = Path(root) / name
            uid: str | None = None
            source: Path | None = None
            kind: str = ""

            if name.endswith(".import"):
                uid = extract_uid_from_import(p)
                source = source_for_import(p)
                kind = "import"
            elif name.endswith(".uid"):
                uid = extract_uid_from_uid_sidecar(p)
                source = source_for_uid_sidecar(p)
                kind = "uid_sidecar"
            elif name.endswith(".tres") or name.endswith(".tscn"):
                uid = extract_uid_from_resource_header(p)
                source = p
                kind = "resource"

            scanned += 1
            if not uid:
                continue

            entry = {
                "uid_file": str(p.relative_to(PROJECT_ROOT)).replace("\\", "/"),
                "source": (
                    str(source.relative_to(PROJECT_ROOT)).replace("\\", "/")
                    if source and source.exists() else None
                ),
                "kind": kind,
                "hash": md5(source) if source and source.exists() else None,
            }
            uid_to_entries[uid].append(entry)

    duplicates = {uid: entries for uid, entries in uid_to_entries.items() if len(entries) > 1}

    summary = {
        "files_scanned": scanned,
        "uids_with_duplicates": len(duplicates),
        "byte_identical_groups": 0,
        "differing_groups": 0,
        "groups": [],
    }

    for uid, entries in sorted(duplicates.items()):
        hashes = {e["hash"] for e in entries if e["hash"]}
        identical = len(hashes) == 1 and None not in hashes
        if identical:
            summary["byte_identical_groups"] += 1
        else:
            summary["differing_groups"] += 1
        summary["groups"].append(
            {
                "uid": uid,
                "byte_identical": identical,
                "entries": entries,
            }
        )

    out = PROJECT_ROOT / "scripts" / "uid_duplicates_report.json"
    out.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(f"Scanned {scanned} files")
    print(f"Found {len(duplicates)} UIDs with duplicates")
    print(f"  byte-identical groups: {summary['byte_identical_groups']}")
    print(f"  groups with differing content: {summary['differing_groups']}")
    print(f"Report: {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
