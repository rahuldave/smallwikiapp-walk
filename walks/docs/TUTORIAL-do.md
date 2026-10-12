<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

# Documenting smallwikiapp, one move at a time

In do mode, you make each move yourself. The notes give every line to type, every command and every file. [The same tutorial in watch mode](TUTORIAL-watch.md).

This walk takes the moves about documentation out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts when the code has
tests, lint and types, and almost no documentation.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The moves add smalldocs, which makes the reference from the code and says what has no documentation. Next, the
library, the command and the tests get their docstrings and docments. Then smalldocs builds a site, and the
README names the tests and the docs. The check of the documentation joins `just check`. The last move comes
after the library becomes a package of its own, and the check counts the library.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

The steps before this walk give the code what the docs describe. [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) adds ruff,
`just check`, and a git hook that runs `just check` before each commit. [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html) adds the
types. In [step-06](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html), the tests that ask the real Wikipedia run only on request, and GitHub runs
the tests. In [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html), `random_page` returns a `Page`, a pydantic model with a title and an
extract. An answer that is not a page, or a language that is not a language code, raises `WikipediaError`.

Before step-09.4, the first three moves of [step-09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html) make the library a package of its own,
`wikirandom`, in `packages/wikirandom`. The app uses it, and `src/wikiapp/wikipedia.py` is gone. The README
and the front page of the docs name both packages. The tests of the library are now
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5aa8fa5b13364731bdd41caf1ecd8af505c7346c) shows what the move changes.

Now we add smalldocs, which writes the reference from the code and lists what has no documentation. The reference
of a function gives its signature, what it does, and what each parameter is. The signature and the types are in the
code. The docstring says what the function does. A docment says what each parameter is. A docment is the comment
beside a parameter, with one parameter to a line.

The block below shows `random_page` with its docments, as the next move writes them. This move does not change
`random_page`.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

The block above is only to read.

smalldocs reads all three, and writes Markdown. It is a Python package, so uv installs it like
any other. smalldocs goes in a fourth dependency group, `docs`, and `dev` includes that group.

In `pyproject.toml`, change the line `dev = ...`, and add the group on the line after it.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```

```bash
uv add --group docs smalldocs
```

Next we write `docs/_smalldocs.yml`, the file of settings that smalldocs reads. For now the file has one section,
`api`, the reference. It names the package to document, the address of its source, and the files of the tests to
check.

Make `docs/_smalldocs.yml` with the lines below.

```yaml
# The settings of smalldocs. `api` is the reference, made from the code of the packages
api:
  packages: [wikiapp]
  source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
  check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

Then we add a recipe `docs`, at the end of the `justfile`. `just docs` runs `smalldocs api`, and gives it the words
after `just docs`. `smalldocs api` has two commands that this step uses:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

Add the recipe at the end of the `justfile`.

