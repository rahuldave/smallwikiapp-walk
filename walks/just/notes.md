This walk takes the moves about the justfile out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts with the project, which
`uv init` began, for Python 3.13. The project has a justfile from the start.

The justfile is the interface of the project. Each task is a verb, such as `just test`, and the recipe behind the
verb names the tool that does the work. A person, a git hook and GitHub each run `just check`, and `check` runs
other verbs. A tool can change behind a verb, and the callers of the verb stay the same.

Each new verb comes in the same way. `just --show VERB` shows the recipe, then the verb runs. Most stops that bring
in a verb also run the tool's own command first. The stops of `test` and `check` do not.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has seventeen stops. Each stop takes a whole step or one move:

1. **The project, and its justfile** (step-00)
2. **`just test`** (step-02.2)
3. **`just fmt`** (step-04.1)
4. **`just lint`** (step-04.3)
5. **`just lint-config`** (step-04.7)
6. **A variable for every recipe** (step-04.8)
7. **`just check`, everything a commit must pass** (step-04.9)
8. **The git hook runs `just check`** (step-04.10)
9. **`just types`** (step-05.1)
10. **The types join `just check`** (step-05.6)
11. **GitHub runs `just check`** (step-06.4)
12. **`just docs`** (step-08.1)
13. **`just docs` alone builds a site** (step-08.5)
14. **The docs check joins `just check`** (step-08.7)
15. **The library, behind the same verbs** (step-09.4)
16. **`just build`** (step-10.1)
17. **`just lint-config` checks the library too** (step-10.3)

Where the whole tutorial makes moves that this walk leaves out, the next stop says what they did. The stop
starts from their code.

**What `just check` runs**

`just check` is the gate of the project. It runs every check that a commit must pass, and stops at the first
that fails. The table gives each stop that changes what it runs.

| Stop | What changes | Where the change is |
|---|---|---|
| 7 | `check` comes in, with the format, the linter, the tests over a floor on the coverage, and the configuration | The justfile |
| 10 | The type checker | The justfile |
| 14 | The docs check | The justfile |
| 15 | The docs check counts the library | `docs/_smalldocs.yml` |
| 17 | The check of the configuration reads the library's `pyproject.toml` | The recipe `lint-config` |

Some moves that the walk leaves out change what `just check` runs too. They change `pyproject.toml`, not the
justfile. The move step-05.3 adds the rules `ANN` to the linter. The move step-06.1 leaves the e2e test out of each
run that does not ask for it, `just check` included. The move step-09.3 makes the floor on the coverage count both
packages.

**Who runs `just check`**

Three callers run `just check`, and none of them changes when `check` changes.

| Caller | From | When it runs |
|---|---|---|
| A person, in the terminal | Stop 7 | When the person remembers |
| The git hook | Stop 8 | Before each commit, in a clone where `just hook` ran |
| GitHub's job `check` | Stop 11 | On every push to main and every pull request |

## The project, and its justfile

This stop is all of step-00. It shows what `uv init` made, the command `wikiapp`, and the first justfile. The
justfile has three recipes. `default` lists the verbs, `help` explains one, and `setup` installs the project.

{{include step-00}}

## `just test`

$ just setup

