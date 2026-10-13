This walk takes the moves about tests out of the whole tutorial of smallwikiapp. `wikiapp` is a small command
that prints the title and the summary of a random Wikipedia page. The walk starts with the project, which `uv init`
began, for Python 3.13. Then the command gets its code, and the tests come after it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has fourteen stops. Each stop takes a whole step, one move, or a few moves in a row:

1. **The project** (step-00)
2. **The command under test** (step-01)
3. **pytest and a first test** (step-02.1 to step-02.2)
4. **Fixtures and mocks** (step-02.3 to step-02.6)
5. **Coverage** (step-02.7)
6. **A shared mock in conftest.py** (step-03.2)
7. **A test of the language** (step-03.3)
8. **A test of an error message** (step-03.6)
9. **`just check`, with a coverage floor** (step-04.9)
10. **End-to-end tests, on request** (step-06.1 to step-06.2)
11. **The tests on GitHub** (step-06.3 to step-06.4)
12. **Tests of a model** (step-07.2 to step-07.3)
13. **A drop in coverage** (step-07.4)
14. **The tests with their group alone** (step-08b.1)

Where the whole tutorial makes moves that this walk leaves out, the next stop says what they did. The stop
starts from their code.

**Kinds of tests**

The walk names each kind of test where it first comes in. The tutorial adds no test for the sake of a kind.

| Kind | What it checks | Where |
|---|---|---|
| End to end | The code against the real Wikipedia, with no mock | Stop 3. From stop 10, it runs only when you ask for it |
| Unit | One part of the code alone, with a mock in place of the network | Stop 4 for the command, until the code splits in two. Stop 7 for the library |
| Integration | The command and the library together, with only the network a mock | Stop 6. The unit tests of the command become integration tests |
| Contract | That the real Wikipedia still answers as the mocks do | Stop 10 |

## The project

This stop is all of step-00. It shows what `uv init` made, and the command `wikiapp`. The justfile lists the
tasks of the project.

{{include step-00}}

## The command under test

This stop is all of step-01. The command asks Wikipedia for a random page, and prints its title and summary. It
sends a User-Agent, and has an option `--version`. The tests of the next stops test this command.

{{include step-01}}

## pytest and a first test

$ just setup

pytest comes in, with a first test, and `just test` runs the tests.

{{include step-02.1..step-02.2}}

## Fixtures and mocks

$ just setup

A fixture gives each test a runner, and a mock takes the place of Wikipedia. Tests check the title that the
command prints, and the request. A failed request ends the command with exit code 1.

{{include step-02.3..step-02.6}}

The command now has four tests that use the mock, and one that asks the real Wikipedia.

## Coverage

$ just setup

Every run of the tests now measures the lines of the code that they run.

{{include step-02.7}}

## A shared mock in conftest.py

$ just setup

Since the last stop, the walk leaves out the move
[step-03.1](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.1). The request moved out of the
command, into a function `random_page` in a new module, `src/wikiapp/wikipedia.py`. The notes call this module
the library, and the command uses it. This stop starts with that code.

The mock moves to `tests/conftest.py`, so that every test file can use it.

{{include step-03.2}}

## A test of the language

$ just setup

`random_page` takes a language, and a test checks the address.

{{include step-03.3}}

## A test of an error message

$ just setup

Since the last stop, the walk leaves out the moves
[step-03.4](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.4) and
[step-03.5](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.5). The command got an option
`--language`. When a request fails, `random_page` raises an error of its own, `WikipediaError`. This stop starts
with that code.

The command prints `WikipediaError` as a message, and a test checks that a failed request prints `Error`.

{{include step-03.6}}

## `just check`, with a coverage floor

$ just setup

Since the last stop, the walk leaves out the first eight moves of
[step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html). ruff formats the code and lints it, with
`just fmt` and `just lint`, and `just lint-config` checks the configuration. ruff formats the tests too.

In the tests, its linter finds an import below the code and unused variables, and a person fixes them. The request got
a timeout of 10 seconds, and the recipes refuse a lockfile that is out of date. This stop starts with that code.

A new recipe, `just check`, runs every check. One of them fails when the tests run less than 90% of the code.

{{include step-04.9}}

## End-to-end tests, on request

$ just setup

Since the last stop, the walk leaves out the last move of
[step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) and the whole of
[step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). `just hook` installs a git hook. Before
each commit, pre-commit runs three small checks of the files, then `just check`.

ty checks the types, and the command reads its version by the name of its package. The code and the tests got their
types. `random_page` returns `dict[str, Any]`, and `just check` runs the type checker too. This stop starts with
that code.

The test that asks the real Wikipedia runs only when you ask for it. A second test of that kind checks the
library.

{{include step-06.1..step-06.2}}

The project now has all four kinds of tests in the table of the intro. They are end to end, unit, integration and
contract.

## The tests on GitHub

$ just setup

The project accepts any Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

{{include step-06.3..step-06.4}}

## Tests of a model

$ just setup

Since the last stop, the walk leaves out the move
[step-07.1](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html#step-07.1). pydantic came in, and
`wikipedia.py` got `Page`, a pydantic model with a title and an extract. This stop starts with that code.

`random_page` returns a `Page`. One test changes. An answer that is not a page is a `WikipediaError` too, and a
new test checks it.

{{include step-07.2..step-07.3}}

## A drop in coverage

$ just setup

New code has no test, and the coverage drops.

{{include step-07.4}}

## The tests with their group alone

$ just setup

Since the last stop, the walk leaves out [step-08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html).
smalldocs came in, in a group `docs`. The code and the tests got docstrings, and `just check` runs a check of the
docs. This stop starts with that code.

This stop changes what GitHub installs to run the tests.

{{include step-08b.1}}

The walk stops here. After it, the whole tutorial adds a workflow that publishes the docs, and makes the steps
[09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html) and
[10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The library becomes a package of its own,
wikirandom. Its tests move to `tests/test_wikirandom.py`, and coverage measures both packages. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
