# smallwikiapp, one move at a time

This tutorial goes through the tagged steps of smallwikiapp, and the small commits between them. Each
small commit is a move, one action. A grey block is code to type, or a command that makes the move. The command
at the end of a move shows what the move did. Every step starts from the code of the step before, so every step
starts with `just setup`. To take the tutorial in timewalk, where you can watch each move or make it yourself,
see the [README](../../README.md).

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

This page is the tutorial for reading on GitHub. `just walk-update` makes it from [notes.md](notes.md),
the notes that timewalk reads, so do not edit it by hand.

- **Each step** links to the code at that step.
- **Each move** links to its commit, which shows exactly what the move changed.
- **A command to run** is in a grey block marked `bash`, and the text under it says what the command prints.
- **Under "Files to read"**, each file links to the file as the move leaves it, and to its change in the commit.

## step-00 The project

[The code at step-00](https://github.com/rahuldave/smallwikiapp/tree/step-00)

```bash
just setup
```

The tutorial starts at step-00, so step-00 has no moves. `uv init --package --python 3.13 --name wikiapp` made
the shape of the project:

- `pyproject.toml`
- `src/wikiapp/__init__.py`, with a function `main`
- `.python-version`, with the Python version

Then the author changed the project by hand. `main` moved to `src/wikiapp/console.py`. `pyproject.toml` got a
description, an author and a licence, and it names `wikiapp.console:main` as the command. `uv lock` wrote the
lockfile, `uv.lock`. The author also wrote the justfile, the README, `.gitignore` and `LICENSE` by hand.

`just setup` runs `uv sync --locked`. The command makes `.venv` with Python 3.13, from `.python-version`. It
installs exactly the packages that the lockfile names. Here, the only package is `wikiapp` itself.

```bash
cat pyproject.toml
```

The line under `[project.scripts]` makes `wikiapp` a command. The name is on the left. The function is on the
right, `main` in `src/wikiapp/console.py`. For now, `main` prints one line.

```bash
uv run wikiapp
cat src/wikiapp/console.py
```

The justfile is the interface of the project. `just` lists the tasks, and `just --show setup` shows the recipe
behind one task. `just help setup` shows the same recipe. Most steps add recipes to the justfile.

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

The moves of step-01 add these things:

- the two packages that the command needs
- a request to Wikipedia for a page
- a header that Wikipedia now asks for
- the option `--version`

### step-01.1 click and requests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/0244a354462fd8bbfa669c0b4fc20d94f30b684f) shows exactly what the move changes.

click makes command lines. requests gets pages over HTTP. Add both packages.

```
uv add click requests
```

The move changed these files:

- `pyproject.toml`: the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: the exact version of each, and of every package they need.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/0244a354462fd8bbfa669c0b4fc20d94f30b684f/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/0244a354462fd8bbfa669c0b4fc20d94f30b684f#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the dependencies of the package, which anyone who installs it gets.
  - look at: `"click>=8.5.0",`
- [`uv.lock`](https://github.com/rahuldave/smallwikiapp/blob/0244a354462fd8bbfa669c0b4fc20d94f30b684f/uv.lock), [its change](https://github.com/rahuldave/smallwikiapp/commit/0244a354462fd8bbfa669c0b4fc20d94f30b684f#diff-84321598744d84dbee2318e634c74c9aae39a1c253f1c4bd17ebf9ef2f807b11): the exact versions, for every platform.

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.
If your numbers are newer, your `uv.lock` differs from the one here, and the move is still correct.

### step-01.2 Ask Wikipedia for a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bfeb0574e98b051ac34d7c01acabebfbe2edea93) shows exactly what the move changes.

The code below is the first code of wikiapp, from 2024, with a docstring that says what the command does.
Replace `src/wikiapp/console.py` with it.

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

`@click.command()` makes `main` a command. The `main` of the original wikiapp had no `-> None`. The `main`
here keeps the annotation that `uv init` gave it at step-00.

- `requests.get` asks the REST API of Wikipedia for the summary of a random page.
- `raise_for_status` raises an exception if the answer is an error.
- `response.json()` reads the answer as a dictionary.

`main` prints the title in green, and the summary wrapped to 70 columns.

The move changed this file:

- `src/wikiapp/console.py`: `main` asks Wikipedia for a page and prints it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/bfeb0574e98b051ac34d7c01acabebfbe2edea93/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/bfeb0574e98b051ac34d7c01acabebfbe2edea93#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): a request, and two lines printed.
  - look at: `with requests.get(API_URL) as response:`

```bash
uv run wikiapp
```

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. Wikipedia now refuses a request whose User-Agent header is the default of
a library. requests sends `python-requests/` and its version.

### step-01.3 A User-Agent

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/daf71c89c6e48812e0dba005ad5889e02473c297) shows exactly what the move changes.

The User-Agent header says who sends the request. The policy of Wikimedia asks for the name of the program,
its version, and a way to reach the person who runs it. In `src/wikiapp/console.py`, add a line under `API_URL`, and pass it as a
header.

```python
USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```

```python
    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```

The move changed this file:

- `src/wikiapp/console.py`: a constant `USER_AGENT`, and the request sends it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/daf71c89c6e48812e0dba005ad5889e02473c297/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/daf71c89c6e48812e0dba005ad5889e02473c297#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the header.
  - look at: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

```bash
uv run wikiapp
```

A title in green, and a paragraph. Run it again for another page.

### step-01.4 --version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d7c0b15653372c416c640bfa0e57d6c3063f33c8) shows exactly what the move changes.

The package can read its own version from the installed package, which has the version in `pyproject.toml`.
Replace `src/wikiapp/__init__.py` with the code below.

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

The move changed these files:

- `src/wikiapp/__init__.py`: `__version__`, from the installed package.
- `src/wikiapp/console.py`: the option `--version`.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/d7c0b15653372c416c640bfa0e57d6c3063f33c8/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d7c0b15653372c416c640bfa0e57d6c3063f33c8#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): the version, which Python reads when it imports the package.
  - look at: `__version__ = importlib.metadata.version(__name__ or __package__)`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/d7c0b15653372c416c640bfa0e57d6c3063f33c8/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d7c0b15653372c416c640bfa0e57d6c3063f33c8#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): click's version option.
  - look at: `@click.version_option(version=__version__)`

```bash
uv run wikiapp --version
uv run wikiapp --help
```

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring.

## step-02 Tests, with mocks

[The code at step-02](https://github.com/rahuldave/smallwikiapp/tree/step-02)

```bash
just setup
```

The moves of this step add pytest and a first test, a recipe for the tests, and a mock in place of Wikipedia.
Then they add four more tests, and coverage on every run. One test asks the real Wikipedia, so the tests need
the network until step 06.

### step-02.1 pytest and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/7e0faa5c8c63362e383414376e4eb741749c6cdf) shows exactly what the move changes.

The tests need pytest, but the package does not. A person who installs wikiapp should not get pytest. So
pytest goes in a dependency group of its own, `test`. uv installs the group `dev` by default, so `dev` includes
`test`. In `pyproject.toml`, add the groups above `[build-system]`.

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

click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code of
the command.

The move changed these files:

- `pyproject.toml`: the groups `test` and `dev`.
- `tests/test_console.py`: the first test.
- `uv.lock`: pytest and what it needs.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/7e0faa5c8c63362e383414376e4eb741749c6cdf/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/7e0faa5c8c63362e383414376e4eb741749c6cdf#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the groups.
  - look at: `dev = [{ include-group = "test" }]`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/7e0faa5c8c63362e383414376e4eb741749c6cdf/tests/test_console.py): a test that runs the command and checks its exit code.
  - look at: `assert result.exit_code == 0`

```bash
uv run pytest
```

The result is `1 passed`. The test asks the real Wikipedia, so it needs the network.

### step-02.2 The recipe `just test`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d155d7210a1a68d864acbf217e09a1cfa7ab8a7f) shows exactly what the move changes.

Add a recipe for the tests at the end of the `justfile`.

```just

# Run the tests. Extra arguments go to pytest: just test -k title
[group('quality')]
[no-exit-message]
test *args:
    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

`"$@"` is every word after `just test`, and the recipe gives each word to pytest whole. `just test help` shows
the recipe. `just` prints each line of a recipe before it runs the line, if the line does not start with `@`.
So `just test` prints `uv run pytest "$@"`, the command that it ran.

The move changed this file:

- `justfile`: the recipe `test`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/d155d7210a1a68d864acbf217e09a1cfa7ab8a7f/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/d155d7210a1a68d864acbf217e09a1cfa7ab8a7f#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `test *args:`

```bash
just --show test
just test
```

The result is the same, `1 passed`.

### step-02.3 A mock in place of Wikipedia

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5bbd685cf8291fc4d3836da190c7d6c510b3d71c) shows exactly what the move changes.

A test that needs the network fails on a train. Also, a test cannot check the title of a random page.
pytest-mock can replace `requests.get` with a mock for the length of one test.

```
uv add --group test pytest-mock
```

Replace `tests/test_console.py` with the code below.

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

A fixture is a function that pytest calls for each test that names it as a parameter. `mocker` is the fixture
of pytest-mock. `mocker.patch("requests.get")` replaces the function, and puts it back after the test. The long
line sets what the mock returns when the code calls `response.json()` inside the `with` block. The mock returns
a page with the title Lorem Ipsum.

The move changed these files:

- `tests/test_console.py`: two fixtures, and a test of the title.
- `pyproject.toml`: pytest-mock in the group `test`.
- `uv.lock`: the exact version of pytest-mock.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/5bbd685cf8291fc4d3836da190c7d6c510b3d71c/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/5bbd685cf8291fc4d3836da190c7d6c510b3d71c#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixtures and the new test. `test_main_succeeds` takes the runner from its fixture.
  - look at: `mock = mocker.patch("requests.get")`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/5bbd685cf8291fc4d3836da190c7d6c510b3d71c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/5bbd685cf8291fc4d3836da190c7d6c510b3d71c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pytest-mock in the group `test`.
  - look at: `"pytest-mock>=3.16.0",`

```bash
just test -k title -v
```

The output shows `test_main_prints_title PASSED`, without the network.

### step-02.4 Tests of the request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/530c581ca62f995e8f00944065aa31702c6afa12) shows exactly what the move changes.

A mock keeps a record of each call to it. Add two tests to `tests/test_console.py`, after `test_main_prints_title`.

```python
def test_main_invokes_requests_get(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.called

def test_main_uses_correct_url(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
```

`call_args[0]` is the tuple of the positional arguments of the last call. Here it holds only the address. The
header is a keyword argument, in `call_args[1]`.

The move changed this file:

- `tests/test_console.py`: two tests of the request.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/530c581ca62f995e8f00944065aa31702c6afa12/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/530c581ca62f995e8f00944065aa31702c6afa12#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the code makes the request, to the right address.
  - look at: `assert mock_requests_get.called`

```bash
just test
```

The result is `4 passed`.

### step-02.5 A test of a failed request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3ab310e810d7a1d2c8dfc4f869ec9e6f61f2683c) shows exactly what the move changes.

The mock can raise an exception as well as return a value. If `side_effect` is an exception, a call to the
mock raises it. Add the test below before `test_main_succeeds`.

```python
def test_main_fails_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = Exception("Boom")
    result = runner.invoke(console.main)
    assert result.exit_code == 1
```

The move changed this file:

- `tests/test_console.py`: a test that a failed request ends the command with exit code 1.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/3ab310e810d7a1d2c8dfc4f869ec9e6f61f2683c/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3ab310e810d7a1d2c8dfc4f869ec9e6f61f2683c#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the mock raises.
  - look at: `mock_requests_get.side_effect = Exception("Boom")`

```bash
just test
```

The result is `5 passed`.

### step-02.6 Coverage

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a685fea8174179bbc25c7e390bd5f875bd56d125) shows exactly what the move changes.

pytest-cov measures which lines of the code the tests run.

```
uv add --group test pytest-cov
```

Turn it on for every run, at the end of `pyproject.toml`.

```toml

[tool.pytest.ini_options]
testpaths = ["tests"]
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
addopts = "--cov=wikiapp --cov-report=term-missing"
```

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented out.
No test used them, so the project does not keep them.

The move changed these files:

- `pyproject.toml`: pytest-cov in the group `test`, and pytest's settings.
- `uv.lock`: pytest-cov and coverage.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/a685fea8174179bbc25c7e390bd5f875bd56d125/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/a685fea8174179bbc25c7e390bd5f875bd56d125#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): coverage on every run.
  - look at: `addopts = "--cov=wikiapp --cov-report=term-missing"`

```bash
just test
```

The table under the tests lists each file of `src/wikiapp`, its statements, and the lines that no test ran.
One line of `console.py` is missing. It is the call to `main` at the end, which runs only when you run the file
as a script.

## step-03 A library and an app

[The code at step-03](https://github.com/rahuldave/smallwikiapp/tree/step-03)

```bash
just setup
```

The code that asks Wikipedia moves into a module of its own, `wikipedia.py`. The module then gets a language
and an error of its own. The command, in `console.py`, uses the module. So wikipedia.py is a library that knows
nothing of the command line, and console.py is the app that uses it.

### step-03.1 random_page moves to wikipedia.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d3f80f14b1769cf9db45c5da2a483303a043804a) shows exactly what the move changes.

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

`random_page` returns the answer from inside the `with` block. The original set `data` there, and returned it
after the block. The result is the same. Then replace `src/wikiapp/console.py` with the code below. The
constants and the request go, and `main` calls `random_page`.

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

The move changed these files:

- `src/wikiapp/wikipedia.py`: a new file with the address, the User-Agent, and `random_page`.
- `src/wikiapp/console.py`: `main` calls `random_page`.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d3f80f14b1769cf9db45c5da2a483303a043804a/src/wikiapp/wikipedia.py): the code that talks to Wikipedia.
  - look at: `def random_page():`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/d3f80f14b1769cf9db45c5da2a483303a043804a/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d3f80f14b1769cf9db45c5da2a483303a043804a#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): only the command stays.
  - look at: `data = random_page()`

```bash
just test
```

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. wikipedia.py calls the function through the module, as `requests.get`, so it gets the mock.

### step-03.2 The mock moves to conftest.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/945d9d0bcdaf01f8efd2545ca8b6e4c5b394590d) shows exactly what the move changes.

pytest reads `tests/conftest.py` before the tests, and every test file can use a fixture in it. The tests of
wikipedia.py, in the next move, need the mock too. Make `tests/conftest.py` with the mock in it. Then delete the
mock from `tests/test_console.py`.

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

The move changed these files:

- `tests/conftest.py`: a new file with the mock.
- `tests/test_console.py`: the mock is gone.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/945d9d0bcdaf01f8efd2545ca8b6e4c5b394590d/tests/conftest.py): the fixture, for every test file.
  - look at: `def mock_requests_get(mocker):`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/945d9d0bcdaf01f8efd2545ca8b6e4c5b394590d/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/945d9d0bcdaf01f8efd2545ca8b6e4c5b394590d#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture is gone, but the tests still name it.

```bash
just test
```

The result is `5 passed`. pytest finds the fixture in conftest.py.

### step-03.3 A language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5b7b97126c6d8a8ff1700ce9174b0fed619b44f8) shows exactly what the move changes.

Each language has its own Wikipedia, at LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, put a
placeholder for the language in the address. Fill it in `random_page`, with English as the default.

```python
API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
```

```python
def random_page(language="en"):
    """Get a random page from Wikipedia."""
    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
```

Then make the first test of the library, `tests/test_wikipedia.py`.

```python
from wikiapp import wikipedia

def test_random_page_uses_given_language(mock_requests_get):
    wikipedia.random_page(language="es")
    args, _ = mock_requests_get.call_args
    assert "es.wikipedia.org" in args[0]
```

The move changed these files:

- `src/wikiapp/wikipedia.py`: `random_page` takes a language.
- `tests/test_wikipedia.py`: a new file with a test that the language chooses the Wikipedia.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/5b7b97126c6d8a8ff1700ce9174b0fed619b44f8/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/5b7b97126c6d8a8ff1700ce9174b0fed619b44f8#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the placeholder, and the code that fills it.
  - look at: `def random_page(language="en"):`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/5b7b97126c6d8a8ff1700ce9174b0fed619b44f8/tests/test_wikipedia.py): the test uses the mock from conftest.py.
  - look at: `assert "es.wikipedia.org" in args[0]`

```bash
just test
```

The result is `6 passed`.

### step-03.4 wikiapp --language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5c36a9e6397a07627ba4822bb1fe15ed11cd7da2) shows exactly what the move changes.

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

click gives the value of the option to the parameter with the same name.

The move changed this file:

- `src/wikiapp/console.py`: the option `--language`, or `-l`.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/5c36a9e6397a07627ba4822bb1fe15ed11cd7da2/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/5c36a9e6397a07627ba4822bb1fe15ed11cd7da2#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the option, which `main` gives to `random_page`.
  - look at: `data = random_page(language=language)`

```bash
uv run wikiapp --language fr
uv run wikiapp --help
```

The first command prints a French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e56dd91911fcc2f6f97322c9ec6a2abdd003576a) shows exactly what the move changes.

If a request fails for any reason, requests raises a `RequestException`. Code that uses the library should
not need to know the exceptions of requests. So the library raises an exception of its own. In
`src/wikiapp/wikipedia.py`, add the class above `random_page`, and put the request in a `try` block.

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

`from error` keeps the original exception, so a traceback shows both exceptions.

The move changed this file:

- `src/wikiapp/wikipedia.py`: the class `WikipediaError`, which `random_page` raises.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e56dd91911fcc2f6f97322c9ec6a2abdd003576a/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e56dd91911fcc2f6f97322c9ec6a2abdd003576a#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the exception, and the line that raises it.
  - look at: `raise WikipediaError(str(error)) from error`

```bash
uv run wikiapp --language xx
```

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback, and the last line is the `WikipediaError`. No code catches the error yet.

### step-03.6 The command prints the error

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3b1b8264f0ccd49f4b14646fe201d4ca89d27562) shows exactly what the move changes.

In `src/wikiapp/console.py`, import the error with `random_page`. Catch it, and raise the exception of click,
which click prints as a message.

```python
from wikiapp.wikipedia import WikipediaError, random_page
```

```python
    try:
        data = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
```

Add a test to `tests/test_console.py`, before `test_main_succeeds`. Put `import requests` under `import pytest`.

```python
def test_main_prints_message_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = requests.RequestException
    result = runner.invoke(console.main)
    assert "Error" in result.output
```

In the original wikiapp, the library raised the exception of click itself, with a note to move it to the
console one day. In this move, the exception of click moves to console.py. wikipedia.py knows Wikipedia and requests, and console.py knows click.

The move changed these files:

- `src/wikiapp/console.py`: `main` catches WikipediaError.
- `tests/test_console.py`: a test of the message.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3b1b8264f0ccd49f4b14646fe201d4ca89d27562/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b1b8264f0ccd49f4b14646fe201d4ca89d27562#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the error becomes a message.
  - look at: `raise click.ClickException(str(error)) from error`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/3b1b8264f0ccd49f4b14646fe201d4ca89d27562/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b1b8264f0ccd49f4b14646fe201d4ca89d27562#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test.
  - look at: `assert "Error" in result.output`

```bash
uv run wikiapp --language xx; echo "exit code $?"
just test
```

The first command prints `Error:` and the message in place of a traceback, then `exit code 1`. The tests give
`7 passed`.

## step-04 Format, lint, a hook

[The code at step-04](https://github.com/rahuldave/smallwikiapp/tree/step-04)

```bash
just setup
```

The eight moves of this step add a formatter, and then the changes that it makes. Next, a linter finds five
problems, and the next three moves fix them. Then a recipe checks the configuration, and another recipe runs every
check. Last, a git hook runs every check before each commit.

A tool comes in one move, and its changes come in the next move. So you see what the tool does before you accept
it. The tests still need the network. Also, pre-commit downloads its hooks from GitHub the first time.

### step-04.1 ruff, and the recipe fmt

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5a753853c419bdc6332bf32d1b133d169a420ac4) shows exactly what the move changes.

ruff is a formatter and a linter in one program. It goes in a third dependency group, `lint`, which `dev`
includes. In `pyproject.toml`, change the line `dev = ...`, and add the group.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }]
lint = []
```

Add ruff to the group. Then add its settings at the end of `pyproject.toml`.

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

Add a recipe at the end of the `justfile`.

```just

# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
[group('quality')]
[no-exit-message]
fmt *args:
    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```

The move changed these files:

- `pyproject.toml`: the group `lint`, and ruff's settings.
- `justfile`: the recipe `fmt`.
- `uv.lock`: ruff.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/5a753853c419bdc6332bf32d1b133d169a420ac4/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/5a753853c419bdc6332bf32d1b133d169a420ac4#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group and the settings.
  - look at: `line-length = 100`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5a753853c419bdc6332bf32d1b133d169a420ac4/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/5a753853c419bdc6332bf32d1b133d169a420ac4#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `fmt *args:`

```bash
uv run ruff format --check
just --show fmt
just fmt --check
```

`--check` changes nothing. It lists the files that it would change, and fails. It prints `6 files would be
reformatted, 1 file already formatted`. The seventh file is the README. The recipe runs the same command, and
passes on the words after `just fmt`.

### step-04.2 The code, formatted

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/feced32a1860c8cf7cbf8bebd0d4255ad65eb3a0) shows exactly what the move changes.

Run the formatter.

```
just fmt
```

The move changed these files:

- `src/wikiapp/__init__.py`: a blank line after the import.
- `src/wikiapp/console.py`: two blank lines before the command and before `if __name__`, and spaces around `==`.
- `src/wikiapp/wikipedia.py`: two blank lines around the class, and the request, longer than 100 characters, split.
- `tests/conftest.py`: two blank lines before the fixture.
- `tests/test_console.py`: two blank lines around each function, and the line longer than 100 characters split.
- `tests/test_wikipedia.py`: two blank lines before the test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/feced32a1860c8cf7cbf8bebd0d4255ad65eb3a0/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/feced32a1860c8cf7cbf8bebd0d4255ad65eb3a0#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the long line of the request, split into three.
  - look at: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/feced32a1860c8cf7cbf8bebd0d4255ad65eb3a0/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/feced32a1860c8cf7cbf8bebd0d4255ad65eb3a0#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): blank lines, and the long address split.
  - look at: `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`

```bash
just fmt --check
just test
```

The check prints `7 files already formatted`, and the tests pass as before. The formatter changes how the code
looks, and never what it does.

### step-04.3 The linter's rules, and the recipe lint

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/766d872a76673e075aef1a0d34d3c6161f85954e) shows exactly what the move changes.

The linter checks the code against rules. At the end of `pyproject.toml`, choose the families of rules. Also
let the tests use `assert`. The rest of the code may not use it, because Python skips every `assert` when it runs
with `-O`.

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

Add a recipe at the end of the `justfile`.

```just

# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
[group('quality')]
[no-exit-message]
lint *args:
    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```

The move changed these files:

- `pyproject.toml`: the rules.
- `justfile`: the recipe `lint`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/766d872a76673e075aef1a0d34d3c6161f85954e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/766d872a76673e075aef1a0d34d3c6161f85954e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): a family of rules on each line.
  - look at: `"tests/**" = ["S101"]`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/766d872a76673e075aef1a0d34d3c6161f85954e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/766d872a76673e075aef1a0d34d3c6161f85954e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `lint *args:`

