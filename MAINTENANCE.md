Creating a release
==================

The release of the new version of Pyenv is done via GitHub Releases.

Release checklist:
* Start [drafting a new release on GitHub](https://github.com/pyenv/pyenv/releases) to generate a summary of changes. Save the summary locally.
  * The summary may need editing. E.g. rephrase entries, delete/merge entries that are too minor or irrelevant to the users (e.g. typo fixes, CI)
* Push the version number in `libexec/pyenv---version`
  * Minor version is pushed if there are significant functional changes (not e.g. bugfixes/formula adaptations/supporting niche use cases).
  * Major version is pushed if there are breaking changes
* Update `CHANGELOG.md` with the new version number and the edited summary (only the changes section), reformatting it like the rest of the changelog sections
* Commit the changes locally into `master`
* Create a new tag with the new version number and push the changes including the tag
* Create a new release on GitHub based on the tag, using the saved summary