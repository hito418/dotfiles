#!/usr/bin/env python3
"""List unresolved review comments on the current PR (GitHub) or MR (GitLab).

Prints a JSON array: [{id, file, line, author, body, url, outdated?}, ...]
`id` is an opaque string; pass it back to resolve_comment.py to resolve.
"""

import json
import subprocess
import sys
from urllib.parse import quote


def git_remote_url() -> str:
    try:
        return subprocess.check_output(
            ["git", "remote", "get-url", "origin"], text=True
        ).strip()
    except subprocess.CalledProcessError:
        sys.exit("error: no 'origin' remote configured")


def detect_platform() -> str:
    url = git_remote_url().lower()
    if "github.com" in url:
        return "github"
    if "gitlab" in url:
        return "gitlab"
    if subprocess.run(["glab", "repo", "view"], capture_output=True).returncode == 0:
        return "gitlab"
    if subprocess.run(["gh", "repo", "view"], capture_output=True).returncode == 0:
        return "github"
    sys.exit(f"error: could not detect platform from remote: {url}")


def list_github() -> list:
    try:
        pr_meta = json.loads(subprocess.check_output(
            ["gh", "pr", "view", "--json", "number"],
            text=True, stderr=subprocess.PIPE,
        ))
    except subprocess.CalledProcessError as e:
        sys.exit(e.stderr.strip() or "error: no PR for current branch")
    repo = json.loads(subprocess.check_output(
        ["gh", "repo", "view", "--json", "owner,name"], text=True,
    ))
    owner, name, number = repo["owner"]["login"], repo["name"], pr_meta["number"]

    query = """
    query($owner: String!, $name: String!, $number: Int!) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $number) {
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              isOutdated
              comments(first: 1) {
                nodes { body path line url author { login } }
              }
            }
          }
        }
      }
    }
    """
    out = subprocess.check_output(
        ["gh", "api", "graphql",
         "-f", f"query={query}",
         "-F", f"owner={owner}",
         "-F", f"name={name}",
         "-F", f"number={number}"],
        text=True,
    )
    threads = json.loads(out)["data"]["repository"]["pullRequest"]["reviewThreads"]["nodes"]
    result = []
    for t in threads:
        if t["isResolved"] or not t["comments"]["nodes"]:
            continue
        c = t["comments"]["nodes"][0]
        result.append({
            "id": t["id"],
            "file": c.get("path"),
            "line": c.get("line"),
            "author": (c.get("author") or {}).get("login"),
            "body": c.get("body"),
            "url": c.get("url"),
            "outdated": t["isOutdated"],
        })
    return result


def list_gitlab() -> list:
    try:
        mr = json.loads(subprocess.check_output(
            ["glab", "mr", "view", "--output", "json"],
            text=True, stderr=subprocess.PIPE,
        ))
    except subprocess.CalledProcessError as e:
        sys.exit(e.stderr.strip() or "error: no MR for current branch")
    repo = json.loads(subprocess.check_output(
        ["glab", "repo", "view", "--output", "json"], text=True,
    ))
    project = quote(repo["full_path"], safe="")
    mr_iid = mr["iid"]

    out = subprocess.check_output(
        ["glab", "api", f"projects/{project}/merge_requests/{mr_iid}/discussions"],
        text=True,
    )
    discussions = json.loads(out)
    result = []
    for d in discussions:
        notes = d.get("notes") or []
        if not notes:
            continue
        note = notes[0]
        if note.get("system") or note.get("resolved") or not note.get("resolvable"):
            continue
        pos = note.get("position") or {}
        result.append({
            "id": d["id"],
            "file": pos.get("new_path") or pos.get("old_path"),
            "line": pos.get("new_line") or pos.get("old_line"),
            "author": (note.get("author") or {}).get("username"),
            "body": note.get("body"),
            "url": f"{mr['web_url']}#note_{note['id']}",
        })
    return result


def main() -> None:
    items = list_github() if detect_platform() == "github" else list_gitlab()
    print(json.dumps(items, indent=2))


if __name__ == "__main__":
    main()
