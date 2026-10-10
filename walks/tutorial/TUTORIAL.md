# smallwikiapp, one move at a time

A tutorial: the tagged steps of smallwikiapp, and the small commits between them, the moves. Each move is one
action. The grey blocks are the code to type, or the command that makes the move; the command at the end of a move
shows what it did. Every step starts from the code of the step before, so every step starts with `just setup`. To
take the tutorial in timewalk, where you can watch each move or make it yourself, see the
[README](../../README.md).

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), written in 2024 with
pixi; where the notes say "the original wikiapp", they mean that one.

This is the tutorial for reading on GitHub. It is made from [notes.md](notes.md), the notes that timewalk
reads, each time the walk is brought up to date: do not edit it by hand. Every step links to the code as it was at
that step, and every move to its commit, which shows exactly what the move changed. A command to run is in a grey
block marked `bash`, and what it prints is said under it. Under "Files to read", each file links to the file as
the move leaves it, and to its change in the commit.

## step-00 The project

[The code at step-00](https://github.com/rahuldave/smallwikiapp/tree/step-00)

```bash
just setup
```

This is where the tutorial starts, so it has no moves. `uv init --package --python 3.13 --name wikiapp` made the
shape of the project: `pyproject.toml`, `src/wikiapp/__init__.py` with a function `main`, and the Python version
in `.python-version`. Then, by hand: `main` moved to `src/wikiapp/console.py`, and `pyproject.toml` got a
description, an author and a licence, and names `wikiapp.console:main` as the command. `uv lock` wrote the
lockfile, `uv.lock`; the justfile, the README, `.gitignore` and `LICENSE` were written by hand. `just setup`
runs `uv sync --locked`, which makes `.venv` with Python 3.13, from `.python-version`, and exactly the packages
the lockfile names: here, the package `wikiapp` itself, and nothing else.

```bash
cat pyproject.toml
```

The line under `[project.scripts]` makes `wikiapp` a command: a name on the left, a function on the right,
`main` in `src/wikiapp/console.py`. For now it prints one line.

```bash
uv run wikiapp
cat src/wikiapp/console.py
```

The justfile is the project's interface. `just` lists the tasks, `just --show setup` shows the recipe behind
one, and `just help setup` says the same. Most steps add recipes to it.

```bash
just
just --show setup
just --show help
just help setup
```

## step-01 A random page

[The code at step-01](https://github.com/rahuldave/smallwikiapp/tree/step-01)

```bash
just setup
```

Four moves: the two packages the command needs, the command asking Wikipedia for a page, a header that
Wikipedia now asks for, and `--version`.

### step-01.1 click and requests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/babd435639351573a535123d8e45146e39b86ff0): exactly what it changes.

click makes command lines; requests fetches pages over HTTP. Add both.

```
uv add click requests
```

What changed:

- `pyproject.toml`: the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: the exact version of each, and of every package they need.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/babd435639351573a535123d8e45146e39b86ff0/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/babd435639351573a535123d8e45146e39b86ff0#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the dependencies of the package, which anyone who installs it gets.
  - look at: `"click>=8.5.0",`
- [`uv.lock`](https://github.com/rahuldave/smallwikiapp/blob/babd435639351573a535123d8e45146e39b86ff0/uv.lock), [its change](https://github.com/rahuldave/smallwikiapp/commit/babd435639351573a535123d8e45146e39b86ff0#diff-84321598744d84dbee2318e634c74c9aae39a1c253f1c4bd17ebf9ef2f807b11): the exact versions, for every platform.

```bash
uv tree --depth 1
```

`uv tree` shows the two under `wikiapp`. A newer version may have come out since this was written: if your
numbers are newer, your `uv.lock` will differ from the one here, and that is fine.

### step-01.2 Ask Wikipedia for a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/7f4aca68a6be75c4adcd6ef8ff76a8c5882ad67a): exactly what it changes.

This is the first code of wikiapp, from 2024, with a docstring that says what the command does. Replace
`src/wikiapp/console.py` with it.

```python
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

`@click.command()` turns `main` into a command. The original's `main` had no `-> None`; this one keeps the
annotation `uv init` gave it at step-00. `requests.get` asks Wikipedia's REST API for the summary of a
random page, `raise_for_status` raises an exception if the answer is an error, and `response.json()` reads the
answer as a dictionary. The title is printed in green, and the summary wrapped to 70 columns.

What changed:

- `src/wikiapp/console.py`: `main` asks Wikipedia for a page and prints it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/7f4aca68a6be75c4adcd6ef8ff76a8c5882ad67a/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/7f4aca68a6be75c4adcd6ef8ff76a8c5882ad67a#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): a request, and two lines printed.
  - look at: `with requests.get(API_URL) as response:`

```bash
uv run wikiapp
```

It fails: the last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error: Forbidden for
url:` and the address. Wikipedia now refuses a request whose User-Agent header is a library's default, and
requests sends `python-requests/` and its version.

### step-01.3 A User-Agent

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/92468952973a0251041a6df78eb07e027bf51336): exactly what it changes.

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

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/92468952973a0251041a6df78eb07e027bf51336/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/92468952973a0251041a6df78eb07e027bf51336#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the header.
  - look at: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

```bash
uv run wikiapp
```

A title in green, and a paragraph. Run it again for another page.

### step-01.4 --version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4f2dea44474a5d0f6eaa814125090449cee226b3): exactly what it changes.

The package can read its own version from what is installed, which is the version in `pyproject.toml`. Replace
`src/wikiapp/__init__.py` with this.

```python
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

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/4f2dea44474a5d0f6eaa814125090449cee226b3/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4f2dea44474a5d0f6eaa814125090449cee226b3#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): the version, read when the package is imported.
  - look at: `__version__ = importlib.metadata.version(__name__ or __package__)`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/4f2dea44474a5d0f6eaa814125090449cee226b3/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4f2dea44474a5d0f6eaa814125090449cee226b3#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): click's version option.
  - look at: `@click.version_option(version=__version__)`

```bash
uv run wikiapp --version
uv run wikiapp --help
```

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options: click writes the help from the
decorators and the docstring.

## step-02 Tests, with mocks

[The code at step-02](https://github.com/rahuldave/smallwikiapp/tree/step-02)

```bash
just setup
```

Six moves: pytest and a first test, a recipe for the tests, a mock in place of Wikipedia, four more tests,
and coverage on every run. One test asks the real Wikipedia, so until step 06 the tests need the network.

### step-02.1 pytest, and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c49cce43cee09fd0cb1cd9bdbfb2f04034732fbd): exactly what it changes.

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

click's `CliRunner` runs a command inside the test, in the same process, and keeps what it printed and its exit
code.

What changed:

- `pyproject.toml`: the groups `test` and `dev`.
- `tests/test_console.py`: the first test.
- `uv.lock`: pytest and what it needs.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c49cce43cee09fd0cb1cd9bdbfb2f04034732fbd/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c49cce43cee09fd0cb1cd9bdbfb2f04034732fbd#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the groups.
  - look at: `dev = [{ include-group = "test" }]`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/c49cce43cee09fd0cb1cd9bdbfb2f04034732fbd/tests/test_console.py): a test that runs the command and checks its exit code.
  - look at: `assert result.exit_code == 0`

```bash
uv run pytest
```

`1 passed`. This test asks the real Wikipedia, so it needs the network.

### step-02.2 just test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/9ad8e152a238cf98fb0dd07db61ebfadd91f5a47): exactly what it changes.

A recipe for the tests. Add it at the end of the `justfile`.

```just

# Run the tests. Extra arguments go to pytest: just test -k title
[group('quality')]
[no-exit-message]
test *args:
    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

`"$@"` is every word after `just test`, passed on to pytest whole. `just test help` shows the recipe. just
prints each line of a recipe before it runs it, unless the line starts with `@`: `just test` prints `uv run
pytest "$@"`, the command it ran.

What changed:

- `justfile`: the recipe `test`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/9ad8e152a238cf98fb0dd07db61ebfadd91f5a47/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/9ad8e152a238cf98fb0dd07db61ebfadd91f5a47#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `test *args:`

```bash
just --show test
just test
```

The same `1 passed`.

### step-02.3 A mock in place of Wikipedia

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b1f2c37139bd85f98c1c39df193bcec206989add): exactly what it changes.

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
- `pyproject.toml`: pytest-mock in the group `test`.
- `uv.lock`: the exact version of pytest-mock.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/b1f2c37139bd85f98c1c39df193bcec206989add/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b1f2c37139bd85f98c1c39df193bcec206989add#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixtures and the new test; `test_main_succeeds` takes the runner from its fixture.
  - look at: `mock = mocker.patch("requests.get")`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/b1f2c37139bd85f98c1c39df193bcec206989add/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b1f2c37139bd85f98c1c39df193bcec206989add#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pytest-mock in the group `test`.
  - look at: `"pytest-mock>=3.16.0",`

```bash
just test -k title -v
```

`test_main_prints_title PASSED`, without the network.

### step-02.4 Tests of the request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8392c95d27554c25137febdb81df36c8a8a66fd3): exactly what it changes.

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

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/8392c95d27554c25137febdb81df36c8a8a66fd3/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8392c95d27554c25137febdb81df36c8a8a66fd3#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the request is made, to the right address.
  - look at: `assert mock_requests_get.called`

```bash
just test
```

`4 passed`.

### step-02.5 A test of a failed request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/709a352a0d1d0e73febac2b6e63cfb9bac4d216d): exactly what it changes.

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

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/709a352a0d1d0e73febac2b6e63cfb9bac4d216d/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/709a352a0d1d0e73febac2b6e63cfb9bac4d216d#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the mock raises.
  - look at: `mock_requests_get.side_effect = Exception("Boom")`

```bash
just test
```

`5 passed`.

### step-02.6 Coverage

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/9e7ba9e779ba8659ce91406c963a0f5cdeeda859): exactly what it changes.

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

