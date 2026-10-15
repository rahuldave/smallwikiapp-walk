We build the tests of `wikiapp`, a small command that prints the title and the summary of a random Wikipedia
page. A test runs the code and checks what it gives back, so a later change cannot break the command without a
failure. This tutorial takes the parts about tests out of the whole tutorial of smallwikiapp. It starts from the
project that `uv init` made, for Python 3.13. Then the command gets its code, and the tests come after it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has fourteen sections:

1. **The project**
2. **The command under test**
3. **pytest and a first test**
4. **Fixtures and mocks**
5. **Coverage**
6. **A shared mock in conftest.py**
7. **A test of the language**
8. **A test of an error message**
9. **`just check`, with a coverage floor**
10. **End-to-end tests, on request**
11. **The tests on GitHub**
12. **Tests of a model**
13. **A drop in coverage**
14. **GitHub installs only the test tools**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**Kinds of tests**

Each kind of test comes in at the section in the table. The tutorial adds no test for the sake of a kind.

| Kind | What it checks | Where |
|---|---|---|
| End-to-end | The code against the real Wikipedia, with no mock | Section 3. From section 10, it runs only when you ask for it |
| Unit | One part of the code alone, with a mock in place of the network | Section 4 for the command, until section 6 moves the request into a library. Section 7 for the library |
| Integration | The command and the library together, with only the network a mock | Section 6. The unit tests of the command become integration tests |
| Contract | That the real Wikipedia still answers as the mocks do | Section 10 |

## The project

Before there is code to test, there is a project. This section shows what `uv init` made, and the command
`wikiapp`. The justfile lists the tasks of the project.

{{include step-00}}

## The command under test

The tests need a command to test. The command asks Wikipedia for a random page, and prints its title and summary.
It sends a User-Agent, and has an option `--version`. The next sections test this command.

{{include step-01}}

## pytest and a first test

$ just setup

We can check the command only by running it and reading what it prints. pytest runs tests for us, and `just test`
runs them all.

{{include step-02.1..step-02.4}}

## Fixtures and mocks

$ just setup

The first test asks the real Wikipedia, so it is slow and needs the network. A fixture is a function that pytest
calls for each test that names it as a parameter. One fixture gives each test a runner, which runs the command and keeps what
it prints. A mock is a stand-in that takes the place of Wikipedia. Tests check the title that the command prints, and the request. A failed
request ends the command with exit code 1.

{{include step-02.5..step-02.9}}

The command now has four tests that use the mock, and one that asks the real Wikipedia.

## Coverage

$ just setup

The tests pass, but nothing says which lines of the code they run. From now on, each run of the tests measures
the coverage, the share of the lines that the tests run.

{{include step-02.10..step-02.11}}

## A shared mock in conftest.py

$ just setup

The code now has a library, a new module `src/wikiapp/wikipedia.py`, with a function `random_page`. The request
moved out of the command into `random_page`, and the command calls it.

Tests of the library need the mock too, and it is in the tests of the command. The mock goes to
`tests/conftest.py`, so that every test file can use it.

{{include step-03.2}}

## A test of the language

$ just setup

`random_page` asks only the English Wikipedia. It takes a language now, and a test checks the address.

{{include step-03.3}}

## A test of an error message

$ just setup

The code now also has an option `--language` on the command. When a request fails, `random_page` raises an error
of its own, `WikipediaError`.

The command should print that error as a message, not as a traceback. A test checks that a failed request prints
`Error`.

{{include step-03.6}}

## `just check`, with a coverage floor

$ just setup

The code now also has ruff, which formats the code and the tests with `just fmt`, and lints them with
`just lint`. `just lint-config` checks the configuration. In the tests, the linter found an import below the code,
and unused variables, and a person fixed them. `just lint --fix` sorted the imports of the command. The request
has a timeout of 10 seconds, and the recipes refuse a lockfile that is out of date.

Each check is a recipe of its own, and a person must remember to run them all. A new recipe, `just check`, runs
every check. One of them fails when the tests run less than 90% of the code.

{{include step-04.11}}

## End-to-end tests, on request

$ just setup

The code now also has a git hook, which `just hook` installs. Before each `git commit`, `pre-commit` runs three
small checks of the files, then `just check`.

The code also has ty, a type checker. A type says what kind of value a name has, for example a string or a
number. Each function of the code and the tests now names the types of its arguments and of the value it returns.
`random_page` returns `dict[str, Any]`, a dictionary whose keys are strings, and `just check` runs ty too. The
command also looks up its version by the fixed name of its package, `wikiapp`.

The test that asks the real Wikipedia fails without the network, and so every check fails with it. It now runs
only when you ask for it. A second test of that kind checks the library.

{{include step-06.1..step-06.2}}

The project now has all four kinds of tests in the table of the intro. They are end-to-end, unit, integration and
contract.

## The tests on GitHub

$ just setup

The tests run on one machine, with one version of Python. The project asks for Python 3.13 or newer. In this
section it starts to accept any version of Python from 3.11 on. Then GitHub runs the tests on three
systems and four versions of Python.

{{include step-06.3..step-06.5}}

## Tests of a model

$ just setup

The code now also has pydantic, and `wikipedia.py` has `Page`, a pydantic model with a title and an extract.

`random_page` returns a `Page` in place of a dictionary, so one test changes. An answer that is not a page is a
`WikipediaError` too, and a new test checks it.

{{include step-07.3..step-07.4}}

## A drop in coverage

$ just setup

A language that is not a language code can send the request to another site. New code checks the language, and
no test reaches it, so the coverage drops.

{{include step-07.5}}

## GitHub installs only the test tools

$ just setup

The code now also has smalldocs, in a group `docs`. The code and the tests have docstrings, and `just check` runs
a check of the docs. `just docs` builds a site, and the README names the tests and the docs.

GitHub installs every tool of the project to run the tests, and the tests need only pytest and its plugins. This
section changes what GitHub installs to run the tests.

{{include step-08b.1}}

This tutorial ends here. After it, the whole tutorial adds a workflow that publishes the docs. The library becomes
a package of its own, wikirandom. Its tests go to `tests/test_wikirandom.py`, and coverage measures both packages.
The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.
