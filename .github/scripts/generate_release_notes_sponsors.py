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
import pathlib
import subprocess
import sys
import typing
import urllib.error
import urllib.request


GITHUB_ORG = "pyenv"
OPENCOLLECTIVE_MEMBERS_URL = "https://opencollective.com/pyenv/members.json"


class SponsorDataError(RuntimeError):
    """Raised when a sponsors data source cannot be queried or parsed."""


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
    latest_release_error = None
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
    except (
        subprocess.CalledProcessError,
        OSError,
        json.JSONDecodeError,
        KeyError,
    ) as exc:
        latest_release_error = exc

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
        detail = ""
        if latest_release_error is not None:
            detail = f" GitHub release lookup failed first: {latest_release_error}."
        raise SponsorDataError(
            "Could not determine the latest release date. "
            "Pass --since explicitly or run from a clone with release tags."
            f"{detail}"
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
            detail = result.stderr.strip() or result.stdout.strip() or "no output"
            raise SponsorDataError(
                "GitHub Sponsors query failed. "
                "Check that `gh auth status` shows access to the pyenv org "
                "and that the token has the scopes required to read sponsorships. "
                f"`gh api graphql` exited {result.returncode}: {detail}"
            )

        try:
            data = json.loads(result.stdout)
        except json.JSONDecodeError as exc:
            raise SponsorDataError(
                "GitHub Sponsors query returned invalid JSON."
            ) from exc

        if "errors" in data:
            raise SponsorDataError(
                f"GitHub Sponsors query returned errors: {data['errors']}"
            )

        try:
            sponsorships = data["data"]["organization"]["sponsorshipsAsMaintainer"]
        except (TypeError, KeyError) as exc:
            raise SponsorDataError(
                "GitHub Sponsors query returned an unexpected response shape."
            ) from exc
        try:
            nodes = sponsorships["nodes"]
            page_info = sponsorships["pageInfo"]
        except (TypeError, KeyError) as exc:
            raise SponsorDataError(
                "GitHub Sponsors query returned incomplete pagination data."
            ) from exc

        for node in nodes:
            try:
                created = datetime.datetime.fromisoformat(
                    node["createdAt"].replace("Z", "+00:00")
                )
                entity = node["sponsorEntity"]
                login = entity["login"]
            except (AttributeError, KeyError, TypeError, ValueError) as exc:
                raise SponsorDataError(
                    "GitHub Sponsors query returned an unexpected sponsor record."
                ) from exc
            if created < since_dt:
                return sponsors
            sponsors.append({
                "login": login,
                "name": entity.get("name") or login,
            })

        try:
            has_next_page = page_info["hasNextPage"]
            cursor = page_info["endCursor"]
        except (TypeError, KeyError) as exc:
            raise SponsorDataError(
                "GitHub Sponsors query returned incomplete pagination data."
            ) from exc
        if not has_next_page:
            return sponsors


def opencollective_sponsors(since: datetime.date, data: typing.Union[str, None]) -> typing.List[typing.Dict]:
    """Return OpenCollective backers active on or after *since*."""
    if data is None:
        req = urllib.request.Request(
            f"{OPENCOLLECTIVE_MEMBERS_URL}?limit=1000",
            headers={"User-Agent": f"{GITHUB_ORG}/release-notes-sponsors"},
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = resp.read()
        except urllib.error.HTTPError as exc:
            raise SponsorDataError(
                f"OpenCollective sponsors query failed for {OPENCOLLECTIVE_MEMBERS_URL}: "
                f"HTTP {exc.code} {exc.reason}"
            ) from exc
        except urllib.error.URLError as exc:
            raise SponsorDataError(
                f"OpenCollective sponsors query failed for {OPENCOLLECTIVE_MEMBERS_URL}: "
                f"{exc.reason}"
            ) from exc
    try:
        members = json.loads(data)
    except json.JSONDecodeError as exc:
        raise SponsorDataError(
            "OpenCollective sponsors query returned invalid JSON."
        ) from exc

    since_dt = datetime.datetime.combine(since, datetime.time.min)
    sponsors = []
    for member in members:
        if member.get("role") != "BACKER":
            continue
        try:
            last_transaction_at = datetime.datetime.strptime(member["lastTransactionAt"], "%Y-%m-%d %H:%M")
            profile = member["profile"].rstrip("/")
        except (KeyError, TypeError, ValueError) as exc:
            raise SponsorDataError(
                "OpenCollective sponsors query returned an unexpected member record."
            ) from exc
        if last_transaction_at < since_dt:
            continue
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
    parser.add_argument(
        "--skip-opencollective",
        action="store_true",
        help="Skip OpenCollective backers if the members endpoint is unavailable.",
    )
    parser.add_argument(
        "--opencollective-data",
        metavar="FILE",
        help="Take OpenCollective API reply from FILE.",
    )
    args = parser.parse_args()

    try:
        since = compute_since_date(args.since)
        oc_sponsors = []
        if not args.skip_opencollective:
            manual_data = (
                pathlib.Path(args.opencollective_data).read_text()) \
                if args.opencollective_data \
                else None
            oc_sponsors = opencollective_sponsors(since, manual_data)
        section = render(since, github_sponsors(since), oc_sponsors)
    except SponsorDataError as exc:
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