The original wikiapp's tests had one more fixture, `mock_wikipedia_random_page`, and a test left commented
out; neither was used, and they are not brought over.

What changed:

- `pyproject.toml`: pytest-cov in the group `test`, and pytest's settings.
- `uv.lock`: pytest-cov and coverage.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/9e7ba9e779ba8659ce91406c963a0f5cdeeda859/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/9e7ba9e779ba8659ce91406c963a0f5cdeeda859#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): coverage on every run.
  - look at: `addopts = "--cov=wikiapp --cov-report=term-missing"`

```bash
just test
```

The table under the tests lists each file of `src/wikiapp`, its statements, and the lines of those no test ran.
One line of `console.py` is missing: the call to `main` at the end, which runs only when the file itself is run
as a script.

## step-03 A library and an app

[The code at step-03](https://github.com/rahuldave/smallwikiapp/tree/step-03)

```bash
just setup
```

Six moves. The code that asks Wikipedia moves into a module of its own, `wikipedia.py`, which learns languages
and gets an error of its own. The command, in `console.py`, uses it. wikipedia.py becomes a library that knows
nothing of the command line, and console.py the app that uses it.

### step-03.1 random_page moves to wikipedia.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a9427561a71d0d6bd0261ef58688e805bdb653a7): exactly what it changes.

Make `src/wikiapp/wikipedia.py`.

```python
import requests

API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"

def random_page():
    """Get a random page from Wikipedia."""
    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
        response.raise_for_status()
        return response.json()
```

`random_page` returns the answer from inside the `with` block, where the original set `data` there and returned
it after; the result is the same. Then replace `src/wikiapp/console.py`: the constants and the request go, and
`main` calls `random_page`.

```python
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

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/a9427561a71d0d6bd0261ef58688e805bdb653a7/src/wikiapp/wikipedia.py): the code that talks to Wikipedia.
  - look at: `def random_page():`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/a9427561a71d0d6bd0261ef58688e805bdb653a7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a9427561a71d0d6bd0261ef58688e805bdb653a7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): what is left is the command.
  - look at: `data = random_page()`

```bash
just test
```

`5 passed`, with no change to the tests. The mock replaces the function `get` in the module `requests`, and
wikipedia.py calls it through the module, as `requests.get`, so it gets the mock.

### step-03.2 The mock moves to conftest.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a23a191c6704f87f8ae2d35dced756448d62d437): exactly what it changes.

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

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/a23a191c6704f87f8ae2d35dced756448d62d437/tests/conftest.py): the fixture, for every test file.
  - look at: `def mock_requests_get(mocker):`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/a23a191c6704f87f8ae2d35dced756448d62d437/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a23a191c6704f87f8ae2d35dced756448d62d437#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture is gone; the tests still name it.

```bash
just test
```

`5 passed`: pytest finds the fixture in conftest.py.

### step-03.3 A language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/02cddf614ac415f2015d25eef50f1298c103c77d): exactly what it changes.

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

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/02cddf614ac415f2015d25eef50f1298c103c77d/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/02cddf614ac415f2015d25eef50f1298c103c77d#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the hole, and its filling.
  - look at: `def random_page(language="en"):`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/02cddf614ac415f2015d25eef50f1298c103c77d/tests/test_wikipedia.py): the test uses the mock from conftest.py.
  - look at: `assert "es.wikipedia.org" in args[0]`

```bash
just test
```

`6 passed`.

### step-03.4 wikiapp --language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/0c008e2d7797ad21caa1c5a9f8828aa4e3f75078): exactly what it changes.

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

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/0c008e2d7797ad21caa1c5a9f8828aa4e3f75078/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/0c008e2d7797ad21caa1c5a9f8828aa4e3f75078#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the option, and `main` passes it on.
  - look at: `data = random_page(language=language)`

```bash
uv run wikiapp --language fr
uv run wikiapp --help
```

A French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/000725e3c6a5946e046d79d577e542fa64dbda31): exactly what it changes.

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

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/000725e3c6a5946e046d79d577e542fa64dbda31/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/000725e3c6a5946e046d79d577e542fa64dbda31#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the exception, and where it is raised.
  - look at: `raise WikipediaError(str(error)) from error`

```bash
uv run wikiapp --language xx
```

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback whose last line is the `WikipediaError`: nothing catches it yet.

### step-03.6 The command prints the error

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/560998138cda5c274494c3d59bbde5fa56fe95b5): exactly what it changes.

In `src/wikiapp/console.py`, import the error with `random_page`, and turn it into click's exception, which
click prints as a message.

```python
from wikiapp.wikipedia import WikipediaError, random_page
```

```python
    try:
        data = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
```

And a test, in `tests/test_console.py`, before `test_main_succeeds`, with `import requests` under `import
pytest`.

```python
def test_main_prints_message_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = requests.RequestException
    result = runner.invoke(console.main)
    assert "Error" in result.output
```

In the original wikiapp, the library raised click's exception itself, with a note to move it to the console
one day. Here it is moved: wikipedia.py knows Wikipedia and requests, console.py knows click.

What changed:

- `src/wikiapp/console.py`: `main` catches WikipediaError.
- `tests/test_console.py`: a test of the message.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/560998138cda5c274494c3d59bbde5fa56fe95b5/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/560998138cda5c274494c3d59bbde5fa56fe95b5#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the error becomes a message.
  - look at: `raise click.ClickException(str(error)) from error`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/560998138cda5c274494c3d59bbde5fa56fe95b5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/560998138cda5c274494c3d59bbde5fa56fe95b5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test.
  - look at: `assert "Error" in result.output`

```bash
uv run wikiapp --language xx; echo "exit code $?"
just test
```

`Error:` and the message, in place of a traceback, and `exit code 1`. `7 passed`.

## step-04 Format, lint, a hook

[The code at step-04](https://github.com/rahuldave/smallwikiapp/tree/step-04)

```bash
just setup
```

Eight moves. A formatter and what it changes; a linter, the five problems it finds, and their fixes; a recipe
that checks the configuration and one that runs every check; and a git hook that runs that before every commit.
A tool comes in one move and what it changes in the next, so that you see what the tool does before you accept
it. The tests still need the network, and pre-commit downloads its hooks from GitHub the first time.

### step-04.1 ruff, and just fmt

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d55cb0e34c42e10883a9e12a8b0ca25371584404): exactly what it changes.

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

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/d55cb0e34c42e10883a9e12a8b0ca25371584404/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/d55cb0e34c42e10883a9e12a8b0ca25371584404#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group and the settings.
  - look at: `line-length = 100`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/d55cb0e34c42e10883a9e12a8b0ca25371584404/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/d55cb0e34c42e10883a9e12a8b0ca25371584404#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `fmt *args:`

```bash
uv run ruff format --check
just --show fmt
just fmt --check
```

`--check` changes nothing: it lists what it would change and fails. `6 files would be reformatted, 1 file
already formatted`: the seventh file is the README. The recipe runs the same command, and passes on the words
after `just fmt`.

### step-04.2 The code, formatted

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8dec927fd06b423e44c4c04ff87bb2d6a94a429d): exactly what it changes.

Run the formatter.

```
just fmt
```

What changed:

- six files: two blank lines around each function and class, one after the imports of `__init__.py`, spaces
  around `==`, and the two lines longer than 100 characters split.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8dec927fd06b423e44c4c04ff87bb2d6a94a429d/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8dec927fd06b423e44c4c04ff87bb2d6a94a429d#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the long line of the request, split into three.
  - look at: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/8dec927fd06b423e44c4c04ff87bb2d6a94a429d/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8dec927fd06b423e44c4c04ff87bb2d6a94a429d#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): blank lines, and the long address split.
  - look at: `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`

```bash
just fmt --check
just test
```

`7 files already formatted`, and the tests pass as before: the formatter changes how the code looks, never what
it does.

### step-04.3 The linter's rules, and just lint

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8236536c7d57b0eb9b78c271f42180852955c23d): exactly what it changes.

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

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/8236536c7d57b0eb9b78c271f42180852955c23d/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/8236536c7d57b0eb9b78c271f42180852955c23d#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): a family of rules on each line.
  - look at: `"tests/**" = ["S101"]`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/8236536c7d57b0eb9b78c271f42180852955c23d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/8236536c7d57b0eb9b78c271f42180852955c23d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `lint *args:`

```bash
uv run ruff check --statistics
just --show lint
just lint --statistics
```

Five problems, each with its code: `I001`, the imports of console.py out of order; `E402`, an import in
test_console.py below code; `F841` twice, a variable assigned and never used; and `S113`, a request with no
timeout. `just lint` shows each one with its lines. `uv run ruff rule S113` explains a code.

### step-04.4 just lint --fix sorts the imports

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/75976381b05d63d57eb1b7fc1ad5aa7665eac1b7): exactly what it changes.

ruff can fix one of the five itself.

```
just lint --fix
```

What changed:

- `src/wikiapp/console.py`: the imports in three blocks: the standard library, the packages installed, then
  wikiapp's own.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/75976381b05d63d57eb1b7fc1ad5aa7665eac1b7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/75976381b05d63d57eb1b7fc1ad5aa7665eac1b7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the imports, sorted.
  - look at: `from wikiapp import __version__`

```bash
just lint --statistics
```

`just lint --fix` reported `Found 5 errors (1 fixed, 4 remaining)` and failed. Four left. They need a person.

### step-04.5 The tests' imports at the top, and no unused variables

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/26dd80f417c207449dcbf1a7b2a705c11f139e88): exactly what it changes.

In `tests/test_console.py`, move `from wikiapp import console` up under `import requests`, where a reader looks
for imports, with a blank line between them: wikiapp's own imports are a block of their own, after the installed
packages, as `--fix` made them in console.py. Where the import was, delete it and the two blank lines after it,
so that one function follows another with two blank lines between. In `test_main_invokes_requests_get` and
`test_main_uses_correct_url`, the result is never read: those tests check the mock, not the result. Make their
first line the call alone.

```python
    runner.invoke(console.main)
```

What changed:

- `tests/test_console.py`: the import at the top, and two assignments gone.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/26dd80f417c207449dcbf1a7b2a705c11f139e88/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/26dd80f417c207449dcbf1a7b2a705c11f139e88#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the import moves; `result =` goes twice.
  - look at: `from wikiapp import console`

```bash
just lint --statistics
just fmt --check
```

One left: `S113`. The format is unchanged: `7 files already formatted`.

### step-04.6 A timeout

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/6ff65200b1bc9f184ff62ae935c681084d8fcd05): exactly what it changes.

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

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/6ff65200b1bc9f184ff62ae935c681084d8fcd05/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/6ff65200b1bc9f184ff62ae935c681084d8fcd05#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): one argument more.
  - look at: `timeout=10`

```bash
just lint
```

`All checks passed!`

### step-04.7 just lint-config, and just check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/58aedae8653fd9f604efa438aeb182c77d246767): exactly what it changes.

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
- `pyproject.toml`: validate-pyproject in the group `lint`.
- `uv.lock`: the exact version of validate-pyproject, and of what it needs.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/58aedae8653fd9f604efa438aeb182c77d246767/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/58aedae8653fd9f604efa438aeb182c77d246767#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipes.
  - look at: `just test -q --cov-fail-under=90`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/58aedae8653fd9f604efa438aeb182c77d246767/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/58aedae8653fd9f604efa438aeb182c77d246767#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one package more in `lint`.
  - look at: `"validate-pyproject>=0.26",`

```bash
uv run validate-pyproject pyproject.toml
uv lock --check
just --fmt --check --unstable
just --show lint-config
just lint-config
just --show check
just check
```

Each check in turn: the format, the linter, the tests, which must run at least 90% of the statements, and the
configuration. The coverage is 96.77%.

### step-04.8 A git hook

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c4b193a0d3b705314214f651d3dc987406425be8): exactly what it changes.

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
- `pyproject.toml`: pre-commit in the group `lint`.
- `uv.lock`: the exact version of pre-commit, and of what it needs.

Files to read:
- [`.pre-commit-config.yaml`](https://github.com/rahuldave/smallwikiapp/blob/c4b193a0d3b705314214f651d3dc987406425be8/.pre-commit-config.yaml): three hooks from pre-commit's collection, then `just check`.
  - look at: `entry: just check`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c4b193a0d3b705314214f651d3dc987406425be8/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c4b193a0d3b705314214f651d3dc987406425be8#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): setup.
  - look at: `uv sync --locked && uv run pre-commit install`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c4b193a0d3b705314214f651d3dc987406425be8/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c4b193a0d3b705314214f651d3dc987406425be8#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pre-commit in the group `lint`.
  - look at: `"pre-commit>=4.6.2",`

```bash
just setup
uv run pre-commit run --files .pre-commit-config.yaml
```

`just setup` prints `pre-commit installed at .git/hooks/pre-commit`. `pre-commit run` runs every hook now, as
git will before a commit, on the file named. The first time, it prints `[INFO]` lines while it downloads the
hooks; then four lines, each `Passed`. `--all-files` would mean every file git tracks, and would skip this new
file until it is added.

## step-05 Types

[The code at step-05](https://github.com/rahuldave/smallwikiapp/tree/step-05)

```bash
just setup
```

Six moves. A type checker, and the one problem it finds; then a lint rule that asks for a type on every
parameter and return, the types, and the type checker in `just check`.

### step-05.1 ty, and just types

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/56c4925bc35e40f38de0fc65b0744963c0c41993): exactly what it changes.

ty reads the code without running it, and finds code whose types cannot fit: a call whose arguments cannot have
the type the function asks for.

```
uv add --group lint ty
```

In the `justfile`, a recipe after `lint`'s recipe and the blank line under it.

```just
# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
[group('quality')]
[no-exit-message]
types *args:
    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}

