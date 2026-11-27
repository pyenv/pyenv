#!/usr/bin/env zsh
# bench.sh — benchmark pyenv shell init time
#
# Usage:
#   ./bench/bench.sh                    # compare upstream/ vs working/, 20 iterations
#   ./bench/bench.sh -n 50              # 50 iterations
#   ./bench/bench.sh -s upstream        # only benchmark upstream/
#   ./bench/bench.sh --shell bash       # use bash instead of zsh
#   ./bench/bench.sh --no-rehash        # pass --no-rehash to pyenv init
#   ./bench/bench.sh --count-forks      # count subprocess spawns instead of timing
#
# What it measures:
#   The full cost of `eval "$(pyenv init - <shell>)"` — both the code generation
#   subprocess (pyenv init) and the eval execution (PATH dedup, rehash, etc).
#   Time is measured inside the spawned shell to exclude shell startup overhead.
#
# Writes results to bench/results/ with a timestamp.

set -euo pipefail

# ── defaults ──────────────────────────────────────────────────────────
ITERATIONS=20
TARGETS=(upstream working)
BENCH_SHELL=zsh
PYENV_INIT_FLAGS=""
COUNT_FORKS=0
SCRIPT_DIR="${0:A:h}"
REPO_DIR="${SCRIPT_DIR:h}"
RESULTS_DIR="${SCRIPT_DIR}/results"

# ── parse args ────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n)              ITERATIONS="$2"; shift 2 ;;
    -s)              if [[ "${TARGETS_SET:-}" != 1 ]]; then TARGETS=(); TARGETS_SET=1; fi
                     TARGETS+=("$2"); shift 2 ;;
    --shell)         BENCH_SHELL="$2"; shift 2 ;;
    --no-rehash)     PYENV_INIT_FLAGS="--no-rehash"; shift ;;
    --flags)         PYENV_INIT_FLAGS="$2"; shift 2 ;;
    --count-forks)   COUNT_FORKS=1; shift ;;
    -h|--help)
      sed -n '2,/^$/s/^# //p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── helpers ───────────────────────────────────────────────────────────

# Median of a sorted array (passed as arguments)
median() {
  local -a vals=("$@")
  local n=${#vals[@]}
  local mid=$(( n / 2 ))
  if (( n % 2 == 1 )); then
    printf '%s' "${vals[$((mid + 1))]}"
  else
    printf '%s' "$(( (${vals[$mid]} + ${vals[$((mid + 1))]}) / 2 ))"
  fi
}

# p95 of a sorted array
p95() {
  local -a vals=("$@")
  local n=${#vals[@]}
  local idx=$(( (n * 95 + 99) / 100 ))
  (( idx > n )) && idx=$n
  printf '%s' "${vals[$idx]}"
}

# Format microseconds as milliseconds with 1 decimal
fmt_ms() {
  local us="$1"
  local ms_int=$(( us / 1000 ))
  local ms_frac=$(( (us % 1000) / 100 ))
  printf '%d.%d ms' "$ms_int" "$ms_frac"
}

# Shell-appropriate flag to skip rc files (isolate measurement from user config)
norc_flag() {
  case "$1" in
    zsh)  echo "--no-rcs" ;;
    bash) echo "--norc" ;;
    *)    echo "--norc" ;;
  esac
}

# Ensure the results directory exists
mkdir -p "$RESULTS_DIR"

# ── build bench command ───────────────────────────────────────────────

# Build the shell command that runs `eval "$(pyenv init - <shell>)"` and
# measures elapsed time. We measure *inside* the spawned shell to exclude
# the shell's own startup overhead.
make_bench_cmd() {
  local pyenv_root="$1"
  local init_flags="$2"
  local shell="$3"

  if [[ "$shell" == "zsh" ]]; then
    # zsh has $EPOCHREALTIME (microsecond precision, no forks)
    cat <<EOZCMD
zmodload zsh/datetime
local _t0=\$EPOCHREALTIME
export PYENV_ROOT="$pyenv_root"
export PATH="$pyenv_root/bin:\$PATH"
eval "\$(pyenv init - zsh $init_flags)"
local _t1=\$EPOCHREALTIME
printf '%d' "\$(( (\$_t1 - \$_t0) * 1000000 ))"
EOZCMD
  else
    # macOS bash 3.2 lacks EPOCHREALTIME; use python3 for sub-ms timing
    cat <<EOBCMD
_t0=\$(python3 -c 'import time; print(int(time.time()*1000000))')
export PYENV_ROOT="$pyenv_root"
export PATH="$pyenv_root/bin:\$PATH"
eval "\$(pyenv init - bash $init_flags)"
_t1=\$(python3 -c 'import time; print(int(time.time()*1000000))')
printf '%d' "\$(( _t1 - _t0 ))"
EOBCMD
  fi
}

# ── fork counting ─────────────────────────────────────────────────────

# pyenv's architecture makes fork counting harder than nvm: each libexec
# script is a separate bash process invoked via exec. PYENV_DEBUG=1 sets
# `set -x` in every script, so xtrace spans all pyenv-internal processes.
# But subprocesses like `sort`, `bash --norc`, etc. don't produce xtrace.
#
# Strategy: combine PYENV_DEBUG xtrace (to see which scripts invoke what)
# with direct grep for known external command patterns in the trace output.

