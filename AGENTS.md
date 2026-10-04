

# AGENTS.md

Context file for AI agents working on pyenv.

**Dual Format**: This file combines Category A (Operations Manual) and Category B (Context Guide) for comprehensive agent guidance.

## Project Overview

pyenv is a Shell project using Makefile.

**Key Info:**
- **Primary Language:** Shell
- **Build System:** Makefile
- **Test Framework:** Bats
- **Total Files:** 1762
- **Test Files:** 66
- **AI Readiness Score:** 70/100 (AI-Native)

---

## 🚨 AI Policy & Operations

Extracted from CONTRIBUTING.md - operational constraints and procedures.

### AI Policy

- The usual principles of respecting existing conventions and making sure that your changes
- Must not break or degrade (e.g. disable features) the build in any of the environments that the release officially supports
- Must not introduce incompatibilities with the vanilla release (including binary incompatibilities)
- Deprecation policy
- Such a fix must not add maintenance burden (e.g. add new logic to `python-build` that has to be kept there indefinitely)

### Key Requirements

- In addition to the above requirements for release-specific fixes,
- 1. Select the source to download and other variable parameters as needed.

### Development Procedures

- We strive to keep commit history one-concern-per-commit to keep it meaningful and easy to follow.
- If a pull request (PR) addresses a single concern (the typical case), we usually squash commits
- from it together when merging so its commit history doesn't matter.
- If however a PR addresses multiple separate concerns, each of them should be presented as a separate commit.
- Adding multiple new Python releases of the same flavor is okay with either a single or multiple commits.



## 🏗️ Architecture & Context Guide

This section provides architectural context and agent-understanding for the codebase.

### Prerequisites

- **Shell:** None (or applicable language version)

- **Test Runner:** Bats



### Project Structure

```
pyenv/
├── Makefile
├── src/                  # Source code
├── tests/                # Test suite (66 files)
└── README.md             # Project documentation
```

### Architecture Overview

#### Key Components
- **Main Entry:** Standard layout
- **Test Suite:** 66 test files
- **Build Configuration:** Makefile
- **Build Command:** cd ~/.pyenv && src/configure && make -C src

#### Design Principles

1. **Modularity** - Code organized by functionality with clear separation of concerns
2. **Testability** - Comprehensive test coverage across critical paths
3. **Clarity** - Explicit naming and structure for AI agent understanding
4. **Consistency** - Uniform patterns and conventions throughout codebase
5. **Maintainability** - Well-documented code with clear intent

### Directory Map

| Directory | Purpose |
|-----------|----------|
| `src/` | Source code |
| `test/` | Test suite |


### Development Workflow

#### Initial Setup

```bash
git clone https://github.com/jaykrishna316/pyenv
cd pyenv
# Add ./bin to your PATH
export PATH="$PWD/bin:$PATH"
```

#### Development Commands

**Running Tests:**
```bash
make test                 # Run all Bats tests
BATS_FILE_FILTER=test-<name>.bats make test  # Run specific test
```

#### Code Quality
```bash
shellcheck ./bin/* ./libexec/* ./plugins/*/bin/* ./plugins/*/libexec/* ./completions/*.bash ./pyenv.d/*/*.bash  # Lint shell scripts
chmod +x ./bin/*         # Ensure scripts executable
```

### Code Style & Conventions

- **Naming:** Use Shell conventions (snake_case for functions, PascalCase for classes)
- **Type Hints:** Not applicable (Shell scripts don't support type hints) (strongly encouraged)
- **Error Handling:** Yes (check exit status of commands) - handle errors at boundaries; let exceptions propagate when another layer owns recovery
- **Logging:** Yes
- **Testing:** Yes - write tests alongside code changes

### Testing Strategy

**Framework:** Bats
**Test Files:** 66 found

Before committing:
1. Run the full Bats test suite: `make test`
2. Lint all shell scripts: `shellcheck ./bin/* ./libexec/* ./plugins/*/bin/* ./plugins/*/libexec/* ./completions/*.bash ./pyenv.d/*/*.bash`
3. Verify scripts are executable: `ls -la ./bin/`
4. Test locally to confirm behavior

### Writing Documentation

When updating docs:
1. Always include explanatory text before code snippets
2. Describe *why* and *what* before showing *how*
3. Keep sections focused on a single concept
4. Use clear, concrete examples

## Known Gotchas & Warnings

- Note: `src/configure && make -C src` builds optional C extension; root `make` may run Docker tests

### Contributing Guidelines

This project has a detailed contribution guide at **`CONTRIBUTING.md`**.

**Key Requirements:**
- **Performance Work**: Requires benchmarks and performance metrics in PR description

**Before submitting:**
1. Read `CONTRIBUTING.md` in full
2. Check recent merged PRs for patterns
3. Follow the specific requirements above

### Common Patterns

When contributing to this project:
1. Read existing code in the area you're modifying
2. Follow the established patterns and style
3. Write tests for new functionality
4. Use clear, descriptive variable and function names
5. Add docstrings for public APIs
6. Update tests when changing behavior

### What We Value

✅ Well-tested code with clear intent
✅ Consistent code style and naming conventions
✅ Code that is easy for AI agents to understand
✅ Clear, descriptive commit messages
✅ Modular, reusable components
✅ Comprehensive documentation

### What We Avoid

❌ Large functions doing multiple things
❌ Commented-out dead code
❌ Inconsistent naming or patterns
❌ Unclear error messages
❌ Unexplained magic numbers or strings
❌ Skipped tests or test TODOs

### AI Readiness Dimensions (Scoring)

This project is evaluated across 8 dimensions:

1. **Architecture** (10/100) - Code organization and modularity
2. **Testing** (15/100) - Test coverage and quality
3. **Dependencies** (12/100) - Dependency management
4. **Conventions** (6/100) - Consistent patterns
5. **Entry Points** (4/100) - Clear main/start locations
6. **Security** (5/100) - Input validation and error handling
7. **Build** (10/100) - Clear build/setup instructions
8. **Documentation** (8/100) - Code and project documentation

### Next Steps

Before making changes:
1. Read relevant source files to understand the existing code
2. Look at existing tests for similar functionality
3. Follow the patterns you see in the codebase
4. Write tests for your changes
5. Run `make test` to verify nothing breaks
6. Run linter: `shellcheck ./bin/* ./libexec/* ./plugins/*/bin/* ./plugins/*/libexec/* ./completions/*.bash ./pyenv.d/*/*.bash`
7. Ensure scripts are executable: `chmod +x ./bin/*`

---

*Generated by Braxis - keeping AI agents in sync with your code*