```

What changed:

- `justfile`: the recipe `types`.
- `pyproject.toml`: ty in the group `lint`.
- `uv.lock`: the exact version of ty.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/56c4925bc35e40f38de0fc65b0744963c0c41993/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/56c4925bc35e40f38de0fc65b0744963c0c41993#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `types *args:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/56c4925bc35e40f38de0fc65b0744963c0c41993/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/56c4925bc35e40f38de0fc65b0744963c0c41993#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): ty in the group `lint`.
  - look at: `"ty>=0.0.85",`

```bash
uv run ty check
just --show types
just types
```

One problem, in `src/wikiapp/__init__.py`: `Expected str, found str | None`. `__name__ or __package__` could
be None, as far as ty can tell, and `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/7e509af4801e90a4a912e39f20933cef2b1b6b84): exactly what it changes.

The installed package is named in `pyproject.toml`: `wikiapp`. That is the name to ask the version of. Change
the last line of `src/wikiapp/__init__.py`.

```python
__version__ = importlib.metadata.version("wikiapp")
```

What changed:

- `src/wikiapp/__init__.py`: the name, written out.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/7e509af4801e90a4a912e39f20933cef2b1b6b84/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/7e509af4801e90a4a912e39f20933cef2b1b6b84#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a string that is never None.
  - look at: `__version__ = importlib.metadata.version("wikiapp")`

```bash
just types
```

`All checks passed!`

### step-05.3 A type on every parameter and return

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/599c53a6634271b36c5a782bd85b2ee9aaddbc3c): exactly what it changes.

ty checks the types that are written. ruff's `ANN` rules make sure they are written. In `pyproject.toml`, add a
line to `select`, after `"N"`.

```toml
    "ANN", # annotations: every parameter and every return value has a type