make_fork_cmd() {
  local pyenv_root="$1"
  local init_flags="$2"
  local shell="$3"

  cat <<EOFCMD
export PYENV_ROOT="$pyenv_root"
export PATH="$pyenv_root/bin:\$PATH"
export PYENV_DEBUG=1
eval "\$(pyenv init - $shell $init_flags)"
EOFCMD
}

# Count subprocess-spawning patterns in xtrace output.
# This catches: exec, command substitution $(), pipes to external commands.
# It's a lower bound — some forks are invisible to xtrace.
count_forks_in_trace() {
  local trace_file="$1"

  # Known external commands that pyenv invokes during init
  local FORK_CMDS='(sort|uniq|bash|cat|sed|diff|cp|rm|mkdir|mktemp|sleep|readlink|pyenv|pyenv-commands|pyenv-init|pyenv-rehash|pyenv-versions|pyenv-hooks)'

  local count
  count=$(grep -oE "(^|\s)${FORK_CMDS}(\s|$)" "$trace_file" \
    | awk '{$1=$1}1' \
    | grep -cE "^${FORK_CMDS}$" 2>/dev/null) || count=0
  echo "$count"
}

# Breakdown of which commands were forked and how many times.
fork_breakdown() {
  local trace_file="$1"
  local FORK_CMDS='(sort|uniq|bash|cat|sed|diff|cp|rm|mkdir|mktemp|sleep|readlink|pyenv|pyenv-commands|pyenv-init|pyenv-rehash|pyenv-versions|pyenv-hooks)'

  grep -oE "(^|\s)${FORK_CMDS}(\s|$)" "$trace_file" \
    | awk '{$1=$1}1' \
    | grep -E "^${FORK_CMDS}$" \
    | sort | uniq -c | sort -rn \
    | head -20
}

# A more reliable approach: count unique process spawns by looking for
# shebang invocations and exec patterns in the PYENV_DEBUG trace.
# Each `+(filename:line): ` prefix with a *different* filename indicates
# a new bash process.
count_script_invocations() {
  local trace_file="$1"
  # Extract unique script filenames from xtrace prefixes
  # Format: +(path/to/script:line): ...
  grep -oE '\+\([^:]+:' "$trace_file" \
    | sed 's/^+(//' | sed 's/:$//' \
    | sort -u
}

# Run fork counting mode
count_forks() {
  echo "pyenv-tune fork count"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "shell:   $BENCH_SHELL"
  echo "flags:   ${PYENV_INIT_FLAGS:-"(none — default init)"}"
  echo "targets: ${TARGETS[*]}"
  echo ""

  local ts="$(date +%Y%m%d-%H%M%S)"
  local results_file="${RESULTS_DIR}/${ts}-forks.txt"

  {
    echo "pyenv-tune fork count — $(date)"
    echo "shell: $BENCH_SHELL | flags: ${PYENV_INIT_FLAGS:-"(default)"}"
    echo "note: lower bound — not all forks are visible to xtrace"
    echo ""
  } > "$results_file"

  local pyenv_root fork_cmd trace_file

  for target in "${TARGETS[@]}"; do
    pyenv_root="${REPO_DIR}/${target}"

    if [[ ! -d "${pyenv_root}/libexec" ]]; then
      echo "ERROR: ${pyenv_root}/libexec not found — is this a pyenv checkout?" >&2
      exit 1
    fi

    echo "▸ Counting forks: ${target}/"

    fork_cmd="$(make_fork_cmd "$pyenv_root" "$PYENV_INIT_FLAGS" "$BENCH_SHELL")"
    trace_file="$(mktemp)"

    # Run with PYENV_DEBUG, which sets xtrace in all pyenv scripts.
    # stderr gets the xtrace output from pyenv scripts.
    # The eval'd shell also inherits PYENV_DEBUG (pyenv exports it).
    "$BENCH_SHELL" "$(norc_flag "$BENCH_SHELL")" -c "$fork_cmd" > /dev/null 2>"$trace_file"

    echo ""
    echo "  Scripts invoked (each = 1 bash fork):"
    local scripts
    scripts="$(count_script_invocations "$trace_file")"
    local script_count
    script_count=$(echo "$scripts" | wc -l | tr -d ' ')
    echo "$scripts" | while read -r s; do
      echo "    · $s"
    done
    echo "  Total script invocations: $script_count"

    echo ""
    echo "  External command breakdown (from xtrace):"
    fork_breakdown "$trace_file" | while read -r line; do
      echo "    $line"
    done

    echo ""

    {
      echo "${target}/"
      echo "  Scripts invoked:"
      echo "$scripts" | while read -r s; do
        echo "    $s"
      done
      echo "  Total script invocations: $script_count"
      echo ""
      echo "  External command breakdown:"
      fork_breakdown "$trace_file"
      echo ""
    } >> "$results_file"

    rm -f "$trace_file"
  done

  echo "results saved to: ${results_file}"
}

