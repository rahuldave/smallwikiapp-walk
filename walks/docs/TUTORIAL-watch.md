<!-- Made by timewalk-tutorial from the notes of the walk. Do not edit it by hand: run timewalk-tutorial again. -->

# Documenting smallwikiapp, one move at a time

In watch mode, you read each move. The notes explain what it changed, and its commit holds the code. [The same tutorial in do mode](TUTORIAL-do.md).

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

## step-08 Docs from the code

[The code at step-08](https://github.com/rahuldave/smallwikiapp/tree/step-08)

```bash
just setup
```

The moves of this step add documentation:

- smalldocs, which makes the reference from the code, and says what has no documentation
- the documentation of the library, of the command and of the tests
- a site
- the tests and the docs in the README's table of folders
- the check of the documentation in `just check`

### step-08.1 smalldocs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/36d19bddbbb90c669475d6ffbdf26b7b346c4f18) shows what the move changes.

The reference of a function gives its signature, what it does, and what each parameter is. The signature and
the types are in the code. The docstring says what the function does. A docment says what each parameter is. A
docment is the comment beside a parameter, with one parameter to a line.

The block below shows `random_page` with its docments. You write it in the next move, not in this move.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

smalldocs reads all three, and writes the reference as Markdown. It is a Python package, so uv installs it like
any other. smalldocs goes in a fourth dependency group, `docs`, and `dev` includes that group. In
`pyproject.toml`, change the line `dev = ...`, and add the group on the line after it.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```

```
uv add --group docs smalldocs
```

smalldocs reads its settings from `docs/_smalldocs.yml`. For now the file has one section, `api`, the
reference. Make the file with these lines.

```yaml
# The settings of smalldocs. `api` is the reference, made from the code of the packages
api:
  packages: [wikiapp]
  source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
  check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

`smalldocs api` has two commands that this step uses:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

Add a recipe at the end of the `justfile`.

```just

# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
[group('docs')]
[no-exit-message]
docs *args:
    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

The move changed these files:

- `docs/_smalldocs.yml`: a new file, with the settings of the reference.
- `justfile`: the recipe `docs`.
- `pyproject.toml`: the group `docs`, with smalldocs.
- `uv.lock`: the exact version of smalldocs and of the packages it needs.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/36d19bddbbb90c669475d6ffbdf26b7b346c4f18/docs/_smalldocs.yml): the package to document, and the tests to check.
  - look at: `packages: [wikiapp]`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/36d19bddbbb90c669475d6ffbdf26b7b346c4f18/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/36d19bddbbb90c669475d6ffbdf26b7b346c4f18#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/36d19bddbbb90c669475d6ffbdf26b7b346c4f18/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/36d19bddbbb90c669475d6ffbdf26b7b346c4f18#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `docs *args:`

```bash
uv run smalldocs api module wikipedia --dir docs
uv run smalldocs api check --dir docs
just --show docs
just docs check
```

`module` prints the reference of `wikipedia.py`, with empty descriptions. For each module and each test file,
`check` counts the functions and classes that are complete. Then it lists every gap, and fails with `1 of 15
functions, methods and classes are typed and documented`. The one is `WikipediaError`, which needs only its
docstring. Above the total, `check` names every gap, and the five modules without a docstring are among them.

### step-08.2 The library documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5a169fc1223a30099ff265f93e2c061b1ef2ed7c) shows what the move changes.

In `src/wikiapp/wikipedia.py`, add these:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

```python
"""Wikipedia's REST API: a random page."""

```

```python
class Page(BaseModel):
    """A page of Wikipedia: its title and the summary of its text."""

    title: str  # The title of the page
    extract: str  # The summary: the first paragraph of the page, as plain text


def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
    """Get a random page from Wikipedia.

    Raises WikipediaError when the language is not a language code, when the request fails, or
    when the answer is not a page.
    """
```

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

The move changed this file:

- `src/wikiapp/wikipedia.py`: a docstring for the module, docments, and a longer docstring.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/5a169fc1223a30099ff265f93e2c061b1ef2ed7c/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/5a169fc1223a30099ff265f93e2c061b1ef2ed7c#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the comments are the documentation.
  - look at: `) -> Page:  # A page chosen at random`