```

What changed:

- `pyproject.toml`: the rules `ANN`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/599c53a6634271b36c5a782bd85b2ee9aaddbc3c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/599c53a6634271b36c5a782bd85b2ee9aaddbc3c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"ANN", # annotations: every parameter and every return value has a type`

```bash
just lint --statistics
```

25 missing: 15 parameters (`ANN001`) and 10 returns (`ANN201`), in the code and in the tests. `just check`
fails here, and stays failing until the next two moves, so the git hook refuses to commit this move or the next.
In do mode you make them without committing; in the project's history they are commits made past the hook.

### step-05.4 Types in the code

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e96b5c5014904c190146e0e793eea7da1af6ef82): exactly what it changes.

In `src/wikiapp/wikipedia.py`, `random_page` takes a string and returns the JSON that Wikipedia sends: a
dictionary from strings to values of any kind. `Any` says that ty cannot check what is inside. Import it at the
top, above `import requests`, with a blank line between them: the standard library is a block of its own.

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

- `src/wikiapp/wikipedia.py`: the types of `random_page`.
- `src/wikiapp/console.py`: the type of `main`'s parameter.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e96b5c5014904c190146e0e793eea7da1af6ef82/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e96b5c5014904c190146e0e793eea7da1af6ef82#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the parameter and the return.
  - look at: `def random_page(language: str = "en") -> dict[str, Any]:`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/e96b5c5014904c190146e0e793eea7da1af6ef82/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e96b5c5014904c190146e0e793eea7da1af6ef82#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the parameter.
  - look at: `def main(language: str) -> None:`

```bash
just lint --statistics
```

What is left is in the tests: 22, 13 parameters and 9 returns.

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/78719d508fddbe173afc20641b1cfae752ae2d85): exactly what it changes.

A fixture's return type is what a test receives: the runner is a `CliRunner`, the mock of `requests.get` a
`Mock`, and `mocker` is pytest-mock's `MockerFixture`, the name that replaced the original wikiapp's
`MockFixture`. A test returns None. Replace `tests/conftest.py`.

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

In `tests/test_console.py`, import `Mock` and `CliRunner` by name, use `CliRunner()` in the fixture, and give
every function its types. Two of them are the pattern for the rest.

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

In `tests/test_wikipedia.py`, the same: `from unittest.mock import Mock` at the top, with a blank line after it,
and the test's types.

```python
def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
```

What changed:

- `tests/conftest.py`: the types of the fixture.
- `tests/test_console.py`: the types of the fixture and of every test.
- `tests/test_wikipedia.py`: the types of the test.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/78719d508fddbe173afc20641b1cfae752ae2d85/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/78719d508fddbe173afc20641b1cfae752ae2d85#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/78719d508fddbe173afc20641b1cfae752ae2d85/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/78719d508fddbe173afc20641b1cfae752ae2d85#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/78719d508fddbe173afc20641b1cfae752ae2d85/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/78719d508fddbe173afc20641b1cfae752ae2d85#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

```bash
just lint
just types
```

Both pass. If `just lint` reports `I001`, the imports are not in the blocks shown above.

### step-05.6 Types join just check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d4cea1ddf1d0ec244e7c6c02a4518b89ac018273): exactly what it changes.

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

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/d4cea1ddf1d0ec244e7c6c02a4518b89ac018273/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/d4cea1ddf1d0ec244e7c6c02a4518b89ac018273#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
  - look at: `just types`

```bash
just check
```

Every check passes, the types among them, with a coverage of 96.88%.

## step-06 End to end, and CI

[The code at step-06](https://github.com/rahuldave/smallwikiapp/tree/step-06)

```bash
just setup
```

Four moves. The tests that ask the real Wikipedia run only when asked for; the project accepts every Python
from 3.11; and GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only when asked for

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/92e8adfe42d25e5d6f6047e5562791ed720ec646): exactly what it changes.

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

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/92e8adfe42d25e5d6f6047e5562791ed720ec646/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/92e8adfe42d25e5d6f6047e5562791ed720ec646#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test, marked.
  - look at: `@pytest.mark.e2e`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/92e8adfe42d25e5d6f6047e5562791ed720ec646/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/92e8adfe42d25e5d6f6047e5562791ed720ec646#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): `-m 'not e2e'`.
  - look at: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

```bash
just test -q
just test -q -m e2e
```

The first: `6 passed, 1 deselected`. The second runs the e2e test alone.

### step-06.2 An end-to-end test of the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/9dd759b5c90bd5aa6515f00f2b86ab38ec9f62bd): exactly what it changes.

The mocks return a dictionary with a title and an extract. This test, from the original wikiapp, checks that the
real Wikipedia still does. Add it at the end of `tests/test_wikipedia.py`, and `import pytest` in a block of its
own between `from unittest.mock import Mock` and `from wikiapp import wikipedia`, with a blank line on each
side.

```python

@pytest.mark.e2e
def test_random_page_returns_dictionary_in_production() -> None:
    page = wikipedia.random_page()
    assert "title" in page
    assert "extract" in page
```

What changed:

- `tests/test_wikipedia.py`: an e2e test.

Files to read:
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/9dd759b5c90bd5aa6515f00f2b86ab38ec9f62bd/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/9dd759b5c90bd5aa6515f00f2b86ab38ec9f62bd#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `assert "extract" in page`

```bash
just test -q -m e2e
```

`2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e0106bea1a8eccd2d9ced7bc35f458900bea048d): exactly what it changes.

`uv init` wrote `requires-python = ">=3.13"`, the Python it was asked for. Nothing here needs more than 3.11,
the oldest Python still given security fixes since 3.10's end on 1 October 2026. In `pyproject.toml`, change the
line, and solve the lockfile again.

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

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/e0106bea1a8eccd2d9ced7bc35f458900bea048d/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/e0106bea1a8eccd2d9ced7bc35f458900bea048d#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `requires-python = ">=3.11"`

```bash
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`--isolated` makes a temporary environment, with Python 3.11, and leaves `.venv` alone. The tests pass on 3.11.

### step-06.4 GitHub runs the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1abc50390a8d51db60fc9cc7f9ad283ca5d41317): exactly what it changes.

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

permissions:
  contents: read  # the jobs read the code, and change nothing on GitHub

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
      - uses: astral-sh/setup-uv@v10.2.0
        with:
          python-version: ${{ matrix.python }}
      - run: uv run --locked pytest

  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10.2.0
      - uses: extractions/setup-just@v4
      - run: just setup
      - run: just check
```

The original wikiapp did this with pixi, one environment for each Python. With uv, `setup-uv` tells uv which
Python to use, and `uv run` installs it if it is missing.

What changed:

- `.github/workflows/test.yaml`: new; two jobs, one of them twelve times.

Files to read:
- [`.github/workflows/test.yaml`](https://github.com/rahuldave/smallwikiapp/blob/1abc50390a8d51db60fc9cc7f9ad283ca5d41317/.github/workflows/test.yaml): the matrix of systems and Pythons.
  - look at: `python: ["3.11", "3.12", "3.13", "3.14"]`

```bash
uv run pre-commit run check-yaml --files .github/workflows/test.yaml
```

The file is valid YAML. GitHub runs it after a push: the Actions tab of the repository shows the thirteen jobs.

## step-07 A page with a shape

[The code at step-07](https://github.com/rahuldave/smallwikiapp/tree/step-07)

```bash
just setup
```

Four moves. A pydantic model says what a page is, `random_page` returns one, and an answer that is not a page
is an error like any other. Then the language itself gets a shape.

### step-07.1 Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/51f2e9de15e717875c9c3e74a7f91d82d75ed91a): exactly what it changes.

The command uses two of the many keys Wikipedia sends, and so far trusts that they are there and are strings. A
pydantic model says so in code.

```
uv add pydantic
```

In `src/wikiapp/wikipedia.py`, import it under `import requests`, and add the class after `WikipediaError`, with
two blank lines before it and after it.

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
- `pyproject.toml`: pydantic, a dependency of the package like click and requests.
- `uv.lock`: the exact version of pydantic, and of what it needs.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/51f2e9de15e717875c9c3e74a7f91d82d75ed91a/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/51f2e9de15e717875c9c3e74a7f91d82d75ed91a#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the model.
  - look at: `class Page(BaseModel):`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/51f2e9de15e717875c9c3e74a7f91d82d75ed91a/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/51f2e9de15e717875c9c3e74a7f91d82d75ed91a#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pydantic, a dependency of the package.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"
```

The first prints `title='A' extract='B'`: the other key is dropped. The second fails with a ValidationError:
`extract` is missing.

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf): exactly what it changes.

In `src/wikiapp/wikipedia.py`, `random_page` makes a Page of the answer and returns it. `Any` is no longer
needed: delete its import, and the blank line under it.

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

In `tests/test_wikipedia.py`, replace the e2e test `test_random_page_returns_dictionary_in_production`, keeping
its marker: its new name says it checks for a Page.

```python
@pytest.mark.e2e
def test_random_page_returns_page_in_production() -> None:
    page = wikipedia.random_page()
    assert isinstance(page, wikipedia.Page)
```

What changed:

- `src/wikiapp/wikipedia.py`: returns a Page.
- `src/wikiapp/console.py`: prints its attributes.
- `tests/test_wikipedia.py`: the e2e test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the return.
  - look at: `return Page.model_validate(response.json())`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): attributes, not keys.
  - look at: `click.secho(page.title, fg="green")`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2f0c65b38f5dbf18da32b25b4f77137bc09fd1bf#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the e2e test checks for a Page.
  - look at: `assert isinstance(page, wikipedia.Page)`

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/20c36b296ac1259775db9111ec6c41040eebfca3): exactly what it changes.

When the answer has no title, `model_validate` raises pydantic's ValidationError. `random_page` turns it into a
WikipediaError, as it does a failed request. In `src/wikiapp/wikipedia.py`, import it, and catch it with
requests' exception.

```python
from pydantic import BaseModel, ValidationError
```

```python
    except (requests.RequestException, ValidationError) as error:
```

And the test from the original wikiapp, at the end of `tests/test_wikipedia.py`. The mock answers with an empty
dictionary.

```python

def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
    with pytest.raises(wikipedia.WikipediaError):
        wikipedia.random_page()
```

What changed:

- `src/wikiapp/wikipedia.py`: a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: its test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/20c36b296ac1259775db9111ec6c41040eebfca3/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/20c36b296ac1259775db9111ec6c41040eebfca3#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): two exceptions caught.
  - look at: `except (requests.RequestException, ValidationError) as error:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/20c36b296ac1259775db9111ec6c41040eebfca3/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/20c36b296ac1259775db9111ec6c41040eebfca3#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `with pytest.raises(wikipedia.WikipediaError):`

```bash
just test -k validation
```

`1 passed, 8 deselected`.

### step-07.4 Only a language code goes into the address

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/716b44afab03e89cd9a9d9061b3f91bc0ca387f9): exactly what it changes.

The language is put into the host name: `{language}.wikipedia.org`. A language such as `example.com/x?` would
send the request, User-Agent and all, to example.com. Every Wikipedia's code is letters and hyphens: `en`, `fr`,
`simple`, `zh-yue`. In `src/wikiapp/wikipedia.py`, import `re` at the top, in a block of its own above `import
requests`, and add a pattern under `API_URL`.

```python
import re

```

```python
LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
```

`random_page` checks the language first, before the `try`.

```python
    if not LANGUAGE.fullmatch(language):
        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
```

What changed:

- `src/wikiapp/wikipedia.py`: the pattern, and the check.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/716b44afab03e89cd9a9d9061b3f91bc0ca387f9/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/716b44afab03e89cd9a9d9061b3f91bc0ca387f9#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): a language is checked before it is used.
  - look at: `if not LANGUAGE.fullmatch(language):`

```bash
uv run wikiapp --language 'example.com/x?'
just test -q
```

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and asks no one.
`7 passed, 2 deselected`. No test reaches the new `raise`, and the coverage table lists its line as missing: 95%
in all, still over the floor of 90%. A coverage drop is something to know, not something to hide with a test.

## step-08 Docs from the code

[The code at step-08](https://github.com/rahuldave/smallwikiapp/tree/step-08)

```bash
just setup
```

Six moves. A script that makes the reference from the code and says what is not documented; the library, the
command and the tests documented; a site; and the check in `just check`.

### step-08.1 docs/apidocs.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c3d97bbb1da2eeec300d2178cf2b76db97f342d0): exactly what it changes.

The reference of a function is its signature, what it does, and what each parameter is. The signature and the
types are in the code. What it does is its docstring. What each parameter is goes in a docment: the comment
beside the parameter, one parameter to a line, which fastcore reads. Here is how `random_page` will look; you
write it in the next move, not this one.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

fastcore goes in a fourth dependency group, `docs`, which `dev` includes. In `pyproject.toml`, change the line
`dev = ...`, and add the group.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```

