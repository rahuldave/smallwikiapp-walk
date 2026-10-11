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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e) shows exactly what the move changes.

click makes command lines. requests gets pages over HTTP. Add both packages.

```
uv add click requests
```

The move changed these files:

- `pyproject.toml`: the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: the exact version of each, and of every package they need.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the dependencies of the package, which anyone who installs it gets.
  - look at: `"click>=8.5.0",`
- [`uv.lock`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/uv.lock), [its change](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e#diff-84321598744d84dbee2318e634c74c9aae39a1c253f1c4bd17ebf9ef2f807b11): the exact versions, for every platform.

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.
If your numbers are newer, your `uv.lock` differs from the one here, and the move is still correct.

### step-01.2 Ask Wikipedia for a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0) shows exactly what the move changes.

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
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/a46ba5420b43d7ea47508ae393977935e7bd8bd0/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): a request, and two lines printed.
  - look at: `with requests.get(API_URL) as response:`

```bash
uv run wikiapp
```

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. Wikipedia now refuses a request whose User-Agent header is the default of
a library. requests sends `python-requests/` and its version.

### step-01.3 A User-Agent

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb) shows exactly what the move changes.

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
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2dd3e2132565971092bffe6a438a36506f4161cb/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the header.
  - look at: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

```bash
uv run wikiapp
```

A title in green, and a paragraph. Run it again for another page.

### step-01.4 --version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c) shows exactly what the move changes.

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
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/48a829ee985a69171af7c66846bdb8e7345a199c/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): the version, which Python reads when it imports the package.
  - look at: `__version__ = importlib.metadata.version(__name__ or __package__)`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/48a829ee985a69171af7c66846bdb8e7345a199c/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): click's version option.
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

The moves of this step add pytest and a first test, a recipe for the tests, and a fixture. Next comes a mock in
place of Wikipedia, with a test of the title. Then they add three more tests, and coverage on every run. One test asks the real Wikipedia, so the tests need
the network until step 06.

### step-02.1 pytest and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the groups.
  - look at: `dev = [{ include-group = "test" }]`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/tests/test_console.py): a test that runs the command and checks its exit code.
  - look at: `assert result.exit_code == 0`

```bash
uv run pytest
```

The result is `1 passed`. The test asks the real Wikipedia, so it needs the network.

### step-02.2 The recipe `just test`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a) shows exactly what the move changes.

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
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/94970c50651566f11d5c9d017cb01004e240821a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `test *args:`

```bash
just --show test
just test
```

The result is the same, `1 passed`.

### step-02.3 The runner as a fixture

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534) shows exactly what the move changes.

Each test of the command needs a `CliRunner`. A fixture makes one for every test that asks for it. A fixture is a
function that pytest calls for each test that names it as a parameter. Replace `tests/test_console.py` with the
code below.

```python
import click.testing
import pytest

@pytest.fixture
def runner():
    return click.testing.CliRunner()

from wikiapp import console

def test_main_succeeds(runner):
    result = runner.invoke(console.main)
    assert result.exit_code == 0
```

The move changed this file:

- `tests/test_console.py`: the fixture `runner`, and `test_main_succeeds` takes the runner from it.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/cd31b8a082b8c3ecf168413a21e06b9888480534/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture, and the test that names it.
  - look at: `def test_main_succeeds(runner):`

```bash
just test
```

The test passes as before, with `1 passed`. It still asks the real Wikipedia.

### step-02.4 A mock in place of Wikipedia

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5) shows exactly what the move changes.

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

`mocker` is the fixture of pytest-mock. `mocker.patch("requests.get")` replaces the function, and puts it back after the test. The long
line sets what the mock returns when the code calls `response.json()` inside the `with` block. The mock returns
a page with the title Lorem Ipsum.

The move changed these files:

- `tests/test_console.py`: the fixture of the mock, and a test of the title.
- `pyproject.toml`: pytest-mock in the group `test`.
- `uv.lock`: the exact version of pytest-mock.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/2aaab1063eca2f40fbc281e2e038c18419ca88c5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture of the mock, and the new test.
  - look at: `mock = mocker.patch("requests.get")`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aaab1063eca2f40fbc281e2e038c18419ca88c5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pytest-mock in the group `test`.
  - look at: `"pytest-mock>=3.16.0",`

