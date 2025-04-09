# Version History

## Release v2.5.5
* Add graalpy 24.2 by @msimacek in https://github.com/pyenv/pyenv/pull/3215
* Switch 3.9+ to OpenSSL 3 by @native-api in https://github.com/pyenv/pyenv/pull/3223
* Add miniforge3-24.11.3-1, miniforge3-24.11.3-2, miniforge3-25.1.1 by @native-api in https://github.com/pyenv/pyenv/pull/3224
* Add CPython 3.9.22, 3.10.17, 3.11.12, 3.12.10, 3.13.3, 3.14.0a7 by @native-api in https://github.com/pyenv/pyenv/pull/3233

## Release v2.5.4
* Add anaconda3-2025.1.1-2 by @binbjz in https://github.com/pyenv/pyenv/pull/3198
* Add PyPy v7.3.19 by @jsirois in https://github.com/pyenv/pyenv/pull/3205
* Add CPython 3.14.0a6 by @nedbat in https://github.com/pyenv/pyenv/pull/3213

## Release v2.5.3
* Add PyPy v7.3.18 by @dand-oss in https://github.com/pyenv/pyenv/pull/3184
* Add Miniconda3 25.1.1-0 by @binbjz in https://github.com/pyenv/pyenv/pull/3190
* Add miniforge3-25.1.1-0, miniforge3-24.11.3-0 by @native-api in https://github.com/pyenv/pyenv/pull/3191
* Add CPython 3.14.0a5 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3194
* Add Miniconda3 25.1.1-1 by @binbjz in https://github.com/pyenv/pyenv/pull/3192
* Update hashes for Python 3.14.0a5 tarballs by @jsirois in https://github.com/pyenv/pyenv/pull/3196
* rehash: Do not execute conda-specific code if conda is not installed by @ChristianFredrikJohnsen in https://github.com/pyenv/pyenv/pull/3151

## Release v2.5.2
* Fix OpenSSL version parsing in python-build script by @threadflow in https://github.com/pyenv/pyenv/pull/3181
* Add GraalPy 24.1.2 by @msimacek in https://github.com/pyenv/pyenv/pull/3176
* Add CPython 3.12.9 and 3.13.2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3183

## Release v2.5.1
* CI: use Ubuntu 24.04; use ubuntu-latest for the ubuntu_build check by @native-api in https://github.com/pyenv/pyenv/pull/3144
* Fix: mistake in configuration hints in `pyenv init` and manpage by @ChristianFredrikJohnsen in https://github.com/pyenv/pyenv/pull/3145
* README: Add recommended curl arguments to suggested installer invocation by @JayBazuzi in https://github.com/pyenv/pyenv/pull/3155
* Add miniforge3-24.11.2-0, miniforge3-24.11.2-1 by @native-api in https://github.com/pyenv/pyenv/pull/3163
* Fix "Unsupported options" error building bundled OpenSSL <3.2.0 by @native-api in https://github.com/pyenv/pyenv/pull/3164
* Add CPython 3.14.0a4 by @nedbat in https://github.com/pyenv/pyenv/pull/3168

## Release v2.5.0
* `pyenv init -` performance improvements; recommend using `pyenv init - <shell>` by @ChristianFredrikJohnsen in https://github.com/pyenv/pyenv/pull/3136
* Add miniconda3-24.11.1-0 by @binbjz in https://github.com/pyenv/pyenv/pull/3138
* Add miniconda3-24.3.0-0 by @native-api in https://github.com/pyenv/pyenv/pull/3139
* CI: only run macos_build_bundled_dependencies and ubuntu_build_tar_gz for CPython by @native-api in https://github.com/pyenv/pyenv/pull/3141
* Add miniforge3 and mambaforge3 24.1.2-0, 24.3.0-0, 24.5.0-0, 24.7.1-0, 24.7.1-1, 24.7.1-2, 24.9.0-0, 24.9.2-0, 24.11.0-0, 24.11.0-1 by @native-api in https://github.com/pyenv/pyenv/pull/3142
* Skip broken miniforge3/mambaforge3 22.11.0-0, 22.11.0-1, 22.11.0-2 in the generation script by @native-api in https://github.com/pyenv/pyenv/pull/3143

## Release v2.4.23
* README: explain using multiple versions by @Finkregh in https://github.com/pyenv/pyenv/pull/3126
* Support PACKAGE_CPPFLAGS and PACKAGE_LDFLAGS by @native-api in https://github.com/pyenv/pyenv/pull/3130
* Adjust suggested shell startup code to support Pyenv with Pyenv-Win in WSL by @native-api in https://github.com/pyenv/pyenv/pull/3132
* Support nonexistent versions being present and set in a local .python-version by @native-api in https://github.com/pyenv/pyenv/pull/3134
* Add CPython 3.14.0a3 by @nedbat in https://github.com/pyenv/pyenv/pull/3135

## Release v2.4.22
* Speed up building bundled OpenSSL by @native-api in https://github.com/pyenv/pyenv/pull/3124
* CI: add building modified scripts with bundled MacOS dependencies by @native-api in https://github.com/pyenv/pyenv/pull/3123
* CL: + test modified scripts with tar.gz source by @native-api in https://github.com/pyenv/pyenv/pull/3125
* Fix 404 for openssl-3.4.0 release in build 3.13.1 by @dlamblin in https://github.com/pyenv/pyenv/pull/3122

## Release v2.4.21
* Add CPython 3.13.1t by @makukha in https://github.com/pyenv/pyenv/pull/3120
* Prefer tcl-tk@8 from Homebrew due to release of Tcl/Tk 9 with which only 3.12+ are compatible by @native-api in https://github.com/pyenv/pyenv/pull/3118

## Release v2.4.20
* README: Fix Markdown in "Notes about python releases" by @noelleleigh in https://github.com/pyenv/pyenv/pull/3112
* README: correct link to shell setup instructions by @shortcuts in https://github.com/pyenv/pyenv/pull/3113
* Add CPython 3.9.21, 3.10.16, 3.11.11, 3.12.8 and 3.13.1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3117

## Release v2.4.19
* Add CPython 3.14.0a2 by @nedbat in https://github.com/pyenv/pyenv/pull/3110
* Add quick start section and gif demo to accompany it. by @madhu-GG in https://github.com/pyenv/pyenv/pull/3044

## Release v2.4.18
* Add miniforge3-24.9.2-0 by @goerz in https://github.com/pyenv/pyenv/pull/3106

## Release v2.4.17
* Add miniconda3-24.9.2-0 by @binbjz in https://github.com/pyenv/pyenv/pull/3096
* Add Anaconda3-2024.10-1 by @binbjz in https://github.com/pyenv/pyenv/pull/3097

## Release v2.4.16
* Add GraalPy 24.1.1 by @msimacek in https://github.com/pyenv/pyenv/pull/3092
* Add CPython 3.14.0a1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3093

## Release v2.4.15
* CI: replace set-output with GITHUB_OUTPUT by @tuzi3040 in https://github.com/pyenv/pyenv/pull/3079
* Make uninstall yes/no prompt consistent with others by @dpoznik in https://github.com/pyenv/pyenv/pull/3080
* Add CPython 3.13.0 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3081
* Avoid shadowing of virtualenvs with the name starting with "python-" by @aarbouin in https://github.com/pyenv/pyenv/pull/3086
* Support free-threaded CPython flavor in prefix resolution by @native-api in https://github.com/pyenv/pyenv/pull/3090

## Release v2.4.14
* Add CPython 3.12.7 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3078
* Add CPython 3.13.0rc3 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3077

## Release v2.4.13
* docs: Use `--verbose` with performance CPython build instructions by @caerulescens in https://github.com/pyenv/pyenv/pull/3053
* Fix latest version resolution when using `python-` prefix by @edmorley in https://github.com/pyenv/pyenv/pull/3056
* Fix tgz checksum for 3.9.20; fallback OpenSSL URLs and checksums by @native-api in https://github.com/pyenv/pyenv/pull/3060
* Fix OpenSSL 3.3.2 download URLs by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3059
* Add GraalPy 24.1.0 by @msimacek in https://github.com/pyenv/pyenv/pull/3066

## Release v2.4.12
* Add CPython 3.13.0rc2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3049
* Add CPython 3.8.20, 3.9.20, 3.10.15, 3.11.10 and 3.12.6 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3050

## Release v2.4.11
* Add /usr/etc/pyenv.d to hooks path by @tomschr in https://github.com/pyenv/pyenv/pull/3039
* Add miniconda3-24.7.1-0 by @binbjz in https://github.com/pyenv/pyenv/pull/3040
* Add PyPy v7.3.17 by @jsirois in https://github.com/pyenv/pyenv/pull/3045

## Release v2.4.10
* Add CPython 3.12.5 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3030

## Release v2.4.9
* Add miniforge3-24.3.0-0 by @goerz in https://github.com/pyenv/pyenv/pull/3028
* Add CPython 3.13.0rc1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3029

## Release v2.4.8
* Fix pyenv-uninstall not having the debug tracing invocation by @native-api in https://github.com/pyenv/pyenv/pull/3020
* Add CPython 3.13.0b4 and 3.13.0b4t by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/3019
* README: Remove reference to Fig by @ThomasHaz in https://github.com/pyenv/pyenv/pull/3018
* Fix tests failing if plugins are installed by @native-api in https://github.com/pyenv/pyenv/pull/3022
* pyenv-latest: replace -q with -b and -f, document as internal by @native-api in https://github.com/pyenv/pyenv/pull/3021

## Release v2.4.7
* Add support for anaconda3-2024.06-1 by @binbjz in https://github.com/pyenv/pyenv/pull/3009
* Fix debug build for X.Yt-dev by @native-api in https://github.com/pyenv/pyenv/pull/

## Release v2.4.6
* CI: push MacOS jobs to MacOS 13 and 14 by @native-api in https://github.com/pyenv/pyenv/pull/3002
* Add 3.13.0b3t and exclude it from `pyenv latest` by @colesbury in https://github.com/pyenv/pyenv/pull/3001
* Speed up `pyenv prefix` by not constructing advice text when it would be discarded by @Erotemic in https://github.com/pyenv/pyenv/pull/3005