```
uv add --group docs fastcore
```

`docs/apidocs.py` is a script of 218 lines. Take it from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/c3d97bbb1da2eeec300d2178cf2b76db97f342d0). It has two commands: `module NAME` prints one module's reference as Markdown, and `check`
lists every function and class, in the package, the tests and the script itself, that lacks a docstring, a type
or a docment, and every module without a docstring. Read its docstring, and any one function: the script follows
its own rule.

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
- `pyproject.toml`: the group `docs`, with fastcore.
- `uv.lock`: the exact version of fastcore.

Files to read:
- [`docs/apidocs.py`](https://github.com/rahuldave/smallwikiapp/blob/c3d97bbb1da2eeec300d2178cf2b76db97f342d0/docs/apidocs.py): the script; every function in it has its docments.
  - look at: `def gaps_of(`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c3d97bbb1da2eeec300d2178cf2b76db97f342d0/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c3d97bbb1da2eeec300d2178cf2b76db97f342d0#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c3d97bbb1da2eeec300d2178cf2b76db97f342d0/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c3d97bbb1da2eeec300d2178cf2b76db97f342d0#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `docs *args:`

```bash
uv run python docs/apidocs.py module wikipedia
just --show docs
just docs check
```

`module` prints the reference of wikipedia.py, with empty descriptions. `check` counts, for each module, how
many of its functions and classes are complete, then lists every gap, and fails: `15 of 29 functions and classes
are typed and documented`. Fourteen are the script's own; the fifteenth is `WikipediaError`, which needs only
its docstring. Above the total, every gap by name, the six modules without a docstring among them.

### step-08.2 The library documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/31f4e8bb646cf61eac57d44eef6689bf683678e8): exactly what it changes.

In `src/wikiapp/wikipedia.py`, a docstring at the top of the module, a docment beside each field of Page, and on
the parameter and the return of `random_page`, whose docstring says when it raises.

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

What changed:

- `src/wikiapp/wikipedia.py`: a module docstring, docments, and a longer docstring.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/31f4e8bb646cf61eac57d44eef6689bf683678e8/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/31f4e8bb646cf61eac57d44eef6689bf683678e8#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the comments are the documentation.
  - look at: `) -> Page:  # A page chosen at random`

```bash
just docs module wikipedia
```

The tables now have their descriptions.

### step-08.3 The command documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/578516dacf8505aa01e6851354ffe64c72765103): exactly what it changes.

`src/wikiapp/__init__.py` and `src/wikiapp/console.py` get a docstring at the top.

```python
"""wikiapp: the title and summary of a random Wikipedia page."""

```

```python
"""The wikiapp command."""

```

In `console.py`, `main` has one parameter to a line, with its docment, and a docstring that says what is
printed. A function that returns None needs no docment for it. click prints the docstring and each option's
help in `wikiapp --help`, so those are documentation too: the help of `--language` says what a language is, in
place of the original wikiapp's "Gets random page from Wikipedia in given language".

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

What changed:

- `src/wikiapp/__init__.py`: a module docstring.
- `src/wikiapp/console.py`: a module docstring; `main`, documented; and the help of `--language`.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/578516dacf8505aa01e6851354ffe64c72765103/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/578516dacf8505aa01e6851354ffe64c72765103#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the docment, the docstring and the help.
  - look at: `language: str,  # The language of the Wikipedia to ask, from --language`

```bash
just docs module console
uv run wikiapp --help
```

The reference of `main` has its description, and `--help` shows the new docstring and the help of the option.

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/85c598938b20b6e77a51daeb7aebc7cca86f6cc9): exactly what it changes.

Every test file says what it tests, every fixture what it returns, and every test, in one line, what it checks.
The docstrings say in words what the asserts say in code. The three files are long to type: take them from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/85c598938b20b6e77a51daeb7aebc7cca86f6cc9). One test is the pattern.

```python
def test_main_prints_title(
    runner: CliRunner,  # The runner from the fixture
    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
) -> None:
    """The command prints the title of the page."""
```

What changed:

- `tests/conftest.py`: a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: a docstring for the file, the fixture and each test, and a docment for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/85c598938b20b6e77a51daeb7aebc7cca86f6cc9/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/85c598938b20b6e77a51daeb7aebc7cca86f6cc9#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/85c598938b20b6e77a51daeb7aebc7cca86f6cc9/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/85c598938b20b6e77a51daeb7aebc7cca86f6cc9#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/85c598938b20b6e77a51daeb7aebc7cca86f6cc9/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/85c598938b20b6e77a51daeb7aebc7cca86f6cc9#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

```bash
just docs check
```

`29 of 29 functions and classes are typed and documented`, and no module is without its docstring.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b7f576fb72fbe71a743cdf0bc065a968ea469dff): exactly what it changes.

Quarto makes a website from Markdown. It is a program of its own, installed apart from uv:
https://quarto.org/docs/get-started/. The site is in `docs/`: a front page, `index.qmd`, and a reference page
for each module, which `apidocs.py build` writes from the code before every render.

This move adds four files:

- `docs/_quarto.yml`, the site's settings;
- `docs/index.qmd`, the front page;
- `docs/linkify.lua`, which turns a name in backticks into a link to its entry;
- `docs/.gitignore`.

`apidocs.py` gains `build`, with an id on each heading and a link to the line of the source. `just docs` with no
words renders the site, and `just setup`, now a script of several lines, says when Quarto is missing. Take the
move from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/b7f576fb72fbe71a743cdf0bc065a968ea469dff), and read
`docs/_quarto.yml`.

What changed:

- `docs/_quarto.yml`: new; the site's settings, and the script to run before each render.
- `docs/index.qmd`: new; the front page.
- `docs/linkify.lua`: new; turns a name in backticks into a link.
- `docs/.gitignore`: new; what Quarto makes and git should not track.
- `docs/apidocs.py`: the command `build`; `entry` and `markdown` take `page`, which adds an id to each heading and
  a link to the source, and leaves out the module's own heading, since Quarto writes the title.
- `justfile`: `docs` renders the site; `setup` checks for Quarto.