```bash
uv run ruff check --statistics
just --show lint
just lint --statistics
```

The linter finds five problems, each with its code:

- `I001`: the imports of console.py are out of order.
- `E402`: an import in test_console.py comes below code.
- `F841`, twice: a variable is assigned and never used.
- `S113`: a request has no timeout.

`just lint` shows each problem with its lines. `uv run ruff rule S113` explains a code.

### step-04.4 The linter sorts the imports

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a6b786b22acae52a142843d5bc4d3465974f6977) shows exactly what the move changes.

ruff can fix one of the five problems itself.

```
just lint --fix
```

The move changed this file:

- `src/wikiapp/console.py`: the imports in three blocks, which are the standard library, the packages
  installed, and then wikiapp's own.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/a6b786b22acae52a142843d5bc4d3465974f6977/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a6b786b22acae52a142843d5bc4d3465974f6977#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the imports, sorted.
  - look at: `from wikiapp import __version__`

```bash
just lint --statistics
```

`just lint --fix` reported `Found 5 errors (1 fixed, 4 remaining)` and failed. Four problems are left, and a
person must fix them.

### step-04.5 The tests' imports at the top, and no unused variables

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/f58fcbc8bae0a8f9dfcababac5214e7bcb179c0f) shows exactly what the move changes.