## Release v2.4.5
* Add CPython 3.13.0b3 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2996

## Release v2.4.4
* Add support for miniconda3 24.5.0-0 with py3.12, py3.11, py3.10, py3.9 by @binbjz in https://github.com/pyenv/pyenv/pull/2994
* Add support for free-threaded Python by @colesbury in https://github.com/pyenv/pyenv/pull/2995

## Release v2.4.3
* Add miniconda3 24.4.0-0 by @binbjz in https://github.com/pyenv/pyenv/pull/2982

## Release v2.4.2
* Add script to install graalpy development builds by @timfel in https://github.com/pyenv/pyenv/pull/2969
* Correct the Explanation of PATH Variable Lookup by @Y-askour in https://github.com/pyenv/pyenv/pull/2975
* Document PYTHON_BUILD_CURL_OPTS, PYTHON_BUILD_WGET_OPTS, PYTHON_BUILD_ARIA2_OPTS by @native-api in https://github.com/pyenv/pyenv/pull/2976
* Add sed and greadlink to shim exceptions by @native-api in https://github.com/pyenv/pyenv/pull/2977
* Add CPython 3.13.0b2 by @jsirois in https://github.com/pyenv/pyenv/pull/2978
* Add CPython 3.12.4 by @xxzgc in https://github.com/pyenv/pyenv/pull/2981

## Release v2.4.1
* Add CPython 3.12.3 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2941
* Add CPython 3.13.0a6 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2942
* Add PyPy v7.3.16 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2948
* Add CPython 3.14-dev, update 3.13-dev by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2960
* Add CPython 3.13.0b1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2959

## Release v2.4.0
* Add CPython 3.13.0a4 by @saaketp in https://github.com/pyenv/pyenv/pull/2903
* Handle the case where `pyenv-commands --sh` returns nothing by @aphedges in https://github.com/pyenv/pyenv/pull/2908
* Document default build configuration customizations by @native-api in https://github.com/pyenv/pyenv/pull/2911
* Use Homebrew in Linux if Pyenv is installled with Homebrew by @native-api in https://github.com/pyenv/pyenv/pull/2906
* Add miniforge and mambaforge 22.11.1-3, 22.11.1-4, 23.1.0-0 to 23.11.0-0 by @aphedges in https://github.com/pyenv/pyenv/pull/2909
* Add miniconda3-24.1.2 by @binbjz in https://github.com/pyenv/pyenv/pull/2915
* Minor grammar fix in libffi backport patch in 2.5.x by @cuinix in https://github.com/pyenv/pyenv/pull/2922
* Add CPython 3.13.0a5 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2924
* Add CPython 3.8.19 and 3.9.19 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2929
* Add GraalPy 24.0.0 by @msimacek in https://github.com/pyenv/pyenv/pull/2928
* Add CPython 3.10.14 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2930
* Add Jython 2.7.3 by @cesarcoatl in https://github.com/pyenv/pyenv/pull/2936
* Add CPython 3.11.9 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2938
* Add anaconda 2024.02 by @native-api in https://github.com/pyenv/pyenv/pull/2939

## Release v2.3.36
* Add a Dependabot config to auto-update GitHub action versions by @kurtmckee in https://github.com/pyenv/pyenv/pull/2863
* Bump the github-actions group with 1 update by @dependabot in https://github.com/pyenv/pyenv/pull/2864
* Add installation prefix to `python-config --ldflags` output by @mhaeuser in https://github.com/pyenv/pyenv/pull/2865
* Add support for miniconda3 23.11.0-1, 23.11.0-2 with py3.11, py3.10, py3.9, py3.8 by @binbjz in https://github.com/pyenv/pyenv/pull/2870
* Add micropython 1.20.0 and 1.21.0 by @cpzt in https://github.com/pyenv/pyenv/pull/2869
* Make "Automatic installer" command in the README a copy-able code block by @ryan-williams in https://github.com/pyenv/pyenv/pull/2874
* Add PyPy 7.3.14 by @dand-oss in https://github.com/pyenv/pyenv/pull/2876
* Add graalpy-23.1.2 by @msimacek in https://github.com/pyenv/pyenv/pull/2884
* Add CPython 3.13.0a3 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2885
* Add PyPy v7.3.15 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2886
* Update pypy3.9-7.3.13 checksums by @ecerulm in https://github.com/pyenv/pyenv/pull/2887
* Add CPython 3.12.2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2899
* Add CPython 3.11.8 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2898

## Release v2.3.35
* Add CPython 3.12.1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2861

## Release v2.3.34
* Fix graalpy-community to use a separate package name by @native-api in https://github.com/pyenv/pyenv/pull/2855
* Move 3.11.5+ to OpenSSL 3 by default by @native-api in https://github.com/pyenv/pyenv/pull/2858
* Add CPython 3.11.7 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2860

## Release v2.3.33
* Add miniforge3-23.3.1-1 by @goerz in https://github.com/pyenv/pyenv/pull/2839
* Add support for miniconda3-3.11-23.10.0-1 by @binbjz in https://github.com/pyenv/pyenv/pull/2843
* Add support for miniconda3 23.10.0-1 with py3.10、py3.9、py3.8 by @binbjz in https://github.com/pyenv/pyenv/pull/2844
* Add CPython 3.13.0a2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2849
* python-build: Document PYTHON_BUILD_HOMEBREW_OPENSSL_FORMULA and PYTHON_BUILD_HTTP_CLIENT by @native-api in https://github.com/pyenv/pyenv/pull/2853

## Release v2.3.32
* Describe --no-rehash option in the manpage by @fsc-eriker in https://github.com/pyenv/pyenv/pull/2832
* Make adding $PYENV_ROOT/bin to PATH independent of other software by @native-api in https://github.com/pyenv/pyenv/pull/2837
* Make `pyenv init` output insertable to startup files by @native-api in https://github.com/pyenv/pyenv/pull/2838

## Release v2.3.31
* Add new anaconda and miniconda definitions by @aphedges in https://github.com/pyenv/pyenv/pull/2824

## Release v2.3.30

* Fix intermittent "broken pipe" in tests by @native-api in https://github.com/pyenv/pyenv/pull/2817
* Add CPython 3.13.0a1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2818
* Add PyPy 7.3.13 by @dand-oss in https://github.com/pyenv/pyenv/pull/2807
* Fix linking against Homebrew's Tcl/Tk 8.6.13 in MacOS by @startergo in https://github.com/pyenv/pyenv/pull/2820

## Release v2.3.29

* Add CPython 3.11.6 by @thecesrom in https://github.com/pyenv/pyenv/pull/2806
* Add GraalPy 23.1.0 definition using the faster Oracle GraalVM distribution by @eregon in https://github.com/pyenv/pyenv/pull/2812
* Install ncurses from Homebrew, if available by @aphedges in https://github.com/pyenv/pyenv/pull/2813

## Release v2.3.28

* Prioritize 'zlib from xcode sdk' flag correctly by @native-api in https://github.com/pyenv/pyenv/pull/2791
* Prefer OpenSSL 3 in Homebrew in 3.13-dev by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2793
* Add CPython 3.12.0rc3 by @saaketp in https://github.com/pyenv/pyenv/pull/2795
* Add graalpy-23.1.0 and split between graalpy and graalpy-community by @msimacek in https://github.com/pyenv/pyenv/pull/2796
* Update the OpenSSL dependency for Python 2.7.18 by @lpapp-foundry in https://github.com/pyenv/pyenv/pull/2797
* Add CPython 3.12.0 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2804

## Release v2.3.27

* Prefer OpenSSL 3 in Homebrew since 3.12 by @native-api in https://github.com/pyenv/pyenv/pull/2781
* Fix get-pip urls for older pypy versions by @TimPansino in https://github.com/pyenv/pyenv/pull/2788
* Update openssl url for 3.12.0rc2 by @zsol in https://github.com/pyenv/pyenv/pull/2789
  
## Release v2.3.26

* Prevent `grep` warning in `conda.bash` by @aphedges in https://github.com/pyenv/pyenv/pull/2768
* fix a typo in README.md by @xzmeng in https://github.com/pyenv/pyenv/pull/2769
* use -I with ensurepip by @xaocon in https://github.com/pyenv/pyenv/pull/2764
* Add CPython 3.12.0rc2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2778

## Release v2.3.25

* Add CPython 3.8.18, 3.9.18, 3.10.13, 3.11.5 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2763
 
## Release v2.3.24

