#!/usr/bin/env zsh
# profile-rehash.sh — timestamp-annotated xtrace of pyenv-rehash
#
# Usage:
#   ./bench/profile-rehash.sh <pyenv-root>
#
# Runs pyenv-rehash with PYENV_DEBUG=1, pipes xtrace through perl to
# prepend microsecond timestamps, then produces:
#   1. Raw timestamped trace (for inspection)
#   2. Summary: top time-consuming gaps between consecutive lines
#   3. Phase breakdown: time spent in each logical section
#
# Requires: perl (with Time::HiRes), bash 3.2+

set -euo pipefail

PYENV_ROOT="${1:?Usage: profile-rehash.sh <pyenv-root>}"
SCRIPT_DIR="${0:A:h}"
RESULTS_DIR="${SCRIPT_DIR}/results"
mkdir -p "$RESULTS_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
RAW_TRACE="${RESULTS_DIR}/${TS}-profile-raw.txt"
SUMMARY="${RESULTS_DIR}/${TS}-profile-summary.txt"

echo "Profiling pyenv-rehash in ${PYENV_ROOT}/"

# ── Clean up shims from prior runs ──────────────────────────────────
rm -rf "${PYENV_ROOT}/shims"
mkdir -p "${PYENV_ROOT}/shims"

# ── Run rehash with xtrace, timestamp each line ─────────────────────
#
# PYENV_DEBUG=1 sets `set -x` in every pyenv script.
# Bash 3.2 sends xtrace to stderr. We pipe stderr through perl
# which prepends a microsecond timestamp to each line.
#
# The 2>&1 trick: run bash with stderr redirected to a pipe, then
# perl timestamps each line.

export PYENV_ROOT
export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/libexec:$PATH"

# We need to capture stderr (xtrace) separately from stdout.
# Strategy: redirect stderr to fd 3, pipe fd 3 through perl.
{
  PYENV_DEBUG=1 bash "${PYENV_ROOT}/libexec/pyenv-rehash" 2>&1 1>/dev/null
} | perl -MTime::HiRes=gettimeofday -ne '
  my ($s, $us) = gettimeofday();
  printf "%d.%06d %s", $s, $us, $_;
' > "$RAW_TRACE"

LINES=$(wc -l < "$RAW_TRACE" | tr -d ' ')
echo "Captured ${LINES} trace lines"

# ── Analyze: compute deltas between consecutive lines ───────────────