In `tests/test_console.py`, move `from wikiapp import console` up, under `import requests`. A reader looks for
imports there. Put a blank line between the two imports. wikiapp's own imports are a block of their own, after
the installed packages, as `--fix` made them in console.py. Where the import was, delete it and the two blank
lines after it. The functions are then two blank lines apart.

In `test_main_invokes_requests_get` and `test_main_uses_correct_url`, no line reads the result. The two tests
check the mock, not the result. Make the first line of each test the call alone.

```python
    runner.invoke(console.main)
```

The move changed this file:

- `tests/test_console.py`: the import at the top, and two assignments gone.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/f58fcbc8bae0a8f9dfcababac5214e7bcb179c0f/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/f58fcbc8bae0a8f9dfcababac5214e7bcb179c0f#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the import moves, and two lines lose `result =`.
  - look at: `from wikiapp import console`

```bash
just lint --statistics
just fmt --check
```

One problem is left, `S113`. The format is unchanged, and the check prints `7 files already formatted`.

### step-04.6 A timeout

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a212a169676e922423ed4b4423041db100c8f298) shows exactly what the move changes.

Without a timeout, requests waits as long as the server keeps the connection open. So the command can wait for
ever. In `src/wikiapp/wikipedia.py`, add `timeout=10` to the request.

