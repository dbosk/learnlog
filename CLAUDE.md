# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Full build: tangle .nw → .py, build package, run tests, compile PDF
make all

# Initialize git submodule (required first time)
git submodule update --init

# Tangle and build package only
cd src/learnlog && make

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

Tutorials follow the same rule: the sources live in
`src/learnlog/tutorials/*.nw`, tangle to runtime `.md` resources, and weave to
`.tex` chapters for the PDF.

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

Five modules, all defined as `.nw` literate source in `src/learnlog/`:

| Module | File | Purpose |
|--------|------|---------|
| `__init__.py` | `learnlog.nw` | Auto-initializes on import; wraps stdout/stderr/stdin for transparent I/O capture; atexit cleanup |
| `_autostart.py` | `learnlog.nw` | Venv startup hook installed via `.pth`; resolves the venv's project root (marker file + `sys.prefix`) for `initialize()`, and imports `learnlog` early enough to capture `SyntaxError`, `python -c`, REPL, `pip`, and other venv-scoped runs. Must never import `learnlog` at module scope: `import learnlog._autostart` already runs `__init__.py`, so the activation veto (`LEARNLOG_SKIP_AUTOSTART`, `learnlog init`) lives in `initialize()`, not here |
| `capture.py` | `capture.nw` | `IOLog` (thread-safe shared buffer), `StreamCapture`/`InputCapture` (transparent tee wrappers); strips ANSI escapes |
| `gitrepo.py` | `gitrepo.nw` | `LearnlogRepo` manages `.learnlog/` hidden Git repo with `--git-dir=.learnlog --work-tree=.`; append-only two-commit protocol (header commit with the code state before the run, trailer commit with the results after, linked by `Run-Id`), `flock` + per-run `GIT_INDEX_FILE` around each commit; `git()` raises `GitError` on failure and `report_error()` records swallowed failures |
| `cli.py` | `cli.nw` | Typer CLI with setup, synchronisation, export/import, tutorials, tag, playback, and analysis commands — `init` (project + venv + autostart; honors active `$VIRTUAL_ENV`), `activate`/`deactivate` (emit shell code for the project `.venv/`), `tutorial` (embedded pytorial catalog under `learnlog tutorial`), `list`, `clone`, `pull`, `set-remote`, `push`, `export` (git bundle), `play` (curses viewer + batch mode), `tag`, `git` (passthrough), and `analyse` |

Tutorial sources in `src/learnlog/tutorials/`:
- `getting-started.nw` — first-run setup, activation, running code, and batch playback
- `playback-and-tagging.nw` — batch and interactive playback plus tagging workflows
- `export-and-share.nw` — bundle export, ProgSnap2 export, and remote sharing workflows
- `analysing-progsnap2.nw` — `learnlog analyse` reports and `Column=Regex` range filtering

### Key design constraints

- **Transparency**: student programs must behave identically with/without learnlog
- **Crash resilience**: `begin_run()` commits a header before execution, `finalize_run()` commits a trailer after; nothing is ever rewritten (no `--amend`), so overlapping runs, pushes, and tags stay correct
- **Reading**: `commits.nw` joins each run's two commits by `Run-Id` (`get_run_trailers`/`merge_run_trailers`); `get_commits()` hides trailer commits, so `list`/`play`/ProgSnap2 show one record per run
- `.learnlog/` in the working directory is the *product's* data (student log repo), not project config
- Git operations use `subprocess.run` (no GitPython dependency)
- `LearnlogRepo.git()` raises `GitError` by default; pass `check=False` only
  where the exit status is the answer (`git diff --cached --quiet`, probes)
- Commit messages always go in via `--file=-` and `input=`, never `-m`
  (Linux caps a single `argv` string at 128 KiB)
- Failures learnlog must swallow are appended to `.learnlog/errors.log` and,
  with `LEARNLOG_DEBUG` set, mirrored to stderr — never `except: pass`
- Runtime dependencies: `typer>=0.9.0` (CLI), `virtualenv>=20` (used by
  `learnlog init` to create project venvs reliably on PEP 668 / split-
  `python3-venv` systems), and `pytorial>=0.2` (embedded interactive
  tutorials)

## Testing

Tests are embedded in `.nw` files as `<<test [[module.py]]>>=` chunks. The `tests/Makefile` auto-discovers and tangles them to `tests/unit/test_*.py` before running pytest.

Key test patterns:
- Temporary directories with `tmp_path` fixture for Git operations
- Subprocess-based integration tests for full import-capture-commit pipeline
- `CliRunner` from Typer for CLI command testing (note: CliRunner doesn't connect a real TTY)

## CI

CircleCI with `dbosk/makefiles` Docker image. Runs `make all` which tangles, builds, tests, and compiles PDF.
