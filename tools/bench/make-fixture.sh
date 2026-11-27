#!/usr/bin/env bash
# make-fixture.sh — create a realistic pyenv versions/ layout for profiling
#
# Usage:
#   ./bench/make-fixture.sh <pyenv-root> [--large]
#
# Creates:
#   - 3 real Python versions (3.10.0, 3.11.0, 3.12.0) with typical bin/ executables
#   - 1 alias (symlink from 3 -> 3.12.0, the --skip-aliases case)
#   - 12 virtualenvs under versions/3.12.0/envs/ (the pyenv-virtualenv layout)
#   - Each virtualenv gets 15-25 executables (popular packages)
#
# With --large:
#   - 6 Python versions
#   - 30 virtualenvs (10 per version)
#   - Stress test for native-api's "dozens of virtualenvs" scenario
#
# Idempotent: removes and recreates the versions/ directory.

set -euo pipefail

PYENV_ROOT="${1:?Usage: make-fixture.sh <pyenv-root> [--large]}"
LARGE=0
[[ "${2:-}" == "--large" ]] && LARGE=1

VERSIONS_DIR="${PYENV_ROOT}/versions"

# Clean slate
rm -rf "$VERSIONS_DIR"
mkdir -p "$VERSIONS_DIR"

# Common Python executables (present in every version)
PYTHON_BINS=(
  python python3 pip pip3 wheel
  python3-config idle3 pydoc3 2to3
  easy_install easy_install-3
)

# Additional executables that show up when popular packages are installed
VENV_BINS_POOL=(
  pytest py.test coverage black isort flake8 mypy
  pylint autopep8 yapf bandit pyflakes pep8
  ipython jupyter jupyter-notebook jupyter-lab
  sphinx-build sphinx-quickstart sphinx-apidoc
  gunicorn uvicorn hypercorn daphne
  celery flask django-admin
  pip pip3 python python3 wheel
  activate activate.csh activate.fish
  easy_install setuptools
  chardetect normalizer dulwich
  tox nox pre-commit
)

# Create a version directory with standard Python bins
make_version() {
  local ver="$1"
  local dir="${VERSIONS_DIR}/${ver}/bin"
  mkdir -p "$dir"
  for bin in "${PYTHON_BINS[@]}"; do
    touch "$dir/$bin"
    chmod +x "$dir/$bin"
  done
}

# Create a virtualenv directory with a subset of bins
make_venv() {
  local parent_ver="$1"
  local venv_name="$2"
  local num_bins="$3"
  local dir="${VERSIONS_DIR}/${parent_ver}/envs/${venv_name}/bin"
  mkdir -p "$dir"

  # Always include python/pip
  touch "$dir/python" "$dir/python3" "$dir/pip" "$dir/pip3"
  chmod +x "$dir/python" "$dir/python3" "$dir/pip" "$dir/pip3"

  # Add random selection from pool
  local count=0
  for bin in "${VENV_BINS_POOL[@]}"; do
    if (( count >= num_bins )); then
      break
    fi
    touch "$dir/$bin"
    chmod +x "$dir/$bin"
    count=$((count + 1))
  done
}

# ── Build the fixture ────────────────────────────────────────────────

if (( LARGE )); then
  VERSIONS=(3.9.0 3.10.0 3.10.5 3.11.0 3.11.7 3.12.0)
  VENVS_PER_VERSION=10
else
  VERSIONS=(3.10.0 3.11.0 3.12.0)
  VENVS_PER_VERSION=4
fi

for ver in "${VERSIONS[@]}"; do
  make_version "$ver"
done

# Create alias: "3" -> 3.12.0 (symlink, should be skipped by --skip-aliases)
ln -s "3.12.0" "${VERSIONS_DIR}/3"

# Create an external symlink: "system-link" -> /usr/bin (should NOT be skipped
# by --skip-aliases since it points outside versions_dir)
mkdir -p "${VERSIONS_DIR}/external-build/bin"
for bin in python python3 pip pip3; do
  touch "${VERSIONS_DIR}/external-build/bin/$bin"
  chmod +x "${VERSIONS_DIR}/external-build/bin/$bin"
done
ln -s "${VERSIONS_DIR}/external-build" "${VERSIONS_DIR}/system-linked"

# Create virtualenvs
VENV_NAMES=(
  myproject web-api data-pipeline ml-training
  docs-site cli-tool test-runner lint-env
  notebook jupyter-work analysis viz-dash
  scraper etl-job monitoring deploy-tools
  dev staging prod benchmarks
  experiment-1 experiment-2 experiment-3 experiment-4
  legacy-app migration-tool compat-layer sdk-dev
)

venv_idx=0
for ver in "${VERSIONS[@]}"; do
  for i in $(seq 1 "$VENVS_PER_VERSION"); do
    venv_name="${VENV_NAMES[$venv_idx]}"
    # Vary the number of executables (15-25)
    num_bins=$(( 15 + (venv_idx % 11) ))
    make_venv "$ver" "$venv_name" "$num_bins"
    venv_idx=$((venv_idx + 1))
    if (( venv_idx >= ${#VENV_NAMES[@]} )); then
      venv_idx=0
    fi
  done

  # Also create symlinks from envs back to versions/ (pyenv-virtualenv does this)
  for env_dir in "${VERSIONS_DIR}/${ver}/envs/"*/; do
    [ -d "$env_dir" ] || continue
    env_name="$(basename "$env_dir")"
    # pyenv-virtualenv creates: versions/<venv-name> -> versions/<ver>/envs/<venv-name>
    ln -s "${ver}/envs/${env_name}" "${VERSIONS_DIR}/${env_name}" 2>/dev/null || true
  done
done

# Summary
version_count=$(ls -1d "${VERSIONS_DIR}"/*/  2>/dev/null | wc -l | tr -d ' ')
symlink_count=$(find "${VERSIONS_DIR}" -maxdepth 1 -type l | wc -l | tr -d ' ')
real_count=$((version_count - symlink_count))
venv_count=$(find "${VERSIONS_DIR}" -path "*/envs/*" -maxdepth 4 -mindepth 4 -type d | wc -l | tr -d ' ')
total_bins=$(find "${VERSIONS_DIR}" -path "*/bin/*" -type f | wc -l | tr -d ' ')

echo "Fixture created in ${VERSIONS_DIR}/"
echo "  Real versions:  ${real_count}"
echo "  Aliases (links): ${symlink_count}"
echo "  Virtualenvs:    ${venv_count}"
echo "  Total binaries: ${total_bins}"
echo "  Top-level dirs: ${version_count}"
