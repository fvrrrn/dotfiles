"""One fzf interface for Sway windows, XDG applications and Kitty output.

Snapshots are private and invocation-local. Reloads and previews never fetch
terminal output again, so typing remains responsive and IDs remain stable.
"""

import argparse
import concurrent.futures
import configparser
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import sqlite3
import stat
import subprocess
import sys
import tempfile


def run(args, **kwargs):
    return subprocess.run(args, text=True, capture_output=True, timeout=8, **kwargs)


def clean(text):
    # Never let terminal escape sequences or delimiters become picker commands.
    return re.sub(r"[\x00-\x1f\x7f-\x9f]", " ", str(text))


def windows():
    tree = json.loads(run(["swaymsg", "-t", "get_tree", "-r"]).stdout)
    found = []

    def walk(node, workspace=""):
        if node.get("type") == "workspace":
            workspace = node["name"]
        app = node.get("app_id") or node.get("window_properties", {}).get("class")
        if app and app != "dfzf-popup" and "dfzf-hidden" not in node.get("marks", []):
            recent = max(
                [int(m.rsplit("-", 1)[-1]) for m in node.get("marks", [])
                 if re.fullmatch(r"_dfzf-sort-\d+", m)] or [0]
            )
            found.append({"con": node["id"], "title": node.get("name") or app,
                          "app": app, "workspace": workspace, "recent": recent,
                          "pid": node.get("pid")})
        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            walk(child, workspace)

    walk(tree)
    return sorted(found, key=lambda w: w["recent"], reverse=True)


def applications():
    roots = [Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))]
    roots += [Path(p) for p in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":") if p]
    # Include Nix profiles even in a compositor with a minimal environment.
    roots += [Path.home() / ".nix-profile/share", Path("/run/current-system/sw/share")]
    desktops = set(os.environ.get("XDG_CURRENT_DESKTOP", "sway").split(":"))
    language = os.environ.get("LC_ALL") or os.environ.get("LC_MESSAGES") or os.environ.get("LANG", "")
    language = language.split(".")[0]
    locales = [language, language.split("_")[0]]
    seen = set()
    found = []
    for root in roots:
        directory = root / "applications"
        for path in sorted(directory.rglob("*.desktop")):
            desktop_id = str(path.relative_to(directory)).replace("/", "-")
            if desktop_id in seen:
                continue
            seen.add(desktop_id)  # Hidden user entries mask system entries too.
            parser = configparser.ConfigParser(interpolation=None, strict=False)
            parser.optionxform = str
            try:
                parser.read(path, encoding="utf-8")
                entry = parser["Desktop Entry"]
            except (OSError, UnicodeError, configparser.Error, KeyError):
                continue
            if entry.get("Type") != "Application" or any(entry.get(k, "").lower() == "true" for k in ("Hidden", "NoDisplay")):
                continue
            only = set(filter(None, entry.get("OnlyShowIn", "").split(";")))
            exclude = set(filter(None, entry.get("NotShowIn", "").split(";")))
            if (only and not only & desktops) or exclude & desktops:
                continue
            if entry.get("TryExec") and not shutil.which(entry["TryExec"]):
                continue
            if not entry.get("Exec") and entry.get("DBusActivatable", "").lower() != "true":
                continue

            def localized(key):
                return next((entry[f"{key}[{loc}]"] for loc in locales if f"{key}[{loc}]" in entry), entry.get(key, ""))

            name = localized("Name")
            if name:
                found.append({"name": name, "comment": localized("Comment"),
                              "keywords": localized("Keywords"), "generic": localized("GenericName"),
                              "path": str(path), "exec": entry.get("Exec", "")})
    return sorted(found, key=lambda a: a["name"].casefold())


def kitty_command(sock, command, *args):
    return run(["kitty", "@", "--to", sock, command, *args])