```just

# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
[group('docs')]
[no-exit-message]
docs *args:
    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

The move changes these files:

- `docs/_smalldocs.yml`: 5 lines added; a new file, with the settings of the reference.
- `justfile`: 6 lines added; the recipe `docs`.
- `pyproject.toml`: 4 lines added, 1 removed; the group `docs`, with smalldocs.
- `uv.lock`: 64 lines added; the exact version of smalldocs and of the packages it needs.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/5aa8fa5b13364731bdd41caf1ecd8af505c7346c/docs/_smalldocs.yml): the package to document, and the tests to check.
  - look at: `packages: [wikiapp]`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/5aa8fa5b13364731bdd41caf1ecd8af505c7346c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/5aa8fa5b13364731bdd41caf1ecd8af505c7346c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5aa8fa5b13364731bdd41caf1ecd8af505c7346c/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/5aa8fa5b13364731bdd41caf1ecd8af505c7346c#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `docs *args:`

The change of `pyproject.toml`:

```diff
@@ -22,7 +22,10 @@ test = [
     "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
-dev = [{ include-group = "test" }, { include-group = "lint" }]
+dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
+docs = [
+    "smalldocs>=0.1.5",
+]
 lint = [
     "pre-commit>=4.6.2",
     "ruff>=0.17.0",
```

The change of `justfile`:

```diff
@@ -74,3 +74,9 @@ check *args:
     just types
     just test -q --cov-fail-under=90
     just lint-config
+
+# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+[group('docs')]
+[no-exit-message]
+docs *args:
+    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/052409c665daee31e9a087510c5b04c7c2d7538f) shows what the move changes.

Now we document the library, `src/wikiapp/wikipedia.py`, with four additions:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

In `src/wikiapp/wikipedia.py`, add the docstring of the module at the top.

```python
"""Wikipedia's REST API: a random page."""

```

Then replace the class `Page` and the head of `random_page`, from its `def` to the end of its docstring, with the
code below.

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

The move changes one file:

- `src/wikiapp/wikipedia.py`: 12 lines added, 4 removed; a docstring for the module, docments, and a longer docstring.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/052409c665daee31e9a087510c5b04c7c2d7538f/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/052409c665daee31e9a087510c5b04c7c2d7538f#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the comments are the documentation.
  - look at: `) -> Page:  # A page chosen at random`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,3 +1,5 @@
+"""Wikipedia's REST API: a random page."""
+
 import re
 
 import requests
@@ -15,12 +17,18 @@ class WikipediaError(Exception):
 class Page(BaseModel):
     """A page of Wikipedia: its title and the summary of its text."""
 
-    title: str
-    extract: str
+    title: str  # The title of the page
+    extract: str  # The summary: the first paragraph of the page, as plain text
+
 
+def random_page(
+    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
+) -> Page:  # A page chosen at random
+    """Get a random page from Wikipedia.
 
-def random_page(language: str = "en") -> Page:
-    """Get a random page from Wikipedia."""
+    Raises WikipediaError when the language is not a language code, when the request fails, or
+    when the answer is not a page.
+    """
     if not LANGUAGE.fullmatch(language):
         raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
     try:
```

```bash
just docs module wikipedia
```

The tables now have their descriptions.

### step-08.3 The command documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cf9e19edc29a4a05bc48b956e79397eb19e2412e) shows what the move changes.

Now we give `src/wikiapp/__init__.py` and `src/wikiapp/console.py` each a docstring at the top.

Add a docstring at the top of `src/wikiapp/__init__.py` and of `src/wikiapp/console.py`.

```python
"""wikiapp: the title and summary of a random Wikipedia page."""

```

```python
"""The wikiapp command."""

```

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

Next we document `main` and its option `--language`. `wikiapp --help` prints the docstring of `main` and the help
of each option, so those are documentation too. The help of `--language` now says what a language is. It replaces
the help of the original wikiapp, "Gets random page from Wikipedia in given language". `main` has one parameter to
a line, with its docment, and a docstring that says what `main` prints. A function that returns None needs no
docment for its return.

In `src/wikiapp/console.py`, replace the line `help=...` of the option `--language` with the line below.

```python
    help="The language of the Wikipedia to ask, as its code: en, fr, es",
```

Then replace the line `def main(...)` and the docstring under it with the code below.

```python
def main(
    language: str,  # The language of the Wikipedia to ask, from --language
) -> None:
    """Print the title and summary of a random Wikipedia page, in the language asked for.

    The title is in green, and the summary is wrapped to 70 columns.
    """
```

The move changes these files:

- `src/wikiapp/__init__.py`: 2 lines added; a docstring for the module.
- `src/wikiapp/console.py`: 10 lines added, 3 removed; a docstring for the module, the documentation of `main`, and the help of `--language`.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/cf9e19edc29a4a05bc48b956e79397eb19e2412e/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/cf9e19edc29a4a05bc48b956e79397eb19e2412e#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a docstring, which `help(wikiapp)` shows.
  - look at: `"""wikiapp: the title and summary of a random Wikipedia page."""`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/cf9e19edc29a4a05bc48b956e79397eb19e2412e/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/cf9e19edc29a4a05bc48b956e79397eb19e2412e#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the docment, the docstring and the help.
  - look at: `language: str,  # The language of the Wikipedia to ask, from --language`

The change of `src/wikiapp/__init__.py`:

```diff
@@ -1,3 +1,5 @@
+"""wikiapp: the title and summary of a random Wikipedia page."""
+
 import importlib.metadata
 
 __version__ = importlib.metadata.version("wikiapp")
```

The change of `src/wikiapp/console.py`:

```diff
@@ -1,3 +1,5 @@
+"""The wikiapp command."""
+
 import textwrap
 
 import click
@@ -11,13 +13,18 @@ from wikiapp.wikipedia import WikipediaError, random_page
     "--language",
     "-l",
     default="en",
-    help="Gets random page from Wikipedia in given language",
+    help="The language of the Wikipedia to ask, as its code: en, fr, es",
     metavar="LANG",
     show_default=True,
 )
 @click.version_option(version=__version__)
-def main(language: str) -> None:
-    """Print the title and summary of a random Wikipedia page."""
+def main(
+    language: str,  # The language of the Wikipedia to ask, from --language
+) -> None:
+    """Print the title and summary of a random Wikipedia page, in the language asked for.
+
+    The title is in green, and the summary is wrapped to 70 columns.
+    """
     try:
         page = random_page(language=language)
     except WikipediaError as error:
```

```bash
just docs module console
uv run wikiapp --help
```

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/12f8bd1e97e91900d04e9676ee1a6ddfedf78084) shows what the move changes.