```bash
just test -k title -v
```

The output shows `test_main_prints_title PASSED`, without the network.

### step-02.5 Tests of the request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f) shows exactly what the move changes.

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
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the code makes the request, to the right address.
  - look at: `assert mock_requests_get.called`

```bash
just test
```

The result is `4 passed`.

### step-02.6 A test of a failed request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7) shows exactly what the move changes.

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
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/16b52dc4f9ec6e997b6954efde180ba6d7f521c7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the mock raises.
  - look at: `mock_requests_get.side_effect = Exception("Boom")`

```bash
just test
```

The result is `5 passed`.

### step-02.7 Coverage

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/bed3c6029878c71bef05322712c388dfb8c058ef/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): coverage on every run.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fec316ee50d27867f0dab60a755372ce1d1839d1) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/fec316ee50d27867f0dab60a755372ce1d1839d1/src/wikiapp/wikipedia.py): the code that talks to Wikipedia.
  - look at: `def random_page():`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/fec316ee50d27867f0dab60a755372ce1d1839d1/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/fec316ee50d27867f0dab60a755372ce1d1839d1#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): only the command stays.
  - look at: `data = random_page()`

```bash
just test
```

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. wikipedia.py calls the function through the module, as `requests.get`, so it gets the mock.

### step-03.2 The mock moves to conftest.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e) shows exactly what the move changes.

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
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/conftest.py): the fixture, for every test file.
  - look at: `def mock_requests_get(mocker):`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture is gone, but the tests still name it.

```bash
just test
```

The result is `5 passed`. pytest finds the fixture in conftest.py.

### step-03.3 A language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the placeholder, and the code that fills it.
  - look at: `def random_page(language="en"):`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/tests/test_wikipedia.py): the test uses the mock from conftest.py.
  - look at: `assert "es.wikipedia.org" in args[0]`

```bash
just test
```

The result is `6 passed`.

### step-03.4 wikiapp --language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f) shows exactly what the move changes.

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
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3bd5616ab15d6b2b526784e8b3b014bceef2548f/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the option, which `main` gives to `random_page`.
  - look at: `data = random_page(language=language)`

```bash
uv run wikiapp --language fr
uv run wikiapp --help
```

The first command prints a French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/56214d31141adcc3dab1ecdd7545b94b03c7f0ea/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the exception, and the line that raises it.
  - look at: `raise WikipediaError(str(error)) from error`

```bash
uv run wikiapp --language xx
```

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback, and the last line is the `WikipediaError`. No code catches the error yet.

### step-03.6 The command prints the error

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7) shows exactly what the move changes.

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
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the error becomes a message.
  - look at: `raise click.ClickException(str(error)) from error`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test.
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

The ten moves of this step add a formatter, and then the changes that it makes. Next, a linter finds five
problems, and the next three moves fix them. Then a recipe checks the configuration, `uv run` stops updating the
lockfile, and another recipe runs every check. Last, a git hook runs every check before each commit.

A tool comes in one move, and its changes come in the next move. So you see what the tool does before you accept
it. The tests still need the network. Also, pre-commit downloads its hooks from GitHub the first time.

### step-04.1 ruff, and the recipe fmt

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/693240e344546dda08ad8fee3951675a0302dbc9/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group and the settings.
  - look at: `line-length = 100`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/693240e344546dda08ad8fee3951675a0302dbc9/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/ca8685e532e9d372857667484e1c94c91ac9e986/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the long line of the request, split into three.
  - look at: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/ca8685e532e9d372857667484e1c94c91ac9e986/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): blank lines, and the long address split.
  - look at: `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`

```bash
just fmt --check
just test
```

The check prints `7 files already formatted`, and the tests pass as before. The formatter changes how the code
looks, and never what it does. One test asks the real Wikipedia, so the tests need the network until step 06.

### step-04.3 The linter's rules, and the recipe lint

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c97fdb1e8e820db24fac697b01283c581924537e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): a family of rules on each line.
  - look at: `"tests/**" = ["S101"]`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c97fdb1e8e820db24fac697b01283c581924537e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf) shows exactly what the move changes.

