We give `wikiapp` one interface for every task, a justfile. `wikiapp` is a small command that prints the title and
the summary of a random Wikipedia page. Its project has many tools, each with its own options. A person, a git hook
and GitHub must all run them the same way. This tutorial takes the parts about the justfile out of the whole
tutorial of smallwikiapp. It starts from the project that `uv init` made, for Python 3.13, and has a justfile
from the start.

The justfile is the interface of the project. Each task is a verb, such as `just test`, and the recipe behind the
verb names the tool that does the work. A person, a git hook and GitHub each run `just check`, and `check` runs
other verbs. A tool can change behind a verb, and the callers of the verb stay the same.

Most sections bring in a verb with three commands. First the tool's own command runs, then `just --show VERB` shows
the recipe, and then the verb runs. The sections of `test` and `check` skip the tool's command. Section 1 runs
`just setup` before it shows the recipe.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has seventeen sections:

1. **The project, and its justfile**
2. **`just test`**
3. **`just fmt`**
4. **`just lint`**
5. **`just lint-config`**
6. **A variable for every recipe**
7. **`just check`, everything a `git commit` must pass**
8. **The git hook runs `just check`**
9. **`just types`**
10. **The types join `just check`**
11. **GitHub runs `just check`**
12. **`just docs`**
13. **`just docs` alone builds a site**
14. **The docs check joins `just check`**
15. **The library, behind the same verbs**
16. **`just build`**
17. **`just lint-config` checks the library too**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**What `just check` runs**

`just check` runs every check that a `git commit` must pass, and ends at the first check that fails. The table gives each section that changes what it runs.

| Section | What changes | Where the change is |
|---|---|---|
| 7 | `check` comes in, with the format, the linter, the tests over a floor on the coverage, and the configuration | The justfile |
| 10 | The type checker | The justfile |
| 14 | The docs check | The justfile |
| 15 | The docs check counts the library | `docs/_smalldocs.yml` |
| 17 | The check of the configuration reads the library's `pyproject.toml` | The recipe `lint-config` |

Some changes that this tutorial leaves out change what `just check` runs too. They change `pyproject.toml`, not
the justfile. Before section 10, the rules `ANN` come into the linter. Before section 11, the end-to-end tests come in. They ask the
real Wikipedia, and pytest leaves them out of each run that does not ask for them, `just check` included. Before section 15, the floor on the coverage counts both
packages.

**Who runs `just check`**

Three callers run `just check`, and none of them changes when `check` changes.

| Caller | From | When it runs |
|---|---|---|
| A person, in the terminal | Section 7 | When the person remembers |
| The git hook | Section 8 | Before each `git commit`, in a clone where `just hook` ran |
| GitHub's job `check` | Section 11 | On every push to main and every pull request |

**The verbs, and what is behind each**

The table gives each verb of the last justfile, and the commands that its recipe runs.

| Verb | What its recipe runs | Section |
|---|---|---|
| `help` | `just --show VERB`, or `just --list --unsorted` | 1 |
| `setup` | `uv sync --locked` | 1 |
| `test` | `uv run pytest` | 2 |
| `fmt` | `uv run ruff format` | 3 |
| `lint` | `uv run ruff check` | 4 |
| `lint-config` | `uv run validate-pyproject`, `uv lock --check` and `just --fmt --check --unstable` | 5 and 17 |
| `check` | `just fmt --check`, `just lint`, `just types`, `just test -q --cov-fail-under=90`, `just docs check` and `just lint-config` | 7, 10 and 14 |
| `hook` | `uv run pre-commit install` | 8 |
| `types` | `uv run ty check` | 9 |
| `docs` | `uv run smalldocs render docs` alone, and `uv run smalldocs api` with words | 12 and 13 |
| `build` | `uv build --all-packages` | 16 |

## The project, and its justfile

The project has a justfile from the start, so the first task already has a verb. This section shows what
`uv init` made, the command `wikiapp`, and the first justfile. The justfile has three recipes. `default` lists the
verbs, `help` explains one, and `setup` installs the project.

{{include step-00}}

**The parts of a justfile**

A justfile has settings, variables and recipes. `set positional-arguments` is a setting. It gives the words after
a verb to the shell of the recipe, as `$1`, `$2` and `"$@"`. The first variable comes in section 6.

A recipe has up to four parts, from the top.

- **A comment.** `just --list` prints it beside the name of the recipe, and `just help VERB` prints it too.
- **Attributes,** in square brackets. `[group('setup')]` puts the recipe under the heading `[setup]` in the list.
  `[private]` leaves `default` out of the list.
- **The name and the parameters.** In `setup *args:`, the star lets `args` take any number of words, or none.
- **The body,** indented under the name. The body of `setup` is one line. The body of `help` is a script, which
  section 5 explains.

`just` with no verb runs the first recipe of the file. Here that is `default`, which lists the others.

## `just test`

$ just setup