Now we document the tests, so that `just docs check` finds no gap. A docment is the comment beside a parameter, or
after the colon of the `def` line for the return. `just docs check`, from step-08.1, counts the functions and
classes that have their types, docments and docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. Each parameter of a test has a docment, one
parameter to a line, and `tests/test_console.py` shows the pattern best.

The three files are long to type, so take them from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/12f8bd1e97e91900d04e9676ee1a6ddfedf78084). The test below shows the pattern.

```python
def test_main_prints_title(
    runner: CliRunner,  # The runner from the fixture
    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
) -> None:
    """The command prints the title of the page."""
```

The move changes these files:

- `tests/conftest.py`: 6 lines added, 1 removed; a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: 33 lines added, 7 removed; docstrings for the file, the fixture and each test, and docments for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: 11 lines added, 2 removed; a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/12f8bd1e97e91900d04e9676ee1a6ddfedf78084/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/12f8bd1e97e91900d04e9676ee1a6ddfedf78084#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/12f8bd1e97e91900d04e9676ee1a6ddfedf78084/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/12f8bd1e97e91900d04e9676ee1a6ddfedf78084#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/12f8bd1e97e91900d04e9676ee1a6ddfedf78084/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/12f8bd1e97e91900d04e9676ee1a6ddfedf78084#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

The change of `tests/conftest.py`:

```diff
@@ -1,3 +1,5 @@
+"""What every test file can use: a mock in place of `requests.get`."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -5,7 +7,10 @@ from pytest_mock import MockerFixture
 
 
 @pytest.fixture
-def mock_requests_get(mocker: MockerFixture) -> Mock:
+def mock_requests_get(
+    mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test
+) -> Mock:  # The mock that replaces `requests.get` for the length of one test
+    """Replace `requests.get` with a mock that answers with one page, Lorem Ipsum."""
     mock = mocker.patch("requests.get")
     mock.return_value.__enter__.return_value.json.return_value = {
         "title": "Lorem Ipsum",
```

The change of `tests/test_console.py`:

```diff
@@ -1,3 +1,5 @@
+"""Tests of the command, `main`, run in the same process by click's CliRunner."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -8,40 +10,64 @@ from wikiapp import console
 
 
 @pytest.fixture
-def runner() -> CliRunner:
+def runner() -> CliRunner:  # A runner that calls a command and keeps what it prints
+    """Give each test a runner for the command."""
     return CliRunner()
 
 
-def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_prints_title(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The command prints the title of the page."""
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
-def test_main_invokes_requests_get(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_invokes_requests_get(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The command makes a request."""
     runner.invoke(console.main)
     assert mock_requests_get.called
 
 
-def test_main_uses_correct_url(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_uses_correct_url(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The request goes to the random page of the English Wikipedia."""
     runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
 
 
-def test_main_fails_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_fails_on_request_error(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """An exception in the request ends the command with exit code 1."""
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
 
-def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_prints_message_on_request_error(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """A failed request is printed as an error message, not a traceback."""
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
 
 @pytest.mark.e2e
-def test_main_succeeds_in_production(runner: CliRunner) -> None:
+def test_main_succeeds_in_production(
+    runner: CliRunner,  # The runner from the fixture
+) -> None:
+    """The command works against the real Wikipedia."""
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -1,3 +1,5 @@
+"""Tests of the library, wikipedia.py."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -5,7 +7,10 @@ import pytest
 from wikiapp import wikipedia
 
 
-def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
+def test_random_page_uses_given_language(
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The language chooses the Wikipedia that is asked."""
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
@@ -13,11 +18,15 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 
 @pytest.mark.e2e
 def test_random_page_returns_page_in_production() -> None:
+    """The real Wikipedia's answer makes a Page."""
     page = wikipedia.random_page()
     assert isinstance(page, wikipedia.Page)
 
 
-def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
+def test_random_page_handles_validation_error(
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """An answer that is not a page raises WikipediaError."""
     mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
     with pytest.raises(wikipedia.WikipediaError):
         wikipedia.random_page()
```

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b2c6edfda40338f49e0d625b4eec7137d19da3c4) shows what the move changes.