ruff can fix one of the five problems itself.

```
just lint --fix
```

The move changed this file:

- `src/wikiapp/console.py`: the imports in three blocks, which are the standard library, the packages
  installed, and then wikiapp's own.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the imports, sorted.
  - look at: `from wikiapp import __version__`

```bash
just lint --statistics
```

`just lint --fix` reported `Found 5 errors (1 fixed, 4 remaining)` and failed. Four problems are left, and a
person must fix them.

### step-04.5 The tests' imports at the top, and no unused variables

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3ba5d239ff4f171c58d4249a33caafc510883b46) shows exactly what the move changes.

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
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/3ba5d239ff4f171c58d4249a33caafc510883b46/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3ba5d239ff4f171c58d4249a33caafc510883b46#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the import moves, and two lines lose `result =`.
  - look at: `from wikiapp import console`

```bash
just lint --statistics
just fmt --check
```

One problem is left, `S113`. The format is unchanged, and the check prints `7 files already formatted`.

### step-04.6 A timeout

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/80c33d4cfaf4b157cd44482712e520c77378cf9c) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/80c33d4cfaf4b157cd44482712e520c77378cf9c/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/80c33d4cfaf4b157cd44482712e520c77378cf9c#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): one more argument.
  - look at: `timeout=10`

```bash
just lint
```

`All checks passed!`

### step-04.7 The recipe lint-config

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a) shows exactly what the move changes.

validate-pyproject checks `pyproject.toml` against the standard for it.

```
uv add --group lint validate-pyproject
```

Add a recipe at the end of the `justfile`. `lint-config` checks the configuration.

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
```

The move changed these files:

- `justfile`: the recipe `lint-config`.
- `pyproject.toml`: validate-pyproject in the group `lint`.
- `uv.lock`: the exact version of validate-pyproject, and of what it needs.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its three checks.
  - look at: `uv run validate-pyproject pyproject.toml`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one package more in `lint`.
  - look at: `"validate-pyproject>=0.26",`

```bash
uv run validate-pyproject pyproject.toml
uv lock --check
just --fmt --check --unstable
just --show lint-config
just lint-config
```

The three checks pass. validate-pyproject prints `Valid file: pyproject.toml`. `uv lock --check` prints
`Resolved 19 packages` and exits with 0, because the lockfile matches `pyproject.toml`.

### step-04.8 A locked lockfile

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a45828b7972f3de77bd6a8d7a00a6b55833832cb) shows exactly what the move changes.

In the `justfile`, under `set positional-arguments`, add the line below. With it, every `uv run` of a recipe
refuses a lockfile that is out of date. Without it, `uv run` quietly updates the lockfile.

```just

export UV_LOCKED := "1"
```

The move changed this file:

- `justfile`: the variable `UV_LOCKED`, exported to every recipe.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/a45828b7972f3de77bd6a8d7a00a6b55833832cb/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/a45828b7972f3de77bd6a8d7a00a6b55833832cb#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): one line.
  - look at: `export UV_LOCKED := "1"`

```bash
just --evaluate UV_LOCKED
```

It prints `1`. `just` puts the variable in the environment of every command of every recipe, so each `uv run`
sees it.

### step-04.9 The recipe check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d) shows exactly what the move changes.

Add a recipe at the end of the `justfile`. `check` runs every check in order, and stops at the first check
that fails.

```just

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

The move changed this file:

- `justfile`: the recipe `check`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/06ea9e2af2238f070b1e33f16aeb70002e25e44d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its four checks.
  - look at: `just test -q --cov-fail-under=90`

```bash
just --show check
just check
```

`just check` runs the format, the linter, the tests and the configuration, in that order. The
tests must run at least 90% of the statements. The coverage is 96.77%.

### step-04.10 A git hook

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9) shows exactly what the move changes.

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
- [`.pre-commit-config.yaml`](https://github.com/rahuldave/smallwikiapp/blob/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9/.pre-commit-config.yaml): three hooks from pre-commit's collection, then `just check`.
  - look at: `entry: just check`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe `hook`.
  - look at: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pre-commit in the group `lint`.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/efda1ef33393ff8f9969a981ff8e3760efe05d67) shows exactly what the move changes.

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
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/efda1ef33393ff8f9969a981ff8e3760efe05d67/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/efda1ef33393ff8f9969a981ff8e3760efe05d67#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `types *args:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/efda1ef33393ff8f9969a981ff8e3760efe05d67/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/efda1ef33393ff8f9969a981ff8e3760efe05d67#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): ty in the group `lint`.
  - look at: `"ty>=0.0.86",`