```python
        with requests.get(
            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
        ) as response:
```

If the server does not answer within 10 seconds, the request now raises an exception. `random_page` turns it
into a WikipediaError, as it does with every other error of requests.

The move changed this file:

- `src/wikiapp/wikipedia.py`: the timeout.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/a212a169676e922423ed4b4423041db100c8f298/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a212a169676e922423ed4b4423041db100c8f298#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): one more argument.
  - look at: `timeout=10`

```bash
just lint
```

`All checks passed!`

### step-04.7 The recipes lint-config and check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/87e187e314adcef8251c2545e20d8d2083cbbba2) shows exactly what the move changes.

validate-pyproject checks `pyproject.toml` against the standard for it.

```
uv add --group lint validate-pyproject
```

In the `justfile`, under `set positional-arguments`, add the line below. With it, every `uv run` of a recipe
refuses a lockfile that is out of date. Without it, `uv run` quietly updates the lockfile.

```just

export UV_LOCKED := "1"
```

Then add two recipes at the end. `lint-config` checks the configuration. `check` runs every check in order, and
stops at the first check that fails.

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

The move changed these files:

- `justfile`: `UV_LOCKED`, and the recipes `lint-config` and `check`.
- `pyproject.toml`: validate-pyproject in the group `lint`.
- `uv.lock`: the exact version of validate-pyproject, and of what it needs.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/87e187e314adcef8251c2545e20d8d2083cbbba2/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/87e187e314adcef8251c2545e20d8d2083cbbba2#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipes.
  - look at: `just test -q --cov-fail-under=90`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/87e187e314adcef8251c2545e20d8d2083cbbba2/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/87e187e314adcef8251c2545e20d8d2083cbbba2#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one package more in `lint`.
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

`just check` runs the format, the linter, the tests and the configuration, in that order. The
tests must run at least 90% of the statements. The coverage is 96.77%.

### step-04.8 A git hook

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c8989273671435cc31dac2b9980ab637c62c7c29) shows exactly what the move changes.

pre-commit installs a git hook. A git hook is a program that git runs before every commit. If the program
fails, git refuses the commit.

```
uv add --group lint pre-commit
```

Make `.pre-commit-config.yaml`.

```yaml
# What every commit must pass. `just hook` installs it as a git hook.
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

In the `justfile`, after `setup`, add a recipe `hook` that installs the hook. It is a recipe of its own, run
once in each clone, because `just setup` runs at every step and never touches git.

```just
# Install the git hook: just check before every commit. Once per clone; just setup never touches git
[group('setup')]
hook *args:
    @{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}
```

The move changed these files:

- `.pre-commit-config.yaml`: a new file, with the hooks.
- `justfile`: the recipe `hook`, which installs the hook.
- `pyproject.toml`: pre-commit in the group `lint`.
- `uv.lock`: the exact version of pre-commit, and of what it needs.

Files to read:
- [`.pre-commit-config.yaml`](https://github.com/rahuldave/smallwikiapp/blob/c8989273671435cc31dac2b9980ab637c62c7c29/.pre-commit-config.yaml): three hooks from pre-commit's collection, then `just check`.
  - look at: `entry: just check`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c8989273671435cc31dac2b9980ab637c62c7c29/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c8989273671435cc31dac2b9980ab637c62c7c29#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe `hook`.
  - look at: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c8989273671435cc31dac2b9980ab637c62c7c29/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c8989273671435cc31dac2b9980ab637c62c7c29#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pre-commit in the group `lint`.
  - look at: `"pre-commit>=4.6.2",`

```bash
uv run pre-commit install
just --show hook
just hook
uv run pre-commit run --files .pre-commit-config.yaml
```

`uv run pre-commit install` prints `pre-commit installed at .git/hooks/pre-commit`, and `just hook` prints the
same line. The hook is in `.git/hooks`, and no step or move changes that folder. So the hook stays for the rest
of the tutorial. If you start at a later step, run `just hook` once there.

`pre-commit run` now runs every hook on the file named, as git will before a commit. The first time, it prints
`[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

With `--all-files`, pre-commit would check every file that git tracks. It would skip the new file until you add
it.

## step-05 Types

[The code at step-05](https://github.com/rahuldave/smallwikiapp/tree/step-05)

```bash
just setup
```

The six moves of this step add a type checker, and fix the one problem that it finds. Then a lint rule asks for
a type on every parameter and return. The last moves add the types, and put the type checker in `just check`.

### step-05.1 ty, and the recipe types

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d59d19907fc93849a2cb2a6af6db76b9ff3bdcab) shows exactly what the move changes.

ty reads the code without running it. It finds code whose types cannot fit, for example a call whose
arguments cannot have the types that the function asks for.

```
uv add --group lint ty
```

In the `justfile`, add a recipe after the recipe `lint` and the blank line under it.

```just
# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
[group('quality')]
[no-exit-message]
types *args:
    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}

```

The move changed these files:

- `justfile`: the recipe `types`.
- `pyproject.toml`: ty in the group `lint`.
- `uv.lock`: the exact version of ty.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/d59d19907fc93849a2cb2a6af6db76b9ff3bdcab/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/d59d19907fc93849a2cb2a6af6db76b9ff3bdcab#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `types *args:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/d59d19907fc93849a2cb2a6af6db76b9ff3bdcab/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/d59d19907fc93849a2cb2a6af6db76b9ff3bdcab#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): ty in the group `lint`.
  - look at: `"ty>=0.0.86",`

```bash
uv run ty check
just --show types
just types
```

ty finds one problem, in `src/wikiapp/__init__.py`. The message is `Expected str, found str | None`. As far as
ty can tell, `__name__ or __package__` could be None. But `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/899da963782847990a532c8a22bb88d7c00eb7d0) shows exactly what the move changes.

`pyproject.toml` gives the name of the installed package, `wikiapp`. Ask for the version of that name. Change
the last line of `src/wikiapp/__init__.py`.

```python
__version__ = importlib.metadata.version("wikiapp")
```

The move changed this file:

- `src/wikiapp/__init__.py`: the name, written out.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/899da963782847990a532c8a22bb88d7c00eb7d0/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/899da963782847990a532c8a22bb88d7c00eb7d0#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a string that is never None.
  - look at: `__version__ = importlib.metadata.version("wikiapp")`

```bash
just types
```

`All checks passed!`

### step-05.3 A type on every parameter and return

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4cfcfd118bcc9bf50911e9b78f364d5bf4270f6a) shows exactly what the move changes.

ty checks the types that the code states. ruff's `ANN` rules make sure that the code states a type for every
parameter and return. In `pyproject.toml`, add a line to `select`, after `"N"`.

```toml
    "ANN", # annotations: every parameter and every return value has a type
```

The move changed this file:

- `pyproject.toml`: the rules `ANN`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4cfcfd118bcc9bf50911e9b78f364d5bf4270f6a/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4cfcfd118bcc9bf50911e9b78f364d5bf4270f6a#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"ANN", # annotations: every parameter and every return value has a type`

```bash
just lint --statistics
```

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). `just check` fails at this move and at the next move, and passes again at step-05.5. So the
git hook refuses to commit this move or the next. In do mode, you make the two moves without a commit. In the
project's history, they are commits made past the hook.

### step-05.4 Types in the code

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e90d3539a291aec5ff8991880c84d826e31e4de3) shows exactly what the move changes.

In `src/wikiapp/wikipedia.py`, `random_page` takes a string. It returns the JSON that Wikipedia sends, which is
a dictionary from strings to values of any kind. `Any` says that ty cannot check the values. Import `Any` at the
top, above `import requests`, with a blank line between them. The standard library is a block of its own.

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

The move changed these files:

- `src/wikiapp/wikipedia.py`: the types of `random_page`.
- `src/wikiapp/console.py`: the type of `main`'s parameter.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e90d3539a291aec5ff8991880c84d826e31e4de3/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e90d3539a291aec5ff8991880c84d826e31e4de3#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the parameter and the return.
  - look at: `def random_page(language: str = "en") -> dict[str, Any]:`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/e90d3539a291aec5ff8991880c84d826e31e4de3/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e90d3539a291aec5ff8991880c84d826e31e4de3#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the parameter.
  - look at: `def main(language: str) -> None:`

```bash
just lint --statistics
```