The command now asks Wikipedia for a random page, and prints its title and summary, with click and requests. It
sends a User-Agent, and has an option `--version`. `default-groups = "all"` in `pyproject.toml` makes uv install
every dependency group. pytest is in a dependency group `test`, with the first test.
`uv run pytest` printed `1 passed`.

A person who runs the tests must know the tool and its options. `just test` is the first verb after `setup`, and
the first that runs a check.

{{include step-02.4}}

The body of `test` is one line, `{{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}`.
`just` works out the part between `{{` and `}}` before a shell sees the line. If the only word after the verb is
`help`, the line is `just help test`. Otherwise it is `uv run pytest "$@"`.

Each later recipe of one line has this form. The longer recipes test the word in the shell, from section 5. So
`just VERB help` explains each verb.

`[no-exit-message]` changes what a failed test prints. Without it, `just` adds a line of its own, which begins
"error: Recipe `test` failed". With it, the report of pytest is the last thing that the recipe prints.

## `just fmt`

$ just setup

The code now also has tests with a mock in place of Wikipedia, and every run measures the coverage. The code is
split into a library, `src/wikiapp/wikipedia.py`, and the command. The command has an option `--language`. The
library raises its own error, `WikipediaError`, and the command turns it into a message.

The code mixes styles. ruff comes in, and `just fmt` formats the code and the tests.

{{include step-04.1..step-04.2}}

## `just lint`

$ just setup

The code is now formatted, by `just fmt`.

A formatter changes how the code looks, and finds no mistakes. The rules of the linter go in `pyproject.toml`, and
`just lint` runs the linter.

{{include step-04.4}}

## `just lint-config`

$ just setup

The code now also has the fixes of the linter's five problems. `just lint --fix` sorted the imports, since the
words after `lint` go to ruff. A person fixed the other four problems.

Nothing checks the files that set up the project. `just lint-config` checks the configuration. Its recipe is a
small shell script, which runs three commands and ends at the first that fails.

{{include step-04.8..step-04.9}}

A recipe has one of two kinds of body. Each line of a plain body runs in a shell of its own, and the recipe ends
at the first line that fails. A body whose first line is `#!/usr/bin/env sh` is a script, and one shell runs all of
it. `help`, from section 1, is a script too. A script without `set -e` goes on after a command fails. In
`lint-config`, `set -e` is the line after `#!/usr/bin/env sh`.

In a script, the test of the word `help` is a line of shell, `[ "$*" = help ]`. It does the same as the `{{ if }}`
of section 2, since `"$*"` is the words after the verb, joined by spaces.

## A variable for every recipe

$ just setup

A recipe that runs `uv` can change the lockfile, and prints no warning. This section changes no recipe. It
changes how each recipe that runs `uv` runs it.

{{include step-04.10}}

## `just check`, everything a `git commit` must pass

$ just setup

A person must remember four verbs before each `git commit`. `just check` runs those four verbs, one after the
other. It names no tool of its own.

{{include step-04.11}}

$ just

`just` lists `help` first, then the other verbs in their groups, each with its comment. `check` is under
`[quality]`, after the four verbs that it runs.

From here on, "each `git commit` must pass `just check`" is the rule of the project. The next section and section
11 add two callers, which run it by themselves. Each later check joins `check`, so each caller runs it too.

## The git hook runs `just check`

$ just setup

A person can forget to run `just check`. `pre-commit` installs a git hook, which is one more caller of
`just check`. The hook also checks YAML files, large files and leftover marks of a merge. But its only check of
the Python code is `just check`.

{{include step-04.12..step-04.13}}

The hook makes sure that `just check` runs on this machine before each `git commit`. It has limits.

- **It is in one clone only.** git does not copy `.git/hooks` with the repository. A clone has the hook only after
  `just hook` runs in it, and `git commit --no-verify` skips the hook.
- **It needs the clone's `.venv`.** `pre-commit install` writes the path of `.venv/bin/python3` into the
  hook, as an absolute path. If `.venv` is gone and no other `pre-commit` is on the PATH, every `git commit`
  fails. The hook prints that `pre-commit` was not found, and asks whether the virtualenv is active.
  `just setup` makes `.venv` again.
- **It runs tools of the machine.** The line `language: system` tells `pre-commit` to run `just check` as it is,
  with the `just` and the `uv` that the machine has.

So the hook runs `just check` on one machine only. In section 11, GitHub runs `just check` too, on
its own machines, for every push to main and every pull request.

## `just types`

$ just setup

The linter does not check types. The next verb runs a type checker, and `check` does not run it yet.

{{include step-05.1..step-05.2}}

## The types join `just check`

$ just setup

In the code now, `__init__.py` asks for the version of `"wikiapp"` by name, which fixes the one problem that
ty found. A family of rules, `ANN`, asks for a type on every parameter and return. The code and the tests have
their types.

`just check` does not run the type checker yet. One line in `check` runs it.

{{include step-05.7}}

