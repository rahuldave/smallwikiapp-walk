This walk takes the moves about format and lint out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts when the command and
its tests work, and no tool checks the code.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The moves add ruff, which formats the code and then finds problems in it. The next moves fix each problem. Then
a recipe checks the configuration, and another runs every check. A git hook runs them before each commit.

Later, the linter asks for a type on every parameter and return. The next moves add the types to the code and to
the tests, and `just check` runs the type checker too. The last move makes `just lint-config` check the
`pyproject.toml` of a second package.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

Between its steps, the whole tutorial makes moves that this walk does not show:

- **Before step-04.9,** the move [step-04.8](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.8). The `justfile` exports `UV_LOCKED`, so that
  `uv run` refuses a lockfile that is out of date.
- **Before step-05.3,** the first two moves of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). ty, a type checker, comes in, and
  `just types` runs it. The command reads its version from the installed package, by its name.
- **Before step-10.3,** the steps [06](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html) to [09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html) and the first two moves of
  [step-10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The tests that ask the real Wikipedia run only on request, so the tests no longer
  need the network. GitHub runs the tests. `random_page` returns a pydantic model, `Page`. smalldocs
  documents the code, and `just check` runs the check of the docs too. The library becomes a package of its own, `packages/wikirandom`, with its own
  `pyproject.toml`, and its tests are in `tests/test_wikirandom.py`. `just build` builds both packages, and the app asks for wikirandom 0.1.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