# ── timing mode ───────────────────────────────────────────────────────

main() {
  if (( COUNT_FORKS )); then
    count_forks
    return
  fi

  echo "pyenv-tune bench"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "shell:      $BENCH_SHELL"
  echo "iterations: $ITERATIONS"
  echo "flags:      ${PYENV_INIT_FLAGS:-"(none — default init)"}"
  echo "targets:    ${TARGETS[*]}"
  echo ""

  local ts="$(date +%Y%m%d-%H%M%S)"
  local results_file="${RESULTS_DIR}/${ts}.txt"

  {
    echo "pyenv-tune bench — $(date)"
    echo "shell: $BENCH_SHELL | iterations: $ITERATIONS | flags: ${PYENV_INIT_FLAGS:-"(default)"}"
    echo ""
  } > "$results_file"

  declare -A result_min result_med result_p95 result_max result_mean
  local pyenv_root bench_cmd min max med mean p95_val sum i us t
  local -a timings

  for target in "${TARGETS[@]}"; do
    pyenv_root="${REPO_DIR}/${target}"

    if [[ ! -d "${pyenv_root}/libexec" ]]; then
      echo "ERROR: ${pyenv_root}/libexec not found — is this a pyenv checkout?" >&2
      exit 1
    fi

    echo "▸ Benchmarking: ${target}/"
    echo "  warming up..."

    # Warmup (3 runs, discarded — pyenv rehash creates shims on first run)
    bench_cmd="$(make_bench_cmd "$pyenv_root" "$PYENV_INIT_FLAGS" "$BENCH_SHELL")"
    for _ in 1 2 3; do
      "$BENCH_SHELL" "$(norc_flag "$BENCH_SHELL")" -c "$bench_cmd" > /dev/null 2>&1
    done

    echo "  running ${ITERATIONS} iterations..."

    timings=()
    for i in $(seq 1 "$ITERATIONS"); do
      us="$("$BENCH_SHELL" "$(norc_flag "$BENCH_SHELL")" -c "$bench_cmd" 2>/dev/null)"
      timings+=("$us")
      if (( i % 5 == 0 )); then
        printf '  %d/%d\n' "$i" "$ITERATIONS"
      fi
    done

    # Sort (zsh numeric sort)
    timings=(${(n)timings})

    # Stats
    min="${timings[1]}"
    max="${timings[-1]}"
    sum=0
    for t in "${timings[@]}"; do
      sum=$(( sum + t ))
    done
    mean=$(( sum / ${#timings[@]} ))
    med="$(median "${timings[@]}")"
    p95_val="$(p95 "${timings[@]}")"

    result_min[$target]="$min"
    result_med[$target]="$med"
    result_p95[$target]="$p95_val"
    result_max[$target]="$max"
    result_mean[$target]="$mean"

    echo ""
    echo "  ${target}/"
    echo "    min:    $(fmt_ms "$min")"
    echo "    median: $(fmt_ms "$med")"
    echo "    mean:   $(fmt_ms "$mean")"
    echo "    p95:    $(fmt_ms "$p95_val")"
    echo "    max:    $(fmt_ms "$max")"
    echo ""

    {
      echo "${target}/"
      echo "  min:    $(fmt_ms "$min")"
      echo "  median: $(fmt_ms "$med")"
      echo "  mean:   $(fmt_ms "$mean")"
      echo "  p95:    $(fmt_ms "$p95_val")"
      echo "  max:    $(fmt_ms "$max")"
      echo "  raw (µs): ${timings[*]}"
      echo ""
    } >> "$results_file"
  done

  # ── comparison ──────────────────────────────────────────────────────

  if (( ${#TARGETS[@]} == 2 )); then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "comparison (median)"

    local a="${TARGETS[1]}" b="${TARGETS[2]}"
    local a_med="${result_med[$a]}"
    local b_med="${result_med[$b]}"

    if (( a_med > 0 )); then
      local diff_us=$(( a_med - b_med ))
      local abs_diff_us=${diff_us#-}
      local pct=$(( (abs_diff_us * 100) / a_med ))
      local label
      if (( diff_us > 0 )); then
        label="faster"
      elif (( diff_us < 0 )); then
        label="slower"
      else
        label="same"
      fi

      echo "  ${a}: $(fmt_ms "$a_med")"
      echo "  ${b}: $(fmt_ms "$b_med")"
      if [[ "$label" == "same" ]]; then
        echo "  delta:    0 ms (identical)"
      else
        echo "  delta:    $(fmt_ms "$abs_diff_us") ${label} (${pct}%)"
      fi

      {
        echo "comparison (median)"
        echo "  ${a}: $(fmt_ms "$a_med")"
        echo "  ${b}: $(fmt_ms "$b_med")"
        if [[ "$label" == "same" ]]; then
          echo "  delta:    0 ms (identical)"
        else
          echo "  delta:    $(fmt_ms "$abs_diff_us") ${label} (${pct}%)"
        fi
      } >> "$results_file"
    fi

    echo ""
  fi

  echo "results saved to: ${results_file}"
}

main