The 22 problems that are left are all in the tests. They are 13 parameters and 9 returns.

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4fb473c006a96a13b7dca1d44e689922b3367a3f) shows exactly what the move changes.

The return type of a fixture is the type of what a test receives. The runner is a `CliRunner`, and the mock of
`requests.get` is a `Mock`. `mocker` is pytest-mock's `MockerFixture`, the name that replaced the original
wikiapp's `MockFixture`. A test returns None. Replace `tests/conftest.py` with this file.

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

In `tests/test_console.py`, import `Mock` and `CliRunner` by name. Use `CliRunner()` in the fixture, and give
every function its types. Two of the functions are the pattern for the rest.

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

In `tests/test_wikipedia.py`, do the same. Put `from unittest.mock import Mock` at the top, with a blank line
after it, and give the test its types.

```python
def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
```

The move changed these files:

- `tests/conftest.py`: the types of the fixture.
- `tests/test_console.py`: the types of the fixture and of every test.
- `tests/test_wikipedia.py`: the types of the test.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/4fb473c006a96a13b7dca1d44e689922b3367a3f/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4fb473c006a96a13b7dca1d44e689922b3367a3f#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/4fb473c006a96a13b7dca1d44e689922b3367a3f/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4fb473c006a96a13b7dca1d44e689922b3367a3f#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/4fb473c006a96a13b7dca1d44e689922b3367a3f/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4fb473c006a96a13b7dca1d44e689922b3367a3f#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

```bash
just lint
just types
```

Both commands pass. If `just lint` reports `I001`, the imports are not in the blocks that the code above shows.

### step-05.6 The recipe check runs the type checker

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/651dfacf9652736ba064cb7d5ed7c448b6717b62) shows exactly what the move changes.

In the `justfile`, in `check`, run `just types` after `just lint`. Also add the types to the comment of `check`.

```just
# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
```

```just
    just lint
    just types
```

The move changed this file:

- `justfile`: `check` runs the type checker.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/651dfacf9652736ba064cb7d5ed7c448b6717b62/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/651dfacf9652736ba064cb7d5ed7c448b6717b62#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
  - look at: `just types`

```bash
just check
```

Every check passes, the type check among them. The coverage is 96.88%.

## step-06 End to end, and CI

[The code at step-06](https://github.com/rahuldave/smallwikiapp/tree/step-06)

```bash
just setup
```

The moves of this step do three things. The tests that ask the real Wikipedia run only when you ask for them.
The project accepts every Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only on request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06d70aceb4d4e9667cbd804c76b4457dc719d5cc) shows exactly what the move changes.

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. In `tests/test_console.py`, mark it `e2e`, which means end to end, and give it a name that
says so.

```python
@pytest.mark.e2e
def test_main_succeeds_in_production(runner: CliRunner) -> None:
```

In `pyproject.toml`, declare the marker, and leave the e2e tests out of every run that does not ask for them.
Replace the comment and the line `addopts`.

```toml
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
# marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
# just test -m e2e
addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
```

The move changed these files:

- `tests/test_console.py`: the marker, and the name.
- `pyproject.toml`: the marker, declared, and the e2e tests left out of a plain run.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/06d70aceb4d4e9667cbd804c76b4457dc719d5cc/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/06d70aceb4d4e9667cbd804c76b4457dc719d5cc#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test, marked.
  - look at: `@pytest.mark.e2e`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/06d70aceb4d4e9667cbd804c76b4457dc719d5cc/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/06d70aceb4d4e9667cbd804c76b4457dc719d5cc#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the option `-m 'not e2e'`.
  - look at: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

```bash
just test -q
just test -q -m e2e
```

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

### step-06.2 An end-to-end test of the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8d5aa93483eafc57b316a90d80b0d331268e2fda) shows exactly what the move changes.

The mocks return a dictionary with a title and an extract. The test below comes from the original wikiapp. It
checks that the real Wikipedia still returns the same keys. Add it at the end of `tests/test_wikipedia.py`. Put
`import pytest` in a block of its own between `from unittest.mock import Mock` and `from wikiapp import
wikipedia`, with a blank line on each side.

```python

@pytest.mark.e2e
def test_random_page_returns_dictionary_in_production() -> None:
    page = wikipedia.random_page()
    assert "title" in page
    assert "extract" in page
```

The move changed this file:

- `tests/test_wikipedia.py`: an e2e test.

Files to read:
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8d5aa93483eafc57b316a90d80b0d331268e2fda/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8d5aa93483eafc57b316a90d80b0d331268e2fda#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `assert "extract" in page`

```bash
just test -q -m e2e
```

The output is `2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/f5f30dab3fdcff2e9258bb587081074d604bbe2b) shows exactly what the move changes.

`uv init` wrote `requires-python = ">=3.13"`, because the command asked for Python 3.13. Nothing here needs
more than 3.11. Python 3.10 reached its end of life on 1 October 2026, so 3.11 is now the oldest Python that
still gets security fixes. In `pyproject.toml`, change the line, and solve the lockfile again.

```toml
requires-python = ">=3.11"
```

```
uv lock
```

The project still runs on 3.13, from `.python-version`.

The move changed these files:

- `pyproject.toml`: the oldest Python that the project accepts.
- `uv.lock`: solved for every Python from 3.11 on.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/f5f30dab3fdcff2e9258bb587081074d604bbe2b/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/f5f30dab3fdcff2e9258bb587081074d604bbe2b#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `requires-python = ">=3.11"`

```bash
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`--isolated` makes a temporary environment with Python 3.11, and does not change `.venv`. The tests pass on
3.11.

### step-06.4 GitHub runs the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/f1cd68a79f3c4645aff6b5488816e47682caedc0) shows exactly what the move changes.

A GitHub Actions workflow is a file in `.github/workflows/`. GitHub runs the jobs of the workflow on every push
to main and on every pull request. Make `.github/workflows/test.yaml`.

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

The original wikiapp used pixi for the same work, with one environment for each Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

The move changed this file:

- `.github/workflows/test.yaml`: a new file with two jobs. GitHub runs one of the jobs twelve times.