```bash
uv run ty check
just --show types
just types
```

ty finds one problem, in `src/wikiapp/__init__.py`. The message is `Expected str, found str | None`. As far as
ty can tell, `__name__ or __package__` could be None. But `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/9d95e1a48037b527b275be02d576cf464baf7df0) shows exactly what the move changes.

`pyproject.toml` gives the name of the installed package, `wikiapp`. Ask for the version of that name. Change
the last line of `src/wikiapp/__init__.py`.

```python
__version__ = importlib.metadata.version("wikiapp")
```

The move changed this file:

- `src/wikiapp/__init__.py`: the name, written out.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/9d95e1a48037b527b275be02d576cf464baf7df0/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/9d95e1a48037b527b275be02d576cf464baf7df0#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a string that is never None.
  - look at: `__version__ = importlib.metadata.version("wikiapp")`

```bash
just types
```

`All checks passed!`

### step-05.3 A type on every parameter and return

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c2da7ec65f0a74620c5e411d96dc516b8d63ad15) shows exactly what the move changes.

ty, the type checker that `just types` runs, checks the types that the code states. ruff's `ANN` rules make sure that the code states a type for every
parameter and return. In `pyproject.toml`, add a line to `select`, after `"N"`.

```toml
    "ANN", # annotations: every parameter and every return value has a type
```

The move changed this file:

- `pyproject.toml`: the rules `ANN`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c2da7ec65f0a74620c5e411d96dc516b8d63ad15/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c2da7ec65f0a74620c5e411d96dc516b8d63ad15#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"ANN", # annotations: every parameter and every return value has a type`

```bash
just lint --statistics
```

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). `just check` fails at this move and at the next move, and passes again at step-05.5. So the
git hook refuses to commit this move or the next. In do mode, you make the two moves without a commit. In the
project's history, they are commits made past the hook.

### step-05.4 Types in the code

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/37ff4096c6af3750178af2e961cf2c61a6fa8d6a) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/37ff4096c6af3750178af2e961cf2c61a6fa8d6a/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/37ff4096c6af3750178af2e961cf2c61a6fa8d6a#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the parameter and the return.
  - look at: `def random_page(language: str = "en") -> dict[str, Any]:`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/37ff4096c6af3750178af2e961cf2c61a6fa8d6a/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/37ff4096c6af3750178af2e961cf2c61a6fa8d6a#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the parameter.
  - look at: `def main(language: str) -> None:`

```bash
just lint --statistics
```

The 22 problems that are left are all in the tests. They are 13 parameters and 9 returns.

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1) shows exactly what the move changes.

Since step-05.3, ruff's `ANN` rules ask for a type on every parameter and return. The code has its types, and
`just lint` finds 22 missing in the tests.

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
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

```bash
just lint
just types
```

Both commands pass. If `just lint` reports `I001`, the imports are not in the blocks that the code above shows.

### step-05.6 The recipe check runs the type checker

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fd2af757335e7569c44a38ef4d4f76a3e71f2989) shows exactly what the move changes.

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
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/fd2af757335e7569c44a38ef4d4f76a3e71f2989/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/fd2af757335e7569c44a38ef4d4f76a3e71f2989#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/49b28350bd9b8bb19f0b98431f81e523953eea26) shows exactly what the move changes.

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
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/49b28350bd9b8bb19f0b98431f81e523953eea26/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/49b28350bd9b8bb19f0b98431f81e523953eea26#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test, marked.
  - look at: `@pytest.mark.e2e`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/49b28350bd9b8bb19f0b98431f81e523953eea26/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/49b28350bd9b8bb19f0b98431f81e523953eea26#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the option `-m 'not e2e'`.
  - look at: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

```bash
just test -q
just test -q -m e2e
```

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

