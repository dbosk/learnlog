# learnlog

A Python package that automatically logs code development and program runs.

By adding `import learnlog` as the first import in a Python file, every
program run is recorded transparently: source code changes, command-line
arguments, standard input/output/error, and unhandled exceptions. The data is
stored in a hidden local Git repository.

## Use cases

- **Studying how students code.**
  Have students add `import learnlog` to their programs. The teacher can then
  study students' development process — for research purposes or to help
  students refine their debugging techniques.

- **Sharing live-coding sessions.**
  A teacher adds `import learnlog` to demonstration scripts during a lecture
  or tutorial. After the session, run `learnlog export` to create a portable
  bundle that students can replay step by step with `learnlog play`.
