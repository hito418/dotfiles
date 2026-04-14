#!/usr/bin/env python3
"""Resolve a review thread (GitHub) or discussion (GitLab) on the current PR/MR.

If --reply is given, posts the reply first, then marks the thread resolved.
"""

import argparse
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


def resolve_github(thread_id: str, reply: str | None) -> None:
    if reply:
        mutation = """
        mutation($id: ID!, $body: String!) {
          addPullRequestReviewThreadReply(
            input: {pullRequestReviewThreadId: $id, body: $body}
          ) { comment { id } }
        }
        """
        subprocess.check_call(
            ["gh", "api", "graphql",
             "-f", f"query={mutation}",
             "-f", f"id={thread_id}",
             "-f", f"body={reply}"],
            stdout=subprocess.DEVNULL,
        )
    mutation = """
    mutation($id: ID!) {
      resolveReviewThread(input: {threadId: $id}) { thread { id } }
    }
    """
    subprocess.check_call(
        ["gh", "api", "graphql",
         "-f", f"query={mutation}",
         "-f", f"id={thread_id}"],
        stdout=subprocess.DEVNULL,
    )


def resolve_gitlab(discussion_id: str, reply: str | None) -> None:
    mr = json.loads(subprocess.check_output(
        ["glab", "mr", "view", "--output", "json"], text=True,
    ))
    repo = json.loads(subprocess.check_output(
        ["glab", "repo", "view", "--output", "json"], text=True,
    ))
    project = quote(repo["full_path"], safe="")
    mr_iid = mr["iid"]
    base = f"projects/{project}/merge_requests/{mr_iid}/discussions/{discussion_id}"

    if reply:
        subprocess.check_call(
            ["glab", "api", "-X", "POST",
             "-f", f"body={reply}",
             f"{base}/notes"],
            stdout=subprocess.DEVNULL,
        )
    subprocess.check_call(
        ["glab", "api", "-X", "PUT",
         "-f", "resolved=true",
         base],
        stdout=subprocess.DEVNULL,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--id", required=True,
                        help="thread/discussion id from list_comments.py")
    parser.add_argument("--reply", default=None,
                        help="optional reply text posted before resolving")
    args = parser.parse_args()

    if detect_platform() == "github":
        resolve_github(args.id, args.reply)
    else:
        resolve_gitlab(args.id, args.reply)


if __name__ == "__main__":
    main()
