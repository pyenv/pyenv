#!/usr/bin/env python3
"""Generate a "Sponsors since <date>" section for release notes.

Queries GitHub Sponsors and OpenCollective for new sponsors since the latest
pyenv release or one month ago, whichever is longer. The output is Markdown
suitable for GitHub Releases.

Requirements:
* Python 3.8+
* The ``gh`` CLI authenticated with the ``read:user`` scope.
* Network access to https://opencollective.com.
"""

import argparse
import calendar
import datetime
import json
import subprocess
import sys
import typing
import urllib.error
import urllib.request


GITHUB_ORG = "pyenv"
OPENCOLLECTIVE_MEMBERS_URL = "https://opencollective.com/pyenv/members.json"


def parse_date(value: str) -> datetime.date:
    return datetime.datetime.fromisoformat(value).date()


def one_month_ago(today: typing.Optional[datetime.date] = None) -> datetime.date:
    today = today or datetime.date.today()
    year = today.year
    month = today.month - 1
    if month == 0:
        year -= 1
        month = 12
    try:
        return datetime.date(year, month, today.day)
    except ValueError:
        last_day = calendar.monthrange(year, month)[1]
        return datetime.date(year, month, last_day)


def latest_release_date() -> datetime.date:
    """Return the publish date of the latest GitHub release."""
    try:
        result = subprocess.run(
            ["gh", "api", f"repos/{GITHUB_ORG}/{GITHUB_ORG}/releases/latest"],
            capture_output=True,
            text=True,
            check=True,
        )
        data = json.loads(result.stdout)
        published = data["published_at"].replace("Z", "+00:00")
        return datetime.datetime.fromisoformat(published).date()
    except (subprocess.CalledProcessError, OSError):
        pass

    try:
        tag = subprocess.run(
            ["git", "describe", "--tags", "--abbrev=0"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        date_str = subprocess.run(
            ["git", "log", "-1", "--format=%cI", tag],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        return datetime.datetime.fromisoformat(date_str).date()
    except (subprocess.CalledProcessError, OSError) as exc:
        raise RuntimeError(
            "Could not determine the latest release date. "
            "Pass --since explicitly or run from a clone with release tags."
        ) from exc


def compute_since_date(explicit_since: typing.Optional[datetime.date]) -> datetime.date:
    if explicit_since is not None:
        return explicit_since
    return min(latest_release_date(), one_month_ago())


def github_sponsors(since: datetime.date) -> typing.List[typing.Dict]:
    """Return GitHub Sponsors created on or after *since*."""
    query = """
    query($org: String!, $after: String) {
      organization(login: $org) {
        sponsorshipsAsMaintainer(
          first: 100,
          after: $after,
          activeOnly: false,
          orderBy: {field: CREATED_AT, direction: DESC}
        ) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            createdAt
            sponsorEntity {
              ... on User { login, name }
              ... on Organization { login, name }
            }
          }
        }
      }
    }
    """
    since_dt = datetime.datetime.combine(
        since, datetime.time.min, tzinfo=datetime.timezone.utc
    )
    sponsors = []
    cursor = None
    while True:
        command = [
            "gh",
            "api",
            "graphql",
            "-F",
            f"org={GITHUB_ORG}",
            "-f",
            f"query={query}",
        ]
        if cursor is not None:
            command.extend(["-F", f"after={cursor}"])

        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"gh API call failed (exit {result.returncode}): {result.stderr.strip()}"
            )

        data = json.loads(result.stdout)
        if "errors" in data:
            raise RuntimeError(f"GitHub GraphQL error: {data['errors']}")

        sponsorships = data["data"]["organization"]["sponsorshipsAsMaintainer"]
        for node in sponsorships["nodes"]:
            created = datetime.datetime.fromisoformat(
                node["createdAt"].replace("Z", "+00:00")
            )
            if created < since_dt:
                return sponsors
            entity = node["sponsorEntity"]
            sponsors.append({
                "login": entity["login"],
                "name": entity.get("name") or entity["login"],
            })

        page_info = sponsorships["pageInfo"]
        if not page_info["hasNextPage"]:
            return sponsors
        cursor = page_info["endCursor"]


def opencollective_sponsors(since: datetime.date) -> typing.List[typing.Dict]:
    """Return OpenCollective backers created on or after *since*."""
    req = urllib.request.Request(
        f"{OPENCOLLECTIVE_MEMBERS_URL}?limit=1000",
        headers={"User-Agent": f"{GITHUB_ORG}/release-notes-sponsors"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        members = json.loads(resp.read())

    since_dt = datetime.datetime.combine(since, datetime.time.min)
    sponsors = []
    for member in members:
        if member.get("role") != "BACKER":
            continue
        created = datetime.datetime.strptime(member["createdAt"], "%Y-%m-%d %H:%M")
        if created < since_dt:
            continue
        profile = member["profile"].rstrip("/")
        slug = profile.split("/")[-1]
        if slug == "github-sponsors":
            # Listed separately under GitHub Sponsors.
            continue
        sponsors.append({
            "name": member.get("name") or slug,
            "profile": profile,
        })
    return sponsors


def render(
    since: datetime.date,
    gh_sponsors: typing.List[typing.Dict],
    oc_sponsors: typing.List[typing.Dict],
) -> str:
    lines = [f"## Sponsors since {since.isoformat()}", ""]

    if gh_sponsors:
        lines.append("### GitHub Sponsors")
        for sponsor in gh_sponsors:
            lines.append(
                markdown_link(
                    sponsor["name"],
                    f"https://github.com/{sponsor['login']}",
                )
            )
        lines.append("")

    if oc_sponsors:
        lines.append("### Open Collective")
        for sponsor in oc_sponsors:
            lines.append(markdown_link(sponsor["name"], sponsor["profile"]))
        lines.append("")

    if not gh_sponsors and not oc_sponsors:
        lines.append("*No new sponsors in this period.*")
        lines.append("")

    return "\n".join(lines)


def markdown_link(text: str, url: str) -> str:
    escaped_text = escape_markdown_text(text)
    escaped_url = url.replace(")", "%29")
    return f"- [{escaped_text}]({escaped_url})"


def escape_markdown_text(text: str) -> str:
    escaped = text.replace("\\", "\\\\")
    for char in r"`*_{}[]()#+-.!|>":
        escaped = escaped.replace(char, f"\\{char}")
    return escaped


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate a sponsors section for GitHub release notes."
    )
    parser.add_argument(
        "--since",
        type=parse_date,
        metavar="YYYY-MM-DD",
        help="Include sponsors created on or after this date.",
    )
    parser.add_argument(
        "--output",
        metavar="FILE",
        help="Write the section to FILE instead of stdout.",
    )
    args = parser.parse_args()

    try:
        since = compute_since_date(args.since)
        section = render(since, github_sponsors(since), opencollective_sponsors(since))
    except (RuntimeError, OSError, urllib.error.URLError, json.JSONDecodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(section)
    else:
        print(section, end="")

    return 0


if __name__ == "__main__":
    sys.exit(main())