perl -e '
  use strict;
  use warnings;

  my @lines;
  my $prev_ts = 0;

  # Read all lines with timestamps
  open my $fh, "<", $ARGV[0] or die "Cannot open $ARGV[0]: $!";
  while (<$fh>) {
    if (/^(\d+\.\d+)\s+(.*)/) {
      my ($ts, $content) = ($1, $2);
      my $delta = 0;
      if ($prev_ts > 0) {
        $delta = ($ts - $prev_ts) * 1_000_000;  # microseconds
      }
      push @lines, { ts => $ts, delta => $delta, content => $content, line => $. };
      $prev_ts = $ts;
    }
  }
  close $fh;

  my $total_lines = scalar @lines;
  return unless $total_lines > 1;

  my $total_us = ($lines[-1]{ts} - $lines[0]{ts}) * 1_000_000;

  # ── Top 30 gaps ──────────────────────────────────────────────────
  my @sorted = sort { $b->{delta} <=> $a->{delta} } @lines;

  print "=" x 70, "\n";
  printf "PYENV-REHASH PROFILE — total: %.1f ms, %d trace lines\n",
    $total_us / 1000, $total_lines;
  print "=" x 70, "\n\n";

  print "TOP 30 GAPS (time between consecutive trace lines)\n";
  print "-" x 70, "\n";
  printf "%-10s %-6s  %s\n", "delta", "line", "trace content";
  print "-" x 70, "\n";

  my $shown = 0;
  for my $l (@sorted) {
    last if $shown >= 30;
    last if $l->{delta} < 50;  # skip sub-50µs gaps
    printf "%7.0f µs  L%-4d  %.100s\n",
      $l->{delta}, $l->{line}, $l->{content};
    $shown++;
  }

  # ── Phase breakdown ──────────────────────────────────────────────
  # Identify phases by looking for key function/command patterns
  print "\n\n";
  print "PHASE BREAKDOWN\n";
  print "-" x 70, "\n";

  my %phases;
  my $current_phase = "startup";
  my $phase_start = $lines[0]{ts};

  for my $l (@lines) {
    my $c = $l->{content};
    my $new_phase;

    if ($c =~ /create_prototype_shim/) {
      $new_phase = "create_prototype_shim";
    } elsif ($c =~ /remove_outdated_shims/) {
      $new_phase = "remove_outdated_shims";
    } elsif ($c =~ /list_executable_names|pyenv-versions/) {
      $new_phase = "list_executable_names";
    } elsif ($c =~ /make_shims/) {
      $new_phase = "make_shims";
    } elsif ($c =~ /pyenv-hooks/) {
      $new_phase = "hooks";
    } elsif ($c =~ /install_registered_shims/) {
      $new_phase = "install_registered_shims";
    } elsif ($c =~ /remove_stale_shims/) {
      $new_phase = "remove_stale_shims";
    }

    if (defined $new_phase && $new_phase ne $current_phase) {
      my $elapsed = ($l->{ts} - $phase_start) * 1_000_000;
      $phases{$current_phase} = ($phases{$current_phase} || 0) + $elapsed;
      $current_phase = $new_phase;
      $phase_start = $l->{ts};
    }
  }
  # Close last phase
  my $elapsed = ($lines[-1]{ts} - $phase_start) * 1_000_000;
  $phases{$current_phase} = ($phases{$current_phase} || 0) + $elapsed;

  # Print phases sorted by time
  for my $p (sort { $phases{$b} <=> $phases{$a} } keys %phases) {
    printf "  %7.1f ms  (%4.1f%%)  %s\n",
      $phases{$p} / 1000,
      ($phases{$p} / $total_us) * 100,
      $p;
  }
  printf "\n  %7.1f ms  (total)\n", $total_us / 1000;

  # ── External command summary ─────────────────────────────────────
  print "\n\n";
  print "EXTERNAL COMMANDS (from xtrace)\n";
  print "-" x 70, "\n";

  my %cmds;
  my %cmd_time;
  for my $l (@lines) {
    my $c = $l->{content};
    # Match commands at start of xtrace line (after + markers)
    if ($c =~ /^\+*\s*([\w\/-]+)(?:\s|$)/) {
      my $cmd = $1;
      # Filter to known external commands
      if ($cmd =~ /^(sort|uniq|bash|cat|sed|diff|cp|rm|mkdir|mktemp|chmod|readlink|realpath|wc|head|tail|printf|echo|read|test|true|false|shopt|local|declare|for|while|if|set|export|eval|source|command|type|enable|pyenv[\w-]*)$/) {
        if ($cmd =~ /^(sort|uniq|bash|cat|sed|diff|cp|rm|mkdir|mktemp|chmod|readlink|realpath|wc|head|tail|pyenv[\w-]*)$/) {
          $cmds{$cmd}++;
          $cmd_time{$cmd} = ($cmd_time{$cmd} || 0) + $l->{delta};
        }
      }
    }
  }

  printf "%-20s %6s  %10s\n", "command", "count", "assoc. µs";
  print "-" x 40, "\n";
  for my $c (sort { $cmd_time{$b} <=> $cmd_time{$a} } keys %cmds) {
    printf "%-20s %6d  %10.0f\n", $c, $cmds{$c}, $cmd_time{$c};
  }

' "$RAW_TRACE" | tee "$SUMMARY"

echo ""
echo "Raw trace:  ${RAW_TRACE}"
echo "Summary:    ${SUMMARY}"