Since the last stop, the walk leaves out [step-01](https://rahuldave.com/smallwikiapp-walk/watch/step-01.html) and
the move [step-02.1](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html#step-02.1). The command asks
Wikipedia for a random page, and prints its title and summary, with click and requests. It sends a User-Agent, and
has an option `--version`. pytest came in, in a dependency group `test`, with the first test. `uv run pytest`
printed `1 passed`. This stop starts with that code.

`just test` is the first verb after `setup`, and the first that runs a check.

{{include step-02.2}}

## `just fmt`

$ just setup

Since the last stop, the walk leaves out the rest of
[step-02](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html) and all of
[step-03](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html). The tests got a mock in place of
Wikipedia, and every run measures the coverage. The code split into a library, `src/wikiapp/wikipedia.py`, and
the command. The command got an option `--language`. The library raises its own error, `WikipediaError`, and
the command turns it into a message. This stop starts with that code.

ruff comes in, and `just fmt` formats the code and the tests.

{{include step-04.1}}

## `just lint`

$ just setup

Since the last stop, the walk leaves out the move
[step-04.2](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.2), in which `just fmt` formatted
the code. This stop starts with that code.

The rules of the linter go in `pyproject.toml`, and `just lint` runs the linter.

{{include step-04.3}}

## `just lint-config`

$ just setup

Since the last stop, the walk leaves out the moves
[step-04.4](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.4) to
[step-04.6](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.6). `just lint --fix` sorted the
imports, since the words after `lint` go to ruff. A person fixed the other four problems. This stop starts with
that code.

`just lint-config` checks the configuration. Its recipe is a small shell script, which runs three commands and
stops at the first that fails.

{{include step-04.7}}

## A variable for every recipe

$ just setup

This move changes no recipe. It changes how each recipe that runs `uv` runs it.

{{include step-04.8}}

## `just check`, everything a commit must pass

$ just setup

`just check` runs four of the other verbs, one after the other. It names no tool of its own.

{{include step-04.9}}

From this stop on, "a commit must pass `just check`" is the rule of the project. The next stop and stop 11 add
two callers, which run it with no one typing it. Each later check joins `check`, so each caller runs it too.

## The git hook runs `just check`

$ just setup

pre-commit installs a git hook. The hook is one more caller of `just check`, and its only check of the code is
`just check`.

{{include step-04.10}}

The hook makes sure that `just check` runs on this machine before each commit. It has limits.

- **It is in one clone only.** git does not copy `.git/hooks` with the repository. A clone has the hook only after
  `just hook` runs in it, and `git commit --no-verify` skips the hook.
- **It needs the clone's `.venv`.** `pre-commit install` writes the path of `.venv/bin/python` into the
  hook, as an absolute path. If `.venv` is gone and no other pre-commit is on the PATH, git refuses every commit.
  The hook prints that `pre-commit` was not found, and asks whether the virtualenv is active. `just setup` makes
  `.venv` again.
- **It runs tools of the machine.** The line `language: system` tells pre-commit to run `just check` as it is,
  with the `just` and the `uv` that the machine has.

So the hook helps on one machine, and `just check` is the gate. At stop 11, GitHub runs the same gate, on
its own machines, for every push to main and every pull request.

## `just types`

$ just setup

The next verb runs a new tool, and `check` does not run it yet.

{{include step-05.1}}

## The types join `just check`

$ just setup

Since the last stop, the walk leaves out the moves
[step-05.2](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html#step-05.2) to
[step-05.5](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html#step-05.5). `__init__.py` now asks for the
version of `"wikiapp"` by name, which fixes the one problem that ty found. A family of rules, `ANN`, asks for a type
on every parameter and return. The code and the tests got their types. This stop starts with
that code.

One line in `check` runs the type checker.

{{include step-05.6}}

`.pre-commit-config.yaml` still says `entry: just check`, and the hook now
checks the types too.

## GitHub runs `just check`

$ just setup

Since the last stop, the walk leaves out the moves
[step-06.1](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.1) to
[step-06.3](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.3). The tests that ask the real
Wikipedia run only on request, with `just test -m e2e`. The project accepts any Python from 3.11 on. This stop
starts with that code.

GitHub's job `check` runs `just setup`, then `just check`, on a fresh machine.

{{include step-06.4}}

The job `check` is the third caller of `just check`, after a person and the git hook. It runs from a fresh clone.
No person has to install it or remember it, and `--no-verify` does not skip it. The job `tests` runs
`uv run --locked pytest`, not a verb, so a change behind `just test` would not reach it.

## `just docs`

$ just setup

Since the last stop, the walk leaves out [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html).
`random_page` returns a `Page`, a pydantic model with a title and an extract. An answer that is not a page, or a
language that is not a language code, raises `WikipediaError`. This stop starts with that code.

smalldocs comes in, and `just docs check` counts what has documentation. The words after `docs` go to `smalldocs
api`.

{{include step-08.1}}

## `just docs` alone builds a site

$ just setup

Since the last stop, the walk leaves out the moves
[step-08.2](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html#step-08.2) to
[step-08.4](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html#step-08.4). The library, the command and
the tests got their documentation, and the docs check finds no gap. This stop starts with that code.

The recipe `docs` changes. With no words, it builds a site. With words, it works as before, so `just docs check`
is the same command.

{{include step-08.5}}

## The docs check joins `just check`

$ just setup

Since the last stop, the walk leaves out the move
[step-08.6](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html#step-08.6), in which the README names the
tests and the docs. This stop starts with that code.

One line in `check` runs the docs check.

{{include step-08.7}}

## The library, behind the same verbs

$ just setup

Since the last stop, the walk leaves out the first three moves of
[step-09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html). The library became a package of its own,
`wikirandom`, in `packages/wikirandom`, in a uv workspace. The app uses it, and `src/wikiapp/wikipedia.py` is gone.
This stop starts with that code.

Those moves did not change the justfile. One justfile, one `.pre-commit-config.yaml` and one hook serve both
packages. `just fmt`, `just lint` and `just types` read every Python file of the repository, so they checked the
library's code from the first move. `just test` measures the coverage of both packages, since the move step-09.3
added `--cov=wikirandom` to `pyproject.toml`. At the start of this stop, `just docs check` still counts only the
app and the tests, 12 of 12. This stop changes `docs/_smalldocs.yml`, behind the verb.

{{include step-09.4}}

The justfile did not change, and `just docs check` checks more. The hook and GitHub's job `check` run the new
docs check without a change.

## `just build`

$ just setup

The last verb is about the packages, not about checks, so `check` does not run it.

{{include step-10.1}}

## `just lint-config` checks the library too

$ just setup

Since the last stop, the walk leaves out the move
[step-10.2](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html#step-10.2). The app asks for wikirandom
0.1. This stop starts with that code.

From step-09.1 to here, validate-pyproject, in `just lint-config`, read only the app's `pyproject.toml`. The hook
and `just check` let every commit through with no check of the library's `pyproject.toml` against the standard.

{{include step-10.3}}

The verb has the same name, and its callers did not change. A file that a recipe leaves out is a file that no
caller checks. The fix goes in one place, the recipe, and all three callers have it.

The walk stops here. After it, the whole tutorial makes the last two moves of
[step-10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The library gets a licence and an author, both packages
get a link to the repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
