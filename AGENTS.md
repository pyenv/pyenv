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
- **Package Manager:** pip or uv
- **Test Runner:** Bats



### Project Structure
