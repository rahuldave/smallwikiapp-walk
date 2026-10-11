This walk takes the moves about documentation out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts when the code is
tested, linted and typed, and has almost no documentation.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The moves add smalldocs, which makes the reference from the code and says what has no documentation. Next, the
library, the command and the tests get their docstrings and docments. Then smalldocs builds a site, and the
README names the tests and the docs. The check of the documentation joins `just check`. The last two moves
come after the library becomes a package of its own. The check counts the library, and the front page and the
README name both packages.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

The steps before this walk give the code what the docs describe. [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) adds ruff,
`just check`, and a git hook that runs `just check` before each commit. [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html) adds the
types. In [step-06](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html), the tests that ask the real Wikipedia run only on request, and GitHub runs
the tests. In [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html), `random_page` returns a `Page`, a pydantic model with a title and an
extract.

Before step-09.4, the first three moves of [step-09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html) make the library a package of its own,
`wikirandom`, in `packages/wikirandom`. The app uses it, and `src/wikiapp/wikipedia.py` is gone. The tests of the library are now
`tests/test_wikirandom.py`.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