def scrollbacks(window_list):
    sockets = set()
    for directory in {Path("/tmp"), Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))}:
        for path in directory.glob("kitty*"):
            try:
                info = path.stat()
                if stat.S_ISSOCK(info.st_mode) and info.st_uid == os.getuid():
                    sockets.add("unix:" + str(path))
            except OSError:
                pass
    if os.environ.get("KITTY_LISTEN_ON"):
        sockets.add(os.environ["KITTY_LISTEN_ON"])
    tasks = []
    for sock in sorted(sockets):
        try:
            listing = json.loads(kitty_command(sock, "ls").stdout)
        except (ValueError, OSError, subprocess.TimeoutExpired):
            continue
        for os_window in listing:
            if os_window.get("wm_class") == "dfzf-popup":
                continue
            tabs = os_window.get("tabs", [])
            active = [w for t in tabs if t.get("is_active") for w in t["windows"] if w.get("is_active")]
            title = active[0]["title"] if active else ""
            matches = [w for w in window_list if w["app"] == "kitty" and w["title"] == title]
            # Ambiguous duplicate titles must not focus the wrong Sway window.
            if len(matches) != 1:
                continue
            for tab in tabs:
                for window in tab["windows"]:
                    tasks.append((sock, matches[0], window))

    def fetch(task):
        sock, parent, window = task
        try:
            response = kitty_command(sock, "get-text", "--match", f"id:{window['id']}",
                                     "--extent", "all", "--add-wrap-markers")
            if response.returncode:
                return None
            # Wrap markers let us count physical rows for scroll-window.
            lines = response.stdout.replace("\r\n", "\n").replace("\r", "\n").splitlines()
            return {"sock": sock, "kitty_id": window["id"], "con": parent["con"],
                    "title": window["title"], "cwd": window.get("cwd", ""),
                    "rows": window.get("lines", 24), "lines": lines}
        except (OSError, subprocess.TimeoutExpired):
            return None

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        return [item for item in pool.map(fetch, tasks) if item]


def snapshot(db):
    db.execute("CREATE TABLE entries (id INTEGER PRIMARY KEY, kind TEXT, label TEXT, payload TEXT)")
    db.execute("CREATE TABLE terminals (id INTEGER PRIMARY KEY, payload TEXT)")

    def add(kind, label, payload):
        db.execute("INSERT INTO entries(kind,label,payload) VALUES (?,?,?)",
                   (kind, clean(label), json.dumps(payload)))

    window_list = windows()
    for window in window_list:
        add("WINDOW", f"{window['title']}  ·  {window['app']} · ws {window['workspace']}", window)
    for app in applications():
        details = " · ".join(filter(None, [app["generic"], app["comment"], app["keywords"].replace(";", " ")]))
        add("APP", app["name"] + ("  ·  " + details if details else ""), app)
    for terminal in scrollbacks(window_list):
        cursor = db.execute("INSERT INTO terminals(payload) VALUES (?)", (json.dumps(terminal),))
        terminal_id = cursor.lastrowid
        # Newest output first on equal scores. Skip repeated lines per terminal.
        seen = set()
        for index in range(len(terminal["lines"]) - 1, -1, -1):
            text = clean(terminal["lines"][index]).strip()
            if not text or text == "~" or text in seen:
                continue
            seen.add(text)
            add("SCROLLBACK", f"{text}  ·  {terminal['title']}", {"terminal": terminal_id, "line": index})
    db.commit()


def record(row):
    return f"{row[0]}\t{row[1]:<10} {row[2]}\n"


def candidates(db, query, kind):
    rows = db.execute("SELECT id,kind,label FROM entries ORDER BY id")
    base, history = [], []
    for row in rows:
        if kind != "ALL" and row[1] != kind:
            continue
        if row[1] == "SCROLLBACK":
            if query.strip():
                history.append(record(row))
        else:
            base.append(record(row))
    sys.stdout.write("".join(base))
    if history:
        # Use fzf itself so quoting, negation and fuzzy matching are identical
        # in both the scrollback prefilter and the interactive mixed list.
        result = run(["fzf", "--filter", query, "--delimiter=\t", "--nth=2..", "--tiebreak=index"],
                     input="".join(history), env={**os.environ, "FZF_DEFAULT_OPTS": ""})
        matches = result.stdout.splitlines()[:120]
        if matches:
            sys.stdout.write("\n".join(matches) + "\n")


def entry(db, identifier):
    kind, label, payload = db.execute("SELECT kind,label,payload FROM entries WHERE id=?", (int(identifier),)).fetchone()
    return kind, label, json.loads(payload)


