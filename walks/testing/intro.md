This walk takes the moves about tests out of the whole tutorial of smallwikiapp. `wikiapp` is a small command
that prints the title and the summary of a random Wikipedia page. The walk starts with the project, which `uv init`
began, for Python 3.13. Then the command gets its code, and the tests come after it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has thirteen stops. Each stop takes a whole step, one move, or a few moves in a row:

1. **The project.** What `uv init` made, and the command `wikiapp`. The justfile lists the tasks of the
   project.
2. **The command under test.** The command asks Wikipedia for a random page, and prints its title and summary.
   It sends a User-Agent, and has an option `--version`.
3. **pytest and a first test.** pytest comes in, with a first test, and `just test` runs the tests.
4. **Fixtures and mocks.** A fixture gives each test a runner, and a mock takes the place of Wikipedia. Tests
   check the title that the command prints, and the request. A failed request ends the command with exit code 1.
5. **Coverage.** Every run of the tests measures the lines of the code that they run.
6. **A shared mock in conftest.py.** The mock moves to `tests/conftest.py`, so that every test file can use it.
7. **A test of the language.** `random_page` takes a language, and a test checks the address.
8. **A test of an error message.** The command prints an error of the library, `WikipediaError`, as a message.
   A test checks that a failed request prints `Error`.
9. **`just check`, with a coverage floor.** A new recipe, `just check`, runs every check. One of them fails when
   the tests run less than 90% of the code.
10. **End-to-end tests, on request.** The test that asks the real Wikipedia runs only when you ask for it. A
    second test of that kind checks the library.
11. **The tests on GitHub.** The project accepts any Python from 3.11 on. GitHub runs the tests on three
    systems and four Pythons.
12. **Tests of a model.** `random_page` returns a pydantic model. One test changes. An answer that is not a page
    is a `WikipediaError` too, and a new test checks it.
13. **A drop in coverage.** New code has no test, and the coverage drops. The tutorial adds no test to hide it.

Each stop starts with `just setup`. From the second stop on, it starts from the code before it.

## Kinds of tests

The walk names each kind of test where it first comes in. The tutorial adds no test for the sake of a kind.

| Kind | What it checks | Where |
|---|---|---|
| End to end | The code against the real Wikipedia, with no mock | Stop 3. From stop 10, it runs only when you ask for it |
| Unit | One part of the code alone, with a mock in place of the network | Stop 4 for the command, until the code splits in two. Stop 7 for the library |
| Integration | The command and the library together, with only the network a mock | Stop 6. The unit tests of the command become integration tests |
| Contract | That the real Wikipedia still answers as the mocks do | Stop 10 |

On GitHub, from stop 11, the unit and integration tests run on every push to main and every pull request. The end-to-end tests do not.

## What the walk leaves out

Between its stops, the whole tutorial makes moves that this walk does not show:

- **Before stop 6,** the move [step-03.1](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.1). The request moves out of the command,
  into a function `random_page` in a new module, `src/wikiapp/wikipedia.py`. The notes call this module the
  library, and the command uses it.
- **Before stop 8,** the moves [step-03.4](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.4) and
  [step-03.5](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.5). The command gets an option `--language`. When a
  request fails, `random_page` raises an error of its own, `WikipediaError`.
- **Before stop 9,** the first eight moves of [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html). ruff formats the code and lints it,
  with `just fmt` and `just lint`, and `just lint-config` checks the configuration. ruff formats the tests too. In
  the tests, its linter finds an import below the code and unused variables, and a person fixes them. The request gets a
  timeout of 10 seconds, and the recipes refuse a lockfile that is out of date.
- **Before stop 10,** the last move of [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) and the whole of
  [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). `just hook` installs a git hook.
  Before each commit, pre-commit runs three small checks of the files, then `just check`. ty checks the types,
  and the command reads its version by the name of its package. The code and the tests get their types.
  `random_page` returns `dict[str, Any]`, and `just check` runs the type checker too.
- **Before stop 12,** the move [step-07.1](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html#step-07.1). pydantic comes in, and
  `wikipedia.py` gets `Page`, a pydantic model with a title and an extract.
- **After stop 13,** the steps [08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html) to [10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The tests get their docstrings. The library becomes
  a package of its own, wikirandom. Its tests move to `tests/test_wikirandom.py`, and coverage measures both
  packages.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
