#!/usr/bin/env bash
# Summary: Print the latest installed or known version with the given prefix
# Usage: pyenv latest [-k|--known] <prefix>
#
#   -k/--known      Select from all known versions instead of installed
#   -b/--bypass     (internal) On a resolution failure, do not print an error message
#                   but rather print the argument unchanged
#   -f/--force      (internal) Same as -b but also do not return a failure exit code

set -e
[ -n "$PYENV_DEBUG" ] && set -x

while [[ $# -gt 0 ]]
do
    case "$1" in
        -k|--known)
            FROM_KNOWN=1
            shift
            ;;
        -b|--bypass)
            BYPASS=1
            shift
            ;;
        -f|--force)
            FORCE=1
            BYPASS=1
            shift
            ;;
        *)
            break
            ;;
    esac
done

prefix=$1
exitcode=0

IFS=$'\n'

    if [[ -z $FROM_KNOWN ]]; then
        DEFINITION_CANDIDATES=( $(pyenv-versions --bare --skip-envs) )
    else
        DEFINITION_CANDIDATES=( $(python-build --definitions ) )
    fi
    
    if printf '%s\n' "${DEFINITION_CANDIDATES[@]}" 2>/dev/null | grep -qxFe "$prefix"; then
        echo "$prefix"
        exit $exitcode;
    fi
    
    suffix=""
    if [[ $prefix =~ ^(.*[0-9])t$ ]]; then
        suffix="t"
        prefix="${BASH_REMATCH[1]}"
    fi
    
    # https://stackoverflow.com/questions/11856054/is-there-an-easy-way-to-pass-a-raw-string-to-grep/63483807#63483807 
    prefix_re="$(sed 's/[^\^]/[&]/g;s/[\^]/\\&/g' <<< "$prefix")"
    suffix_re="$(sed 's/[^\^]/[&]/g;s/[\^]/\\&/g' <<< "$suffix")"
    # FIXME: more reliable and readable would probably be to loop over them and transform in pure Bash
    DEFINITION_CANDIDATES=(\
      $(printf '%s\n' "${DEFINITION_CANDIDATES[@]}" | \
      grep -Ee "^$prefix_re[-.].*$suffix_re\$" || true))

    DEFINITION_CANDIDATES=(\
        $(printf '%s\n' "${DEFINITION_CANDIDATES[@]}" | \
          sed -E -e '/-dev$/d' -e '/-src$/d' -e '/-latest$/d' -e '/(a|b|rc)[0-9]+$/d' \
            $(if [[ -z $suffix ]]; then echo "-e /[0-9]t\$/d"; fi)
        ));

    # Compose a sorting key, followed by | and original value
    DEFINITION_CANDIDATES=(\
        $(printf '%s\n' "${DEFINITION_CANDIDATES[@]}" | \
          awk \
            '{ if (match($0,"^[[:alnum:]]+-"))
               { print substr($0,0,RLENGTH-1) "." substr($0,RLENGTH+1) "..|" $0; }
             else
               { print $0 "...|" $0; }
             }'))
    DEFINITION_CANDIDATES=(\
        $(printf '%s\n' "${DEFINITION_CANDIDATES[@]}" \
          | sort -t. -k1,1r -k 2,2nr -k 3,3nr -k4,4nr \
          | cut -f2 -d $'|' \
        || true))
    DEFINITION="${DEFINITION_CANDIDATES[0]}"

    if [[ -n "$DEFINITION" ]]; then
        echo "$DEFINITION"
    else
        if [[ -z $BYPASS ]]; then
            echo "pyenv: no $([[ -z $FROM_KNOWN ]] && echo installed || echo known) versions match the prefix \`$prefix'" >&2
        else
            echo "$prefix"
        fi
        if [[ -z $FORCE ]]; then
            exitcode=1
        fi
    fi

exit $exitcode
