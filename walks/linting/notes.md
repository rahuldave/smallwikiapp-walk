We give `wikiapp` a formatter and a linter. `wikiapp` is a small command that prints the title and the summary of
a random Wikipedia page. A formatter writes every file in one style. Then, when someone changes the code, the list of
changed lines shows only what they meant to change, and no changes of style. A linter finds problems that the tests do not find.

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
| One recipe for every check | `just check` runs every check, one after the other | Section 7 |
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

The code now also has tests, and pytest runs them. pytest is in a dependency group `test`, a named list of
packages in `pyproject.toml`, and uv installs every group. In the tests, a mock takes the place of Wikipedia, so
the tests never ask the real site. Each run of the tests also measures the coverage, the share of the lines of
code that the tests run.

The code is split into a library,
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

The lockfile, `uv.lock`, lists the exact version of each package. Until now, `uv run` updated it without a
word. The justfile now sets `UV_LOCKED`, so each recipe that runs `uv` refuses a lockfile that is out of date.

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

The code now also has ty, a type checker, which `just types` runs. A type says what kind of value a name has, for
example a string or a number. The code found the name of its package with
`__name__ or __package__`. It gave that name to `importlib.metadata.version`, which looks up the version of a
package. ty found that the name could be None, the value Python uses for no value at all, but
`importlib.metadata.version` needs a string. So the code now gives it the string `"wikiapp"`, the name of its
package.

ty checks only the types that are written in the code, and the code has almost none. ruff's rules `ANN` report
each parameter and each return value that has no type. Then the code and the tests get their types.

{{include step-05.4..step-05.6}}

## The library's pyproject.toml too

$ just setup

The code now also has the type checker in `just check`. The project accepts any Python from 3.11 on. On every push
to main, GitHub runs the tests and `just check`, and it publishes a site with the docs.

`random_page`, the function of the library that asks Wikipedia for a random page, returns a `Page`. A `Page`
has a title and a summary, and pydantic, a library that checks data, checks that the answer of Wikipedia has
both. smalldocs documents the code, and `just check` runs the check of
the docs. The library is a package of its own, `packages/wikirandom`, with its own `pyproject.toml`. `just build`
builds both packages. The app is the package `wikiapp`, and it needs a 0.1 version of wikirandom.

Until this section, `just lint-config` checks only the app's `pyproject.toml`. After it, `just lint-config` also
checks the library's `pyproject.toml`.

{{include step-10.3}}

This tutorial ends here. After it, the whole tutorial gives the library a licence. Both packages get a link to the
repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.