```bash
just docs module wikipedia
```

The tables now have their descriptions.

### step-08.3 The command documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367) shows what the move changes.

Add a docstring at the top of `src/wikiapp/__init__.py` and of `src/wikiapp/console.py`.

```python
"""wikiapp: the title and summary of a random Wikipedia page."""

```

```python
"""The wikiapp command."""

```

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class. Python
still shows it, in `help(wikiapp)`.

In `console.py`, give `main` one parameter to a line, with its docment, and a docstring that says what `main`
prints. A function that returns None needs no docment for its return. `wikiapp --help` prints the docstring and
the help of each option, so those are documentation too. The help of `--language` now says what a language is.
It replaces the help of the original wikiapp, "Gets random page from Wikipedia in given language".

```python
    help="The language of the Wikipedia to ask, as its code: en, fr, es",
```

```python
def main(
    language: str,  # The language of the Wikipedia to ask, from --language
) -> None:
    """Print the title and summary of a random Wikipedia page, in the language asked for.

    The title is in green, and the summary is wrapped to 70 columns.
    """
```

The move changed these files:

- `src/wikiapp/__init__.py`: a docstring for the module.
- `src/wikiapp/console.py`: a docstring for the module, the documentation of `main`, and the help of `--language`.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the docment, the docstring and the help.
  - look at: `language: str,  # The language of the Wikipedia to ask, from --language`

```bash
just docs module console
uv run wikiapp --help
```

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff) shows what the move changes.

A docment is the comment beside a parameter, or after the colon of the `def` line for the return.
`just docs check`, from step-08.1, counts the functions and classes that have their types, docments and
docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code.

`tests/test_console.py` shows the pattern best. Each parameter of a test has a docment, and the docstring of
the test is one line.

The move changed these files:

- `tests/conftest.py`: a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: a docstring for the file, the fixture and each test, and a docment for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/49e01b4ba130cbba887a160c8d845e4196897e8a) shows what the move changes.

smalldocs also makes a website from Markdown. The site is in `docs/`. It has a front page, `index.qmd`, and a
reference page for each module. Each build writes the reference pages from the code, before it builds the site.
A name in backticks, such as `random_page`, becomes a link to its entry.

The move adds the front page, `docs/index.qmd`. A `.qmd` file is Markdown, with a header between two `---` lines
that gives the title of the page. It also adds the settings of the site to `docs/_smalldocs.yml`.
The settings are the type of the project, its output folder, the title, the sidebar, the theme and a table of
contents on each page. `just docs` with no words builds the site.

Read `docs/_smalldocs.yml` first. Its new lines are the settings of the site, above the section `api`.

The move changed these files:

- `docs/_smalldocs.yml`: the settings of the site above the section `api`, and a comment above `api`. The
  comment at the top now says that `just docs` builds the site.
- `docs/index.qmd`: a new file, the front page.
- `justfile`: with no words, `docs` builds the site, and its comment says so. The recipe is now a script of
  several lines.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/49e01b4ba130cbba887a160c8d845e4196897e8a/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/49e01b4ba130cbba887a160c8d845e4196897e8a#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the site. The sidebar lists the front page, then the reference pages.
  - look at: `contents: api/*  # the reference pages, which each build makes from the code`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/49e01b4ba130cbba887a160c8d845e4196897e8a/docs/index.qmd): the front page, written by hand.
  - look at: `Each build of the site makes the pages under Reference from the code.`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/49e01b4ba130cbba887a160c8d845e4196897e8a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/49e01b4ba130cbba887a160c8d845e4196897e8a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): with no words, `docs` builds the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

