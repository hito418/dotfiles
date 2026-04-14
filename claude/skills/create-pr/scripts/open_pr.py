#!/usr/bin/env python3
"""Create a PR (GitHub) or MR (GitLab), auto-detecting platform from git remote.

Pushes the current branch first, then creates the PR/MR via gh/glab.
"""

import argparse
import subprocess
import sys


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


def current_branch() -> str:
    return subprocess.check_output(
        ["git", "branch", "--show-current"], text=True
    ).strip()


def detect_base() -> str:
    try:
        upstream = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD@{upstream}"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
        return upstream.split("/", 1)[-1]
    except subprocess.CalledProcessError:
        return "main"


def push(head: str) -> None:
    subprocess.check_call(["git", "push", "-u", "origin", head])


def create_github(title: str, body: str, base: str, head: str) -> str:
    return subprocess.check_output(
        ["gh", "pr", "create",
         "--base", base,
         "--head", head,
         "--title", title,
         "--body", body,
         "--assignee", "@me"],
        text=True,
    ).strip()


def create_gitlab(title: str, body: str, base: str, head: str) -> str:
    out = subprocess.check_output(
        ["glab", "mr", "create",
         "--target-branch", base,
         "--source-branch", head,
         "--title", title,
         "--description", body,
         "--assignee", "@me"],
        text=True,
    )
    for line in out.splitlines():
        line = line.strip()
        if line.startswith("http"):
            return line
    return out.strip()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--title", required=True)
    parser.add_argument("--body", required=True)
    parser.add_argument("--base", default=None,
                        help="target branch (default: upstream tracking or 'main')")
    args = parser.parse_args()

    head = current_branch()
    if not head:
        sys.exit("error: could not determine current branch (detached HEAD?)")

    base = args.base or detect_base()
    if base == head:
        sys.exit(f"error: head and base are both '{head}'; switch to a feature branch")

    platform = detect_platform()
    push(head)

    if platform == "github":
        print(create_github(args.title, args.body, base, head))
    else:
        print(create_gitlab(args.title, args.body, base, head))


if __name__ == "__main__":
    main()
