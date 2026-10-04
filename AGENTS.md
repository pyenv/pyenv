# AGENTS.md

## Project Overview

pyenv is a Bash (shell) project with a small C companion in `src/`, built via Makefile. It manages Python versions by installing and switching between different Python builds.

## Repository Structure
pyenv/
├── bin/ # User-facing executables
├── shims/ # Version-switch shims
├── plugins/ # Plugin system (python-build, etc.)
├── src/ # C extension for version detection
├── libexec/ # Shell implementation (core logic)
├── test/ # Bats test suite (26 test files)
└── Makefile # Build and test targets
## Development Setup

Clone the repository:
```bash
git clone https://github.com/pyenv/pyenv.git
cd pyenv
No additional installation needed; run directly or add `./bin` to your PATH.
Running Tests
make test                 # Run all Bats tests
make test-<test-name>    # Run specific test
The test suite uses [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).
Code Style
- Shell scripts: Follow POSIX shell conventions where possible, with bash-specific features where needed
- Naming: Use snake_case for variables and functions
- Comments: Document non-obvious logic; avoid stating the obvious
- C code (in `src/`): Keep minimal; use for performance-critical detection logic only
Contribution Workflow
Fork and create a feature branch
Make changes to shell scripts in `libexec/` or plugins
Run `make test` to validate
Submit a pull request with a clear description
Key Commands
- `make` - Build C extension
- `make test` - Run full Bats test suite
- `make install` - Install to prefix
- `./bin/pyenv versions` - List installed Python versions
Testing Guidelines
- Write Bats tests for new features in `test/`
- Each test file focuses on a specific subsystem
- Use `bats-core` assertions and helpers
- Ensure all tests pass before submitting PRs
Plugin Development
pyenv's plugin system allows extending functionality:
- Place plugins in `plugins/<plugin-name>/`
- Document expected hooks and environment variables
- Follow shell script conventions from the main codebase
Conventions
- Branches: Use `feature/` prefix for new features, `fix/` for fixes
- Commits: Write clear, descriptive messages
- PRs: Reference related issues; include testing notes
