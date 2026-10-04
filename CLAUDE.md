# CLAUDE.md

@AGENTS.md

This project uses AGENTS.md as the standard agent context. Claude Code loads it automatically via the @AGENTS.md import above.

## Claude Code Setup

1. **Read AGENTS.md first** for full project context
2. **Run `make test`** before proposing changes
3. **Follow shell scripting conventions** outlined in AGENTS.md
4. **Test changes locally** to ensure Bats tests pass

## Quick Commands

```bash
make test              # Run all tests
make test-<name>       # Run specific test suite
src/configure && make -C src  # Build C extension
```

See AGENTS.md for full documentation.

## Commit Attribution

All commits must include a `Co-Authored-By` trailer with a real, verified
contributor name and email. Do not use placeholder values such as
`Your Name <your.email@example.com>`.