Files to read:
- [`.github/workflows/test.yaml`](https://github.com/rahuldave/smallwikiapp/blob/f1cd68a79f3c4645aff6b5488816e47682caedc0/.github/workflows/test.yaml): the matrix of systems and Pythons.
  - look at: `python: ["3.11", "3.12", "3.13", "3.14"]`

```bash
uv run pre-commit run check-yaml --files .github/workflows/test.yaml
```

The file is valid YAML. GitHub runs the workflow after a push. The **Actions** tab of the repository shows the
thirteen jobs.

## step-07 A page with a shape

[The code at step-07](https://github.com/rahuldave/smallwikiapp/tree/step-07)

```bash
just setup
```

The moves of this step give a page a shape. A pydantic model says what a page is, and `random_page` returns
one. An answer that is not a page becomes an error like any other. The last move checks that the language is a
language code.

### step-07.1 The model Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41d4791ec82d883e586068533a9615c9cd3def02) shows exactly what the move changes.

The command uses two of the many keys that Wikipedia sends. Until now, the code expects these keys to be there,
with strings as values, but nothing checks it. A pydantic model states the two keys and their types in code.

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

The move changed these files:

- `src/wikiapp/wikipedia.py`: the class `Page`.
- `pyproject.toml`: pydantic, a dependency of the package, as click and requests are.
- `uv.lock`: the exact version of pydantic, and of what it needs.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/41d4791ec82d883e586068533a9615c9cd3def02/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/41d4791ec82d883e586068533a9615c9cd3def02#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the model.
  - look at: `class Page(BaseModel):`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/41d4791ec82d883e586068533a9615c9cd3def02/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/41d4791ec82d883e586068533a9615c9cd3def02#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pydantic, a dependency of the package.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"
```

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails
with a ValidationError, because `extract` is missing.

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2) shows exactly what the move changes.

In `src/wikiapp/wikipedia.py`, `random_page` makes a Page of the answer and returns the Page. The code no
longer uses `Any`, so delete its import, and the blank line under it.

```python
def random_page(language: str = "en") -> Page:
```

```python
            return Page.model_validate(response.json())
```

In `src/wikiapp/console.py`, `main` prints the attributes of the page. ty and an editor know the names of the
attributes. A misspelled key of a dictionary shows up only when the program runs.

```python
    try:
        page = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
    click.secho(page.title, fg="green")
    click.echo(textwrap.fill(page.extract))
```

In `tests/test_wikipedia.py`, replace the e2e test `test_random_page_returns_dictionary_in_production`, and
keep its marker. The new name says that the test checks for a Page.

```python
@pytest.mark.e2e
def test_random_page_returns_page_in_production() -> None:
    page = wikipedia.random_page()
    assert isinstance(page, wikipedia.Page)
```

The move changed these files:

- `src/wikiapp/wikipedia.py`: returns a Page.
- `src/wikiapp/console.py`: prints the attributes of the Page.
- `tests/test_wikipedia.py`: the e2e test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the return.
  - look at: `return Page.model_validate(response.json())`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): attributes, not keys.
  - look at: `click.secho(page.title, fg="green")`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d7971160f956d3d7eeae3bdc3188f2a1e88c11b2#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the e2e test checks for a Page.
  - look at: `assert isinstance(page, wikipedia.Page)`

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/72d00434681ffca5f834c48facd04586d667c1f8) shows exactly what the move changes.

When the answer has no title, `model_validate` raises the ValidationError of pydantic. `random_page` turns it
into a WikipediaError, as it does with a failed request. In `src/wikiapp/wikipedia.py`, import ValidationError,
and catch it together with the exception of requests.

```python
from pydantic import BaseModel, ValidationError
```

```python
    except (requests.RequestException, ValidationError) as error:
```

Add the test from the original wikiapp at the end of `tests/test_wikipedia.py`. In the test, the mock answers
with an empty dictionary.

```python

def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
    with pytest.raises(wikipedia.WikipediaError):
        wikipedia.random_page()
```

The move changed these files:

- `src/wikiapp/wikipedia.py`: a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: a test of the ValidationError.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/72d00434681ffca5f834c48facd04586d667c1f8/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/72d00434681ffca5f834c48facd04586d667c1f8#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): two exceptions caught.
  - look at: `except (requests.RequestException, ValidationError) as error:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/72d00434681ffca5f834c48facd04586d667c1f8/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/72d00434681ffca5f834c48facd04586d667c1f8#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `with pytest.raises(wikipedia.WikipediaError):`

```bash
just test -k validation
```

The output is `1 passed, 8 deselected`.

### step-07.4 Only a language code goes into the address

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/46dd48eefeafc44375e9c6e098793cda68a09897) shows exactly what the move changes.

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as
`example.com/x?` sends the request to example.com, with the User-Agent. The code of every Wikipedia has only
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. In `src/wikiapp/wikipedia.py`, import `re`
at the top, in a block of its own above `import requests`. Add a pattern under `API_URL`.

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

The move changed this file:

- `src/wikiapp/wikipedia.py`: the pattern, and the check.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/46dd48eefeafc44375e9c6e098793cda68a09897/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/46dd48eefeafc44375e9c6e098793cda68a09897#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the code checks a language before it uses it.
  - look at: `if not LANGUAGE.fullmatch(language):`

```bash
uv run wikiapp --language 'example.com/x?'
just test -q
```

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%. A drop in coverage is
something to know about. Do not hide it with a new test.

## step-08 Docs from the code

[The code at step-08](https://github.com/rahuldave/smallwikiapp/tree/step-08)

```bash
just setup
```

The moves of this step add documentation:

- a script that makes the reference from the code, and says what has no documentation
- the documentation of the library, of the command and of the tests
- a site
- the check of the documentation in `just check`

### step-08.1 The script docs/apidocs.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be) shows exactly what the move changes.

The reference of a function gives its signature, what it does, and what each parameter is. The signature and
the types are in the code. The docstring says what the function does. A docment says what each parameter is. A
docment is the comment beside a parameter, with one parameter to a line, and fastcore reads it.

The block below shows `random_page` with its docments. You write it in the next move, not in this move.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

fastcore goes in a fourth dependency group, `docs`, and `dev` includes that group. In `pyproject.toml`, change
the line `dev = ...`, and add the group.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```

```
uv add --group docs fastcore
```

`docs/apidocs.py` is a script of 218 lines. Take it from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be). The script has two commands:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package, the tests and the script itself.

Read the docstring of the script, and any one function. The script follows its own rule.

Add a recipe at the end of the `justfile`.

```just

# The reference, from the code: just docs check, just docs module wikipedia. Words go to docs/apidocs.py
[group('docs')]
[no-exit-message]
docs *args:
    {{ if args == "help" { "just help docs" } else { 'uv run python docs/apidocs.py "$@"' } }}
```

The move changed these files:

- `docs/apidocs.py`: a new file, with the commands `check` and `module`.
- `justfile`: the recipe `docs`.
- `pyproject.toml`: the group `docs`, with fastcore.
- `uv.lock`: the exact version of fastcore.

Files to read:
- [`docs/apidocs.py`](https://github.com/rahuldave/smallwikiapp/blob/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be/docs/apidocs.py): the script. Every function in it has its docments.
  - look at: `def gaps_of(`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/3ba5bbb1f3df12a205ddc8dd984e8964e5f469be#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `docs *args:`

```bash
uv run python docs/apidocs.py module wikipedia
just --show docs
just docs check
```

`module` prints the reference of wikipedia.py, with empty descriptions. For each module, `check` counts the
functions and classes that are complete. Then it lists every gap, and fails with `15 of 29 functions and
classes are typed and documented`. Fourteen of the 15 are in the script. The fifteenth is `WikipediaError`,
which needs only its docstring. Above the total, `check` names every gap, and the six modules without a
docstring are among them.

### step-08.2 The library documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/54d471e703a705581d3cfc3d8a992ee09bcda797) shows exactly what the move changes.

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

The move changed this file:

- `src/wikiapp/wikipedia.py`: a docstring for the module, docments, and a longer docstring.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/54d471e703a705581d3cfc3d8a992ee09bcda797/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/54d471e703a705581d3cfc3d8a992ee09bcda797#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the comments are the documentation.
  - look at: `) -> Page:  # A page chosen at random`

```bash
just docs module wikipedia
```

The tables now have their descriptions.

### step-08.3 The command documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/64a6f678d104d644aabb5e878d4daab9a78f60b9) shows exactly what the move changes.

Add a docstring at the top of `src/wikiapp/__init__.py` and of `src/wikiapp/console.py`.

```python
"""wikiapp: the title and summary of a random Wikipedia page."""

```

```python
"""The wikiapp command."""

```

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
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/64a6f678d104d644aabb5e878d4daab9a78f60b9/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/64a6f678d104d644aabb5e878d4daab9a78f60b9#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the docment, the docstring and the help.
  - look at: `language: str,  # The language of the Wikipedia to ask, from --language`

```bash
just docs module console
uv run wikiapp --help
```

The reference of `main` now has its description. `--help` shows the new docstring and the help of the option.

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d) shows exactly what the move changes.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. The three files are long to type, so take
them from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d). The test below shows the
pattern.

```python
def test_main_prints_title(
    runner: CliRunner,  # The runner from the fixture
    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
) -> None:
    """The command prints the title of the page."""
```

The move changed these files:

- `tests/conftest.py`: a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: a docstring for the file, the fixture and each test, and a docment for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d241a8ff0ff2a6fddc6f5202ce2801ec282efb4d#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

```bash
just docs check
```

`check` prints `29 of 29 functions and classes are typed and documented`, and every module has its docstring.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/abd10aaf9d3fff19d36cddee58e1cfb2553b0497) shows exactly what the move changes.

Quarto makes a website from Markdown. Quarto is a program of its own, and you install it apart from uv, from
https://quarto.org/docs/get-started/. The site is in `docs/`. It has a front page, `index.qmd`, and a reference
page for each module. Before every render, `apidocs.py build` writes the reference pages from the code.

The move adds four files:

- `docs/_quarto.yml`, the settings of the site
- `docs/index.qmd`, the front page
- `docs/linkify.lua`, which turns a name in backticks into a link to its entry
- `docs/.gitignore`

`apidocs.py` gets the command `build`, which puts an id on each heading and a link to the line of the source.
`just docs` with no words renders the site. `just setup` is now a script of several lines, and it says when
Quarto is missing. Take the move from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/abd10aaf9d3fff19d36cddee58e1cfb2553b0497),
and read `docs/_quarto.yml`.

The move changed these files:

- `docs/_quarto.yml`: a new file, with the settings of the site, and the script to run before each render.
- `docs/index.qmd`: a new file, the front page.
- `docs/linkify.lua`: a new file, which turns a name in backticks into a link.
- `docs/.gitignore`: a new file, which lists what Quarto makes and git must not track.
- `docs/apidocs.py`: the command `build`. `entry` and `markdown` take `page`, which adds an id to each heading
  and a link to the source. With `page`, the reference leaves out the heading of the module, because Quarto writes the title.
- `justfile`: `docs` renders the site, and `setup` checks for Quarto.