Now we make a docs site, because smalldocs also makes a website from Markdown. The site is in `docs/`. It has a
front page, `index.qmd`, and a reference page for each module. Each build writes the reference pages from the code,
before it builds the site. A name in backticks, such as `random_page`, becomes a link to its entry.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site. The front page, `docs/index.qmd`, is
new. A `.qmd` file is Markdown, with a header between two `---` lines that gives the title of the page.

In `docs/_smalldocs.yml`, replace the first line, a comment, with the lines below. The section `api` stays as it
is, under them.

```yaml
# The settings of smalldocs. `just docs` builds the site into docs/_site
project:
  type: website
  output-dir: _site

website:
  title: "wikiapp"
  sidebar:
    contents:
      - index.qmd
      - section: Reference
        contents: api/*  # the reference pages, which each build makes from the code

theme: cosmo
toc: true

# `api` is the reference, made from the code of the packages. A name in backticks links to its entry
```

The front page is long to type, so take `docs/index.qmd` from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/b2c6edfda40338f49e0d625b4eec7137d19da3c4).

Next we change the recipe `docs`, so that `just docs` with no words builds the site, with `smalldocs render docs`.
With words, it runs `smalldocs api` as before. The recipe is now a script of several lines.

In the `justfile`, replace the recipe `docs`, from its comment to its last line, with the code below.

```just
# The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
[group('docs')]
[no-exit-message]
docs *args:
    #!/usr/bin/env sh
    if [ "$*" = help ]; then just help docs; exit 0; fi
    if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
    exec uv run smalldocs api "$@" --dir docs
```

The move changes these files:

- `docs/_smalldocs.yml`: 17 lines added, 1 removed; the settings of the site above the section `api`, and a comment above `api`. The
  comment at the top now says that `just docs` builds the site.
- `docs/index.qmd`: 35 lines added; a new file, the front page.
- `justfile`: 5 lines added, 2 removed; with no words, `docs` builds the site, and its comment says so. The recipe is now a script of
  several lines.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/b2c6edfda40338f49e0d625b4eec7137d19da3c4/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b2c6edfda40338f49e0d625b4eec7137d19da3c4#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the site. The sidebar lists the front page, then the reference pages.
  - look at: `contents: api/*  # the reference pages, which each build makes from the code`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/b2c6edfda40338f49e0d625b4eec7137d19da3c4/docs/index.qmd): the front page, written by hand.
  - look at: `Each build of the site makes the pages under Reference from the code.`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/b2c6edfda40338f49e0d625b4eec7137d19da3c4/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/b2c6edfda40338f49e0d625b4eec7137d19da3c4#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): with no words, `docs` builds the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

The change of `docs/_smalldocs.yml`:

```diff
@@ -1,4 +1,20 @@
-# The settings of smalldocs. `api` is the reference, made from the code of the packages
+# The settings of smalldocs. `just docs` builds the site into docs/_site
+project:
+  type: website
+  output-dir: _site
+
+website:
+  title: "wikiapp"
+  sidebar:
+    contents:
+      - index.qmd
+      - section: Reference
+        contents: api/*  # the reference pages, which each build makes from the code
+
+theme: cosmo
+toc: true
+
+# `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
   packages: [wikiapp]
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
```

The change of `justfile`:

```diff
@@ -75,8 +75,11 @@ check *args:
     just test -q --cov-fail-under=90
     just lint-config
 
-# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+# The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
 [group('docs')]
 [no-exit-message]
 docs *args:
-    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
+    #!/usr/bin/env sh
+    if [ "$*" = help ]; then just help docs; exit 0; fi
+    if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
+    exec uv run smalldocs api "$@" --dir docs
```

```bash
uv run smalldocs render docs
just --show docs
just docs
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. On the front page, `random_page` is a link to its entry. Each build makes the site and the reference
pages, and git ignores them.

### step-08.6 The README names the tests and the docs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/200e1c28a172ef898f93486832a601a8eac48379) shows what the move changes.

Now we bring the table of folders in the README up to date. The README gets `tests/` and `docs/` among the
folders. It also says that `wikipedia.py` is the library and `console.py` the command.

Take the README from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/200e1c28a172ef898f93486832a601a8eac48379). Or copy the rows
below, in place of the `src/wikiapp/` row.

```markdown
| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
| `tests/` | The tests. `just test` runs them |
| `docs/` | The docs site. smalldocs makes its reference from the code |
```

The move changes one file:

- `README.md`: 3 lines added, 1 removed; rows for `tests/` and `docs/`, and the `src/wikiapp/` row names the library and the command.

Files to read:
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/200e1c28a172ef898f93486832a601a8eac48379/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/200e1c28a172ef898f93486832a601a8eac48379#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): the folders.
  - look at: `| The docs site. smalldocs makes its reference from the code |`

The change of `README.md`:

```diff
@@ -30,7 +30,9 @@ Then `just setup`, and `uv run wikiapp`.
 | Path | What it is |
 |---|---|
 | `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
-| `src/wikiapp/` | The code. `console.py` is the `wikiapp` command |
+| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
+| `tests/` | The tests. `just test` runs them |
+| `docs/` | The docs site. smalldocs makes its reference from the code |
 | `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
 | `.python-version` | The Python version the project uses |
 | `.gitignore` | Everything a run makes, ignored from the first commit on |
```

```bash
grep -n -E 'tests/|docs/' README.md
```

`grep` prints the two new rows of the table.

### step-08.7 The docs check in `just check`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1ea19fb90f9341fd939f150ef44d2089986e07be) shows what the move changes.

Now we add `just docs check` to the recipe `check`, after the tests, and name the docs in the comment above it.

In the `justfile`, replace the comment above `check` with the line below.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

Then, in `check`, add `just docs check` after the line of the tests.

```just
    just test -q --cov-fail-under=90
    just docs check
```

The move changes one file:

- `justfile`: 2 lines added, 1 removed; the docs check in `check`, and the comment.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/1ea19fb90f9341fd939f150ef44d2089986e07be/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/1ea19fb90f9341fd939f150ef44d2089986e07be#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in `check`.
  - look at: `just docs check`

The change of `justfile`:

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -73,6 +73,7 @@ check *args:
     just lint
     just types
     just test -q --cov-fail-under=90
+    just docs check
     just lint-config
 
 # The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
```

```bash
just check
```

The docs check prints `15 of 15`. Now the git hook refuses a commit that leaves a function, a parameter or a
field without documentation.

## step-09.4 The docs check counts the library

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/024ec7d71c51f7d8d6ef351641f301df94ada4be), the commit before step-09.4.

```bash
just setup
```

### step-09.4 The docs check counts the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea) shows what the move changes.

Now we make the docs check count the library, in `docs/_smalldocs.yml`.
Since step-09.3, the app uses the library `wikirandom`, a package of its own in `packages/wikirandom`. But
`docs/_smalldocs.yml` names only `wikiapp`. The line `packages:` in the section `api` now names both.

In `docs/_smalldocs.yml`, change the line `packages:` in the section `api`, so that it names both.

```yaml
  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
```

The move changes one file:

- `docs/_smalldocs.yml`: 1 line added, 1 removed; two packages.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/compare/024ec7d71c51f7d8d6ef351641f301df94ada4be...51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the list.
  - look at: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

The change of `docs/_smalldocs.yml`:

```diff
@@ -16,6 +16,6 @@ toc: true
 
 # `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
-  packages: [wikiapp]
+  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
   check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

```bash
just docs check
just docs
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and on the front page, `random_page` is now a link to its entry. `just check` passes.
