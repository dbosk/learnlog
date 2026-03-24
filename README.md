# learnlog

A Python package that automatically logs code development and program runs.

By adding `import learnlog` as the first import in a Python file, every
program run is recorded transparently: source code changes, command-line
arguments, standard input/output/error, and unhandled exceptions. The data is
stored in a hidden local Git repository.

## Use cases

- **Sharing live-coding sessions.**
  A teacher adds `import learnlog` to demonstration scripts during a lecture
  or tutorial. After the session the teacher pushes the log to a remote
  repository:

  ```bash
  learnlog set-remote <url>
  learnlog push
  ```

  Students clone the log and replay it step by step:

  ```bash
  learnlog clone <url>
  learnlog play
  ```

  Alternatively, the teacher can run `learnlog export` to create a portable
  bundle file that students import and replay with `learnlog play` — useful
  when a shared Git remote is not available.

- **Studying how students code.**
  A researcher creates an empty Git repository for each student. Each student
  adds `import learnlog` to their programs and pushes the log:

  ```bash
  learnlog set-remote <url>
  learnlog push
  ```

  The researcher then clones each student's repository to analyse the
  development data:

  ```bash
  learnlog clone <url>
  learnlog play
  ```

  This gives a complete timeline of how students develop and debug their
  code — for research purposes or to help students refine their debugging
  techniques.