Files to read:
- [`docs/_quarto.yml`](https://github.com/rahuldave/smallwikiapp/blob/abd10aaf9d3fff19d36cddee58e1cfb2553b0497/docs/_quarto.yml): `pre-render` runs the script.
  - look at: `pre-render: python apidocs.py build  # the reference pages are made from the code, never by hand`
- [`docs/apidocs.py`](https://github.com/rahuldave/smallwikiapp/blob/abd10aaf9d3fff19d36cddee58e1cfb2553b0497/docs/apidocs.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/abd10aaf9d3fff19d36cddee58e1cfb2553b0497#diff-da01f36fbf3b920a98c35ef6b70581a4f7a056ee5fce1a3cf3ca0c713601f832): `build`.
  - look at: `def build() -> int:  # The exit code, always 0`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/abd10aaf9d3fff19d36cddee58e1cfb2553b0497/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/abd10aaf9d3fff19d36cddee58e1cfb2553b0497#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): with no words, `docs` renders the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run quarto render docs; fi`

```bash
just docs
```

Quarto prints `Output created: _site/index.html`. Open `docs/_site/index.html` in a browser. On the front page,
`random_page` is a link to its entry.

### step-08.6 The docs check in `just check`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2ec28cc8ec6fcaf18d1cc6e94ce60efa2a385d53) shows exactly what the move changes.

In the `justfile`, in `check`, run `just docs check` after the tests, and say so in the comment.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

```just
    just test -q --cov-fail-under=90
    just docs check
```

The README gets Quarto among the tools, and `tests/` and `docs/` among the folders. It also says that
`wikipedia.py` is the library and `console.py` the command. Take the README from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/2ec28cc8ec6fcaf18d1cc6e94ce60efa2a385d53). Or copy the rows below. Put the Quarto row under the row of `just`, and the three rows
in place of the `src/wikiapp/` row.

```markdown
| [Quarto](https://quarto.org/) | The docs site, from `just docs` |
```

```markdown
| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
| `tests/` | The tests. `just test` runs them |
| `docs/` | The docs site. `apidocs.py` makes its reference from the code |
```

The move changed these files:

- `justfile`: the docs check in `check`.
- `README.md`: rows for Quarto, `tests/` and `docs/`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/2ec28cc8ec6fcaf18d1cc6e94ce60efa2a385d53/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/2ec28cc8ec6fcaf18d1cc6e94ce60efa2a385d53#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in `check`.
  - look at: `just docs check`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/2ec28cc8ec6fcaf18d1cc6e94ce60efa2a385d53/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/2ec28cc8ec6fcaf18d1cc6e94ce60efa2a385d53#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): the tools and the folders.
  - look at: `| [Quarto](https://quarto.org/) | The docs site, from`

```bash
just check
```

The docs check prints `30 of 30`. The thirtieth is `build`, from the move before. Now the git hook refuses a
commit that leaves a function, a parameter or a field without documentation.

## step-09 The library as a package

[The code at step-09](https://github.com/rahuldave/smallwikiapp/tree/step-09)

```bash
just setup
```

The code that asks Wikipedia becomes a package of its own, `wikirandom`, in the same repository. The first move
makes an empty package. The next moves add the code, make the app use the library, and update the docs. Any other
program could then install wikirandom without wikiapp and click.

### step-09.1 An empty library, wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1d86faecf9c8d7644c1298b7a7fd077ebed7b7e8) shows exactly what the move changes.

uv can make a second package inside a project. The two packages then form a *workspace*, which has one lockfile
and one `.venv` for both.

```
uv init --lib --author-from none packages/wikirandom
```

uv makes `packages/wikirandom/`, with these files in it:

- `pyproject.toml`, the library's own
- `README.md`, empty
- `src/wikirandom/__init__.py`, with an example function, `hello`
- `src/wikirandom/py.typed`, the mark that tells a type checker that the package has types

In the project's `pyproject.toml`, uv adds `[tool.uv.workspace]`. uv copied the Python version from
`.python-version`. In `packages/wikirandom/pyproject.toml`, make the library need 3.11, as the app does. Also give
the library a description.

```toml
description = "A random page of Wikipedia, in any language"
```

```toml
requires-python = ">=3.11"
```

Replace `packages/wikirandom/README.md` with a heading and one line of what it is, and lock again.

```markdown
# wikirandom

A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```

```
uv lock
```

The move changed these files:

- `packages/wikirandom/pyproject.toml`: new. It has the package's name, version and description, and uv_build.
- `packages/wikirandom/README.md`: new. It says what the library is.
- `packages/wikirandom/src/wikirandom/__init__.py`: new. It has uv's example function, `hello`.
- `packages/wikirandom/src/wikirandom/py.typed`: new and empty. It tells ty and other checkers that the package has types.
- `pyproject.toml`: the workspace, with one member.
- `uv.lock`: the second package.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/1d86faecf9c8d7644c1298b7a7fd077ebed7b7e8/packages/wikirandom/pyproject.toml): a package of its own.
  - look at: `name = "wikirandom"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/1d86faecf9c8d7644c1298b7a7fd077ebed7b7e8/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/1d86faecf9c8d7644c1298b7a7fd077ebed7b7e8#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the workspace.
  - look at: `"packages/wikirandom",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"
```

The command prints `Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`,
and runs the command there. The app does not depend on the library yet, so a plain `uv run` would not install it.
`--author-from none` kept uv from writing your name and email from git into the library's `pyproject.toml`.

### step-09.2 The code goes into wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/84edaff0c838b5d995a3a18e9c6fc095f9cc8ec0) shows exactly what the move changes.

The library needs requests and pydantic.

```
uv add --package wikirandom requests pydantic
```

Replace `packages/wikirandom/src/wikirandom/__init__.py` with the code of `src/wikiapp/wikipedia.py`. Change its
docstring to say what the package is. Change its User-Agent to name the program that makes the request.

```python
"""wikirandom: a random page of Wikipedia, in any language, from its REST API."""
```

```python
USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```

The move changed these files:

- `packages/wikirandom/src/wikirandom/__init__.py`: the code of wikipedia.py.
- `packages/wikirandom/pyproject.toml`: requests and pydantic, which are the library's dependencies.
- `uv.lock`: the library's dependencies.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/84edaff0c838b5d995a3a18e9c6fc095f9cc8ec0/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/84edaff0c838b5d995a3a18e9c6fc095f9cc8ec0#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the library.
  - look at: `def random_page(`
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/84edaff0c838b5d995a3a18e9c6fc095f9cc8ec0/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/84edaff0c838b5d995a3a18e9c6fc095f9cc8ec0#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): its dependencies.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The command prints the title of a French page. The app still has its own `wikipedia.py`, and does not use the
library yet.

### step-09.3 The app uses wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e123e9147b4bf5c85fcfaa7fd98b8ab689b615e7) shows exactly what the move changes.

Make the library a dependency of the app. Take requests and pydantic out of the app's dependencies, because the
app no longer imports them.

```
uv add wikirandom
uv remove requests pydantic
```

Because wikirandom is a member of the workspace, `uv add` writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`. So uv installs the library from `packages/wikirandom` as an editable package, and not from
PyPI.

In `src/wikiapp/console.py`, import from the library. ruff sorts the import with the installed packages, under
`import click`.

```python
import click
from wikirandom import WikipediaError, random_page

from wikiapp import __version__
```

Delete `src/wikiapp/wikipedia.py`. Rename `tests/test_wikipedia.py` to `tests/test_wikirandom.py`. Then make the
test file test the library:

- Change its docstring to `Tests of the library, wikirandom.`
- Put `import wikirandom` under `import pytest`, in place of `from wikiapp import wikipedia` and the blank line
  before it.
- Change `wikipedia.random_page`, `wikipedia.Page` and `wikipedia.WikipediaError` to `wikirandom.random_page`,
  `wikirandom.Page` and `wikirandom.WikipediaError`.

Keep the host `es.wikipedia.org` in the first test as it is.

```
git rm src/wikiapp/wikipedia.py
git mv tests/test_wikipedia.py tests/test_wikirandom.py
```

In `pyproject.toml`, make coverage measure both packages.

```toml
# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
```

```toml
addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
```

The move changed these files:

- `pyproject.toml`: wikirandom in, requests and pydantic out. The source of wikirandom is the workspace, and coverage measures both packages.
- `uv.lock`: the app's dependencies are now click and wikirandom.
- `src/wikiapp/console.py`: imports from wikirandom.
- `src/wikiapp/wikipedia.py`: deleted.
- `tests/test_wikirandom.py`: renamed from `tests/test_wikipedia.py`, and it tests wikirandom.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/e123e9147b4bf5c85fcfaa7fd98b8ab689b615e7/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/e123e9147b4bf5c85fcfaa7fd98b8ab689b615e7#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app depends on the library.
  - look at: `wikirandom = { workspace = true }`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/e123e9147b4bf5c85fcfaa7fd98b8ab689b615e7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e123e9147b4bf5c85fcfaa7fd98b8ab689b615e7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): one import.
  - look at: `from wikirandom import WikipediaError, random_page`
- [`tests/test_wikirandom.py`](https://github.com/rahuldave/smallwikiapp/blob/e123e9147b4bf5c85fcfaa7fd98b8ab689b615e7/tests/test_wikirandom.py): the same three tests.
  - look at: `wikirandom.random_page(language="es")`

```bash
just test -q
uv tree --depth 2
just docs check
```

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`. `uv tree` shows that wikiapp needs click and wikirandom, and
that wikirandom needs requests and pydantic. `just docs check` still counts the app alone, 27 of 27. The next
move adds the library.

### step-09.4 The docs name both packages

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/6414c34cd7b069a785eeb8e1b87d8096ef173824) shows exactly what the move changes.

`docs/apidocs.py` documented one package, and only its modules. It now documents a list of packages. It also
documents the `__init__.py` of each package, because wikirandom is a single module. Take it from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/6414c34cd7b069a785eeb8e1b87d8096ef173824). The main changes are `PACKAGES` and `package_modules`. `check` and
`build` follow from them, and `build` writes a page only for a module that defines something.

```python
PACKAGES = ("wikiapp", "wikirandom")  # the app, and the library in packages/wikirandom
```

The front page of the site, `docs/index.qmd`, and the README's table of folders now say that the repository
contains two packages. Take both files too, from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/6414c34cd7b069a785eeb8e1b87d8096ef173824).

The move changed these files:

- `docs/apidocs.py`: two packages.
- `docs/index.qmd`: two packages, the library and the app.
- `README.md`: a row for the library, and the `src/wikiapp/` row says the app.

Files to read:
- [`docs/apidocs.py`](https://github.com/rahuldave/smallwikiapp/blob/6414c34cd7b069a785eeb8e1b87d8096ef173824/docs/apidocs.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/6414c34cd7b069a785eeb8e1b87d8096ef173824#diff-da01f36fbf3b920a98c35ef6b70581a4f7a056ee5fce1a3cf3ca0c713601f832): the list, and the package's own module.
  - look at: `mods += [pkg, *(importlib.import_module(f"{name}.{s}") for s in subs)]`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/6414c34cd7b069a785eeb8e1b87d8096ef173824/docs/index.qmd), [its change](https://github.com/rahuldave/smallwikiapp/commit/6414c34cd7b069a785eeb8e1b87d8096ef173824#diff-bfcaadbc044f4848960f04c96f4ac5930e20671e52514c04dd8347ff6f79ca7b): two packages.
  - look at: `The code has two packages, in one repository:`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/6414c34cd7b069a785eeb8e1b87d8096ef173824/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/6414c34cd7b069a785eeb8e1b87d8096ef173824#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): one row more, and the `src/wikiapp/` row says the app.
  - look at: `| The library the app uses: a random page of Wikipedia. A package of its own |`

```bash
just docs check
just check
```

The docs check prints `wikirandom 3 of 3`, and `30 of 30` in all.

## step-10 Build

[The code at step-10](https://github.com/rahuldave/smallwikiapp/tree/step-10)

```bash
just setup
```

The moves of this step build each package into a wheel, the file that pip and uv install. Then the app says
which versions of the library it accepts. Both packages say their licence and where their source is. Last, the
library's User-Agent says the version that is installed.

### step-10.1 The recipe `build`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/0e1d76cbf675825c3148be4e02b8f31bdea72182) shows exactly what the move changes.

`uv build --all-packages` builds every package of the workspace into `dist/`, which `.gitignore` lists. Add a
recipe for it at the end of the `justfile`.

```just

# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
[group('setup')]
[no-exit-message]
build *args:
    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```

The move changed this file:

- `justfile`: the recipe `build`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/0e1d76cbf675825c3148be4e02b8f31bdea72182/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/0e1d76cbf675825c3148be4e02b8f31bdea72182#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `build *args:`

```bash
uv build --all-packages
just --show build
just build
unzip -l dist/wikiapp-0.1.0-py3-none-any.whl
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

`dist/` now has a source archive, `.tar.gz`, and a wheel, `.whl`, for each package. The app's wheel contains
`wikiapp/` and its metadata, which says that the app needs click and wikirandom. The metadata does not say which
version of wikirandom, because `uv add wikirandom` in a workspace writes no version. An install from PyPI would
get any package that PyPI has under that name. Today PyPI has none, so wikirandom would have to be published
first.

### step-10.2 The app needs wikirandom 0.1

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/587a53d6dd956d694ee2ac100b736f39fb1e613d) shows exactly what the move changes.

The app's wheel says that the app needs `wikirandom`, of any version. An install from PyPI would take any package
that anyone publishes under that name. Give the app the range of versions that it was built and tested with.

```
uv add "wikirandom>=0.1.0,<0.2"
```

Nothing else changes in the workspace. `[tool.uv.sources]` still installs the library from
`packages/wikirandom`.

The move changed this file:

- `pyproject.toml`: a version range on wikirandom.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/587a53d6dd956d694ee2ac100b736f39fb1e613d/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/587a53d6dd956d694ee2ac100b736f39fb1e613d#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"wikirandom>=0.1.0,<0.2",`

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

### step-10.3 A licence and a repository link for both

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/f7148f3ed1701501a6e7b526c1c80440029cb734) shows exactly what the move changes.

