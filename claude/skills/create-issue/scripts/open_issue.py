#!/usr/bin/env python3
"""Create an issue on GitHub or GitLab, auto-detecting platform from git remote."""

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
    # Self-hosted fallback: whichever CLI recognizes the repo.
    if subprocess.run(["glab", "repo", "view"], capture_output=True).returncode == 0:
        return "gitlab"
    if subprocess.run(["gh", "repo", "view"], capture_output=True).returncode == 0:
        return "github"
    sys.exit(f"error: could not detect platform from remote: {url}")


def create_github(title: str, body: str) -> str:
    return subprocess.check_output(
        ["gh", "issue", "create",
         "--title", title,
         "--body", body,
         "--assignee", "@me"],
        text=True,
    ).strip()


def create_gitlab(title: str, body: str) -> str:
    out = subprocess.check_output(
        ["glab", "issue", "create",
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
    args = parser.parse_args()

    platform = detect_platform()
    if platform == "github":
        print(create_github(args.title, args.body))
    else:
        print(create_gitlab(args.title, args.body))


if __name__ == "__main__":
    main()