* README update: Added UNIX reference near Automatic installer by @VictorieeMan in https://github.com/pyenv/pyenv/pull/2744
* Fix FreeBSD tests in MacOS CI by @native-api in https://github.com/pyenv/pyenv/pull/2748
* Add CPython 3.12.0rc1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2752
* [Add an updated Anaconda and Miniconda installers](https://github.com/pyenv/pyenv/commit/db871427c7a232e18ee7a6dc0182989a646ccca9)

## Release v2.3.23

* Add CPython 3.12.0b4 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2741
* Add new anaconda and miniconda definitions by @aphedges in https://github.com/pyenv/pyenv/pull/2742

## Release v2.3.22

* Add CPython 3.12.0b3 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2730
* Add Cinder 3.10 and Cinder configure patches by @filips123 in https://github.com/pyenv/pyenv/pull/2739

## Release v2.3.21

* Add graalpy-23.0.0 by @msimacek in https://github.com/pyenv/pyenv/pull/2724
* Add PyPy 7.3.12 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2726
* Fix occasional 'libexec/pyenv-latest: line 39: printf: write error: Broken pipe' by @native-api in https://github.com/pyenv/pyenv/pull/2729

## Release v2.3.20

* Backport bpo-42351 to 3.5.10 by @native-api in https://github.com/pyenv/pyenv/pull/2717
* Add missing patches for Python 3.7/3.8/3.9 by @tomkins in https://github.com/pyenv/pyenv/pull/2718

## Release v2.3.19

* Add CPython 3.7.17, 3.8.17 and 3.9.17 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2711
* Add CPython 3.11.4 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2715
* Add CPython 3.10.12 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2714
* Add CPython 3.12.0b2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2713

## Release 2.3.18

* Fix not showing symlink contents for unselected versions in `pyenv versions` by @native-api in https://github.com/pyenv/pyenv/pull/2675
* Correct link in has_tar_xz_support else branch of 3.10.11 and 3.11.3 by @mirekdlugosz in https://github.com/pyenv/pyenv/pull/2677
* Fix #2682: Correct pyenv_user_setup.bash file by @tomschr in https://github.com/pyenv/pyenv/pull/2687
* fix: updating heredoc delimiter to be random and unique by @aviadhahami in https://github.com/pyenv/pyenv/pull/2691
* Support ksh alternative names by @kpschoedel in https://github.com/pyenv/pyenv/pull/2697
* Add CPython 3.12.0b1 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2701
* Update 3.12-dev and add 3.13-dev by @t0b3 in https://github.com/pyenv/pyenv/pull/2703

## Release 2.3.17

* Try locate `readlink` first in pyenv-hooks, fix #2654 by @Harry-Chen in https://github.com/pyenv/pyenv/pull/2655
* Add CPython 3.12.0a7 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2668
* Add CPython 3.11.3 by @mirekdlugosz in https://github.com/pyenv/pyenv/pull/2671
* Add CPython 3.10.11 by @mirekdlugosz in https://github.com/pyenv/pyenv/pull/2670

## Release 2.3.16

* Add Miniforge3-22.11.1-4 by @jlec in https://github.com/pyenv/pyenv/pull/2642
* Add Anaconda3-2023.03 by @anton-petrov in https://github.com/pyenv/pyenv/pull/2648

## Release 2.3.15

* Add miniconda 23.1.0-1 by @aphedges in https://github.com/pyenv/pyenv/pull/2635
* Add CPython 3.12.0a6 by @saaketp in https://github.com/pyenv/pyenv/pull/2638

## Release 2.3.14

* Fix indentation by @rafrafek in https://github.com/pyenv/pyenv/pull/2620
* Support for "BusyBox version" of "head" by @schuellerf in https://github.com/pyenv/pyenv/pull/2629
* bpo-27987 for v3.5.10 and v3.6.15: align by 16bytes on 64bit platforms by @chaimleib in https://github.com/pyenv/pyenv/pull/2630
* bpo-36231 for v3.5.10: fix Unsupported MacOS X CPU type in ffi.h by @chaimleib in https://github.com/pyenv/pyenv/pull/2633
* README: clarify behavior of `pyenv latest` by @mrienstra in https://github.com/pyenv/pyenv/pull/2634

## Release 2.3.13

* Fix pyenv-latest to ignore virtualenvs by @native-api in https://github.com/pyenv/pyenv/pull/2608
* Show symlink contents in non-bare `pyenv versions' by @native-api in https://github.com/pyenv/pyenv/pull/2609
* Ignore virtualenvs in `pyenv latest' in a clean way by @native-api in https://github.com/pyenv/pyenv/pull/2610
* Fix link resolving in pyenv-versions by @laggardkernel in https://github.com/pyenv/pyenv/pull/2612
* Add CPython 3.11.2 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2615
* Add CPython 3.10.10 by @edgarrmondragon in https://github.com/pyenv/pyenv/pull/2616
* Add CPython 3.12.0a5 by @Afront in https://github.com/pyenv/pyenv/pull/2614

## Release 2.3.12

* Undefined name: do not forget self when accessing flavor by @cclauss in https://github.com/pyenv/pyenv/pull/2595
* Fix wrong libpython being linked to in MacOS by @native-api in https://github.com/pyenv/pyenv/pull/2596
* Fix `:latest` by @native-api in https://github.com/pyenv/pyenv/pull/2599
* Fix `pyenv which` to support auto-resolved prefixes by @native-api in https://github.com/pyenv/pyenv/pull/2601
* Add more recent build of nogil Python. by @colesbury in https://github.com/pyenv/pyenv/pull/2602

## Release 2.3.11

* Add CPython 3.12.0a4 by @Afront in https://github.com/pyenv/pyenv/pull/2590
* Add a script to add the latest miniforge and mambaforge versions by @smcgivern in https://github.com/pyenv/pyenv/pull/2560
* Add missing Miniforge/Mambaforge versions (4.10.2-0 - 22.9.0-3) by @smcgivern in https://github.com/pyenv/pyenv/pull/2591
* Fix using dependencies from Ports in FreeBSD that are not searched with pkg-config by @native-api in https://github.com/pyenv/pyenv/pull/2593
* Fix priority for user-supplied configure and make flags by (**_only set --enable-shared if user hasn't supplied --disable-shared_**) @native-api in https://github.com/pyenv/pyenv/pull/2592
* Fix a compilation error in 3.8.10+ and 3.9.5+ when linking against Op… by @native-api in https://github.com/pyenv/pyenv/pull/2594

## Release 2.3.10

* Remove stray newline after python-build installation by @tklauser in https://github.com/pyenv/pyenv/pull/2566
* Allow multiple versions for pyenv-install by @rockandska in https://github.com/pyenv/pyenv/pull/2568
* --enable-shared by default by @anton-petrov in https://github.com/pyenv/pyenv/pull/2554
* Fix non-bash output while detecting shell by @ianchen-tw in https://github.com/pyenv/pyenv/pull/2561
* add pypy 7.3.11 release by @dand-oss in https://github.com/pyenv/pyenv/pull/2576
* Mention how to build for maximum performance by @hauntsaninja in https://github.com/pyenv/pyenv/pull/2579
* Add miniconda 22.11.1-1 by @aphedges in https://github.com/pyenv/pyenv/pull/2583
* Add Fig as autocomplete suggestion  by @brendanfalk in https://github.com/pyenv/pyenv/pull/2574
* Fix using dependencies from Ports in BSD with no pkg-config by @native-api in https://github.com/pyenv/pyenv/pull/2586

## Release 2.3.9

* Add -latest suffix to miniforge3 by @nwh in https://github.com/pyenv/pyenv/pull/2551
* Add PyPy 7.3.10 by @dand-oss in https://github.com/pyenv/pyenv/pull/2553
* Add miniforge3 and mambaforge 22.9.0-2 by @smcgivern in https://github.com/pyenv/pyenv/pull/2559
* Fix compilation error when building OpenSSL 1.1.1q in MacOS 11+ for 3.9.16 by @lisbethw1130 in https://github.com/pyenv/pyenv/pull/2558
* Add `openssl` patches for 3.7.15, 3.7.16, and 3.8.16 by @samdoran in https://github.com/pyenv/pyenv/pull/2564
* Add support for Anaconda3-2022.10 by @huypn12 in https://github.com/pyenv/pyenv/pull/2565

## Release 2.3.8

* Export detected shell environment in pyenv-init by @ianchen-tw in https://github.com/pyenv/pyenv/pull/2540
* Add CPython 3.12.0a3 by @saaketp in https://github.com/pyenv/pyenv/pull/2545
* Add CPython 3.11.1 by @anton-petrov in https://github.com/pyenv/pyenv/pull/2549
* Add CPython 3.10.9 by @rudisimo in https://github.com/pyenv/pyenv/pull/2544
* Add 3.7.16, 3.8.16, 3.9.16 by @chadac in https://github.com/pyenv/pyenv/pull/2550

## Release 2.3.7

* Add Python version 3.11 to the macOS build by @jbkkd in https://github.com/pyenv/pyenv/pull/2510
* Don't use Zlib from XCode SDK if a custom compiler is used by @native-api in https://github.com/pyenv/pyenv/pull/2516
* Change line endings from CRLF to LF by @hoang-himself in https://github.com/pyenv/pyenv/pull/2517
* Fix resolution of a name that's a prefix of another name by @native-api in https://github.com/pyenv/pyenv/pull/2521
* GitHub Workflows security hardening by @sashashura in https://github.com/pyenv/pyenv/pull/2511
* Add nushell to activate list by @theref in https://github.com/pyenv/pyenv/pull/2524
* Fix compilation error when building OpenSSL 1.1.1q in MacOS 11+ for 3.9.15 and 3.8.15 by @twangboy in https://github.com/pyenv/pyenv/pull/2520
* Add simple `.editorconfig` file by @aphedges in https://github.com/pyenv/pyenv/pull/2518
* Support `aria2c` being a snap by @native-api in https://github.com/pyenv/pyenv/pull/2528
* Add CPython 3.12.0a2 by @saaketp in https://github.com/pyenv/pyenv/pull/2527
* Add --no-push-path option by @isaacl in https://github.com/pyenv/pyenv/pull/2526
* Fix typo in README.md by @weensy in https://github.com/pyenv/pyenv/pull/2535
* Copy auto installer oneliner to readme by @spookyuser in https://github.com/pyenv/pyenv/pull/2538

## Release 2.3.6

* Add CPython 3.10.8 (#2480)
* Add CPython 3.7.15, 3.8.15, and 3.9.15 (#2482)
* Add CPython 3.11.0 (#2493)
* Add CPython 3.12.0a1 (#2495)
* Add graalpy-22.3.0 (#2497)
* Auto-resolve prefixes to the latest version (#2487)
  * It must be a full prefix -- the actual searched prefix is `<prefix>[-.]`
  * Other flavors are likely sorted incorrectly atm
  * Prereleases and versions with some suffixes (`-dev`, `-src`, `-latest`) are not searched
  * `pyenv uninstall` has been excluded from the resolution feature: deleting a dynamically selected installation could be problematic
* Fix OpenSSL 1.1.1q compilation error in MacOS 11+ (#2500)
* Link to Tcl/Tk from Homebrew via pkgconfig for 3.11+ (#2501)
* Fix syntax error in `pyenv init -` if PYENV_ROOT has spaces (#2506)

## Release 2.3.5

* Add CPython 3.10.7 (#2454)
* Docs: update Fish PATH update (#2449)
* Add CPython 3.7.14, 3.8.14 and 3.9.14 (#2456)
* Update miniconda3-3.9-4.12.0 (#2460)
* Add CPython 3.11.0rc2 (#2459)
* Add patches for 3.7.14 to support Apple Silicon (#2463)
* Add ability to skip all use of Homebrew (#2464)
* Drop Travis integration (#2468)
* Build CPython 3.12+ with --with-dsymutil in MacOS (#2471)
* Add Pyston 2.3.5 (#2476)

## Release 2.3.4

* Add CPython 3.11.0rc1 (#2434)
* Add support for multiple versions in `pyenv uninstall` (#2432)
* Add micropython 1.18 and 1.19.1 (#2443)
* CI: support Micropython, deleted scripts; build with -v (#2447)
* Re-allow paths in .python-version while still preventing CVE-2022-35861 (#2442)
* CI: Bump OS versions (#2448)
* Add Cinder 3.8 (#2433)

## Release 2.3.3

* Use version sort in `pyenv versions` (#2405)
* Add CPython 3.11.0b4 (#2411)
* Python-build: Replace deprecated git protocol use with https in docs (#2413)
* Fix relative path traversal due to using version string in path (#2412)
* Allow pypy2 and pypy3 patching (#2421, #2419)
* Add CPython 3.11.0b5 (#2420)
* Add GraalPython 22.2.0 (#2425)
* Add CPython 3.10.6 (#2428)

## Release 2.3.2

* Add CPython 3.11.0b2 (#2380)
* Honor CFLAGS_EXTRA for MicroPython #2006 (#2007)
* Add post-install checks for curses, ctypes, lzma, and tkinter (#2353)
* Add CPython 3.11.0b3 (#2382)
* Add flags for Homebrew into `python-config --ldflags` (#2384)
* Add CPython 3.10.5 (#2386)
* Add Anaconda 2019.10, 2021.04, 2022.05; support Anaconda in add_miniconda.py (#2385)
* Add Pyston-2.3.4 (#2390)
* Update anaconda3-2022.05 MacOSX arm64 md5 (#2391)

## Release 2.3.1

* Version file read improvements (#2269)
* Add CPython 3.11.0b1 (#2358)
* Update 3.11-dev and add 3.12-dev (#2361)
* Add CPython 3.9.13 (#2372)
* Add miniconda 4.12.0 (#2371)
* Fix endless loop in `pyenv init -` under SSH in some shell setups (#2374)
* CI: Add tests for modified Python build scripts (#2286)

## Release 2.3.0

* Bump openssl 1.1 to 1.1.1n for CPython 3.7 3.8 3.9 (#2276)
* Doc Fix: Escape a hash character causing unwanted GitHub Issue linking (#2282)
* Add CPython 3.9.12 (#2296)
* Add CPython 3.10.4 (#2295)
* Add patch for 3.6.15 to support Xcode 13.3 (#2288)
* Add patch for 3.7.12 to support Xcode 13.3 (#2292)
* Add CONTRIBUTING.md (#2287)
* Add PyPy 7.3.9 release 2022-03-30 (#2308)
* Add Pyston 2.3.3 (#2316)
* Add CPython 3.11.0a7 (#2315)
* Add "nogil" Python v3.9.10 (#2342)
* Support XCode 13.3 in all releases that officially support MacOS 11 (#2344)
* Add GraalPython 22.1.0 (#2346)
* Make PYENV_DEBUG imply -v for `pyenv install` (#2347)
* Simplify init scheme (#2310)
* Don't use Homebrew outside of MacOS (#2349)
* Add `:latest` syntax to documentation for the `install` command (#2351)

## Release 2.2.5

* Add CPython 3.10.3
* Add CPython 3.9.11
* Add CPython 3.8.13
* Add CPython 3.7.13
* Add CPython 3.11.0a6 (#2266)
* Add PyPy 7.3.8 (#2253)
* Add miniconda3-3.7-4.11.0, miniconda3-3.8-4.11.0, miniconda3-3.9-4.11.0 (#2268)
* Add pyston-2.3.2 (#2240)
* Fix UnicodeDecodeError for CPython 3.6.15 and 3.7.12 (#2237)
* python-build: add URL for get-pip for Python 3.6 (#2238)
* Bump openssl to 1.1.1n for CPython 3.10.x

## Release 2.2.4

* Added docstrings to several undocumented functions (#2197)
* Fix incorrect pypy 2.7-7.3.6 sha256 hashes (#2208)
* Fix a regression in include paths when compiling ctypes in 3.6.15/3.7.12 (#2209)
* Revert "Disable coreutils on M1 Apple Silicon with arm64 (#2020)" (#2212)
* CPython 3.11.0a4 (#2217)
* CPython 3.9.10 and 3.10.2 (#2219)
* miniconda3-latest: added Linux-aarch64 (#2221)
* Add GraalPython 22.0.0 (#2226)


## Release 2.2.3

* Add new pypy versions (pypy2.7-7.3.2~7.3.5) to the version list (#2194)
* Fix Python 3.7.12 compilation on macOS arm64/M1. (#2190)
* Fix Python 3.6.15 compilation on macOS arm64/M1. (#2189)
* Add Anaconda3-2021.11 (#2193)
* CPython 3.11.0a3 (#2187)
* Fix errant "echo" in README install instructions (#2185)
* Add Miniforge and Mambaforge 4.10.3-10 (#2184)
* Add CPython 3.10.1 (#2183)
* Fix 3.6.15 build on macOS (#2182)

## Release 2.2.2

* Add support for macOS Apple M1 (#2164)

## Release 2.2.1

* Add CPython 3.9.9 (#2162)
* Add CPython 3.9.8 (#2152)
* Add Add micropython 1.17 (#2158)
* Add Add micropython 1.16 (#2158)
* Patch 3.10.0 configure, fixes https://bugs.python.org/issue45350 (#2155)
* Use command and type instead of which (#2144)
* Add definition of pyenv help in COMMANDS.md #2139
* Use OpenSSL 1.0 for CPython 2.7.18

## Release 2.2.0
* Adding PyPy release 7.3.7 (Python 3.7 and 3.8). (#2132)
* Append Homebrew custom prefix to search path (#1957)
* Add documentation for init command (#2125)
* Add setup instructions for the case when one installs Pyenv as part of a batch job (#2127)
* Add documentation for completions command (#2126)
* Default --with-universal-archs to universal2 on Apple Silicon (#2122)
* Update README.md (#2120)
* Add GraalPython 21.3.0 (#2117)
* Pypy ver 7.3.6 - python 3.7 and python 3.8 (#2111)
* Discover Tcl/Tk reliably and use active version (#2106)
* Fish installation instructions (#2104)
* Add CPython 3.11.0a1 (#2099)

## Release 2.1.0
* Fix mambaforge-pypy3 build (#2096)
* Add Python 3.10.0 (#2093)
* Add documentation for exec command (#2090)
* Add documentation for shims command (#2091)
* Add documentation for hooks command (#2089)
* Add documentation for root command (#2088)
* Add documentation for prefix command (#2087)
* Update to Pyston's v2 package of the 2.3.1 release (#2078)
* Add pyston-2.3.1 support (#2075)
* Don't update conda when installing pip (#2074)
* Improve `add_miniconda.py` (#2072)
* GitHub actions tests (#2073)
* Fix sed commands (#2071)
* macOS: fix the build of Python 2.7.18 on macOS 11.5.2 (Big Sur) + Apple Silicon (#2061)

## Release 2.0.7
* Update setup instructions in the Readme (#2067)
* Allow tcl-tk as argument or try with homebrew by default (#1646)
* Allow system Python in sbin (#2065)
* Prevent addition of duplicate plugin dirs to PATH (#2045)
* Disable coreutils on M1 Apple Silicon with arm64 (#2020)
* Add Python 3.10.0rc2 (#2053)
* Add space after `yes/no` prompt (#2040)
* Add CPython v3.6.15 and v3.7.12 (#2052)
* Add missing Python 2.6.x definitions and patches (#2051)
* Fix build of ossaudiodev in Linux/FreeBSD for Python 2.6 (#2049)
* Fix build of ossaudiodev in Linux/FreeBSD for Python 3.1 (#2047)

## Release 2.0.6
* Add CPython 3.9.7 (#2044)
* Add CPython v3.8.12 (#2043)
* Adapt conda.bash for bash associative array (#2037)

## Release 2.0.5

* Move man page to location where it can be automatically found by man (#2032)
* Update checksums for CPython 3.10.0rc1 (#2025)
* Remove 3.9.3 (#2022)
* Add CPython 3.10.0rc1(#2023)

## Release 2.0.4

- Added scripts for rolling releases of Miniforge (#2019)
- Update pyston-2.3 (#2017)
- Add GraalPython 21.2.0 (#2018)
- Add CPython  3.10.0b4 (#2013), (#2005)
- Add Pyston 2.3 (#2012)

## Release 2.0.3

* Remove PATH warning (#2001)
* Add Python 3.6.14, 3.7.11, 3.8.11, and 3.9.6 (#1996)
* Miniforge minor update to 4.10.1-5 (#1992)
* Suggest that fish users init in interactive mode (#1991)

## Release 2.0.2

* Miniforge minor update to 4.10.1-5 (#1992)
* Suggest that fish users init in interactive mode (#1991)
* Add 3.10.0b3 (#1988)
* Revert "Drop inferring version to install from `pyenv local`" (#1984)
* Use system Python3 for tests (#1979)
* Check for shims in path with pure Bash (#1978)
* Update setup instructions for debian, ubuntu etc. (#1977)

## Release 2.0.1

* Drop inferring version to install from `pyenv local` (#1907)
* Create mambaforge-4.10.1-4 (#1971)
* Add 3.10.0b2 recipe (#1966)
* Fix .bashrc `echo` install syntax error (#1965)
* Add explicit Zsh instructions for MacOS (#1964)
* Install pip with pyston (#1955)
* Mention log file if an error happened before building, too (#1537)
* Add pypy3.7-7.3.5 (#1950)

## Release 2.0.0

* Support for CPython 3.9.5 has been added.
* Support for CPython 3.8.10 has been added.
* Support for CPython 3.10.0b1 has been added.
* Support for GraalPython 21.1.0 has been added.
* Support for  Anaconda 2021.05 has been added.
* Support for   Miniforge3 4.10.1-1 has been added.
* CPython 3.10-dev target branch renamed.
* CPython 3.10-dev and 3.11-dev updated.
* Bump OpenSSL to 1.1.1x for all Pythons that support MacOS 11
* Update generated configuration files before run ./configure
* Full shell configuration instructions placed into `pyenv init`
* Prevent build from installing MacOS apps globally
* ldflags_dirs is not needed for Python and causes failures
* Report cache filename at download
* Add micropython 1.15
* Correct URLs for Stackless builds and add Stackless 2.7.16

## Breaking changes
* Split startup logic into PATH and everything else (https://github.com/pyenv/pyenv/issues/1649#issuecomment-694388530)

## 1.2.27

* Add GraalPython 21.1.0 (#1882)
* Add CPython 3.10.0a7 (#1880)
* Docs(README): fix info about version-file separator (#1874)
* List versions starting with a dot (#1350)
* Feat: support (skip) commented lines in version-file (#1866)
* pypy3.7-7.3.4 (#1873)
* Create miniforge3-4.10 (#1868)
* Add CPython 3.9.4 (#1865)

## 1.2.26

* Add CPython 3.9.4 (#1865)

## 1.2.25

* bpo-43631: update to openssl 1.1.1k (#1861)
* Add CPython 3.9.3 and 3.8.9 (#1859)
* Add micropython 1.14 (#1858)
* Shell detect improvements (#1835)
* Test(init): remove misleading detect from parent shell case arg (#1856)
* Add GraalPython 21.0.0 (#1855)

## 1.2.24

* GitHub Actions: Add $PYENV_ROOT/shims to $PATH (#1838)
* Add Python 3.10.0a6 (#1839)
* Remove the "Using script's directory as PYENV_DIR if shim is invoked with a script argument" feature (#1814)
* Update GET_PIP_URL (#1844)
* GitHub Action to build Python versions on Ubuntu (#1794)
* Make work in nounset (-u) mode (#1786)
* Update miniforge3-4.9.2 (#1834)
* Added aarch64 for Linux in anaconda_architecture() (#1833)
* Hook script to add latest suffix for install command (#1831)
* Fix error link (#1832)
* Clarify proxy variable names in readme (#1830)
* Travis CI: Add Xcode 12 on macOS 10.15.5 (#1708)
* Added --nosystem argument (#1829)
* Add CPython 3.8.8 (#1825)
* Add CPython 3.9.2 (#1826)
* Add manpage (#1790)

## 1.2.23

+ python-build: Add CPython v3.7.10 (#1818)
+ python-build: Add CPython v3.6.13 (#1817)
* python-build: Add PyPy 3.7-c-jit-latest (#1812)
* python-build: Add PyPy 3.7 (#1718, #1726, #1780)
* python-build: Add miniconda3 4.9.2 (#1763)
* python-build: Add miniconda3 4.8.3 (#1763)
* python-build: Add miniconda3 4.8.2 (#1763)
* python-build: Add Miniforge3-4.9.2 (#1782)
* python-build: Fix download links for some PyPy and Stackless versions (#1692)
* python-build: Add PYENV_DEBUG option (#1806)
* python-build: Fix get-pip which dropped support for legacy Python (#1793)
* pyenv-help: Fix `sed: RE error: illegal byte sequence` (#1714)
* pyenv-versions: Fix not printing asterisk for current version in Bash 3 (#1815)
* pyenv-prefix: "system" python - support cases where python3 is in PATH but not python (#1655)
* pyenv-which: Added fallback to system executable (#1797)
* pyenv-rehash: Use associative arrays for better performance on bash >= 4 (#1749)
* pyenv-rehash: Try to sleep in 0.1 sec steps when acquiring lock (#1798)
* pyenv: Use a better PS4 as recommended by Bash Hackers Wiki (#1810)

## 1.2.22

+ python-build: Add LDFLAGS for zlib on macOS >= 1100 (#1711)
+ python-build: Add the CPython 3.9.1 (#1752)
+ python-build: Change order of LDFLAGS paths (#1754)
+ python-build: Docker config for testing python-build (#1548)
+ python-build: Put prerequisite for installation before install (#1750)
+ python-build: Add GraalPython 20.3 (#1736)
+ python-build: Add CPython 3.8.7
+ python-build: Added anaconda3-2020.11 (#1774)
+ python-build: Added arm64 architecture support in python-build for macOS  (#1775)

## 1.2.21

* python-build: Add CPython 3.9.0 (#1706)
* python-build: Add CPython 3.8.6 (#1698)
* python-build: Add CPython 3.7.9 (#1680)
* python-build: Add CPython 3.6.12 (#1680)
* python-build: Add CPython 3.5.10 (#1690)
* python-build: Add Jython 2.7.2 (#1672)
* python-build: Add Graalpython 20.1.0 (#1594)
* python-build: Add Graalpython 20.2.0 (#1594)
* python-build: Add Anaconda3-2020.07 (#1684)
* python-build: Add micropython-1.13 (#1704)
* python-build: Fix PyPy download links (#1682)
* python-build: Support for `PYTHON_BUILD_MIRROR_URL` when checksums do not exist (#1673)
* pyenv: Search for plugins in `PYENV_DIR` and `PYENV_ROOT` (#1697)
* pyenv-help: Fix 'sed: RE error: illegal byte sequence' (#1670)

## 1.2.20

* python-build: Add CPython 3.8.5 (#1667)
* python-build: Add CPython 3.8.4 (#1658)
* python-build: Add CPython 3.7.8
* python-build: Add CPython 3.6.11
* pyenv-install: Make grep detection more robust (#1663)
* python-build: Fix has_tar_xz_support function on FreeBSD. (#1652)

## 1.2.19

* python-build: Add CPython 3.8.3 (#1612)
* python-build: Add CPython 2.7.18 (#1593)
* python-build: Add CPython 3.10-dev (#1619)
* python-build: Add anaconda3-2020.02 (#1584)
* python-build: Add stackless 3.7.5 (#1589)

## 1.2.18

* python-build: Update download URLs for old OpenSSL releases (#1578)
* python-build: Prevent `brew: command not found` messages that are not errors (#1544)

## 1.2.17

* python-build: Add CPython 3.8.2
* python-build: Add CPython 3.7.7 (#1553)
* python-build: Add Miniconda versions newer than 4.3.30 (#1361)
* python-build: Add Micropython 1.12 (#1542)
* python-build: Add Add CPython 3.9.0a4
* pyenv: Fix sed illegal byte sequence error (#1521)

## 1.2.16

* python-build: Add CPython 3.8.1 (#1497)
* python-build: Add CPython 3.7.6 (#1498)
* python-build: Add CPython 3.6.10 (#1499)
* python-build: Add CPython 3.5.9 (#1448)
* python-build: Add PyPy 7.3.0 (1502)

## 1.2.15

* python-build: Add CPython 3.7.5 (#1423)
* python-build: Add CPython 2.7.17 (#1433)
* python-build: Add CPython 3.5.8 (#1441)
* python-build: Add PyPy 7.2.0 (#1418)
* python-build: Add anaconda3-2019.10 (#1427)
* pyenv-help: Show text for all pyenv commands in pyenv-help (#1421)

## 1.2.14

* python-build: Add CPython 3.8.0 (#1416)
* python-build: Add Anaconda-2019.07 (#1382)
* python-build: Add Micropython 1.11 (#1395)
* python-build: Fix compatibility issues with Homebrew installed Tcl/Tk (#1397)
* pyenv-exec: Do not use `exec -a`, do not mangle PATH for system Python (#1169)

## 1.2.13

* python-build: Add CPython 3.7.4
* python-build: Add CPython 3.6.9

## 1.2.12

* python-build: Find zlib from Xcode or brew on Mojave (#1353)
* python-build: Add PyPy 7.1.1 (#1335)
* python-build: Add CPython 3.8.0b1

## 1.2.11

* python-build: Fix `posix_close` name collision in 2.4 builds (#1321)
* python-build: Add CPython 3.4.10 (#1322)
* python-build: Add Anaconda 2019.03
* python-build: Allow overriding the preference of OpenSSL version per definition basis (#1302, #1325, #1326)
* python-build: Imported changes from rbenv/ruby-build 20190401 (#1327)
* python-build: Use GNU Readline 8.0 on macOS if brew's package isn't available (#1329)

## 1.2.10

* python-build: Force y, Y, yes or YES to confirm installation (#1217)
* python-build: Add PyPy 7.0.0, 7.1.0
* python-build: Add CPython 2.7.16, 3.5.7 and 3.7.3
* python-build: Install `python-gdb.py` (#1190, #1289)
* python-build: Add micropython 1.10
* python-build: Prefer Homebrew's OpenSSL 1.1 over 1.0 (#839, #1302)

## 1.2.9

* python-build: Add CPython 3.7.2 and CPython 3.6.8 (#1256)
* python-build: Add anaconda[23]-5.3.1 (#1246)
* python-build: Add Anaconda 2018.12 (#1259)
* python-build: Fix ironpython-dev git repo url (#1260)
* python-build: Add `OPENSSL_NO_SSL3` patch for CPython 3.3.7 (#1263)

## 1.2.8

* python-build: Add CPython 3.7.1
* python-build: Add CPython 3.6.7
* python-build: Add anaconda[23]-5.3.0 (#1220)

## 1.2.7

* python-build: Add CPython 3.5.6 (#1199)
* python-build: Add CPython 3.4.9

## 1.2.6

* python-build: Added CPython 3.6.6 (#1178)
* python-build: Check wget version iff wget is going to be used (#1180)

## 1.2.5

* python-build: Add CPython 3.7.0 (#1177)
* python-build: Add micropython 1.9.4 (#1160)
* python-build: Add anaconda[23]-5.2.0 (#1165)
* pyenv: Fix `seq(1)` is not available on OpenBSD (#1166)

## 1.2.4

* python-build: Add CPython 2.7.15
* python-build: Add PyPy 6.0.0
* python-build: Allow overriding HTTP client type based on environment variable `PYTHON_BUILD_HTTP_CLIENT` (#1126)
* python-build: Use version-specific `get-pip.py` when installing 2.6 and 3.2 (#1131)
* pyenv: Merge rbenv master (#1151)
* pyenv: Make `pyenv-rehash` safer for multiple processes (#1092)

## 1.2.3

* python-build: Add CPython 3.6.5
* python-build: Set openssl PKG_CONFIG_PATH for python 3.7 (#1117)
* python-build: Add ActivePython versions 2.7.14, 3.5.4, 3.6.0 (#1113)
* python-build: Unset `PIP_VERSION` before invoking `get-pip.py` as a workaround for `invalid truth value` error (#1124)

## 1.2.2

* python-build: Add PyPy3 5.10.1 (#1084)
* python-build: Add CPython 3.5.5 (#1090)
* python-build: Add Anaconda[23]-5.1.0 (#1100)
* python-build: Fix checksum issue for CPython 3.4.8 (#1094)
* python-build: Prevent Anaconda from installing a `clear` shim (#1084)
## 1.2.1

* python-build: Add CPython 3.6.4
* python-build: Add PyPy[23] 5.10

## 1.2.0

* python-build: Import changes from ruby-build v20171031 (#1026)
* python-build: Ignore LibreSSL bundled with macOS 10.13 (#1025)
* python-build: Skip passing `--enable-unicode` to CPython 3.3+ (#912)
* python-build: Add CPython 3.3.7 (#1053)
* python-build: Add micropython 1.9.3
* python-build: Add PyPy 5.9.0
* python-build: Add Miniconda[23] 4.3.14, 4.3.21, 4.3.27, 4.3.30
* python-build: Add Anaconda[23] 5.0.1
* python-build: Update Anaconda[23] 5.0.0 to 5.0.0.1 bugfix release

## v1.1.5

* python-build: Add CPython 3.6.3
* python-build: Add CPython 3.7.0a1
* python-build: Add Anaconda[23] 5.0.0

## v1.1.4

* pyenv: Workaround for scripts in `$PATH` which needs to be source'd (#100, #688, #953)
* python-build: Add support for PyPy3 executables like `libpypy3-c.so` (#955, #956)
* python-build: Add CPython 2.7.14, 3.4.7, 3.5.4 (#965, #971, #980)
* python-build: Add Jython 2.7.1 (#973)

## v1.1.3

* python-build: Add CPython 3.6.2 (#951)

## v1.1.2

* pyenv: Fix incorrect `pyenv --version` output in v1.1.1 (#947)

## v1.1.1

* python-build: Update links to Portable Pypy 5.8-1 bugfix release, affects pypy2.7-5.8.0 and pypy3.5-5.8.0 definitions (#939)

## v1.1.0

* python-build: Add PyPy 5.7.1 (#888)
* pyenv: Merge rbenv master (#927)
* python-build: Add PyPy 5.8.0 (#932)
* python-build: Anaconda[23] 4.4.0
* python-build: Add micropython-dev

## 1.0.10

* python-build: Add Anaconda2/Anaconda3 4.3.1 (#876)
* python-build: Make miniconda-latest point to miniconda2-latest (#881)
* python-build: Fix typo in MacOS packages for anaconda2-4.3.0/4.2.0 (#880)

## 1.0.9

* pyenv: Migrate project site from https://github.com/yyuu/pyenv to https://github.com/pyenv/pyenv
* python-build: Add PyPy2 5.7.0 (#872, #868)
* python-build: Add PyPy3 5.7.0-beta (#871, #869)
* python-build: Add CPython 3.6.1 (#873)
* python-build: Add Pyston 0.6.1 (#859)
* python-build: Change default mirror site URL from https://yyuu.github.io/pythons to https://pyenv.github.io/pythons
* python-build: Upgrade OpenSSL from 1.0.2g to 1.0.2k (#850)

## 1.0.8

* pyenv: Fix fish subcommand completion (#831)
* python-build: Add Anaconda2/Anaconda3 4.3.0  (#824)
* python-build: Use CPython on GitHub as the source repository of CPython development versions (#836, #837)
* python-build: Fix checksum verification issue on the platform where OpenSSL isn't available (#840)

## 1.0.7

* python-build: Add CPython 3.5.3 (#811)
* python-build: Add CPython 3.4.6 (#812)
* python-build: Fix tar.gz checksum of CPython 3.6.0 (#793)
* python-build: Jython installer workaround (#800)
* python-build: Disable optimization (`-O0`) when `--debug` was specified (#808)

## 1.0.6

* python-build: Add CPython 3.6.0 (#787)

## 1.0.5

* python-build: Add CPython 2.7.13 (#782)
* python-build: Add CPython 3.6.0rc2 (#781)
* python-build: Add Anaconda 4.2.0 (#774)
* python-build: Add Anaconda3 4.2.0 (#765)
* python-build: Add IronPython 2.7.7 (#755)

## 1.0.4

* python-build: Add PyPy 5.6.0 (#751)
* python-build: Add PyPy3 3.5 nightlies (`pypy3.5-c-jit-latest` #737)
* python-build: Add Stackless 2.7.12 (#753)
* python-build: Add Stackless 2.7.11
* python-build: Add Stackless 2.7.10
* python-build: Add Pyston 0.6.0
* python-build: Add CPython 3.6.0b4 (#762)

## 1.0.3

* python-build: Add CPython 3.6.0b3 (#731, #744)
* python-build: Add PyPy3.3 5.5-alpha (#734, #736)
* python-build: Stop specifying `--enable-unicode=ucs4` on OS X (#257, #726)
* python-build: Fix 3.6-dev and add 3.7-dev (#729, #730)
* python-build: Add a patch for https://bugs.python.org/issue26664 (#725)
* python-build: Add Pyston 0.5.1 (#718)
* python-build: Add Stackless 3.4.2 (#720)
* python-build: Add IronPython 2.7.6.3 (#716)
* python-build: Add Stackless 2.7.9 (#714)

## 1.0.2

* python-build: Add CPython 3.6.0b1 (#699)
* python-build: Add anaconda[23] 4.1.1 (#701, #702)
* python-build: Add miniconda[23] 4.1.11 (#703, #704, #706)
* python-build: Remove `bin.orig` if exists to fix an issue with `--enable-framework` (#687, #700)

## 1.0.1

* python-build: Add CPython 3.6.0a4 (#673)
* python-build: Add PyPy2 5.4, 5.4.1 (#683, #684, #695, #697)
* python-build: Add PyPy Portable 5.4, 5.4.1 (#685, #686, #696)
* python-build: Make all HTTP source URLs to HTTPS (#680)

## 1.0.0

* pyenv: Import latest changes from rbenv as of Aug 15, 2016 (#669)
* pyenv: Add workaround for system python at `/bin/python` (#628)
* python-build: Import changes from ruby-build v20160602 (#668)

## 20160726

* python-build: pypy-5.3.1: Remove stray text (#648)
* python-build: Add CPython 3.6.0a3 (#657)
* python-build: Add anaconda[23]-4.1.0
* pyenv: Keep using `.tar.gz` archives if tar doesn't support `-J` (especially on BSD) (#654, #663)
* pyenv: Fixed conflict between pyenv-virtualenv's `rehash` hooks of `envs.bash`
* pyenv: Write help message of `sh-*` commands to stdout properly (#650, #651)

## 20160629

* python-build: Added CPython 2.7.12 (#645)
* python-build: Added PyPy 3.5.1 (#646)
* python-build: Added PyPy Portable 5.3.1

## 20160628

* python-build: Added PyPy3.3 5.2-alpha1 (#631)
* python-build: Added CPython 2.7.12rc1
* python-build: Added CPython 3.6.0a2 (#630)
* python-build: Added CPython 3.5.2 (#643)
* python-build: Added CPython 3.4.5 (#643)
* python-build: Added PyPy2 5.3 (#626)
* pyenv: Skip creating shims for system executables bundled with Anaconda rather than ignoring them in `pyenv-which` (#594, #595, #599)
* python-build: Configured GCC as a requirement to build CPython prior to 2.4.4 (#613)
* python-build: Use `aria2c` - ultra fast download utility if available (#534)

## 20160509

* python-build: Fixed wrong SHA256 of `pypy-5.1-linux_x86_64-portable.tar.bz2` (#586, #587)
* python-build: Added miniconda[23]-4.0.5
* python-build: Added PyPy (Portable) 5.1.1 (#591, #592, #593)

## 20160422

* python-build: Added PyPy 5.1 (#579)
* python-build: Added PyPy 5.1 Portable
* python-build: Added PyPy 5.0.1 (#558)
* python-build: Added PyPy 5.0.1 Portable
* python-build: Added PyPy 5.0 Portable
* python-build: Added anaconda[23]-4.0.0 (#572)
* python-build: Added Jython 2.7.1b3 (#557)

## 20160310

* python-build: Add PyPy-5.0.0 (#555)
* pyenv: Import recent changes from rbenv 1.0 (#549)

## 20160303

* python-build: Add anaconda[23]-2.5.0 (#543)
* python-build: Import recent changes from ruby-build 20160130
* python-build: Compile with `--enable-unicode=ucs4` by default for CPython (#257, #542)
* python-build: Switch download URL of Continuum products from HTTP to HTTPS (#543)
* python-build: Added pypy-dev special case in pyenv-install to use py27 (#547)
* python-build: Upgrade OpenSSL to 1.0.2g (#550)

## 20160202

* pyenv: Run rehash automatically after `conda install`
* python-build: Add CPython 3.4.4 (#511)
* python-build: Add anaconda[23]-2.4.1, miniconda[23]-3.19.0
* python-build: Fix broken build definitions of CPython/Stackless 3.2.x (#531)

### 20151222

* pyenv: Merge recent changes from rbenv as of 2015-12-14 (#504)
* python-build: Add a `OPENSSL_NO_SSL3` patch for CPython 2.6, 2.7, 3.0, 3.1, 3.2 and 3.3 series (#507, #511)
* python-build: Stopped using mirror at pyenv.github.io for CPython since http://www.python.org is on fast.ly

### 20151210

* pyenv: Add a default hook for Anaconda to look for original `$PATH` (#491)
* pyenv: Skip virtualenv aliases on `pyenv versions --skip-aliases` (pyenv/pyenv-virtualenv#126)
* python-build: Add CPython 2.7.11, 3.5.1 (#494, #498)
* python-build: Update OpenSSL to 1.0.1q (#496)
* python-build: Adding SSL patch to build 2.7.3 on Debian (#495)

### 20151124

* pyenv: Import recent changes from rbenv 5fb9c84e14c8123b2591d22e248f045c7f8d8a2c
* pyenv: List anaconda-style virtual environments as a version in pyenv (#471)
* python-build: Import recent changes from ruby-build v20151028
* python-build: Add PyPy 4.0.1 (#489)
* python-build: Add `miniconda*-3.18.3` (#477)
* python-build: Add CPython 2.7.11 RC1

### 20151105

* python-build: Add anaconda2-2.4.0 and anacondaa3-2.4.0
* python-build: Add Portable PyPy 4.0 (#472)

### 20151103

* python-build: Add PyPy 4.0.0 (#463)
* python-build: Add Jython 2.7.1b2
* python-build: Add warning about setuptools issues on CPython 3.0.1 on OS X (#456)

### 20151006

* pyenv: Different behaviour when invoking .py script through symlink (#379, #404)
* pyenv: Enabled Gitter on the project (#436, #444)
* python-build: Add Jython 2.7.1b1
* python-build: Install OpenSSL on OS X if no proper version is available (#429)

### 20150913

* python-build: Add CPython 3.5.0
* python-build: Remove CPython 3.5.0 release candidates
* python-build: Fixed anaconda3 repo's paths (#439)
* python-build: Add miniconda-3.16.0 and miniconda3-3.16.0 (#435)

### 20150901

* python-build: Add CPython 3.5.0 release candidates; 3.5.0rc1 and 3.5.0rc2
* python-build: Disabled `_FORTITY_SOURCE` to fix CPython >= 2.4, <= 2.4.3 builds (#422)
* python-build: Removed CPython 3.5.0 betas
* python-build: Add miniconda-3.10.1 and miniconda3-3.10.1 (#414)
* python-build: Add PyPy 2.6.1 (#433)
* python-build: Add PyPy-STM 2.3 and 2.5.1 (#428)
* python-build: Ignore user's site-packages on ensurepip/get-pip (#411)
* pyenv: Import recent changes from ruby-build v20150818

#### 20150719

* python-build: Add CPython `3.6-dev` (#413)
* python-build: Add Anaconda/Anaconda3 2.3.0
* python-build: Fix download URL of portable PyPy 2.6 (fixes #389)
* python-build: Use custom `MACOSX_DEPLOYMENT_TARGET` if defined (#312)
* python-build: Use original CPython repository instead of mirror at bitbucket.org as the source of `*-dev` versions (#409)
* python-build: Pin pip version to 1.5.6 for python 3.1.5 (#351)

#### 20150601

* python-build: Add PyPy 2.6.0
* python-build: Add PyPy 2.5.1 portable
* python-build: Add CPython 3.5.0 beta releases; 3.5.0b1 and 3.5.0b2
* python-build: Removed CPython 3.5.0 alpha releases
* python-build: Fix inverted condition for `--altinstall` of ensurepip (#255)
* python-build: Skip installing `setuptools` by `ez_setup.py` explicitly (fixes #381)
* python-build: Import changes from ruby-build v20150519

#### 20150524

* pyenv: Improve `pyenv version`, if there is one missing (#290)
* pyenv: Improve pip-rehash to handle versions in command, like `pip2` and `pip3.4` (#368)
* python-build: Add CPython release; 2.7.10 (#380)
* python-build: Add Miniconda/Miniconda3 3.9.1 and Anaconda/Anaconda3 2.2.0 (#375, #376)

#### 20150504

* python-build: Add Jython 2.7.0
* python-build: Add CPython alpha release; 3.5.0a4
* python-build: Add CPython 3.1, 3.1.1, and 3.1.2
* python-build: Fix pip version to 1.5.6 for CPython 3.1.x (#351)

#### 20150326

* python-build: Add Portable PyPy binaries from https://github.com/squeaky-pl/portable-pypy (#329)
* python-build: Add CPython alpha release; 3.5.0a2 (#328)
* python-build: Add pypy-2.5.1 (fixes #338)
* pyenv: Import recent changes from rbenv 4d72eefffc548081f6eee2e54d3b9116b9f9ee8e

#### 20150226

* python-build: Add CPython release; 3.4.3 (#323)
* python-build: Add CPython alpha release; 3.5.0a1 (#324)
* python-build: Add Miniconda/Miniconda3 3.8.3 (#318)

#### 20150204

* python-build: Add PyPy 2.5.0 release (#311)
* python-build: Add note about `--enable-shared` and RPATH (#217)
* python-build: Fix regression of `PYTHON_MAKE_INSTALL_TARGET` and add test (#255)
* python-build: Symlink `pythonX.Y-config` to `python-config` if `python-config` is missing (#296)
* python-build: Latest `pip` can't be installed into `3.0.1` (#309)

#### 20150124

* python-build: Import recent changes from ruby-build v20150112
* python-build: Prevent adding `/Library/Python/X.X/site-packages` to `sys.path` when `--enable-framework` is enabled on OS X. Thanks @s1341 (#292)
* python-build: Add new IronPython release; 2.7.5

#### 20141211

* pyenv: Add built-in `pip-rehash` feature. You don't need to install [pyenv-pip-rehash](https://github.com/pyenv/pyenv-pip-rehash) anymore.
* python-build: Add new CPython release; 2.7.9 (#284)
* python-build: Add new PyPy releases; pypy3-2.4.0, pypy3-2.4.0-src (#277)
* python-build: Add build definitions of PyPy nightly build

#### 20141127

* python-build: Add new CPython release candidates; 2.7.9rc1 (#276)

#### 20141118

* python-build: Fix broken `setup_builtin_patches` (#270)
* python-build: Add a patch to allow building 2.6.9 on OS X 10.9 with `--enable-framework` (#269, #271)

#### 20141106

* pyenv: Optimize pyenv-which. Thanks to @blueyed (#129)
* python-build: Add Miniconda/Miniconda3 3.7.0 and Anaconda/Anaconda3 2.1.0 (#260)
* python-build: Use HTTPS for mirror download URLs (#262)
* python-build: Set `rpath` for `--shared` build of PyPy (#244)
* python-build: Support `make altinstall` when building CPython/Stackless (#255)
* python-build: Import recent changes from ruby-build v20141028 (#265)

#### 20141012

* python-build: Add new CPython releases; 3.2.6, 3.3.6 (#253)

#### 20141011

* python-build: Fix build error of Stackless 3.3.5 on OS X (#250)
* python-build: Add new Stackless releases; stackless-2.7.7, stackless-2.7.8, stackless-3.4.1 (#252)

#### 20141008

* python-build: Add new CPython release; 3.4.2 (#251)
* python-build: Add new CPython release candidates; 3.2.6rc1, 3.3.6rc1 (#248)

#### 20140924

* pyenv: Fix an unintended behavior when user does not have write permission on `$PYENV_ROOT` (#230)
* pyenv: Fix a zsh completion issue (#232)
* python-build: Add new PyPy release; pypy-2.4.0, pypy-2.4.0-src (#241)

#### 20140825

* pyenv: Fix zsh completion with multiple words (#215)
* python-build: Display the package name of `hg` as `mercurial` in message (#212)
* python-build: Unset `PIP_REQUIRE_VENV` during build (#216)
* python-build: Set `MACOSX_DEPLOYMENT_TARGET` from the product version of OS X (#219, #220)
* python-build: Add new Jython release; jython2.7-beta3 (#223)

#### 20140705

* python-build: Add new CPython release; 2.7.8 (#201)
* python-build: Support `SETUPTOOLS_VERSION` and `PIP_VERSION` to allow installing specific version of setuptools/pip (#202)

#### 20140628

* python-build: Add new Anaconda releases; anaconda-2.0.1, anaconda3-2.0.1 (#195)
* python-build: Add new PyPy3 release; pypy3-2.3.1 (#198)
* python-build: Add ancient CPython releases; 2.1.3, 2.2.3, 2.3.7 (#199)
* python-build: Use `ez_setup.py` and `get-pip.py` instead of installing them from tarballs (#194)
* python-build: Add support for command-line options to `ez_setup.py` and `get-pip.py` (#200)

#### 20140615

* python-build: Update default setuptools version (4.0.1 -> 5.0) (#190)

#### 20140614

* pyenv: Change versioning schema (`v0.4.0-YYYYMMDD` -> `vYYYYMMDD`)
* python-build: Add new PyPy release; pypy-2.3.1, pypy-2.3.1-src
* python-build: Create symlinks for executables with version suffix (#182)
* python-build: Use SHA2 as default digest algorithm to verify downloaded archives
* python-build: Update default setuptools version (4.0 -> 4.0.1) (#183)
* python-build: Import recent changes from ruby-build v20140524 (#184)

#### 0.4.0-20140602

* python-build: Add new Anaconda/Anaconda3 releases; anaconda-2.0.0, anaconda3-2.0.0 (#179)
* python-build: Add new CPython release; 2.7.7 (#180)
* python-build: Update default setuptools version (3.6 -> 4.0) (#181)
* python-build: Respect environment variables of `CPPFLAGS` and `LDFLAGS` (#168)
* python-build: Support for xz-compressed Python tarballs (#177)

#### 0.4.0-20140520

* python-build: Add new CPython release; 3.4.1 (#170, #171)
* python-build: Update default pip version (1.5.5 -> 1.5.6) (#169)

#### 0.4.0-20140516

* pyenv: Prefer gawk over awk if both are available.
* python-build: Add new PyPy release; pypy-2.3, pypy-2.3-src (#162)
* python-build: Add new Anaconda release; anaconda-1.9.2 (#155)
* python-build: Add new Miniconda releases; miniconda-3.3.0, minoconda-3.4.2, miniconda3-3.3.0, miniconda3-3.4.2
* python-build: Add new Stackless releases; stackless-2.7.3, stackless-2.7.4, stackless-2.7.5, stackless-2.7.6, stackless-3.2.5, stackless-3.3.5 (#164)
* python-build: Add IronPython versions (setuptools and pip will work); ironpython-2.7.4, ironpython-dev
* python-build: Add new Jython beta release; jython-2.7-beta2
* python-build: Update default setuptools version (3.4.1 -> 3.6)
* python-build: Update default pip version (1.5.4 -> 1.5.5)
* python-build: Update GNU Readline (6.2 -> 6.3)
* python-build: Import recent changes from ruby-build v20140420

#### 0.4.0-20140404

* pyenv: Reads only the first word from version file. This is as same behavior as rbenv.
* python-build: Fix build of Tkinter with Tcl/Tk 8.6 (#131)
* python-build: Fix build problem with Readline 6.3 (#126, #131, #149, #152)
* python-build: Do not exit with errors even if some of modules are absent (#131)
* python-build: MacOSX was misspelled as MaxOSX in `anaconda_architecture` (#136)
* python-build: Use default `cc` as the C Compiler to build CPython (#148, #150)
* python-build: Display value from `pypy_architecture` and `anaconda_architecture` on errors (pyenv/pyenv-virtualenv#18)
* python-build: Remove old development version; 2.6-dev
* python-build: Update default setuptools version (3.3 -> 3.4.1)

#### 0.4.0-20140317

* python-build: Add new CPython releases; 3.4.0 (#133)
* python-build: Add new Anaconda releases; anaconda-1.9.0, anaconda-1.9.1
* python-build: Add new Miniconda releases; miniconda-3.0.4, miniconda-3.0.5, miniconda3-3.0.4, miniconda3-3.0.5
* python-build: Update default setuptools version (3.1 -> 3.3)

#### 0.4.0-20140311

* python-build: Add new CPython releases; 3.3.5 (#127)
* python-build: Add new CPython release candidates; 3.4.0rc1, 3.4.0rc2, 3.4.0rc3
* python-build: Update default setuptools version (2.2 -> 3.1)
* python-build: Update default pip version (1.5.2 -> 1.5.4)
* python-build: Import recent changes from ruby-build v20140225

#### 0.4.0-20140211

* python-build: Add new CPython release candidates; 3.3.4, 3.4.0b3
* python-build: Add [Anaconda](https://store.continuum.io/cshop/anaconda/) and [Miniconda](http://repo.continuum.io/miniconda/) binary distributions
* python-build: Display error if the wget does not support Server Name Indication (SNI) to avoid SSL verification error when downloading from https://pypi.python.org. (#60)
* python-build: Update default setuptools version (2.1 -> 2.2)
* python-build: Update default pip version (1.5.1 -> 1.5.2)
* python-build: Import recent changes from ruby-build v20140204

#### 0.4.0-20140123

* pyenv: Always append the directory at the top of the `$PATH` to return proper value for `sys.executable` (#98)
* pyenv: Unset `GREP_OPTIONS` to avoid issues of conflicting options (#101)
* python-build: Install `pip` with using `ensurepip` if available
* python-build: Add support for framework installation (`--enable-framework`) of CPython (#55, #99)
* python-build: Import recent changes from ruby-build v20140110.1
* python-build: Import `bats` tests from ruby-build v20140110.1

#### 0.4.0-20140110.1

* python-build: Fix build error of CPython 2.x on the platform where the `gcc` is llvm-gcc.

#### 0.4.0-20140110

* pyenv: Reliably detect parent shell in `pyenv init` (#93)
* pyenv: Import recent changes from rbenv 0.4.0
* pyenv: Import `bats` tests from rbenv 0.4.0
* python-build: Add new CPython releases candidates; 3.4.0b2
* python-build: Add ruby-build style patching feature (#91)
* python-build: Set `RPATH` if `--enable-shared` was given (#65, #66, 82)
* python-build: Update default setuptools version (2.0 -> 2.1)
* python-build: Update default pip version (1.4.1 -> 1.5)
* python-build: Activate friendly CPython during build if the one is not activated (8fa6b4a1847851919ad7857c6c42ed809a4d277b)
* python-build: Fix broken install.sh
* python-build: Import recent changes from ruby-build v20131225.1
* version-ext-compat: Removed from default plugin. Please use [pyenv-version-ext](https://github.com/pyenv/pyenv-version-ext) instead.

#### 0.4.0-20131217

* python-build: Fix broken build of CPython 3.3+ on Darwin
* python-build: Not build GNU Readline uselessly on Darwin

#### 0.4.0-20131216

* python-build: Add new CPython releases; 3.3.3 (#80)
* python-build: Add new CPython releases candidates; 3.4.0b1
* python-build: Add new PyPy releases; pypy-2.2.1, pypy-2.2.1-src
* python-build: Update default setuptools version (1.3.2 -> 2.0)
* python-build: Imported recent changes from ruby-build v20131211
* pyenv: Fix pyenv-prefix to trim "/bin" in `pyenv prefix system` (#88)

#### 0.4.0-20131116

* python-build: Add new CPython releases; 2.6.9, 2.7.6 (#76)
* python-build: Add new CPython release candidates; 3.3.3-rc1, 3.3.3-rc2
* python-build: Add new PyPy releases; pypy-2.2, pypy-2.2-src (#77)
* python-build: Update default setuptools version (1.1.6 -> 1.3.2)
* python-build: Imported recent changes from ruby-build v20131030

#### 0.4.0-20131023

* pyenv: Improved [fish shell](http://fishshell.com/) support
* python-build: Add new PyPy releases; pypy-2.1, pypy-2.1-src, pypy3-2.1-beta1, pypy3-2.1-beta1-src
* python-build: Add ancient versions; 2.4, 2.4.1, 2.4.3, 2.4.4 and 2.4.5
* python-build: Add alpha releases; 3.4.0a2, 3.4.0a3, 3.4.0a4
* python-build: Update default pip version (1.4 -> 1.4.1)
* python-build: Update default setuptools version (0.9.7 -> 1.1.6)

#### 0.4.0-20130726

* pyenv: Fix minor issue of variable scope in `pyenv versions`
* python-build: Update base version to ruby-build v20130628
* python-build: Use brew managed OpenSSL and GNU Readline if they are available
* python-build: Fix build of CPython 3.3+ on OS X (#29)
* python-build: Fix build of native modules of CPython 2.5 on OS X (#33)
* python-build: Fix build of CPython 2.6+ on openSUSE (#36)
* python-build: Add ancient versions; 2.4.2 and 2.4.6. The build might be broken. (#37)
* python-build: Update default pip version (1.3.1 -> 1.4)
* python-build: Update default setuptools version (0.7.2 -> 0.9.7)

#### 0.4.0-20130613

* pyenv: Changed versioning schema. There are two parts; the former is the base rbenv version, and the latter is the date of release.
* python-build: Add `--debug` option to build CPython with debug symbols. (#11)
* python-build: Add new CPython versions: 2.7.4, 2.7.5, 3.2.4, 3.2.5, 3.3.1, 3.3.2 (#12, #17)
* python-build: Add `svnversion` patch for old CPython versions (#14)
* python-build: Enable mirror by default for faster download (#20)
* python-build: Add `OPENSSL_NO_SSL2` patch for old CPython versions (#22)
* python-build: Install GNU Readline on Darwin if the system one is broken (#23)
* python-build: Bundle patches in `${PYTHON_BUILD_ROOT}/share/python-build/patches` and improve patching mechanism (`apply_patches`).
* python-build: Verify native extensions after building. (`build_package_verify_py*`)
* python-build: Add `install_hg` to install package from Mercurial repository
* python-build: Support building Jython and PyPy.
* python-build: Add new CPython development versions: 2.6-dev, 2.7-dev, 3.1-dev, 3.2-dev, 3.3-dev, 3.4-dev
* python-build: Add new Jython development versions: jython-2.5.4-rc1, jython-2.5-dev, jython-2.7-beta1, jython-dev
* python-build: Add new PyPy versions: pypy-1.5{,-src}, pypy-1.6, pypy-1.7, pypy-2.0{,-src}, pypy-2.0.1{,-src}, pypy-2.0.2{,-src}
* python-build: Add new PyPy development versions: pypy-1.7-dev, pypy-1.8-dev, pypy-1.9-dev, pypy-2.0-dev, pypy-dev, pypy-py3k-dev
* python-build: Add new Stackless development versions: stackless-2.7-dev, stackless-3.2-dev, stackless-3.3-dev, stackless-dev
* python-build: Update default pip version (1.2.1 -> 1.3.1)
* python-build: Update default setuptools version (0.6.34 (distribute) -> 0.7.2 ([new setuptools](https://bitbucket.org/pypa/setuptools)))

#### 0.2.0 (February 18, 2013)

* Import changes from rbenv 0.4.0.

#### 0.1.2 (October 23, 2012)

* Add push/pop for version stack management.
* Support multiple versions via environment variable.
* Now GCC is not a requirement to build CPython and Stackless.

#### 0.1.1 (September 3, 2012)

* Support multiple versions of Python at a time.

#### 0.1.0 (August 31, 2012)

* Initial public release.