The library's wheel has no licence, and neither package says where its source is. Copy the project's `LICENSE`
into `packages/wikirandom/`. In `packages/wikirandom/pyproject.toml`, under `readme`, give the licence and the
author, as the app's `pyproject.toml` does.

```
cp LICENSE packages/wikirandom/LICENSE
```

```toml
license = "Apache-2.0"
license-files = ["LICENSE"]
authors = [{ name = "Rahul Dave" }]
```

Add the repository to both `pyproject.toml` files. PyPI shows it on the package's page. In the library's file,
put it above `[build-system]`. In the app's file, put it under `[project.scripts]`.

```toml

[project.urls]
Repository = "https://github.com/rahuldave/smallwikiapp"
```

In the `justfile`, make `lint-config` check both files.

```just
    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
```

The move changed these files:

- `packages/wikirandom/LICENSE`: new. It has the same licence as the app.
- `packages/wikirandom/pyproject.toml`: the licence, the author, the repository.
- `pyproject.toml`: the repository.
- `justfile`: `lint-config` checks both.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/f7148f3ed1701501a6e7b526c1c80440029cb734/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/f7148f3ed1701501a6e7b526c1c80440029cb734#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): what PyPI would show.
  - look at: `license = "Apache-2.0"`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/f7148f3ed1701501a6e7b526c1c80440029cb734/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/f7148f3ed1701501a6e7b526c1c80440029cb734#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/f7148f3ed1701501a6e7b526c1c80440029cb734/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/f7148f3ed1701501a6e7b526c1c80440029cb734#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app's repository.
  - look at: `[project.urls]`
- [`packages/wikirandom/LICENSE`](https://github.com/rahuldave/smallwikiapp/blob/f7148f3ed1701501a6e7b526c1c80440029cb734/packages/wikirandom/LICENSE): the same Apache-2.0 licence as the app's.
  - look at: `Apache License`

```bash
just lint-config
just build
unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA
```

`just lint-config` prints `Valid file` twice. The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

### step-10.4 The User-Agent says the installed version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/17a61c88ea28aac93d7ba1b3d204cb6282b5061f) shows exactly what the move changes.

The User-Agent says `0.1.0`, written by hand. It would still say `0.1.0` after a change of the version in
`packages/wikirandom/pyproject.toml`. In `packages/wikirandom/src/wikirandom/__init__.py`, read the version from
the installed package, as `wikiapp --version` does. Add `import importlib.metadata` above `import re`, in the
same block. Then replace the line `USER_AGENT`.

```python
import importlib.metadata
import re
```

```python
VERSION = importlib.metadata.version("wikirandom")
USER_AGENT = f"wikirandom/{VERSION} (https://github.com/rahuldave/smallwikiapp)"
```

The move changed this file:

- `packages/wikirandom/src/wikirandom/__init__.py`: the package reads its version once, when Python imports it.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/17a61c88ea28aac93d7ba1b3d204cb6282b5061f/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/17a61c88ea28aac93d7ba1b3d204cb6282b5061f#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the version now comes from one place, pyproject.toml.
  - look at: `VERSION = importlib.metadata.version("wikirandom")`

```bash
uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"
just check
```

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.
