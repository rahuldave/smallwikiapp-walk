# smallwikiapp, one move at a time

A tutorial: the tagged steps of smallwikiapp, and the small commits between them. Each small commit is a move,
one action. In do mode you make each move yourself, from its notes: type the code, run the command in the
grey block, then run the command at the end of the move, which shows what the move did, and press Done. In
watch mode, Show checks out each move's commit instead, and the notes explain what changed. Every step starts
from the code of the step before, so every step starts with `just setup`.

## step-00 The project

$ just setup

This is where the tutorial starts, so it has no moves. `uv init --package --python 3.13 --name wikiapp` made
the shape of the project: `pyproject.toml`, the code under `src/wikiapp/`, the Python version in
`.python-version`, and the lockfile, `uv.lock`. `just setup` runs `uv sync --locked`, which makes `.venv` with
exactly what the lockfile says. Here that is Python 3.13 and the package `wikiapp` itself, and nothing else.

$ cat pyproject.toml

The two lines under `[project.scripts]` make `wikiapp` a command: a name on the left, a function on the right,
`main` in `src/wikiapp/console.py`. For now it prints one line.

$ uv run wikiapp
$ cat src/wikiapp/console.py

The justfile is the project's interface. `just` lists the tasks, and `just help setup` shows the command behind
one. Every step adds recipes to it.

$ just
$ just help setup

## step-01 A random page

$ just setup

Four moves: the two packages the command needs, the command asking Wikipedia for a page, a header that
Wikipedia now asks for, and `--version`.

### step-01.1 click and requests

click makes command lines; requests fetches pages over HTTP. Add both.

```
uv add click requests
```

What changed:

- `pyproject.toml`: the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: the exact version of each, and of every package they need.

files:
- diff `pyproject.toml`: the dependencies of the package, which anyone who installs it gets.
  show: `"click>=8.5.0",`
- diff `uv.lock`: the exact versions, for every platform.

$ uv tree --depth 1

`uv tree` shows the two under `wikiapp`. A newer version may have come out since this was written: if your
numbers are newer, your `uv.lock` will differ from the one here, and that is fine.

### step-01.2 Ask Wikipedia for a page

This is the first code of wikiapp, as it was written in 2024. Replace `src/wikiapp/console.py` with it.

```python
"""The wikiapp command."""
import click
import requests
import textwrap

API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"

@click.command()
def main() -> None:
    """Print the title and summary of a random Wikipedia page."""
    with requests.get(API_URL) as response:
        response.raise_for_status()
        data = response.json()
        title = data["title"]
        extract = data["extract"]
        click.secho(title, fg="green")
        click.echo(textwrap.fill(extract))

if __name__=="__main__":
    main()
```

`@click.command()` turns `main` into a command. `requests.get` asks Wikipedia's REST API for the summary of a
random page, `raise_for_status` raises an exception if the answer is an error, and `response.json()` reads the
answer as a dictionary. The title is printed in green, and the summary wrapped to 70 columns.

What changed:

- `src/wikiapp/console.py`: `main` asks Wikipedia for a page and prints it.

files:
- diff `src/wikiapp/console.py`: a request, and two lines printed.
  show: `with requests.get(API_URL) as response:`

$ uv run wikiapp

It fails: the last line of the traceback is `403 Client Error: Forbidden`. Since 2025 Wikipedia refuses a
request that does not say who is asking, and requests says only `python-requests` and its version.

### step-01.3 A User-Agent

The User-Agent header says who is asking. Wikimedia's policy asks for the name of the program, its version, and
a way to reach whoever runs it. In `src/wikiapp/console.py`, add a line under `API_URL`, and pass it as a
header.

```python
USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```

```python
    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```

What changed:

- `src/wikiapp/console.py`: a constant `USER_AGENT`, and the request sends it.

files:
- diff `src/wikiapp/console.py`: the header.
  show: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

$ uv run wikiapp

A title in green, and a paragraph. Run it again for another page.

### step-01.4 --version

The package can read its own version from what is installed, which is the version in `pyproject.toml`. Replace
`src/wikiapp/__init__.py` with this.

```python
"""wikiapp: the title and summary of a random Wikipedia page."""
import importlib.metadata
__version__ = importlib.metadata.version(__name__ or __package__)
```

In `src/wikiapp/console.py`, import it under `import click`, and add an option above `def main`.

```python
from wikiapp import __version__
```

```python
@click.command()
@click.version_option(version=__version__)
def main() -> None:
```

What changed:

- `src/wikiapp/__init__.py`: `__version__`, from the installed package.
- `src/wikiapp/console.py`: the option `--version`.

files:
- diff `src/wikiapp/__init__.py`: the version, read when the package is imported.
  show: `__version__ = importlib.metadata.version(__name__ or __package__)`
- diff `src/wikiapp/console.py`: click's version option.
  show: `@click.version_option(version=__version__)`

$ uv run wikiapp --version
$ uv run wikiapp --help

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options: click writes the help from the
decorators and the docstring.

## step-02 Tests, with mocks

$ just setup

Six moves: pytest and a first test, a recipe for the tests, a mock in place of Wikipedia, three more tests,
and coverage on every run.

### step-02.1 pytest, and the first test

Tests need pytest, but the package does not: someone who installs wikiapp should not get pytest. pytest goes
in a dependency group of its own, `test`. uv installs the group `dev` by default, so `dev` includes `test`.
In `pyproject.toml`, above `[build-system]`, add the groups.