def terminal_entry(db, payload):
    return json.loads(db.execute("SELECT payload FROM terminals WHERE id=?", (payload["terminal"],)).fetchone()[0])


def preview(db, identifier):
    kind, label, payload = entry(db, identifier)
    print(clean(label), "\n")
    if kind == "APP":
        print("Launch application\n", clean(payload["exec"]), "\n", clean(payload["path"]))
    elif kind == "WINDOW":
        print("Focus window\nWorkspace:", clean(payload["workspace"]))
    else:
        terminal = terminal_entry(db, payload)
        print("Focus terminal and scroll to output\nDirectory:", clean(terminal["cwd"]), "\n")
        index = payload["line"]
        for i in range(max(0, index - 6), min(len(terminal["lines"]), index + 12)):
            print(("> " if i == index else "  ") + clean(terminal["lines"][i]))


def activate(db, identifier):
    kind, _, payload = entry(db, identifier)
    if kind == "APP":
        terminal_path = str(Path(__file__).resolve().parent / "terminal")
        result = run(["gio", "launch", payload["path"]],
                     env={**os.environ, "PATH": terminal_path + os.pathsep + os.environ["PATH"]})
    else:
        target = terminal_entry(db, payload) if kind == "SCROLLBACK" else payload
        result = run(["swaymsg", f"[con_id={target['con']}] focus"])
        if kind == "SCROLLBACK":
            kitty_command(target["sock"], "focus-window", "--match", f"id:{target['kitty_id']}")
            kitty_command(target["sock"], "scroll-window", "--match", f"id:{target['kitty_id']}", "start")
            # Position the selected physical row near the centre of the screen.
            offset = max(0, payload["line"] - target["rows"] // 2)
            result = kitty_command(target["sock"], "scroll-window", "--match", f"id:{target['kitty_id']}", f"{offset}l+")
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)


def picker(db, path):
    helper = shlex.join([sys.executable, str(Path(__file__).resolve()), "--db", path])
    reload_cmd = helper + ' --list --kind "$(cat ' + shlex.quote(path + ".kind") + ')" --query={q}'
    Path(path + ".kind").write_text("ALL")
    bindings = ["change:reload(" + reload_cmd + ")"]
    for key, kind in [("0", "ALL"), ("w", "WINDOW"), ("a", "APP"), ("s", "SCROLLBACK")]:
        command = "printf '%s' " + kind + " > " + shlex.quote(path + ".kind")
        bindings.append(f"alt-{key}:execute-silent({command})+change-prompt({kind.title()} > )+reload({reload_cmd})")
    base = "".join(record(row) for row in db.execute("SELECT id,kind,label FROM entries WHERE kind!='SCROLLBACK' ORDER BY id"))
    result = subprocess.run(
        ["fzf", "--delimiter=\t", "--with-nth=2..", "--layout=reverse",
         "--prompt=Search > ", "--tiebreak=index", "--cycle", "--margin=1,2",
         "--header=Enter: open · Esc: close · Alt-W/A/S: filter · Alt-0: all",
         "--preview=" + helper + " --preview {1}", "--preview-window=down:40%:wrap",
         "--bind=" + ",".join(bindings)],
        input=base, stdout=subprocess.PIPE, text=True,
        env={**os.environ, "FZF_DEFAULT_OPTS": "", "SHELL": shutil.which("bash")},
    )
    if result.returncode == 0 and result.stdout.strip():
        activate(db, result.stdout.split("\t", 1)[0])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", help=argparse.SUPPRESS)
    parser.add_argument("--list", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--preview", help=argparse.SUPPRESS)
    parser.add_argument("--query", default="", help=argparse.SUPPRESS)
    parser.add_argument("--kind", default="ALL", help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.db:
        with sqlite3.connect(args.db) as db:
            if args.list:
                candidates(db, args.query, args.kind)
            elif args.preview:
                preview(db, args.preview)
        return
    with tempfile.TemporaryDirectory(prefix="dfzf-search-", dir=os.environ.get("XDG_RUNTIME_DIR")) as directory:
        path = str(Path(directory) / "snapshot.sqlite")
        with sqlite3.connect(path) as db:
            snapshot(db)
            picker(db, path)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError, sqlite3.Error) as error:
        print(f"dfzf-search: {error}", file=sys.stderr)
        sys.exit(1)
