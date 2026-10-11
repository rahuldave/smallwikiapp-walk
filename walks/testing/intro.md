This walk takes the moves about tests out of the whole tutorial of smallwikiapp. `wikiapp` is a small command
that prints the title and the summary of a random Wikipedia page. The walk starts when the command works and has
no tests.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The moves add pytest and a first test, and the recipe `just test`. Then come a fixture, a mock in place of
Wikipedia, tests of the request and of a failed request, and the coverage of every run.

Then the code splits into a library, `wikipedia.py`, and the command. The mock moves to `conftest.py`, so that
the library gets tests of its own. The library gets a language, the command an option `--language`, and the
library an error, `WikipediaError`. The command turns the error into a message, and a test checks it. One move
gives the tests their types.

The test that asks the real Wikipedia then runs only when you ask for it, and the library gets a test of the
same kind. The project accepts any Python from 3.11 on. GitHub runs the tests, except the two that ask Wikipedia.
When the library starts to return a pydantic model, one move renames a test, and the next adds one. The last move
documents the tests.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

Between its steps, the whole tutorial makes moves that this walk does not show:

- **Before step-05.5,** [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) and the first four moves of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html).
  ruff formats the code and lints it, and the request gets a timeout of 10 seconds. ruff also formats the
  tests, moves their imports to the top and removes unused variables. `just check` fails when the tests run less
  than 90% of the code. `just check` runs every check, and pre-commit runs it as a git hook
  before each commit. ty checks the types, and `just types` runs it. ruff's `ANN` rules ask for a type on
  every parameter and return, and the code gets its types.
- **Before step-06,** the last move of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). `just check` runs `just types` too.
- **Before step-07.2,** the move [step-07.1](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html#step-07.1). pydantic comes in, and
  `wikipedia.py` gets `Page`, a pydantic model with a title and an extract.
- **Before step-08.4,** the last move of [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html) and the first three moves of
  [step-08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html). `random_page` checks the language before it puts it in the address. smalldocs
  comes in, and `just docs check` counts the functions and classes that have their types, docments and
  docstrings. The library and the command get theirs.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
