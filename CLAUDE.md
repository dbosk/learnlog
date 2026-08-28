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
- **Always activate the `dbosk-skills:literate-programming` skill before editing `.nw` files**
- Use the `dbosk-skills:review` skill to review literate quality of changes

These skills come from the `dbosk-skills` plugin (github.com/dbosk/claude-skills),
declared in `.claude/settings.json` so they install automatically, including in
remote (web) sessions.

### Related skills

- `dbosk-skills:latex-writing` — for LaTeX conventions in `.nw` documentation sections
- `dbosk-skills:variation-theory` — for structuring educational content in documentation
- `dbosk-skills:try-first-tell-later` — for pedagogical exercise design

## Architecture

The core modules, all defined as `.nw` literate source in `src/learnlog/`
(`commits.nw` and `progsnap2.nw` hold the read and export sides):

| Module | File | Purpose |
|--------|------|---------|
| `__init__.py` | `learnlog.nw` | Auto-initializes on import; wraps stdout/stderr/stdin for transparent I/O capture; atexit cleanup; `find_learnlog_dir()`/`_resolve_workdir()` decide which project a run belongs to. `_is_opted_out()`/`_learnlog_cli_subcommand()` implement the recording veto: `LEARNLOG_SKIP_AUTOSTART`, plus **every CLI subcommand except `play`/`list`** (`REVIEW_SUBCOMMANDS`) — the veto returns *before* `_resolve_workdir()`, so a vetoed command creates no repository at all. Review runs skip both capture chunks and instead accumulate `view_trace` via the public `record_view(commit_hash, action)`. A run is owned by the pid that started it: `initialize()` records `run_pid` and registers `on_exit` immediately after `begin_run()` (before any stream wiring, which fails into "run recorded, I/O not captured"), and `on_exit`/`_release_c_invocation` return early in any other process, so a forked child cannot finalise its parent's run. `on_exit` restores the streams last, in a `finally`, so capture stays live until the trailer is composed. `_resolve_workdir()` exports `LEARNLOG_ANCHOR_PREFIX = sys.prefix` beside `LEARNLOG_PROJECT_ROOT` and obeys an inherited anchor only when the prefix matches (or is absent), so a child wired to a different project logs into its own |
| `_autostart.py` | `learnlog.nw` | Venv startup hook installed via `.pth`; resolves the venv's project root (marker file + `sys.prefix`) for `initialize()`, and imports `learnlog` early enough to capture `SyntaxError`, `python -c`, REPL, `pip`, and other venv-scoped runs. Must never import `learnlog` at module scope: `import learnlog._autostart` already runs `__init__.py`, so the recording veto (`LEARNLOG_SKIP_AUTOSTART`, and every subcommand outside `REVIEW_SUBCOMMANDS`) lives in `initialize()`, not here |
| `capture.py` | `capture.nw` | `IOLog` (thread-safe shared buffer), `StreamCapture`/`InputCapture` (transparent tee wrappers); strips ANSI escapes |
| `gitrepo.py` | `gitrepo.nw` | `LearnlogRepo` manages `.learnlog/` hidden Git repo with `--git-dir=.learnlog --work-tree=.`; append-only two-commit protocol (header commit with the code state before the run, trailer commit with the results after, linked by `Run-Id`). Run commits go in via `commit-tree` + guarded `update-ref` on `recording_branch()` (`commit_on_branch()`), so they never consummate a half-finished merge/cherry-pick/rebase (`unfinished_operation()`) and land on the recording branch even when HEAD is detached; the header uses a per-run `GIT_INDEX_FILE` (seeded with `copy2`, published back under git's own `index.lock` protocol), the trailer uses no index at all; `run_index` cleanup removes the private index **and** its `.lock`, and `reclaim_run_indexes(lock)` sweeps killed runs' leftovers — only under a held commit lock (which now yields its handle), the proof that no `run_index` block is live. `_acquire_lock` re-checks the inode after `flock` so a deleted-and-recreated lock file cannot void mutual exclusion. `git_environment()` strips every ambient `GIT_*` variable except a transport/config allow-list. `ensure_configured()` runs on every construction (under the commit lock only when writing) and keeps `info/exclude` (incl. `.learnlogignore` and `*.learnlog`/`*.progsnap2`), `commit.gpgsign=false`, and the fallback identity current — this is what makes clones work. `git()` raises `GitError` on failure and `report_error()` records swallowed failures. Owns `REVIEW_SUBCOMMANDS` (the run-record vocabulary both `__init__` and `commits` import) and writes a review run's `Viewed: <hash> <ISO-8601> <action>` trailer lines |
| `cli.py` | `cli.nw` | Typer CLI with setup, synchronisation, export/import, tutorials, tag, playback, and analysis commands — `init` (project + venv + autostart; honors active `$VIRTUAL_ENV`; refuses `$HOME`-or-above unless `--force`), `activate`/`deactivate` (emit shell code for the project `.venv/`), `tutorial` (embedded pytorial catalog under `learnlog tutorial`), `list`, `clone` (atomic staging + checkout into an empty target; the cloned repo is configured by `ensure_configured()`), `pull` (fetch + merge in the object database via `merge-tree`/private-index fallback; never touches the student's work tree or shared index, advances the ref with a guarded `update-ref` under the commit lock, aborts clean on conflict), `set-remote`, `push` (explicit `refs/heads/*` + `refs/tags/*` refspecs so lightweight milestone tags ship, matching `export`), `export` (git bundle; written via staging file + `os.replace`), `play` (curses viewer + batch mode), `tag`, `git` (**hidden** escape-hatch passthrough — absent from `--help` so students don't drive the log with raw git, still invocable by name for repair; injects `-e .learnlog`/`-e '!.learnlog'` into `clean`, refuses `reset --hard` without `--allow-destructive`, and builds its env with `git_environment()` — as does `tag`), `doctor` (reports/repairs the interpreter's autostart wiring; dead wiring exits 1), and `analyse`. Only `play` and `list` are recorded runs; every other subcommand leaves no trace, which is what makes `clone` into an empty directory, a fast-forwarding `pull`, and a `tag` on the student's own run possible |
| `viewer.py` | `viewer.nw` | `PlaybackViewer` (curses) and `play_batch`; both report each commit they display to `learnlog.record_view` — actions `open`/`next`/`prev`/`jump-first`/`jump-last` interactively, `batch` in batch mode. A keypress that does not change the displayed commit records nothing |

Tutorial sources in `src/learnlog/tutorials/`:
- `getting-started.nw` — first-run setup, activation, running code, and batch playback
- `playback-and-tagging.nw` — batch and interactive playback plus tagging workflows
- `export-and-share.nw` — bundle export, ProgSnap2 export, and remote sharing workflows
- `analysing-progsnap2.nw` — `learnlog analyse` reports and `Column=Regex` range filtering

### Key design constraints

- **Transparency**: student programs must behave identically with/without learnlog
- **Crash resilience**: `begin_run()` commits a header before execution, `finalize_run()` commits a trailer after; nothing is ever rewritten (no `--amend`), so overlapping runs, pushes, and tags stay correct
- **Reading**: `commits.nw` joins each run's two commits by `Run-Id` (`get_run_trailers`/`merge_run_trailers`; tag/ref resolution joins the same way via `scan_run_commits`/`resolve_record_commit`, with the topological parent only as legacy fallback); readers walk `recording_branch()`, not HEAD; `get_commits()` hides trailer commits, so `list`/`play`/ProgSnap2 show one record per run. Review runs (`learnlog play`/`list`) are shown **by default** — reflection is part of the story; `filter_internal_runs()` hides only learnlog's plumbing (the `pip install learnlog` from `init`, and records of other subcommands left by older versions), which `--all` restores. Predicates: `is_learnlog_*` (all of learnlog's own activity), `is_review_*` (play/list), `is_internal_*` (learnlog activity that is not review)
- `.learnlog/` in the working directory is the *product's* data (student log repo), not project config
- **Bounded discovery**: `find_learnlog_dir()` never returns `$HOME` or
  anything above it, and stops at a `.git` boundary (checked after
  `.learnlog/`, so a project root that is also a checkout still wins). An
  autostart-wired interpreter (marker file present, `site.py` enabled) whose
  project no longer resolves logs *nothing* rather than guessing; so does a
  run whose only candidate root is `$HOME`. Both raise `UnanchoredRun`, which
  `initialize()`'s handler turns into a `LEARNLOG_DEBUG` diagnostic;
  `learnlog doctor` makes that silent state visible and `--repair`
  re-wires it. An empty marker file reads as no marker
- `tests/Makefile` exports `LEARNLOG_SKIP_AUTOSTART=1` so the suite never logs
  its own pytest process; `test_env`/`_autostart_env` strip it for the
  subprocess tests that must be logged
- Git operations use `subprocess.run` (no GitPython dependency)
- `LearnlogRepo.git()` raises `GitError` by default; pass `check=False` only
  where the exit status is the answer (`git diff --cached --quiet`, probes),
  and `text=False` where the output is a file rather than a message
  (`git archive`) — the `GitError`/timeout semantics are identical.  The
  commands that keep inherited stdio on purpose (`push`, `clone`, `pull`'s
  fetch, the `learnlog git` passthrough) stay outside the wrapper: capturing
  would hide progress and credential prompts.  Pull's merge and ref advance
  go through the wrapper — they talk to no remote
- ProgSnap2 code-state names are untrusted input: `safe_snapshot_path()`
  in `progsnap2.nw` rejects absolute names, `..`, drive/UNC prefixes,
  `.learnlog/` and anything resolving outside the work tree; unsafe
  entries are skipped with a warning on stderr rather than aborting the
  import
- Commit messages always go in on stdin (`--file=-`/`commit-tree` with
  `input=`), never `-m` (Linux caps a single `argv` string at 128 KiB);
  `commit-tree` also keeps I/O logs verbatim where porcelain would strip them
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
- Anything that depends on **whether a command records itself** is invisible to `CliRunner` tests, because the suite exports `LEARNLOG_SKIP_AUTOSTART=1`. Those belong in the share-cycle end-to-end suite in `learnlog.nw` (`cli_project` fixture), which runs the real CLI from a wired scratch venv in subprocesses that are genuinely logged

## CI

CircleCI with `dbosk/makefiles` Docker image. Runs `make all` which tangles, builds, tests, and compiles PDF.