```toml
[dependency-groups]
test = []
dev = [{ include-group = "test" }]
```

Then add pytest to the group `test`, and make the first test, `tests/test_console.py`.

```
uv add --group test pytest
```

```python
import click.testing

from wikiapp import console

def test_main_succeeds():
    runner = click.testing.CliRunner()
    result = runner.invoke(console.main)
    assert result.exit_code == 0
```

click's `CliRunner` runs a command inside the test, in the same process, and keeps what it printed and its
exit code.

What changed:

- `pyproject.toml`: the groups `test` and `dev`.
- `tests/test_console.py`: the first test.
- `uv.lock`: pytest and what it needs.

files:
- diff `pyproject.toml`: the groups.
  show: `dev = [{ include-group = "test" }]`
- file `tests/test_console.py`: a test that runs the command and checks its exit code.
  show: `assert result.exit_code == 0`

$ uv run pytest

`1 passed`. This test asks the real Wikipedia, so it needs the network.

### step-02.2 just test

A recipe for the tests. Add it at the end of the `justfile`.

```just

# Run the tests. Extra arguments go to pytest: just test -k title
[group('quality')]
[no-exit-message]
test *args:
    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

`"$@"` is every word after `just test`, passed on to pytest whole. `just test help` shows the recipe.

What changed:

- `justfile`: the recipe `test`.

files:
- diff `justfile`: the recipe.
  show: `test *args:`

$ just --show test
$ just test

The same `1 passed`.

### step-02.3 A mock in place of Wikipedia

A test that needs the network fails on a train, and a random page cannot be checked for its title. pytest-mock
can replace `requests.get` with a mock for the length of one test.

```
uv add --group test pytest-mock
```

Replace `tests/test_console.py` with this.

```python
import click.testing
import pytest

@pytest.fixture
def runner():
    return click.testing.CliRunner()

@pytest.fixture
def mock_requests_get(mocker):
    mock = mocker.patch("requests.get")
    mock.return_value.__enter__.return_value.json.return_value = {
        "title": "Lorem Ipsum",
        "extract": "Lorem ipsum dolor sit amet",
    }
    return mock

from wikiapp import console

