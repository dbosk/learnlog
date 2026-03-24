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
  learnlog set-remote git@gitlab.kth.se:dbosk/lecture01.git
  learnlog push
  ```

  Students clone the log and replay it step by step:

  ```bash
  learnlog clone git@gitlab.kth.se:dbosk/lecture01.git
  learnlog play
  ```

  Alternatively, when a shared Git remote is not available, the teacher can
  export the log as a portable bundle file:

  ```bash
  learnlog export -o lecture01.bundle
  ```

  The teacher distributes the file (e.g. via a course page) and students
  replay it directly:

  ```bash
  learnlog play lecture01.bundle
  ```

- **Studying how students code.**
  A researcher creates an empty Git repository for each student. Each student
  adds `import learnlog` to their programs and pushes the log:

  ```bash
  learnlog set-remote git@gitlab.kth.se:dbosk/alice-log.git
  learnlog push
  ```

  The researcher then clones each student's repository to analyse the
  development data:

  ```bash
  learnlog clone git@gitlab.kth.se:dbosk/alice-log.git
  learnlog play
  ```

  Alternatively, the student can export the log as a bundle and submit it
  through the course platform:

  ```bash
  learnlog export -o alice-log.bundle
  ```

  The researcher then replays it directly:

  ```bash
  learnlog play alice-log.bundle
  ```

  This gives a complete timeline of how students develop and debug their
  code — for research purposes or to help students refine their debugging
  techniques.