Files to read:
- [`docs/_quarto.yml`](https://github.com/rahuldave/smallwikiapp/blob/b7f576fb72fbe71a743cdf0bc065a968ea469dff/docs/_quarto.yml): `pre-render` runs the script.
  - look at: `pre-render: python apidocs.py build  # the reference pages are made from the code, never by hand`
- [`docs/apidocs.py`](https://github.com/rahuldave/smallwikiapp/blob/b7f576fb72fbe71a743cdf0bc065a968ea469dff/docs/apidocs.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b7f576fb72fbe71a743cdf0bc065a968ea469dff#diff-da01f36fbf3b920a98c35ef6b70581a4f7a056ee5fce1a3cf3ca0c713601f832): `build`.
  - look at: `def build() -> int:  # The exit code, always 0`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/b7f576fb72fbe71a743cdf0bc065a968ea469dff/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/b7f576fb72fbe71a743cdf0bc065a968ea469dff#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): no words, the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run quarto render docs; fi`

```bash
just docs
```

`Output created: _site/index.html`. Open `docs/_site/index.html` in a browser: on the front page, `random_page`
is a link to its entry.

### step-08.6 The docs check joins just check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ce7b705f261780042de92640a34071c937214015): exactly what it changes.

In the `justfile`, in `check`, run `just docs check` after the tests, and say so in the comment.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

```just
    just test -q --cov-fail-under=90
    just docs check
```

The README gains Quarto among the tools, `tests/` and `docs/` among the folders, and says that `wikipedia.py` is
the library and `console.py` the command. Take the README from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/ce7b705f261780042de92640a34071c937214015), or copy these rows: the Quarto row under the just row, and the three rows in place of
the `src/wikiapp/` row.

```markdown
| [Quarto](https://quarto.org/) | The docs site, from `just docs` |
```

```markdown
| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
| `tests/` | The tests. `just test` runs them |
| `docs/` | The docs site. `apidocs.py` makes its reference from the code |
```

What changed:

- `justfile`: the docs check in `check`.
- `README.md`: Quarto, tests and docs.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/ce7b705f261780042de92640a34071c937214015/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/ce7b705f261780042de92640a34071c937214015#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
  - look at: `just docs check`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/ce7b705f261780042de92640a34071c937214015/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/ce7b705f261780042de92640a34071c937214015#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): the tools and the folders.
  - look at: `| [Quarto](https://quarto.org/) | The docs site, from`

```bash
just check
```

`30 of 30`: `build`, which came in the move before, is the thirtieth. Now the git hook refuses a commit that
leaves a function, a parameter or a field undocumented.

## step-09 The library as a package

[The code at step-09](https://github.com/rahuldave/smallwikiapp/tree/step-09)

```bash
just setup
```

Four moves. The code that asks Wikipedia becomes a package of its own, `wikirandom`, in the same repository: an
empty package first, then the code, then the app using it, then the docs. Any other program could install
wikirandom without wikiapp and click.

### step-09.1 An empty library, wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/297ada06eab31fa4d58fa9bf7a13e841d04e7e8b): exactly what it changes.

uv can make a second package inside a project. The two then form a *workspace*: one lockfile and one `.venv` for
both.

```
uv init --lib --author-from none packages/wikirandom
```

uv makes `packages/wikirandom/`, with these files in it:

- `pyproject.toml`, the library's own;
- `README.md`, empty;
- `src/wikirandom/__init__.py`, with an example function, `hello`;
- `src/wikirandom/py.typed`, the mark that tells a type checker the package has types.

In the project's `pyproject.toml` it adds `[tool.uv.workspace]`. uv copied the Python version from
`.python-version`; in `packages/wikirandom/pyproject.toml`, make the library need 3.11, like the app, and give
it a description.

```toml
description = "A random page of Wikipedia, in any language"
```

```toml
requires-python = ">=3.11"
```

Replace `packages/wikirandom/README.md` with a heading and one line of what it is, and lock again.

```markdown
# wikirandom

A random page of Wikipedia, in any language: the library that the command `wikiapp` uses.
```

```
uv lock
```

What changed:

- `packages/wikirandom/`: new; a package with uv's example function, `hello`.
- `pyproject.toml`: the workspace, with one member.
- `uv.lock`: the second package.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/297ada06eab31fa4d58fa9bf7a13e841d04e7e8b/packages/wikirandom/pyproject.toml): a package of its own.
  - look at: `name = "wikirandom"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/297ada06eab31fa4d58fa9bf7a13e841d04e7e8b/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/297ada06eab31fa4d58fa9bf7a13e841d04e7e8b#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the workspace.
  - look at: `"packages/wikirandom",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"
```

`Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`, and runs there:
the app does not depend on it yet, so a plain `uv run` would not install it. `--author-from none` kept uv from
writing your name and email from git into the library's `pyproject.toml`.

### step-09.2 wikirandom gets the code

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/9a4a80f0a96303df3aee8c331d799f0c4a1ffaab): exactly what it changes.

The library needs requests and pydantic.

```
uv add --package wikirandom requests pydantic
```

Replace `packages/wikirandom/src/wikirandom/__init__.py` with the code of `src/wikiapp/wikipedia.py`, its
docstring changed to say what the package is, and its User-Agent changed to name the program that makes the
request.

```python
"""wikirandom: a random page of Wikipedia, in any language, from its REST API."""
```

```python
USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```

What changed:

- `packages/wikirandom/src/wikirandom/__init__.py`: the code of wikipedia.py.
- `packages/wikirandom/pyproject.toml`: requests and pydantic, the library's dependencies.
- `uv.lock`: the library's dependencies.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/9a4a80f0a96303df3aee8c331d799f0c4a1ffaab/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/9a4a80f0a96303df3aee8c331d799f0c4a1ffaab#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the library.
  - look at: `def random_page(`
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/9a4a80f0a96303df3aee8c331d799f0c4a1ffaab/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/9a4a80f0a96303df3aee8c331d799f0c4a1ffaab#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): its dependencies.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The title of a French page. The app still has its own `wikipedia.py`, and does not use the library yet.

### step-09.3 The app uses wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b0ad9785fa3775f58babe661243fe46ec2948e53): exactly what it changes.

Make the library a dependency of the app, and take requests and pydantic out of the app's dependencies: it no
longer imports them.

```
uv add wikirandom
uv remove requests pydantic
```

Because wikirandom is a member of the workspace, `uv add` writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`: uv installs it from `packages/wikirandom`, editable, not from PyPI.

In `src/wikiapp/console.py`, import from the library. ruff sorts it with the installed packages, under `import
click`.

```python
import click
from wikirandom import WikipediaError, random_page

from wikiapp import __version__
```

Delete `src/wikiapp/wikipedia.py`. Rename `tests/test_wikipedia.py` to `tests/test_wikirandom.py`, and make it
test the library: its docstring says `Tests of the library, wikirandom.`, it imports `import wikirandom` under
`import pytest`, in place of `from wikiapp import wikipedia` and the blank line before it, and
`wikipedia.random_page`, `wikipedia.Page` and `wikipedia.WikipediaError` become `wikirandom.random_page`,
`wikirandom.Page` and `wikirandom.WikipediaError`. The host `es.wikipedia.org` in the first test stays as it is.

```
git rm src/wikiapp/wikipedia.py
git mv tests/test_wikipedia.py tests/test_wikirandom.py
```

In `pyproject.toml`, coverage measures both packages.

```toml
# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
```

```toml
addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
```

What changed:

- `pyproject.toml`: wikirandom in, requests and pydantic out; its source in the workspace; coverage of both.
- `uv.lock`: the app's dependencies are click and wikirandom.
- `src/wikiapp/console.py`: imports from wikirandom.
- `src/wikiapp/wikipedia.py`: deleted.
- `tests/test_wikipedia.py`: now `tests/test_wikirandom.py`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/b0ad9785fa3775f58babe661243fe46ec2948e53/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b0ad9785fa3775f58babe661243fe46ec2948e53#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app depends on the library.
  - look at: `wikirandom = { workspace = true }`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/b0ad9785fa3775f58babe661243fe46ec2948e53/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b0ad9785fa3775f58babe661243fe46ec2948e53#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): one import.
  - look at: `from wikirandom import WikipediaError, random_page`
- [`tests/test_wikirandom.py`](https://github.com/rahuldave/smallwikiapp/blob/b0ad9785fa3775f58babe661243fe46ec2948e53/tests/test_wikirandom.py): the same three tests.
  - look at: `wikirandom.random_page(language="es")`

```bash
just test -q
uv tree --depth 2
just docs check
```

`7 passed, 2 deselected`, and the coverage table lists `packages/wikirandom/src/wikirandom/__init__.py`. `uv
tree` shows wikiapp needing click and wikirandom, and wikirandom needing requests and pydantic. `just docs
check` still counts the app alone, 27 of 27: the next move adds the library.

### step-09.4 The docs name both packages

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e84679d0c0293465570e00c87bb5b53a98bdc813): exactly what it changes.

`docs/apidocs.py` documented one package, and only its modules. It now documents a list of packages, and each
package's own `__init__.py` too, because wikirandom is a single module. Take it from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/e84679d0c0293465570e00c87bb5b53a98bdc813). The main change is `PACKAGES` and `package_modules`; `check` and
`build` follow from it, and `build` writes a page only for a module that defines something.

```python
PACKAGES = ("wikiapp", "wikirandom")  # the app, and the library in packages/wikirandom
```

The front page of the site, `docs/index.qmd`, and the README's table of folders say that the repository contains
two packages: take them too, from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/e84679d0c0293465570e00c87bb5b53a98bdc813).

What changed:

- `docs/apidocs.py`: two packages.
- `docs/index.qmd`: two packages, the library and the app.
- `README.md`: a row for the library, and the `src/wikiapp/` row says the app.

Files to read:
- [`docs/apidocs.py`](https://github.com/rahuldave/smallwikiapp/blob/e84679d0c0293465570e00c87bb5b53a98bdc813/docs/apidocs.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e84679d0c0293465570e00c87bb5b53a98bdc813#diff-da01f36fbf3b920a98c35ef6b70581a4f7a056ee5fce1a3cf3ca0c713601f832): the list, and the package's own module.
  - look at: `mods += [pkg, *(importlib.import_module(f"{name}.{s}") for s in subs)]`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/e84679d0c0293465570e00c87bb5b53a98bdc813/docs/index.qmd), [its change](https://github.com/rahuldave/smallwikiapp/commit/e84679d0c0293465570e00c87bb5b53a98bdc813#diff-bfcaadbc044f4848960f04c96f4ac5930e20671e52514c04dd8347ff6f79ca7b): two packages.
  - look at: `It is two packages, in one repository:`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/e84679d0c0293465570e00c87bb5b53a98bdc813/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/e84679d0c0293465570e00c87bb5b53a98bdc813#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): one row more, and the `src/wikiapp/` row says the app.
  - look at: `| The library the app uses: a random page of Wikipedia. A package of its own |`

```bash
just docs check
just check
```

`wikirandom 3 of 3` in the docs check, and `30 of 30` in all.

## step-10 Build

[The code at step-10](https://github.com/rahuldave/smallwikiapp/tree/step-10)

```bash
just setup
```

Four moves. Each package builds into a wheel, the file that pip and uv install; the app says which versions of
the library it accepts; both say their licence and where their source is; and the library's User-Agent says the
version that is installed.

### step-10.1 just build

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ac01b3ec38dd668698a794a11f35154aecca8ae4): exactly what it changes.

`uv build --all-packages` builds every package of the workspace into `dist/`, which `.gitignore` lists. A recipe
for it, at the end of the `justfile`.

```just

# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
[group('setup')]
[no-exit-message]
build *args:
    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```

What changed:

- `justfile`: the recipe `build`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/ac01b3ec38dd668698a794a11f35154aecca8ae4/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/ac01b3ec38dd668698a794a11f35154aecca8ae4#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `build *args:`

```bash
uv build --all-packages
just --show build
just build
unzip -l dist/wikiapp-0.1.0-py3-none-any.whl
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

Four files in `dist/`: for each package, a source archive, `.tar.gz`, and a wheel, `.whl`. The app's wheel
contains `wikiapp/` and its metadata, which says it needs click and wikirandom. It does not say which
wikirandom: `uv add wikirandom` in a workspace writes no version. Installed from PyPI, it would get whatever
PyPI has under that name; today there is nothing, so wikirandom would have to be published first.

### step-10.2 The app needs wikirandom 0.1

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/097d05d9a6b99c0c76160e43afef377d28ddb182): exactly what it changes.

The app's wheel says it needs `wikirandom`, any version. Installed from PyPI, it would take whatever anyone
publishes under that name. Give it the range it was built and tested with.

```
uv add "wikirandom>=0.1.0,<0.2"
```

In the workspace nothing else changes: `[tool.uv.sources]` still installs it from `packages/wikirandom`.

What changed:

- `pyproject.toml`: a version range on wikirandom.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/097d05d9a6b99c0c76160e43afef377d28ddb182/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/097d05d9a6b99c0c76160e43afef377d28ddb182#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"wikirandom>=0.1.0,<0.2",`

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

### step-10.3 A licence and a home for both

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/825550faff7dc27cd6c60cb3bf4c56761e9393b1): exactly what it changes.

The library's wheel has no licence, and neither package says where its source is. Copy the project's `LICENSE`
into `packages/wikirandom/`, and in `packages/wikirandom/pyproject.toml`, under `readme`, give the licence and
the author, as the app's `pyproject.toml` does.

```
cp LICENSE packages/wikirandom/LICENSE
```

```toml
license = "Apache-2.0"
license-files = ["LICENSE"]
authors = [{ name = "Rahul Dave" }]
```

In both `pyproject.toml` files, above `[build-system]` in the library's and under `[project.scripts]` in the
app's, the repository, which PyPI shows on the package's page.

```toml

[project.urls]
Repository = "https://github.com/rahuldave/smallwikiapp"
```

In the `justfile`, `lint-config` checks both files.

```just
    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
```

What changed:

- `packages/wikirandom/LICENSE`: new; the same licence.
- `packages/wikirandom/pyproject.toml`: the licence, the author, the repository.
- `pyproject.toml`: the repository.
- `justfile`: `lint-config` checks both.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/825550faff7dc27cd6c60cb3bf4c56761e9393b1/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/825550faff7dc27cd6c60cb3bf4c56761e9393b1#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): what PyPI would show.
  - look at: `license = "Apache-2.0"`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/825550faff7dc27cd6c60cb3bf4c56761e9393b1/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/825550faff7dc27cd6c60cb3bf4c56761e9393b1#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/825550faff7dc27cd6c60cb3bf4c56761e9393b1/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/825550faff7dc27cd6c60cb3bf4c56761e9393b1#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app's repository.
  - look at: `[project.urls]`
- [`packages/wikirandom/LICENSE`](https://github.com/rahuldave/smallwikiapp/blob/825550faff7dc27cd6c60cb3bf4c56761e9393b1/packages/wikirandom/LICENSE): the same Apache-2.0 licence as the app's.
  - look at: `Apache License`

```bash
just lint-config
just build
unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA
```

`Valid file` twice. The library's metadata has `License-Expression: Apache-2.0`, `License-File: LICENSE` and
`Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

### step-10.4 The User-Agent says the installed version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cb1a3e3748ad6b8d5c166e94e193403ff33ce8f8): exactly what it changes.

The User-Agent says `0.1.0`, written by hand, and would go on saying it after the version in
`packages/wikirandom/pyproject.toml` changed. In `packages/wikirandom/src/wikirandom/__init__.py`, read it from
the installed package, as `wikiapp --version` does. Add `import importlib.metadata` in the block of `import re`,
above it, and replace the line `USER_AGENT`.

```python
import importlib.metadata
import re
```

```python
VERSION = importlib.metadata.version("wikirandom")
USER_AGENT = f"wikirandom/{VERSION} (https://github.com/rahuldave/smallwikiapp)"
```

What changed:

- `packages/wikirandom/src/wikirandom/__init__.py`: the version, read once, when the package is imported.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/cb1a3e3748ad6b8d5c166e94e193403ff33ce8f8/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/cb1a3e3748ad6b8d5c166e94e193403ff33ce8f8#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): one place for the version: pyproject.toml.
  - look at: `VERSION = importlib.metadata.version("wikirandom")`

```bash
uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"
just check
```

`wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.
