General guidance
================

* The usual principles of respecting existing conventions and making sure that your changes
  are in line with the overall product design apply when contributing code to Pyenv.

* We are limited to Bash 3.2 features

  That's because that's the version shipped with MacOS.
  (They didn't upgrade past it and switched to Zsh because later versions
  are covered by GPLv3 which has additional restrictions unacceptable for Apple.)

  You can still add performance optimizations etc that take advantage of newer Bash features
  as long as there is a fallback execution route for Bash 3.

* Be extra careful when submitting logic specific for the Apple Silicon platform

  As of this writing, Github Actions do not support it and only one team member has the necessary hardware.
  So we may be unable to test your changes and may have to take your word for it.


Formatting PRs
==============

We strive to keep commit history one-concern-per-commit to keep it meaningful and easy to follow.
If a pull request (PR) addresses a single concern (the typical case), we usually squash commits
from it together when merging so its commit history doesn't matter.
If however a PR addresses multiple separate concerns, each of them should be presented as a separate commit.
Adding multiple new Python releases of the same flavor is okay with either a single or multiple commits.


Authoring installation scripts
==============================

Adding new Python release support
---------------------------------

The easiest way to add support for a new Python release is to copy the script from the previous one
and adjust it as necessary. In many cases, just changing version numbers, URLs and hashes is enough.
Do pay attention to other "magic numbers" that may be present in a script --
e.g. the set of architectures and OS versions supported by a release -- since those change from time to time, too.

Make sure to also copy any patches for the previous release that still apply to the new one.
Typically, a patch no longer applies if it addresses a problem that's already fixed in the new release.

For prereleases, we only create an entry for the latest prerelease in a specific version line.
When submitting a newer prerelease, replace the older one.


Adding version-specific fixes/patches
-------------------------------------

We accept fixes to issues in specific Python releases that prevent users from using them with Pyenv.

In the default configuration for a Python release, we strive to provide as close to vanilla experience as practical,
to maintain [the principle of the least surprise](https://en.wikipedia.org/wiki/Principle_of_least_astonishment).
As such, any such fixes:

* Must not break or degrade (e.g. disable features) the build in any of the environments that the release officially supports
* Must not introduce incompatibilities with the vanilla release (including binary incompatibilities)
* Should not patch things unnecessarily, to minimize the risk of the aforementioned undesirable side effects.
  * E.g. if the fix is for a specific environment, its logic ought to only fire in this specific environment and not touch execution paths for other environments.
  * As such, it's advisable to briefly explain in the PR what each added patch does and why it is necessary to fix the declared problem

Generally, version-specific fixes belong in the scripts for the affected releases and/or patches for them -- this guarantees that their effect is limited to only those releases.

<h3>Backporting upstream patches</h3>

Usually, this is the easiest way to backport a fix for a problem that is fixed in a newer release.

* Clone Python, check out the tag for the appropriate release and create a branch
* Apply existing patches if there are any (with either `patch` or `git am`) and commit
* Cherry-pick the upstream commit that fixes the problem in a newer release
* Commit and `git format-patch`
* Commit the generated patch file into Pyenv, test your changes and submit a PR


Deprecation policy
------------------

We do not provide official support for EOL releases and environments or otherwise provide any kind of extended support for old Python releases.

We do however accept fixes from interested parties that would allow running older, including EOL, releases in environments that they do not officially support.
In addition to the above requirements for release-specific fixes,

* Such a fix must not add maintenance burden (e.g. add new logic to `python-build` that has to be kept there indefinitely)
  * Unless the added logic is useful for both EOL and non-EOL releases. In this case, it will be considered as being primarily an improvement for non-EOL releases.
* Support is provided on a "best effort" basis: we do not actively maintain these fixes but won't actively break them, either, and will accept any corrections.
  Since old releases never change, it's pretty safe to assume that the fixes will continue to work until a later version
  of an environment introduces further incompatible changes.


Advanced changes / adding new Python flavor support
---------------------------------------------------

An installation script is sourced from `python-build`. All installation scripts are based on the same logic:

1. Select the source to download and other variable parameters as needed.

   This includes showing an error if the user's environment (OS, architecture) is not supported by the release.
   Binary releases that only officially support specific distro(s) typically show a warning in other distros instead.

2. Run one of the `install_*` shell functions

`install_*` shell functions defined in `python-build` install Python from different kinds of sources -- compressed package (binary or source), upstream installation script, VCS checkout. Pick one that's the most appropriate for your packaging.

Each of them accepts a couple of function-specific arguments which are followed by arguments that constitute the build sequence. Each `<argument>` in the build sequence corresponds to the `install_*_<argument>` function in `python-build`. Check what's available and add any functions with logic specific to your flavor if needed.

We strive to keep out of `python-build` parts of build logic that are release-specific and/or tend to change abruptly between releases -- e.g. sets of supported architectures and other software's versions. This results in logic duplication between installation scripts -- but since old releases never change once released, this doesn't really add to the maintenance burden. As a rule of thumb, `python-build` can host parts of logic that are expected to stay the same for an indefinite amount of time -- for an entire Python flavor or release line.
