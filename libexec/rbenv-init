#!/usr/bin/env bash
# Summary: Configure the shell environment for rbenv
# Usage: rbenv init [<shells>...]
#        rbenv init - [--no-rehash] [<shell>]
#
# Modifies shell initialization files to bootstrap rbenv functionality.
# Typically, this will add a line that eval's the output of `rbenv init -`.
# If no shells are named by arguments, the current shell will be detected
# by inspecting the parent process. If a shell is already configured for
# rbenv, the init command does nothing and exits with zero status.
#
# In the `rbenv init -` mode, this outputs a script to be eval'd in the
# current shell. Most importantly, that script prepends the rbenv shims
# directory to the PATH environment variable. To aid interactive shells,
# the script also installs the magic `rbenv()` shell function and loads
# shell completions for rbenv commands.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo -
  echo --no-rehash
  echo bash
  echo fish
  echo ksh
  echo zsh
  exit
fi

print=""
no_rehash=""
shells=()
while [ $# -gt 0 ]; do
  case "$1" in
  "-" )
    print=1
    ;;
  "--no-rehash" )
    no_rehash=1
    ;;
  * )
    shells+=("$1")
    ;;
  esac
  shift
done

if [ "${#shells[@]}" -eq 0 ]; then
  shell="$(ps -p "$PPID" -o 'args=' 2>/dev/null || true)"
  shell="${shell%% *}"
  shell="${shell##-}"
  shell="${shell:-$SHELL}"
  shell="${shell##*/}"
  shells=("${shell%%-*}")
fi

root="${BASH_SOURCE:-$0}"
root="${root%/*}"
root="${root%/*}"

rbenv_in_path=true
if [ -n "$RBENV_ORIG_PATH" ]; then
  PATH="$RBENV_ORIG_PATH" type -P rbenv >/dev/null || rbenv_in_path=""
fi

if [ -z "$print" ]; then
  display_path() {
    if [ "${1/#$HOME\/}" != "$1" ]; then
      # shellcheck disable=SC2088
      printf '~/%s' "${1/#$HOME\/}"
    else
      printf '%s' "$1"
    fi
  }

  rbenv_command=rbenv
  if [ -z "$rbenv_in_path" ]; then
    rbenv_command="$(display_path "$root/bin/rbenv")"
  fi

  color_start=""
  color_end=""
  if [ -t 1 ]; then
    color_start=$'\e[33;1m'
    color_end=$'\e[m'
  fi

  write_config() {
    if grep -q "rbenv init" "$1" 2>/dev/null; then
      printf 'skipping %s%s%s: already configured for rbenv.\n' "$color_start" "$(display_path "$1")" "$color_end"
      return 0
    fi
    mkdir -p "${1%/*}"
    # shellcheck disable=SC2016
    printf '\n# Added by `rbenv init` on %s\n%s\n' "$(date)" "$2" >> "$1"
    printf 'writing %s%s%s: now configured for rbenv.\n' "$color_start" "$(display_path "$1")" "$color_end"
  }

  status=0
  for shell in "${shells[@]}"; do
    case "$shell" in
    bash )
      if [ -f ~/.bashrc ] && [ ! -f ~/.bash_profile ]; then
        profile="$HOME/.bashrc"
      else
        # shellcheck disable=SC2012
        profile="$(ls ~/.bash_profile ~/.bash_login ~/.profile 2>/dev/null | head -n1)"
        [ -n "$profile" ] || profile="$HOME/.bash_profile"
      fi
      write_config "$profile" \
        "eval \"\$($rbenv_command init - --no-rehash bash)\""
      ;;
    zsh )
      # check zshrc for backward compatibility with older rbenv init
      if grep -q rbenv "${ZDOTDIR:-$HOME}/.zshrc" 2>/dev/null; then
        profile="${ZDOTDIR:-$HOME}/.zshrc"
      else
        profile="${ZDOTDIR:-$HOME}/.zprofile"
      fi
      write_config "$profile" \
        "eval \"\$($rbenv_command init - --no-rehash zsh)\""
      ;;
    ksh | ksh93 | mksh )
      # There are two implementations of Korn shell: AT&T (ksh93) and Mir (mksh).
      # Systems may have them installed under those names, or as ksh, so those
      # are recognized here. The obsolete ksh88 (subsumed by ksh93) and pdksh
      # (subsumed by mksh) are not included, since they are unlikely to still
      # be in use as interactive shells anywhere.
      write_config "$HOME/.profile" \
        "eval \"\$($rbenv_command init - ksh)\""
      ;;
    fish )
      write_config "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
        "status --is-interactive; and $rbenv_command init - --no-rehash fish | source"
      ;;
    * )
      printf 'unsupported shell: "%s"\n' "$shell" >&2
      status=1
      ;;
    esac
  done
  exit $status
fi

mkdir -p "${RBENV_ROOT}/"{shims,versions}

shell="${shells[0]}"
case "$shell" in
fish )
  [ -n "$rbenv_in_path" ] || printf "set -gx PATH '%s/bin' \$PATH\n" "$root"
  printf "set -gx PATH '%s/shims' \$PATH\n" "$RBENV_ROOT"
  printf 'set -gx RBENV_SHELL %s\n' "$shell"
;;
* )
  # shellcheck disable=SC2016
  [ -n "$rbenv_in_path" ] || printf 'export PATH="%s/bin:${PATH}"\n' "$root"
  # shellcheck disable=SC2016
  printf 'export PATH="%s/shims:${PATH}"\n' "$RBENV_ROOT"
  printf 'export RBENV_SHELL=%s\n' "$shell"

  completion="${root}/completions/rbenv.${shell}"
  if [ -r "$completion" ]; then
    printf "source '%s'\n" "$completion"
  fi
;;
esac

if [ -z "$no_rehash" ]; then
  echo 'command rbenv rehash 2>/dev/null'
fi

IFS=$'\n' read -d '' -r -a commands <<<"$(rbenv-commands --sh)" || true

case "$shell" in
fish )
  cat <<EOS
function rbenv
  set command \$argv[1]
  set -e argv[1]

  switch "\$command"
  case ${commands[*]}
    rbenv "sh-\$command" \$argv|source
  case '*'
    command rbenv "\$command" \$argv
  end
end
EOS
  ;;
ksh | ksh93 | mksh )
  cat <<EOS
function rbenv {
  typeset command
EOS
  ;;
* )
  cat <<EOS
rbenv() {
  local command
EOS
  ;;
esac

if [ "$shell" != "fish" ]; then
IFS="|"
cat <<EOS
  command="\${1:-}"
  if [ "\$#" -gt 0 ]; then
    shift
  fi

  case "\$command" in
  ${commands[*]})
    eval "\$(rbenv "sh-\$command" "\$@")";;
  *)
    command rbenv "\$command" "\$@";;
  esac
}
EOS
fi
