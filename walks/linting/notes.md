We give `wikiapp` a formatter and a linter. `wikiapp` is a small command that prints the title and the summary of
a random Wikipedia page. A formatter writes every file in one style, so a change shows only what it changes. A
linter finds problems that the tests do not find.

This tutorial takes the parts about format and lint out of the
whole tutorial of smallwikiapp. It starts from the project that `uv init` made, for Python 3.13. The command
then gets its code, and the format and the lint check that code and its tests.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has ten sections:

1. **The project**
2. **The command**
3. **A formatter**
4. **The linter's rules**
5. **The linter's problems, fixed**
6. **A check of the configuration**
7. **`just check`, every check in one recipe**
8. **A git hook**
9. **The linter asks for types**
10. **The library's pyproject.toml too**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**Kinds of checks**

Each kind of check comes in at the section in the table.

| Kind | What it does | Where |
|---|---|---|
| Formatter | Changes how the code looks, never what it does | Section 3 |
| Linter | Finds problems in the code, against rules | Section 4 |
| A fix by the tool | A fix that ruff counts as safe, such as the order of imports | Section 5 |
| A fix by a person | The rest. ruff has no fix for some problems, and marks others unsafe | Section 5 |
| A check of the configuration | Finds errors in `pyproject.toml`, the lockfile and the justfile | Sections 6 and 10 |
| One recipe for every check | `just check` runs every check, and each `git commit` must pass it | Section 7 |
| A hook | Runs `just check` by itself, before each `git commit` | Section 8 |
| A linter's rule about types | Checks that each type is written. The type checker checks that it is right | Section 9 |

## The project

Before there is code to check, there is a project. This section shows what `uv init` made, and the command
`wikiapp`. The justfile lists the tasks of the project.

{{include step-00}}

## The command

The checks need code to check. The command asks Wikipedia for a random page, and prints its title and summary. It
sends a User-Agent, and has an option `--version`.

{{include step-01}}

## A formatter

$ just setup

The code now also has pytest, in a dependency group `test`, and uv installs every group. It has tests, with a
mock in place of Wikipedia, and coverage on every run. The code is split into a library,
`src/wikiapp/wikipedia.py`, and the command. The command has an option `--language`. The library takes a language
and raises its own error, `WikipediaError`, and the command prints it as a message.

The code mixes styles, and nothing keeps one style. ruff comes in, in a new group `lint`, and `just fmt` formats
the code and the tests.

{{include step-04.1..step-04.3}}

## The linter's rules

$ just setup

A linter needs rules to check. The rules go in `pyproject.toml`, and `just lint` finds five problems.

{{include step-04.4}}

## The linter's problems, fixed

$ just setup

The linter found five problems. A person fixes the tests, and gives the request a timeout. Then
`just lint --fix` fixes the last problem, the order of the imports.

{{include step-04.5..step-04.7}}

The linter finds no problem now. Of its five problems, ruff fixed one, and a person fixed four.

## A check of the configuration

$ just setup

The linter reads the Python code, and nothing checks the files that set up the project. `just lint-config` checks
`pyproject.toml`, the lockfile and the justfile.

{{include step-04.8..step-04.9}}

## `just check`, every check in one recipe

$ just setup

The code now also has recipes that refuse a lockfile that is out of date.

Each check is a recipe of its own, and a person must remember to run them all. `just check` runs the format, the
linter, the tests and the configuration, in order.

{{include step-04.11}}

Later in the whole tutorial, GitHub runs `just check` too, on every push to main and every pull request.

## A git hook

$ just setup

A person can forget to run `just check`. `pre-commit` runs three small checks of the files, then `just check`,
before each `git commit`.

{{include step-04.12..step-04.13}}

## The linter asks for types

$ just setup

The code now also has ty, a type checker, which `just types` runs. The command reads its version by the name of
its package.

ty checks only the types that the code writes. A rule asks for a type on every parameter and return. The code and
the tests get their types.

{{include step-05.4..step-05.6}}

## The library's pyproject.toml too

$ just setup

The code now also has the type checker in `just check`. The tests that ask the real Wikipedia run
only on request. The project accepts any Python from 3.11 on. GitHub runs the tests and `just check`. The job `tests` on GitHub installs the group `test` alone, and a
workflow publishes the docs site.

`random_page` returns a pydantic model, `Page`. smalldocs documents the code, and `just check` runs the check of
the docs. The library is a package of its own, `packages/wikirandom`, with its own `pyproject.toml`. `just build`
builds both packages, and the app asks for wikirandom 0.1.

Until this section, `just lint-config` checks only the app's `pyproject.toml`. After it, `just lint-config` also
checks the library's `pyproject.toml`.

{{include step-10.3}}

This tutorial ends here. After it, the whole tutorial gives the library a licence. Both packages get a link to the
repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.