```bash
uv run smalldocs render docs
just --show docs
just docs
```

smalldocs prints `wrote 3 page(s) to docs/_site`. Open `docs/_site/index.html` in a browser. On the front page,
`random_page` is a link to its entry. Each build makes the site and the reference pages, and git ignores
them.

### step-08.6 The README names the tests and the docs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e1f81d1d14b883402dc65cc0129bf99a139c387b) shows what the move changes.

The README gets `tests/` and `docs/` among the folders. It also says that `wikipedia.py` is the library and
`console.py` the command.

The move changed this file:

- `README.md`: rows for `tests/` and `docs/`, and the `src/wikiapp/` row names the library and the command.

Files to read:
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/e1f81d1d14b883402dc65cc0129bf99a139c387b/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/e1f81d1d14b883402dc65cc0129bf99a139c387b#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): the folders.
  - look at: `| The docs site. smalldocs makes its reference from the code |`

```bash
grep -n -E 'tests/|docs/' README.md
```

`grep` prints the two new rows of the table.

### step-08.7 The docs check in `just check`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/86367b4256bbe5096403d613a77fd3f8da6ead58) shows what the move changes.

In the `justfile`, in `check`, run `just docs check` after the tests. Replace the comment above `check` with
the first line below.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

```just
    just test -q --cov-fail-under=90
    just docs check
```

The move changed this file:

- `justfile`: the docs check in `check`, and the comment.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/86367b4256bbe5096403d613a77fd3f8da6ead58/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/86367b4256bbe5096403d613a77fd3f8da6ead58#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in `check`.
  - look at: `just docs check`

```bash
just check
```

The docs check prints `15 of 15`. Now the git hook refuses a commit that leaves a function, a parameter or a
field without documentation.

## step-09.4 to step-09.5

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/517abf247f7a42038536d843fe7585f745d57897), the commit before step-09.4.

```bash
just setup
```

### step-09.4 The docs check counts the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/426d87e7d66b979bbc8b1d6067583395ab08e01c) shows what the move changes.

Since step-09.3, the app uses the library `wikirandom`, a package of its own in `packages/wikirandom`. But
`docs/_smalldocs.yml` names only `wikiapp`. Change the line `packages:` in the section `api`, so that it names
both.

```yaml
  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
```

The move changed this file:

- `docs/_smalldocs.yml`: two packages.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/426d87e7d66b979bbc8b1d6067583395ab08e01c/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/426d87e7d66b979bbc8b1d6067583395ab08e01c#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the list.
  - look at: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

```bash
just docs check
```

The docs check prints `wikirandom 3 of 3`, and `15 of 15` in all.

### step-09.5 The front page and the README name both packages

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/43da298fbb7d16f7cb11bd3e3406fe8631a3e309) shows what the move changes.

The front page of the site, `docs/index.qmd`, and the README's table of folders now say that the repository
contains two packages.

The move changed these files:

- `docs/index.qmd`: two packages, the library and the app.
- `README.md`: a row for the library, and the `src/wikiapp/` row says the app.

Files to read:
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/43da298fbb7d16f7cb11bd3e3406fe8631a3e309/docs/index.qmd), [its change](https://github.com/rahuldave/smallwikiapp/commit/43da298fbb7d16f7cb11bd3e3406fe8631a3e309#diff-bfcaadbc044f4848960f04c96f4ac5930e20671e52514c04dd8347ff6f79ca7b): two packages.
  - look at: `The code has two packages, in one repository:`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/43da298fbb7d16f7cb11bd3e3406fe8631a3e309/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/43da298fbb7d16f7cb11bd3e3406fe8631a3e309#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): one row more, and the `src/wikiapp/` row says the app.
  - look at: `| The library the app uses: a random page of Wikipedia. A package of its own |`

```bash
just docs
just check
```

`just docs` writes 3 pages, and the front page names both packages. `just check` passes.