### step-06.2 An end-to-end test of the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d0d10f6aeb1359ed5e93081dccde0435d9f7395d) shows exactly what the move changes.

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
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d0d10f6aeb1359ed5e93081dccde0435d9f7395d/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d0d10f6aeb1359ed5e93081dccde0435d9f7395d#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `assert "extract" in page`

```bash
just test -q -m e2e
```

The output is `2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e8933c57a023759eeee6db0b3683ca8aa51a6b8e) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/e8933c57a023759eeee6db0b3683ca8aa51a6b8e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/e8933c57a023759eeee6db0b3683ca8aa51a6b8e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `requires-python = ">=3.11"`

```bash
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`--isolated` makes a temporary environment with Python 3.11, and does not change `.venv`. The tests pass on
3.11.

### step-06.4 GitHub runs the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/0ca4b5a3e8f67d2394b5b96e001a706bf2df20e6) shows exactly what the move changes.

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
- [`.github/workflows/test.yaml`](https://github.com/rahuldave/smallwikiapp/blob/0ca4b5a3e8f67d2394b5b96e001a706bf2df20e6/.github/workflows/test.yaml): the matrix of systems and Pythons.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/570c70fe5d6de269121f442425d0e941f09cdbd5) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/570c70fe5d6de269121f442425d0e941f09cdbd5/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/570c70fe5d6de269121f442425d0e941f09cdbd5#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the model.
  - look at: `class Page(BaseModel):`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/570c70fe5d6de269121f442425d0e941f09cdbd5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/570c70fe5d6de269121f442425d0e941f09cdbd5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pydantic, a dependency of the package.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"
```

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails
with a ValidationError, because `extract` is missing.

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e7c47feb06c01fae6f047f9202b768016f2113e4) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e7c47feb06c01fae6f047f9202b768016f2113e4/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e7c47feb06c01fae6f047f9202b768016f2113e4#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the return.
  - look at: `return Page.model_validate(response.json())`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/e7c47feb06c01fae6f047f9202b768016f2113e4/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e7c47feb06c01fae6f047f9202b768016f2113e4#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): attributes, not keys.
  - look at: `click.secho(page.title, fg="green")`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e7c47feb06c01fae6f047f9202b768016f2113e4/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e7c47feb06c01fae6f047f9202b768016f2113e4#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the e2e test checks for a Page.
  - look at: `assert isinstance(page, wikipedia.Page)`

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/9ff635a09d07020b2a36f0d76b3005cbd489d2e9) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/9ff635a09d07020b2a36f0d76b3005cbd489d2e9/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/9ff635a09d07020b2a36f0d76b3005cbd489d2e9#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): two exceptions caught.
  - look at: `except (requests.RequestException, ValidationError) as error:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/9ff635a09d07020b2a36f0d76b3005cbd489d2e9/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/9ff635a09d07020b2a36f0d76b3005cbd489d2e9#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `with pytest.raises(wikipedia.WikipediaError):`

```bash
just test -k validation
```

The output is `1 passed, 8 deselected`.

### step-07.4 Only a language code goes into the address

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/55822322c0a870d808bd25cc2f934169cf7a5386) shows exactly what the move changes.

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
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/55822322c0a870d808bd25cc2f934169cf7a5386/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/55822322c0a870d808bd25cc2f934169cf7a5386#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the code checks a language before it uses it.
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

- smalldocs, which makes the reference from the code, and says what has no documentation
- the documentation of the library, of the command and of the tests
- a site
- the tests and the docs in the README's table of folders
- the check of the documentation in `just check`

### step-08.1 smalldocs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/36d19bddbbb90c669475d6ffbdf26b7b346c4f18) shows exactly what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5a169fc1223a30099ff265f93e2c061b1ef2ed7c) shows exactly what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367) shows exactly what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff) shows exactly what the move changes.

A docment is the comment beside a parameter, or after the colon of the `def` line for the return.
`just docs check`, from step-08.1, counts the functions and classes that have their types, docments and
docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. The three files are long to type, so take
them from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff). The test below shows the
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
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/632adbffca8dee5475b394b877bb642da3ed1aff#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

```bash
just docs check
```