def test_main_prints_title(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert "Lorem Ipsum" in result.output

def test_main_succeeds(runner):
    result = runner.invoke(console.main)
    assert result.exit_code == 0
```

A fixture is a function that pytest calls for each test that names it as a parameter. `mocker` is pytest-mock's
fixture: `mocker.patch("requests.get")` replaces the function and puts it back after the test. The long line
says what the mock returns where the code calls `response.json()` inside the `with` block: a page whose title is
Lorem Ipsum.

What changed:

- `tests/test_console.py`: two fixtures, and a test of the title.

files:
- diff `tests/test_console.py`: the fixtures and the new test.
  show: `mock = mocker.patch("requests.get")`

$ just test -k title -v

`test_main_prints_title PASSED`, without the network.

### step-02.4 Tests of the request

A mock remembers how it was called. Add two tests to `tests/test_console.py`, after `test_main_prints_title`.

```python
def test_main_invokes_requests_get(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.called

def test_main_uses_correct_url(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
```

`call_args[0]` is the tuple of the positional arguments of the last call: here, the address alone. The header
is a keyword argument, in `call_args[1]`.

What changed:

- `tests/test_console.py`: two tests of the request.

files:
- diff `tests/test_console.py`: the request is made, to the right address.
  show: `assert mock_requests_get.called`

$ just test

`4 passed`.

### step-02.5 A test of a failed request

The mock can raise as well as return: when `side_effect` is set to an exception, calling the mock raises it.
Add this test before `test_main_succeeds`.

```python
def test_main_fails_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = Exception("Boom")
    result = runner.invoke(console.main)
    assert result.exit_code == 1
```

What changed:

- `tests/test_console.py`: a test that a failed request ends the command with exit code 1.

files:
- diff `tests/test_console.py`: the mock raises.
  show: `mock_requests_get.side_effect = Exception("Boom")`

$ just test

`5 passed`.

### step-02.6 Coverage

pytest-cov measures which lines of the code the tests run.

```
uv add --group test pytest-cov
```

At the end of `pyproject.toml`, turn it on for every run.

```toml

[tool.pytest.ini_options]
testpaths = ["tests"]
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
addopts = "--cov=wikiapp --cov-report=term-missing"
```

What changed:

- `pyproject.toml`: pytest's settings.
- `uv.lock`: pytest-cov and coverage.

files:
- diff `pyproject.toml`: coverage on every run.
  show: `addopts = "--cov=wikiapp --cov-report=term-missing"`

$ just test

The table under the tests lists each file of `src/wikiapp`, its lines, and the lines no test ran. One line of
`console.py` is missing: the call to `main` at the end, which runs only when the file itself is run as a
script.

## step-03 A library and an app

$ just setup

Six moves. The code that asks Wikipedia moves into a module of its own, `wikipedia.py`, which learns languages
and gets an error of its own. The command, in `console.py`, uses it. wikipedia.py becomes a library that knows
nothing of the command line, and console.py the app that uses it.

### step-03.1 random_page moves to wikipedia.py

Make `src/wikiapp/wikipedia.py`.

```python
"""Wikipedia's REST API: a random page."""
import requests

API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"

def random_page():
    """Get a random page from Wikipedia."""
    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
        response.raise_for_status()
        return response.json()
```

Then replace `src/wikiapp/console.py`: the constants and the request go, and `main` calls `random_page`.

```python
"""The wikiapp command."""
import click
from wikiapp import __version__
import textwrap

from wikiapp.wikipedia import random_page

@click.command()
@click.version_option(version=__version__)
def main() -> None:
    """Print the title and summary of a random Wikipedia page."""
    data = random_page()
    title = data["title"]
    extract = data["extract"]
    click.secho(title, fg="green")
    click.echo(textwrap.fill(extract))

if __name__=="__main__":
    main()
```

What changed:

- `src/wikiapp/wikipedia.py`: new; the address, the User-Agent, and `random_page`.
- `src/wikiapp/console.py`: `main` calls `random_page`.

files:
- file `src/wikiapp/wikipedia.py`: the code that talks to Wikipedia.
  show: `def random_page():`
- diff `src/wikiapp/console.py`: what is left is the command.
  show: `data = random_page()`

$ just test

`5 passed`, with no change to the tests: they replace `requests.get` wherever it is called from.

### step-03.2 The mock moves to conftest.py

pytest reads `tests/conftest.py` before the tests, and every test file can use a fixture defined there. The
tests of wikipedia.py, in the next move, need the mock too. Make `tests/conftest.py` with it, and delete it from
`tests/test_console.py`.

```python
import pytest

@pytest.fixture
def mock_requests_get(mocker):
    mock = mocker.patch("requests.get")
    mock.return_value.__enter__.return_value.json.return_value = {
        "title": "Lorem Ipsum",
        "extract": "Lorem ipsum dolor sit amet",
    }
    return mock
```

What changed:

- `tests/conftest.py`: new; the mock.
- `tests/test_console.py`: without it.

files:
- file `tests/conftest.py`: the fixture, for every test file.
  show: `def mock_requests_get(mocker):`
- diff `tests/test_console.py`: the fixture is gone; the tests still name it.

$ just test

`5 passed`: pytest finds the fixture in conftest.py.

### step-03.3 A language

Each language has its own Wikipedia, at LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, give the address
a hole for the language, and fill it in `random_page`, with English as the default.

```python
API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
```

```python
def random_page(language="en"):
    """Get a random page from Wikipedia."""
    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
```

And the first test of the library, `tests/test_wikipedia.py`.

```python
from wikiapp import wikipedia

def test_random_page_uses_given_language(mock_requests_get):
    wikipedia.random_page(language="es")
    args, _ = mock_requests_get.call_args
    assert "es.wikipedia.org" in args[0]
```

What changed:

- `src/wikiapp/wikipedia.py`: `random_page` takes a language.
- `tests/test_wikipedia.py`: new; a test that the language chooses the Wikipedia.

files:
- diff `src/wikiapp/wikipedia.py`: the hole, and its filling.
  show: `def random_page(language="en"):`
- file `tests/test_wikipedia.py`: the test uses the mock from conftest.py.
  show: `assert "es.wikipedia.org" in args[0]`

$ just test

`6 passed`.

### step-03.4 wikiapp --language

In `src/wikiapp/console.py`, add an option between `@click.command()` and `@click.version_option`, and pass it
on.

```python
@click.option(
    "--language",
    "-l",
    default="en",
    help="Gets random page from Wikipedia in given language",
    metavar="LANG",
    show_default=True,
)
```

```python
def main(language) -> None:
    """Print the title and summary of a random Wikipedia page."""
    data = random_page(language=language)
```

click passes the option's value to the parameter of the same name.

What changed:

- `src/wikiapp/console.py`: the option `--language`, or `-l`.

files:
- diff `src/wikiapp/console.py`: the option, and `main` passes it on.
  show: `data = random_page(language=language)`

$ uv run wikiapp --language fr
$ uv run wikiapp --help

A French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

Whatever goes wrong with a request, requests raises a `RequestException`. Code that uses the library should
not need to know requests' exceptions: the library raises one of its own. In `src/wikiapp/wikipedia.py`, add
the class above `random_page`, and wrap the request.

```python
class WikipediaError(Exception):
    """Wikipedia could not give a page."""

def random_page(language="en"):
    """Get a random page from Wikipedia."""
    try:
        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
            response.raise_for_status()
            return response.json()
    except requests.RequestException as error:
        raise WikipediaError(str(error)) from error
```

`from error` keeps the original exception, so a traceback shows both.

What changed:

- `src/wikiapp/wikipedia.py`: the class `WikipediaError`; `random_page` raises it.

files:
- diff `src/wikiapp/wikipedia.py`: the exception, and where it is raised.
  show: `raise WikipediaError(str(error)) from error`

$ uv run wikiapp --language xx

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback whose last line is the `WikipediaError`: nothing catches it yet.

### step-03.6 The command prints the error

In `src/wikiapp/console.py`, import the error with `random_page`, and turn it into click's exception, which click
prints as a message.

```python
from wikiapp.wikipedia import WikipediaError, random_page
```

```python
    try:
        data = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
```

And a test, in `tests/test_console.py`, before `test_main_succeeds`, with `import requests` at the top.

```python
def test_main_prints_message_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = requests.RequestException
    result = runner.invoke(console.main)
    assert "Error" in result.output
```

In wikiapp, the original, the library raised click's exception itself, with a note to move it to the console
one day. Here it is moved: wikipedia.py knows Wikipedia and requests, console.py knows click.

What changed:

- `src/wikiapp/console.py`: `main` catches WikipediaError.
- `tests/test_console.py`: a test of the message.

files:
- diff `src/wikiapp/console.py`: the error becomes a message.
  show: `raise click.ClickException(str(error)) from error`
- diff `tests/test_console.py`: the test.
  show: `assert "Error" in result.output`

$ uv run wikiapp --language xx
$ just test

`Error:` and the message, and exit code 1, in place of a traceback. `7 passed`.

## step-04 Format, lint, a hook

$ just setup

Eight moves. A formatter, then a linter that finds five problems, the fixes, one recipe that runs every check,
and a git hook that runs it before every commit. In each pair, the first move brings the tool and the second
the result, so that you see what the tool does before you accept it.

### step-04.1 ruff, and just fmt

ruff is a formatter and a linter in one program. It goes in a third dependency group, `lint`, which `dev`
includes. In `pyproject.toml`, change the line `dev = ...`, and add the group.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }]
lint = []
```

Add ruff to it, and its settings at the end of `pyproject.toml`.

```
uv add --group lint ruff
```

```toml

[tool.ruff]
# The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
# better at 100.
line-length = 100

[tool.ruff.format]
# The formatter has no style to argue about. These are ruff's defaults, written out so they are visible.
quote-style = "double"            # "text", not 'text'
indent-style = "space"            # four spaces, never tabs
skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
```

And a recipe, at the end of the `justfile`.

```just

# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
[group('quality')]
[no-exit-message]
fmt *args:
    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```

What changed:

- `pyproject.toml`: the group `lint`, and ruff's settings.
- `justfile`: the recipe `fmt`.
- `uv.lock`: ruff.

files:
- diff `pyproject.toml`: the group and the settings.
  show: `line-length = 100`
- diff `justfile`: the recipe.
  show: `fmt *args:`

$ just fmt --check

`--check` changes nothing: it lists what it would change and fails. `6 files would be reformatted, 1 file
already formatted`.

### step-04.2 The code, formatted

Run the formatter.

```
just fmt
```

What changed:

- six files: two blank lines around each function and class, one after the imports, spaces around `==`, and
  the two lines longer than 100 characters split.

files:
- diff `src/wikiapp/wikipedia.py`: the long line of the request, split into three.
  show: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- diff `tests/test_console.py`: blank lines, and the long address split.

$ just fmt --check
$ just test

`7 files already formatted`, and the tests pass as before: the formatter changes how the code looks, never what
it does.

### step-04.3 The linter's rules, and just lint

The linter checks the code against rules. At the end of `pyproject.toml`, choose the families of rules, and let
the tests use `assert`: the rest of the code may not, because Python skips every `assert` when run with `-O`.

```toml

[tool.ruff.lint]
# What the linter checks: a family of rules on each line, and why it is on
select = [
    "E",   # pycodestyle errors: the basics, from indentation to line length
    "W",   # pycodestyle warnings: stray whitespace and the like
    "F",   # pyflakes: names that are unused, undefined or redefined
    "I",   # isort: imports in one order, standard library first
    "B",   # bugbear: constructs that are likely bugs, such as a mutable default argument
    "UP",  # pyupgrade: older syntax that this Python has a newer form for
    "SIM", # simplify: code that can be said in fewer words
    "S",   # bandit: security, from `assert` in production code to a request with no timeout
    "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
]

[tool.ruff.lint.per-file-ignores]
# A test is written with assert
"tests/**" = ["S101"]
```

And a recipe, at the end of the `justfile`.

```just

# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
[group('quality')]
[no-exit-message]
lint *args:
    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```

What changed:

- `pyproject.toml`: the rules.
- `justfile`: the recipe `lint`.

files:
- diff `pyproject.toml`: a family of rules on each line.
  show: `"tests/**" = ["S101"]`
- diff `justfile`: the recipe.
  show: `lint *args:`

$ just lint --statistics

Five problems, each with its code: `I001`, the imports of console.py out of order; `E402`, an import in
test_console.py below code; `F841` twice, a variable assigned and never used; and `S113`, a request with no
timeout. `just lint` shows each one with its lines. `uv run ruff rule S113` explains a code.

### step-04.4 just lint --fix sorts the imports

ruff can fix one of the five itself.

```
just lint --fix
```

What changed:

- `src/wikiapp/console.py`: the imports in three blocks: the standard library, the packages installed, then
  wikiapp's own.

files:
- diff `src/wikiapp/console.py`: the imports, sorted.
  show: `from wikiapp import __version__`

$ just lint --statistics

Four left. They need a person.

### step-04.5 The tests' imports at the top, and no unused variables

In `tests/test_console.py`, move `from wikiapp import console` up under `import requests`, where a reader looks
for imports. In `test_main_invokes_requests_get` and `test_main_uses_correct_url`, the result is never read:
those tests check the mock, not the result. Make their first line the call alone.

```python
    runner.invoke(console.main)
```

What changed:

- `tests/test_console.py`: the import at the top, and two assignments gone.

files:
- diff `tests/test_console.py`: the import moves; `result =` goes twice.
  show: `from wikiapp import console`

$ just lint --statistics

One left: `S113`.

### step-04.6 A timeout

Without a timeout, requests waits for as long as the server keeps the connection open, and the command can hang
for ever. In `src/wikiapp/wikipedia.py`, add `timeout=10` to the request.

```python
        with requests.get(
            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
        ) as response:
```

A request that waits more than 10 seconds for the server now raises an exception, which `random_page` turns
into a WikipediaError like any other.

What changed:

- `src/wikiapp/wikipedia.py`: the timeout.

files:
- diff `src/wikiapp/wikipedia.py`: one argument more.
  show: `timeout=10`

$ just lint

`All checks passed!`

### step-04.7 just lint-config, and just check

validate-pyproject checks `pyproject.toml` against the standard for it.

```
uv add --group lint validate-pyproject
```

In the `justfile`, under `set positional-arguments`, make every `uv run` of a recipe refuse a lockfile that is
out of date, in place of quietly updating it.

```just

export UV_LOCKED := "1"
```

And two recipes at the end: `lint-config` checks the configuration, and `check` runs every check, in order,
stopping at the first that fails.

```just

# Check the configuration: pyproject.toml, the lockfile, and this justfile
[group('quality')]
[no-exit-message]
lint-config *args:
    #!/usr/bin/env sh
    set -e
    if [ "$*" = help ]; then just help lint-config; exit 0; fi
    uv run validate-pyproject pyproject.toml
    uv lock --check
    just --fmt --check --unstable

# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
[group('quality')]
[no-exit-message]
check *args:
    #!/usr/bin/env sh
    set -e
    if [ "$*" = help ]; then just help check; exit 0; fi
    just fmt --check
    just lint
    just test -q --cov-fail-under=90
    just lint-config
```

What changed:

- `justfile`: `UV_LOCKED`, and the recipes `lint-config` and `check`.
- `pyproject.toml`, `uv.lock`: validate-pyproject.

files:
- diff `justfile`: the recipes.
  show: `just test -q --cov-fail-under=90`
- diff `pyproject.toml`: one package more in `lint`.

$ just check

Each check in turn: the format, the linter, the tests, which must run at least 90% of the lines, and the
configuration. The coverage is 96.77%.

### step-04.8 A git hook

pre-commit installs a git hook: a program that git runs before every commit, and that refuses the commit if it
fails.

```
uv add --group lint pre-commit
```

Make `.pre-commit-config.yaml`.

```yaml
# What every commit must pass. `just setup` installs it as a git hook.
#
# The project's own checks are one hook that runs `just check`, so the hook and the terminal run the
# same thing. The hooks before it guard against files that should never be committed.
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: check-yaml
      - id: check-added-large-files
        args: [--maxkb=1000]
      - id: check-merge-conflict
  - repo: local
    hooks:
      - id: check
        name: just check
        entry: just check
        language: system
        pass_filenames: false
        always_run: true
```

In the `justfile`, `setup` installs the hook too, so every working copy has it.

```just
# Install Python and every dependency into .venv, exactly as the lockfile says, and the git hook
[group('setup')]
setup *args:
    @{{ if args == "help" { "just help setup" } else { "uv sync --locked && uv run pre-commit install" } }}
```

What changed:

- `.pre-commit-config.yaml`: new; the hooks.
- `justfile`: `setup` installs the hook.
- `pyproject.toml`, `uv.lock`: pre-commit.

files:
- file `.pre-commit-config.yaml`: three hooks from pre-commit's collection, then `just check`.
  show: `entry: just check`
- diff `justfile`: setup.
  show: `uv sync --locked && uv run pre-commit install`

$ just setup
$ uv run pre-commit run --all-files

`just setup` prints `pre-commit installed at .git/hooks/pre-commit`. `pre-commit run` runs every hook now, as
git will before a commit: four lines, each `Passed`.

## step-05 Types

$ just setup

Six moves. A type checker, and the one problem it finds; then a lint rule that asks for a type on every
parameter and return, the types, and the type checker in `just check`.

### step-05.1 ty, and just types

ty reads the code without running it, and finds calls whose arguments cannot have the type the function asks
for.

```
uv add --group lint ty
```

In the `justfile`, a recipe after `lint`.

```just
# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
[group('quality')]
[no-exit-message]
types *args:
    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}

```

What changed:

- `justfile`: the recipe `types`.
- `pyproject.toml`, `uv.lock`: ty.

files:
- diff `justfile`: the recipe.
  show: `types *args:`

$ just types

One problem, in `src/wikiapp/__init__.py`: `Expected str, found str | None`. `__name__ or __package__` could
be None, as far as ty can tell, and `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

The installed package is named in `pyproject.toml`: `wikiapp`. That is the name to ask the version of. Change the
last line of `src/wikiapp/__init__.py`.

```python
__version__ = importlib.metadata.version("wikiapp")
```

What changed:

- `src/wikiapp/__init__.py`: the name, written out.

files:
- diff `src/wikiapp/__init__.py`: a string that is never None.
  show: `__version__ = importlib.metadata.version("wikiapp")`

$ just types

`All checks passed!`

### step-05.3 A type on every parameter and return

ty checks the types that are written. ruff's `ANN` rules make sure they are written. In `pyproject.toml`, add a
line to `select`, after `"N"`.

```toml
    "ANN", # annotations: every parameter and every return value has a type
```

What changed:

- `pyproject.toml`: the rules `ANN`.

files:
- diff `pyproject.toml`: one line.
  show: `"ANN", # annotations: every parameter and every return value has a type`

$ just lint --statistics

25 missing: 15 parameters (`ANN001`) and 10 returns (`ANN201`), in the code and in the tests. `just check`
fails here, and stays failing until the next two moves.

### step-05.4 Types in the code

In `src/wikiapp/wikipedia.py`, `random_page` takes a string and returns the JSON that Wikipedia sends: a
dictionary from strings to values of any kind. `Any` says that ty cannot check what is inside. Import it at the
top, above `import requests`.

```python
from typing import Any
```

```python
def random_page(language: str = "en") -> dict[str, Any]:
```

In `src/wikiapp/console.py`, `main` takes the language as a string.

```python
def main(language: str) -> None:
```

What changed:

- `src/wikiapp/wikipedia.py`, `src/wikiapp/console.py`: the types of the code.

files:
- diff `src/wikiapp/wikipedia.py`: the parameter and the return.
  show: `def random_page(language: str = "en") -> dict[str, Any]:`
- diff `src/wikiapp/console.py`: the parameter.
  show: `def main(language: str) -> None:`

$ just lint --statistics

What is left is in the tests: 22, 13 parameters and 9 returns.

### step-05.5 Types in the tests

A fixture's return type is what a test receives: the runner is a `CliRunner`, the mock of `requests.get` a `Mock`,
and `mocker` is pytest-mock's `MockerFixture`. A test returns None. Replace `tests/conftest.py`.

```python
from unittest.mock import Mock

import pytest
from pytest_mock import MockerFixture

@pytest.fixture
def mock_requests_get(mocker: MockerFixture) -> Mock:
    mock = mocker.patch("requests.get")
    mock.return_value.__enter__.return_value.json.return_value = {
        "title": "Lorem Ipsum",
        "extract": "Lorem ipsum dolor sit amet",
    }
    return mock
```

In `tests/test_console.py`, import `Mock` and `CliRunner` by name, use `CliRunner()` in the fixture, and give every
function its types. Two of them, as the pattern for the rest:

```python
from unittest.mock import Mock

import pytest
import requests
from click.testing import CliRunner

from wikiapp import console

@pytest.fixture
def runner() -> CliRunner:
    return CliRunner()

def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
```

In `tests/test_wikipedia.py`, the same: `from unittest.mock import Mock` at the top, and

```python
def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
```

What changed:

- `tests/conftest.py`, `tests/test_console.py`, `tests/test_wikipedia.py`: a type on every parameter and return.

files:
- diff `tests/conftest.py`: the fixture returns a Mock.
  show: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- diff `tests/test_console.py`: the runner is a CliRunner.
  show: `def runner() -> CliRunner:`
- diff `tests/test_wikipedia.py`: one test.

$ just lint
$ just types

Both pass.

### step-05.6 Types join just check

In the `justfile`, in `check`, run `just types` after `just lint`, and say so in its comment.

```just
# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
```

```just
    just lint
    just types
```

What changed:

- `justfile`: `check` runs the type checker.

files:
- diff `justfile`: one line in check.
  show: `just types`

$ just check

## step-06 End to end, and CI

$ just setup

Four moves. The tests that ask the real Wikipedia run only when asked for; the project accepts every Python
from 3.11; and GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only when asked for

`test_main_succeeds` is the one test that goes over the network: it fails without one, and its result depends
on Wikipedia. Mark it `e2e`, end to end, and rename it to say so, in `tests/test_console.py`.

```python
@pytest.mark.e2e
def test_main_succeeds_in_production(runner: CliRunner) -> None:
```

In `pyproject.toml`, declare the marker, and leave e2e tests out of every run unless asked for: replace the
comment and the line `addopts`.

```toml
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
# marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
# just test -m e2e
addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
```

What changed:

- `tests/test_console.py`: the marker, and the name.
- `pyproject.toml`: the marker, declared and left out.

files:
- diff `tests/test_console.py`: the test, marked.
  show: `@pytest.mark.e2e`
- diff `pyproject.toml`: `-m 'not e2e'`.
  show: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

$ just test -q
$ just test -q -m e2e

The first: `6 passed, 1 deselected`. The second runs the e2e test alone.

### step-06.2 An end-to-end test of the library

The mocks return a dictionary with a title and an extract. This test, from wikiapp, checks that the real
Wikipedia still does. Add it at the end of `tests/test_wikipedia.py`, with `import pytest` at the top.

```python

@pytest.mark.e2e
def test_random_page_returns_dictionary_in_production() -> None:
    page = wikipedia.random_page()
    assert "title" in page
    assert "extract" in page
```

What changed:

- `tests/test_wikipedia.py`: an e2e test.

files:
- diff `tests/test_wikipedia.py`: the test.
  show: `assert "extract" in page`

$ just test -q -m e2e

`2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

`uv init` wrote `requires-python = ">=3.13"`, the Python it was run with. Nothing here needs more than 3.11, the
oldest Python still given security fixes. In `pyproject.toml`, change the line, and solve the lockfile again.

```toml
requires-python = ">=3.11"
```

```
uv lock
```

The project still runs on 3.13, from `.python-version`.

What changed:

- `pyproject.toml`: the oldest Python.
- `uv.lock`: solved for every Python from 3.11 on.

files:
- diff `pyproject.toml`: one line.
  show: `requires-python = ">=3.11"`

$ uv run --isolated --python 3.11 python --version
$ uv run --isolated --python 3.11 pytest -q

`--isolated` makes a temporary environment, with Python 3.11, and leaves `.venv` alone. The tests pass on 3.11.

### step-06.4 GitHub runs the tests

A GitHub Actions workflow is a file in `.github/workflows/`. On every push to main and every pull request,
GitHub runs its jobs. Make `.github/workflows/test.yaml`.

```yaml
# What GitHub runs on every push to main and every pull request.
#
# tests: the tests, on three systems and four Pythons, twelve jobs at once.
# check: everything `just check` runs, once, as the git hook does.
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  tests:
    strategy:
      fail-fast: false  # one failing job does not stop the others
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python: ["3.11", "3.12", "3.13", "3.14"]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10
        with:
          python-version: ${{ matrix.python }}
      - run: uv run --locked pytest

  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10
      - uses: extractions/setup-just@v4
      - run: just setup
      - run: just check
```

wikiapp did this with pixi, one environment for each Python. With uv, `setup-uv` installs the Python it is given,
and `uv run` uses it.

What changed:

- `.github/workflows/test.yaml`: new; two jobs, one of them twelve times.

files:
- file `.github/workflows/test.yaml`: the matrix of systems and Pythons.
  show: `python: ["3.11", "3.12", "3.13", "3.14"]`

$ uv run pre-commit run check-yaml --all-files

The file is valid YAML. GitHub runs it after a push: the Actions tab of the repository shows the thirteen jobs.

## step-07 A page with a shape

$ just setup

Three moves. A pydantic model says what a page is, `random_page` returns one, and an answer that is not a page
is an error like any other.

### step-07.1 Page

The command uses two of the many keys Wikipedia sends, and so far trusts that they are there and are strings. A
pydantic model says so in code.

```
uv add pydantic
```

In `src/wikiapp/wikipedia.py`, import it under `import requests`, and add the class after `WikipediaError`.

```python
from pydantic import BaseModel
```

```python
class Page(BaseModel):
    """A page of Wikipedia: its title and the summary of its text."""

    title: str
    extract: str
```

What changed:

- `src/wikiapp/wikipedia.py`: the class `Page`.
- `pyproject.toml`, `uv.lock`: pydantic, a dependency of the package like click and requests.

files:
- diff `src/wikiapp/wikipedia.py`: the model.
  show: `class Page(BaseModel):`

$ uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
$ uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"

The first prints `title='A' extract='B'`: the other key is dropped. The second fails with a ValidationError:
`extract` is missing.

### step-07.2 random_page returns a Page

In `src/wikiapp/wikipedia.py`, `random_page` makes a Page of the answer and returns it. `Any` is no longer
needed: delete its import.

```python
def random_page(language: str = "en") -> Page:
```

```python
            return Page.model_validate(response.json())
```

In `src/wikiapp/console.py`, `main` prints the page's attributes. ty and an editor know them, where a key of a
dictionary could be misspelled and found only when the program runs.

```python
    try:
        page = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
    click.secho(page.title, fg="green")
    click.echo(textwrap.fill(page.extract))
```

In `tests/test_wikipedia.py`, the e2e test checks for a Page.

```python
def test_random_page_returns_page_in_production() -> None:
    page = wikipedia.random_page()
    assert isinstance(page, wikipedia.Page)
```

What changed:

- `src/wikiapp/wikipedia.py`: returns a Page.
- `src/wikiapp/console.py`: prints its attributes.
- `tests/test_wikipedia.py`: the e2e test.

files:
- diff `src/wikiapp/wikipedia.py`: the return.
  show: `return Page.model_validate(response.json())`
- diff `src/wikiapp/console.py`: attributes, not keys.
  show: `click.secho(page.title, fg="green")`

$ just check
$ uv run wikiapp

### step-07.3 An answer that is not a page

When the answer has no title, `model_validate` raises pydantic's ValidationError. `random_page` turns it into a
WikipediaError, as it does a failed request. In `src/wikiapp/wikipedia.py`:

```python
from pydantic import BaseModel, ValidationError
```

```python
    except (requests.RequestException, ValidationError) as error:
```

And the test from wikiapp, at the end of `tests/test_wikipedia.py`: the mock answers with an empty dictionary.

```python

def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
    with pytest.raises(wikipedia.WikipediaError):
        wikipedia.random_page()
```

What changed:

- `src/wikiapp/wikipedia.py`: a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: its test.

files:
- diff `src/wikiapp/wikipedia.py`: two exceptions caught.
  show: `except (requests.RequestException, ValidationError) as error:`
- diff `tests/test_wikipedia.py`: the test.
  show: `with pytest.raises(wikipedia.WikipediaError):`

$ just test -k validation

## step-08 Docs from the code

$ just setup

Six moves. A script that makes the reference from the code and says what is not documented; the library, the
command and the tests documented; a site; and the check in `just check`.

### step-08.1 docs/apidocs.py

The reference of a function is its signature, what it does, and what each parameter is. The signature and the
types are in the code. What it does is its docstring. What each parameter is goes in a docment: the comment
beside the parameter, one parameter to a line, which fastcore reads.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask
) -> Page:  # A page chosen at random
```

fastcore goes in a fourth dependency group, `docs`, which `dev` includes. In `pyproject.toml`:

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```

```
uv add --group docs fastcore
```

`docs/apidocs.py` is a script of 200 lines; take it from this move with **Apply this file** on the Next change
tab, or copy it from GitHub. It has two commands: `module NAME` prints one module's reference as Markdown, and
`check` lists every function and class, in the package, the tests and the script itself, that lacks a
docstring, a type or a docment. Read its docstring, and any one function: the script follows its own rule.

And a recipe, at the end of the `justfile`.

```just

# The reference, from the code: just docs check, just docs module wikipedia. Words go to docs/apidocs.py
[group('docs')]
[no-exit-message]
docs *args:
    {{ if args == "help" { "just help docs" } else { 'uv run python docs/apidocs.py "$@"' } }}
```

What changed:

- `docs/apidocs.py`: new; `check` and `module`.
- `justfile`: the recipe `docs`.
- `pyproject.toml`, `uv.lock`: the group `docs`, with fastcore.

files:
- file `docs/apidocs.py`: the script; every function in it has its docments.
  show: `def gaps_of(`
- diff `pyproject.toml`: the group.
  show: `docs = [`

$ just docs module wikipedia
$ just docs check

`module` prints the reference of wikipedia.py, with empty descriptions. `check` counts, for each module, how
many of its functions and classes are complete, then lists every gap, and fails: `15 of 29`, and the 15
are the script's own.

### step-08.2 The library documented

In `src/wikiapp/wikipedia.py`, a docment beside each field of Page, and on the parameter and the return of
`random_page`, whose docstring says when it raises.

```python
class Page(BaseModel):
    """A page of Wikipedia: its title and the summary of its text."""

    title: str  # The title of the page
    extract: str  # The summary: the first paragraph of the page, as plain text

def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
    """Get a random page from Wikipedia.

    Raises WikipediaError when the request fails, or when the answer is not a page.
    """
```

What changed:

- `src/wikiapp/wikipedia.py`: docments, and a longer docstring.

files:
- diff `src/wikiapp/wikipedia.py`: the comments are the documentation.
  show: `) -> Page:  # A page chosen at random`

$ just docs module wikipedia

The tables now have their descriptions.

### step-08.3 The command documented

In `src/wikiapp/console.py`, one parameter to a line, with its docment, and a docstring that says what is printed.
A function that returns None needs no docment for it.

```python
def main(
    language: str,  # The language of the Wikipedia to ask, from --language
) -> None:
    """Print the title and summary of a random Wikipedia page.

    The title is in green, and the summary is wrapped to 70 columns. When Wikipedia gives no page,
    click prints the error and the command exits with 1.
    """
```

What changed:

- `src/wikiapp/console.py`: `main`, documented.

files:
- diff `src/wikiapp/console.py`: the docment and the docstring.
  show: `language: str,  # The language of the Wikipedia to ask, from --language`

$ just docs module console

### step-08.4 The tests documented

Every test file says what it tests, every fixture what it returns, and every test, in one line, what it checks:
the docstrings say in words what the asserts say in code. The three files are long to type; take them with
**Apply the whole move**. One test, as the pattern:

```python
def test_main_prints_title(
    runner: CliRunner,  # The runner from the fixture
    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
) -> None:
    """The command prints the title of the page."""
```

What changed:

- `tests/conftest.py`, `tests/test_console.py`, `tests/test_wikipedia.py`: a docstring for each file, fixture and
  test, and a docment for each parameter.

files:
- diff `tests/conftest.py`: the fixture, documented.
  show: `"""Replace `requests.get` with a mock that answers with one page, Lorem Ipsum."""`
- diff `tests/test_console.py`: seven functions.
- diff `tests/test_wikipedia.py`: three tests.

$ just docs check

`29 of 29 functions and classes are typed and documented`.

### step-08.5 A site

Quarto makes a website from Markdown. It is a program of its own, not a Python package:
https://quarto.org/docs/get-started/. The site is in `docs/`: a front page, `index.qmd`, and a reference page for
each module, which `apidocs.py build` writes from the code before every render.

This move adds `docs/_quarto.yml`, `docs/index.qmd`, `docs/linkify.lua`, which turns a name in backticks into a
link to its entry, and `docs/.gitignore`. `apidocs.py` gains `build`, with an id on each heading and a link to
the line of the source. `just docs` with no words renders the site, and `just setup` says when Quarto is
missing. Take the move with **Apply the whole move**, and read `docs/_quarto.yml`, the shortest.

What changed:

- `docs/_quarto.yml`, `docs/index.qmd`, `docs/linkify.lua`, `docs/.gitignore`: new; the site.
- `docs/apidocs.py`: the command `build`.
- `justfile`: `docs` renders the site; `setup` checks for Quarto.

files:
- file `docs/_quarto.yml`: `pre-render` runs the script.
  show: `pre-render: python apidocs.py build  # the reference pages are made from the code, never by hand`
- diff `docs/apidocs.py`: `build`.
  show: `def build() -> int:  # The exit code, always 0`
- diff `justfile`: no words, the site.
  show: `if [ "$#" -eq 0 ]; then exec uv run quarto render docs; fi`

$ just docs
$ open docs/_site/index.html

`Output created: _site/index.html`. On the front page, `random_page` is a link to its entry.

### step-08.6 The docs check joins just check

In the `justfile`, in `check`, run `just docs check` after the tests, and say so in the comment.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

```just
    just test -q --cov-fail-under=90
    just docs check
```

The README gains Quarto among the tools, and `tests/` and `docs/` among the folders.

What changed:

- `justfile`: the docs check in `check`.
- `README.md`: Quarto, tests and docs.

files:
- diff `justfile`: one line.
  show: `just docs check`
- diff `README.md`: the tools and the folders.

$ just check

`30 of 30`: `build` is the thirtieth. Now the git hook refuses a commit that leaves a function, a parameter or a field undocumented.