`.pre-commit-config.yaml` still says `entry: just check`, and the hook now
checks the types too.

## GitHub runs `just check`

$ just setup

In the code now, the tests that ask the real Wikipedia run only on request, with `just test -m e2e`. The project
accepts any Python from 3.11 on.

The hook runs only in a clone where `just hook` ran. GitHub's job `check` runs `just setup`, then `just check`, on
a fresh machine.

{{include step-06.5}}

The job `check` is the third caller of `just check`, after a person and the git hook. It runs from a fresh clone.
No person has to install it or remember it, and `--no-verify` does not skip it. The job `tests` runs
`uv run --locked pytest`, not a verb, so a change behind `just test` would not reach it.

## `just docs`

$ just setup

In the code now, `random_page` returns a `Page`, a pydantic model with a title and an extract. An answer that
is not a page, or a language that is not a language code, raises `WikipediaError`.

Nothing says which parts of the code have documentation. smalldocs comes in, and `just docs check` counts what has
documentation. The words after `docs` go to `smalldocs api`.

{{include step-08.1..step-08.2}}

## `just docs` alone builds a site

$ just setup

The code now also has the documentation of the library, the command and the tests, and the docs check finds no
gap.

The reference is text in a terminal. The recipe `docs` changes. With no words, it builds a site. With words, it
works as before, so `just docs check` is the same command.

{{include step-08.6}}

## The docs check joins `just check`

$ just setup

The code now also has a README that names the tests and the docs.

`just check` does not run the docs check yet. One line in `check` runs it.

{{include step-08.8}}

## The library, behind the same verbs

$ just setup

In the code now, the library is a package of its own, `wikirandom`, in `packages/wikirandom`, in a uv workspace.
The app uses it, and `src/wikiapp/wikipedia.py` is gone. The tests of the library are in `tests/test_wikirandom.py`.
The project on GitHub also changed, and the next paragraphs say what it does now.

A dependency group is a named list of packages in `pyproject.toml`. This project has three groups. Their names are
`docs`, `lint` and `test`. The line `default-groups = "all"` in `pyproject.toml` makes `uv sync` and `uv run` install
all three.

GitHub reads the jobs of the project from files in `.github/workflows`. Each of these files is a workflow. The jobs
`tests` and `check` are in one workflow, `.github/workflows/test.yaml`. A second workflow,
`.github/workflows/docs.yaml`, has two jobs. The job `build` builds the docs site. Then the job `deploy` puts the site
on GitHub Pages, the part of GitHub that serves websites.

The job `tests` runs only the tests, and needs only the group `test`. It runs `uv run --locked
--no-default-groups --group test pytest`. `--no-default-groups` tells uv to install none of the groups that
`default-groups = "all"` names. `--group test` then adds the group `test` alone. So uv installs the app, the
packages that the app needs, and the group `test`, and no other group.

`uv.lock` lists the exact version of each package that uv installs. `--locked` makes uv stop with an error if
`uv.lock` does not match `pyproject.toml`.

The docs workflow runs `uv run --locked --no-default-groups --group docs smalldocs render docs`. The options work as
they do in the job `tests`. uv installs the app, the packages that the app needs, and the group `docs`, and no other
group.

The docs workflow does not run `just docs`. With no words, the recipe `docs` runs `uv run smalldocs render docs`,
with no option for dependency groups. So `just docs` makes uv install all three groups, but the workflow needs only
the group `docs`. Line 26 of `.github/workflows/docs.yaml` runs `uv run` directly, so the docs workflow is
not a caller of `just docs`. If someone changes the command in the recipe `docs`, the change does not reach the
workflow.

Those changes did not change the justfile. One justfile, one `.pre-commit-config.yaml` and one hook work for both
packages. `just fmt`, `just lint` and `just types` read every Python file of the repository, so they checked the
library's code from the first. `just test` measures the coverage of both packages, since `pyproject.toml` has
`--cov=wikirandom`. Here, `just docs check` still counts only the functions, methods and classes of the app and
the tests. This section
changes `docs/_smalldocs.yml`, behind the verb.

{{include step-09.10}}

The justfile did not change, and `just docs check` checks more. The hook and GitHub's job `check` run the new
docs check without a change.

## `just build`

$ just setup

The packages must be built before anyone can install them. The last verb is about the packages, not about checks,
so `check` does not run it.

{{include step-10.1}}

## `just lint-config` checks the library too

$ just setup

In the code now, the app asks for wikirandom 0.1.

Since the library became a package, validate-pyproject, in `just lint-config`, has read only the app's
`pyproject.toml`. The hook and `just check` let every `git commit` through with no check of the library's
`pyproject.toml` against the standard.

{{include step-10.3}}

The verb has the same name, and its callers did not change. A file that a recipe leaves out is a file that no
caller checks. The fix goes in one place, the recipe, and all three callers have it.

This tutorial ends here. After it, the library gets a licence and an author, both packages get a link to the
repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.
