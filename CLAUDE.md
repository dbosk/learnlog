# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Full build: tangle .nw → .py, build package, run tests, compile PDF
make all

# Initialize git submodule (required first time)
git submodule update --init

# Tangle and build package only
cd src/learnlog && make compile

# Run tests (tangles test chunks from .nw files automatically)
cd tests && make test
# Or directly after tangling:
poetry run pytest -v
# Single test:
poetry run pytest tests/unit/test_cli.py::test_find_learnlog_dir -v

# Build PDF documentation
cd doc && make

# Install in editable mode
make install

# Clean build artifacts
make clean
```

## Literate Programming (Critical)

**The `.nw` files are the source of truth.** Never edit generated `.py` files directly — always edit the corresponding `.nw` file in `src/learnlog/` and tangle.

- `notangle -R"[[filename.py]]" file.nw` extracts Python code
- `noweave` extracts LaTeX documentation
- Code chunks: `<<[[filename.py]]>>=`
- Test chunks: `<<test [[filename.py]]>>=` (auto-discovered by `tests/Makefile`)
- **Always activate the `literate-programming` skill before editing `.nw` files**
- Use the `review-literate-programming` skill to review literate quality of changes

### Related skills

- `latex-writing` — for LaTeX conventions in `.nw` documentation sections
- `variation-theory` — for structuring educational content in documentation
- `try-first-tell-later` — for pedagogical exercise design

## Architecture

Four modules, all defined as `.nw` literate source in `src/learnlog/`:

| Module | File | Purpose |
|--------|------|---------|
| `__init__.py` | `learnlog.nw` | Auto-initializes on import; wraps stdout/stderr/stdin for transparent I/O capture; atexit cleanup |
| `capture.py` | `capture.nw` | `IOLog` (thread-safe shared buffer), `StreamCapture`/`InputCapture` (transparent tee wrappers); strips ANSI escapes |
| `gitrepo.py` | `gitrepo.nw` | `LearnlogRepo` manages `.learnlog/` hidden Git repo with `--git-dir=.learnlog --work-tree=.`; crash-resilient commit strategy (commit header before run, amend with results after) |
| `cli.py` | `cli.nw` | Typer CLI with `export` (git bundle) and `play` (curses viewer + batch mode) commands |

### Key design constraints

- **Transparency**: student programs must behave identically with/without learnlog
- **Crash resilience**: `begin_run()` commits before execution, `finalize_run()` amends after
- `.learnlog/` in the working directory is the *product's* data (student log repo), not project config
- Git operations use `subprocess.run` (no GitPython dependency)
- Only runtime dependency: `typer>=0.9.0`

## Testing

Tests are embedded in `.nw` files as `<<test [[module.py]]>>=` chunks. The `tests/Makefile` auto-discovers and tangles them to `tests/unit/test_*.py` before running pytest.

Key test patterns:
- Temporary directories with `tmp_path` fixture for Git operations
- Subprocess-based integration tests for full import-capture-commit pipeline
- `CliRunner` from Typer for CLI command testing (note: CliRunner doesn't connect a real TTY)

## CI

CircleCI with `dbosk/makefiles` Docker image. Runs `make all` which tangles, builds, tests, and compiles PDF.
