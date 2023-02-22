#!/usr/bin/env bash
#
# Summary: Display help for a command
#
# Usage: pyenv help [--usage] COMMAND
#
# Parses and displays help contents from a command's source file.
#
# A command is considered documented if it starts with a comment block
# that has a `Summary:' or `Usage:' section. Usage instructions can
# span multiple lines as long as subsequent lines are indented.
# The remainder of the comment block is displayed as extended
# documentation.

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --usage
  exec pyenv-commands
fi

command_path() {
  local command="$1"
  command -v pyenv-"$command" || command -v pyenv-sh-"$command" || true
}

extract_initial_comment_block() {
  LC_ALL= \
  LC_CTYPE=C \
  sed -ne "
    /^#/ !{
      q
    }

    s/^#$/# /

    /^# / {
      s/^# //
      p
    }
  "
}

collect_documentation() {
  # `tail` prevents "broken pipe" errors due to `head` closing the pipe without reading everything
  # https://superuser.com/questions/554855/how-can-i-fix-a-broken-pipe-error/642932#642932
  $(type -P gawk awk | tail -n +1 | head -n1) '
    /^Summary:/ {
      summary = substr($0, 10)
      next
    }

    /^Usage:/ {
      reading_usage = 1
      usage = usage "\n" $0
      next
    }

    /^( *$|       )/ && reading_usage {
      usage = usage "\n" $0
      next
    }

    {
      reading_usage = 0
      help = help "\n" $0
    }

    function escape(str) {
      gsub(/[`\\$"]/, "\\\\&", str)
      return str
    }

    function trim(str) {
      sub(/^\n*/, "", str)
      sub(/\n*$/, "", str)
      return str
    }

    END {
      if (usage || summary) {
        print "summary=\"" escape(summary) "\""
        print "usage=\"" escape(trim(usage)) "\""
        print "help=\"" escape(trim(help)) "\""
      }
    }
  '
}

documentation_for() {
  local filename
  filename="$(command_path "$1")"
  if [ -n "$filename" ]; then
    extract_initial_comment_block < "$filename" | collect_documentation
  fi
}

print_summary() {
  local command="$1"
  local summary usage help
  eval "$(documentation_for "$command")"

  if [ -n "$summary" ]; then
    printf "   %-9s   %s\n" "$command" "$summary"
  fi
}

print_summaries() {
  for command; do
    print_summary "$command"
  done
}

print_help() {
  local command="$1"
  local summary usage help
  eval "$(documentation_for "$command")"
  [ -n "$help" ] || help="$summary"

  if [ -n "$usage" ] || [ -n "$summary" ]; then
    if [ -n "$usage" ]; then
      echo "$usage"
    else
      echo "Usage: pyenv ${command}"
    fi
    if [ -n "$help" ]; then
      echo
      echo "$help"
      echo
    fi
  else
    echo "Sorry, this command isn't documented yet." >&2
    return 1
  fi
}

print_usage() {
  local command="$1"
  local summary usage help
  eval "$(documentation_for "$command")"
  [ -z "$usage" ] || echo "$usage"
}

unset usage
if [ "$1" = "--usage" ]; then
  usage="1"
  shift
fi

if [ -z "$1" ] || [ "$1" == "pyenv" ]; then
  echo "Usage: pyenv <command> [<args>]"
  [ -z "$usage" ] || exit
  echo
  echo "Some useful pyenv commands are:"
  print_summaries $(exec pyenv-commands | sort -u)
  echo
  echo "See \`pyenv help <command>' for information on a specific command."
  echo "For full documentation, see: https://github.com/pyenv/pyenv#readme"
else
  command="$1"
  if [ -n "$(command_path "$command")" ]; then
    if [ -n "$usage" ]; then
      print_usage "$command"
    else
      print_help "$command"
    fi
  else
    echo "pyenv: no such command \`$command'" >&2
    exit 1
  fi
fi
