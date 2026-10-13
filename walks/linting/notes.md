This walk takes the moves about format and lint out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts with the project, which
`uv init` began, for Python 3.13. The command then gets its code. The moves about format and lint come after, and
check that code and its tests.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has ten stops. Each stop takes a whole step, one move, or a few moves in a row:

1. **The project** (step-00)
2. **The command** (step-01)
3. **A formatter** (step-04.1 to step-04.2)
4. **The linter's rules** (step-04.3)
5. **The linter's problems, fixed** (step-04.4 to step-04.6)
6. **A check of the configuration** (step-04.7)
7. **`just check`, every check in one recipe** (step-04.9)
8. **A git hook** (step-04.10)
9. **The linter asks for types** (step-05.3 to step-05.5)
10. **The library's pyproject.toml too** (step-10.3)

Where the whole tutorial makes moves that this walk leaves out, the next stop says what they did. The stop
starts from their code.

**Kinds of checks**

The walk names each kind of check where it first comes in.

| Kind | What it does | Where |
|---|---|---|
| Formatter | Changes how the code looks, never what it does | Stop 3 |
| Linter | Finds problems in the code, against rules | Stop 4 |
| A fix by the tool | A fix that ruff counts as safe, such as the order of imports | Stop 5 |
| A fix by a person | The rest. ruff has no fix for some problems, and marks others unsafe | Stop 5 |
| A check of the configuration | Finds errors in `pyproject.toml`, the lockfile and the justfile | Stops 6 and 10 |
| A gate | `just check` runs every check, and a commit must pass it | Stop 7 |
| A hook | Runs the gate by itself, before each commit | Stop 8 |
| A linter's rule about types | Checks that each type is written. The type checker checks that it is right | Stop 9 |

## The project

This stop is all of step-00. It shows what `uv init` made, and the command `wikiapp`. The justfile lists the
tasks of the project.

{{include step-00}}

## The command

This stop is all of step-01. The command asks Wikipedia for a random page, and prints its title and summary. It
sends a User-Agent, and has an option `--version`.

{{include step-01}}

## A formatter

$ just setup

Since the last stop, the walk leaves out the steps [02](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html)
and [03](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html). pytest came in, in a dependency group `test`,
which the group `dev` includes. Tests came in, with a mock in place of Wikipedia, and coverage on every run.

The code split into a library, `src/wikiapp/wikipedia.py`, and the command. The command got an option
`--language`. The library takes a language and raises its own error, `WikipediaError`, and the command prints it
as a message. This stop starts with that code.

ruff comes in, and `just fmt` formats the code and the tests.

{{include step-04.1..step-04.2}}

## The linter's rules

$ just setup

The rules of the linter go in `pyproject.toml`, and `just lint` finds five problems.

{{include step-04.3}}

## The linter's problems, fixed

$ just setup

ruff fixes the order of the imports. A person fixes the tests, and gives the request a timeout.

{{include step-04.4..step-04.6}}

The linter finds no problem now. Of its five problems, ruff fixed one, and a person fixed four.

## A check of the configuration

$ just setup

`just lint-config` checks `pyproject.toml`, the lockfile and the justfile.

{{include step-04.7}}

## `just check`, every check in one recipe

$ just setup

Since the last stop, the walk leaves out the move
[step-04.8](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.8). The recipes now refuse a
lockfile that is out of date. This stop starts with that code.

`just check` runs the format, the linter, the tests and the configuration, in order.

{{include step-04.9}}

From the move [step-06.4](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.4), which this walk
leaves out, GitHub runs `just check` too, on every push to main and every pull request.

## A git hook

$ just setup

pre-commit runs three small checks of the files, then `just check`, before each commit.

{{include step-04.10}}

## The linter asks for types

$ just setup

Since the last stop, the walk leaves out the first two moves of
[step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). ty, a type checker, came in, and
`just types` runs it. The command reads its version by the name of its package. This stop starts with that code.

A rule asks for a type on every parameter and return. The code and the tests get their types.

{{include step-05.3..step-05.5}}

## The library's pyproject.toml too

$ just setup

Since the last stop, the walk leaves out the last move of
[step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html), the steps
[06](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html) to
[09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html), and the first two moves of
[step-10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). `just check` runs the type checker too.

The tests that ask the real Wikipedia run only on request. GitHub runs the tests and `just check`, and
publishes the docs site.

`random_page` returns a pydantic model, `Page`. smalldocs documents the code, and `just check` runs the check of
the docs. The library became a package of its own, `packages/wikirandom`, with its own `pyproject.toml`.
`just build` builds both packages, and the app asks for wikirandom 0.1. This stop starts with that code.

`just lint-config` checks the library's `pyproject.toml` too.

{{include step-10.3}}

The walk stops here. After it, the whole tutorial makes the last two moves of
[step-10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The library gets a licence, both packages
get a link to the repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