`check` prints `15 of 15 functions, methods and classes are typed and documented`, and every module has its
docstring.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/49e01b4ba130cbba887a160c8d845e4196897e8a) shows exactly what the move changes.

smalldocs also makes a website from Markdown. The site is in `docs/`. It has a front page, `index.qmd`, and a
reference page for each module. Each build writes the reference pages from the code, before it builds the site.
A name in backticks, such as `random_page`, becomes a link to its entry.

The move adds the front page, `docs/index.qmd`. A `.qmd` file is Markdown, with a header between two `---` lines
that gives the title of the page. It also adds the settings of the site to `docs/_smalldocs.yml`.
The settings are the type of the project, its output folder, the title, the sidebar, the theme and a table of
contents on each page. `just docs` with no words builds the site. Take the move
from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/49e01b4ba130cbba887a160c8d845e4196897e8a), and read `docs/_smalldocs.yml`.

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
`random_page` is a link to its entry. The site and the reference pages are made by each build, and git ignores
them.

### step-08.6 The README names the tests and the docs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e1f81d1d14b883402dc65cc0129bf99a139c387b) shows exactly what the move changes.

The README gets `tests/` and `docs/` among the folders. It also says that `wikipedia.py` is the library and
`console.py` the command. Take the README from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/e1f81d1d14b883402dc65cc0129bf99a139c387b). Or copy the rows below, in place of the `src/wikiapp/` row.

```markdown
| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
| `tests/` | The tests. `just test` runs them |
| `docs/` | The docs site. smalldocs makes its reference from the code |
```

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/86367b4256bbe5096403d613a77fd3f8da6ead58) shows exactly what the move changes.

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

## step-09 The library as a package

[The code at step-09](https://github.com/rahuldave/smallwikiapp/tree/step-09)

```bash
just setup
```

The code that asks Wikipedia becomes a package of its own, `wikirandom`, in the same repository. The first move
makes an empty package. The next moves add the code, and make the app use the library. The last two moves update the docs and the
README. Any other
program could then install wikirandom without wikiapp and click.

### step-09.1 An empty library, wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/677e1d1f52c3f1c57b4ec0914618f43ddf62123c) shows exactly what the move changes.

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
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/677e1d1f52c3f1c57b4ec0914618f43ddf62123c/packages/wikirandom/pyproject.toml): a package of its own.
  - look at: `name = "wikirandom"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/677e1d1f52c3f1c57b4ec0914618f43ddf62123c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/677e1d1f52c3f1c57b4ec0914618f43ddf62123c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the workspace.
  - look at: `"packages/wikirandom",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"
