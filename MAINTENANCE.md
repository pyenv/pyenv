Creating a release
==================

The release of the new version of Pyenv is done via GitHub Releases.

Release checklist:
* Start [drafting a new release on GitHub](https://github.com/pyenv/pyenv/releases) to generate a summary of changes.  
Type the would-be tag name in the "Choose a tag" field and press "Generate release notes"
  * The summary may need editing. E.g. rephrase entries, delete/merge entries that are too minor or irrelevant to the users (e.g. typo fixes, CI)
* Add a sponsors section to the release notes by running:
  ```bash
  .github/scripts/generate_release_notes_sponsors.py
  ```
  Paste the output at the end of the release notes.
  * This lists new GitHub Sponsors and OpenCollective backers since the last release or within the last month, whichever is longer.
  * The GitHub Sponsors query requires the `gh` CLI with the `read:user` scope.
  * If OpenCollective is unavailable, pass `--skip-opencollective` and add those backers manually.
* Update `CHANGELOG.md` with the new version number and the edited summary (only the changes section)
* Push the version number in `libexec/pyenv---version` and `plugins/python-build/bin/python-build`
  * Minor version is pushed if there are significant functional changes (not e.g. bugfixes/formula adaptations/supporting niche use cases).
  * Major version is pushed if there are breaking changes
* Commit the changes locally into `master`
* Create a new tag locally with the same name as specified in the new release window
* Push the changes including the tag
* In the still open new release window, press "Publish release". The now-existing tag will be used.