```

The command prints `Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`,
and runs the command there. The app does not depend on the library yet, so a plain `uv run` would not install it.
`--author-from none` kept uv from writing your name and email from git into the library's `pyproject.toml`.

### step-09.2 The code goes into wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2b9c4a770d2ebe370f77b3dd93bc3f02b0c27bf7) shows exactly what the move changes.

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
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/2b9c4a770d2ebe370f77b3dd93bc3f02b0c27bf7/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2b9c4a770d2ebe370f77b3dd93bc3f02b0c27bf7#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the library.
  - look at: `def random_page(`
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2b9c4a770d2ebe370f77b3dd93bc3f02b0c27bf7/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2b9c4a770d2ebe370f77b3dd93bc3f02b0c27bf7#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): its dependencies.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The command prints the title of a French page. The app still has its own `wikipedia.py`, and does not use the
library yet.

### step-09.3 The app uses wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/517abf247f7a42038536d843fe7585f745d57897) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/517abf247f7a42038536d843fe7585f745d57897/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/517abf247f7a42038536d843fe7585f745d57897#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app depends on the library.
  - look at: `wikirandom = { workspace = true }`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/517abf247f7a42038536d843fe7585f745d57897/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/517abf247f7a42038536d843fe7585f745d57897#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): one import.
  - look at: `from wikirandom import WikipediaError, random_page`
- [`tests/test_wikirandom.py`](https://github.com/rahuldave/smallwikiapp/blob/517abf247f7a42038536d843fe7585f745d57897/tests/test_wikirandom.py): the same three tests.
  - look at: `wikirandom.random_page(language="es")`

```bash
just test -q
uv tree --depth 2
just docs check
```

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`. `uv tree` shows that wikiapp needs click and wikirandom, and
that wikirandom needs requests and pydantic. `just docs check` still counts the app and the tests alone, 12 of 12. The next
move adds the library. The README still names `wikipedia.py`, and the front page of the site
`wikiapp.wikipedia`, until step-09.5.

### step-09.4 The docs check counts the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/426d87e7d66b979bbc8b1d6067583395ab08e01c) shows exactly what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/43da298fbb7d16f7cb11bd3e3406fe8631a3e309) shows exactly what the move changes.

The front page of the site, `docs/index.qmd`, and the README's table of folders now say that the repository
contains two packages. Take both files from [the move's commit](https://github.com/rahuldave/smallwikiapp/commit/43da298fbb7d16f7cb11bd3e3406fe8631a3e309).

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

## step-10 Build

[The code at step-10](https://github.com/rahuldave/smallwikiapp/tree/step-10)

```bash
just setup
```

The moves of this step build each package into a wheel, the file that pip and uv install. Then the app says
which versions of the library it accepts, and `just lint-config` checks the library's `pyproject.toml` too.
Both packages say their licence and where their source is. Last, the
library's User-Agent says the version that is installed.

### step-10.1 The recipe `build`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4903a582a9fae628e6544b2182f77f8caf386dbe) shows exactly what the move changes.

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
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4903a582a9fae628e6544b2182f77f8caf386dbe/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/4903a582a9fae628e6544b2182f77f8caf386dbe#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/663682b805962a82b4c0e8d18ede21e3cd5188d9) shows exactly what the move changes.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/663682b805962a82b4c0e8d18ede21e3cd5188d9/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/663682b805962a82b4c0e8d18ede21e3cd5188d9#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"wikirandom>=0.1.0,<0.2",`

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

### step-10.3 lint-config checks both pyproject.toml files

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5e6110fbb134015850291ff3558eed9d1951d4c6) shows exactly what the move changes.

Since step 09, the repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. In
the `justfile`, in `lint-config`, replace the line `uv run validate-pyproject pyproject.toml` with the line below.

```just
    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
```

The move changed this file:

- `justfile`: `lint-config` checks both files.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5e6110fbb134015850291ff3558eed9d1951d4c6/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/5e6110fbb134015850291ff3558eed9d1951d4c6#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.

### step-10.4 A licence and a repository link for both

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b4ecef0371b625e151bdbbbaa89187074347c2a8) shows exactly what the move changes.

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
put it after the list `dependencies`, so that one blank line comes before it and one after it. In the app's file, put it after the line
`wikiapp = "wikiapp.console:main"` of `[project.scripts]`.

```toml

[project.urls]
Repository = "https://github.com/rahuldave/smallwikiapp"
```

The move changed these files:

- `packages/wikirandom/LICENSE`: new. It has the same licence as the app.
- `packages/wikirandom/pyproject.toml`: the licence, the author, the repository.
- `pyproject.toml`: the repository.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/b4ecef0371b625e151bdbbbaa89187074347c2a8/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b4ecef0371b625e151bdbbbaa89187074347c2a8#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): what PyPI would show.
  - look at: `license = "Apache-2.0"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/b4ecef0371b625e151bdbbbaa89187074347c2a8/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b4ecef0371b625e151bdbbbaa89187074347c2a8#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app's repository.
  - look at: `[project.urls]`
- [`packages/wikirandom/LICENSE`](https://github.com/rahuldave/smallwikiapp/blob/b4ecef0371b625e151bdbbbaa89187074347c2a8/packages/wikirandom/LICENSE): the same Apache-2.0 licence as the app's.
  - look at: `Apache License`

```bash
just build
unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA
```

The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

### step-10.5 The User-Agent says the installed version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bf2c5d6a7fc39320ac0a9cda0ef3343d35364ac8) shows exactly what the move changes.

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
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/bf2c5d6a7fc39320ac0a9cda0ef3343d35364ac8/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/bf2c5d6a7fc39320ac0a9cda0ef3343d35364ac8#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the version now comes from one place, pyproject.toml.
  - look at: `VERSION = importlib.metadata.version("wikirandom")`

```bash
uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"
just check
```

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.
