<!-- Made by timewalk-tutorial from the notes of the walk. Do not edit it by hand: run timewalk-tutorial again. -->

# Testing smallwikiapp, one move at a time

In watch mode, you read each move. The notes explain what it changed, and its commit holds the code. [The same tutorial in do mode](TUTORIAL-do.md).

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
The last move documents the tests.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

Between its steps, the whole tutorial makes moves that this walk does not show:

- **Before step-05.5,** [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) and the first four moves of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html).
  ruff formats the code and lints it, and the request gets a timeout of 10 seconds. `just check` runs every check, and pre-commit runs it as a git hook
  before each commit. ty checks the types, and `just types` runs it. ruff's `ANN` rules ask for a type on
  every parameter and return, and the code gets its types.
- **Before step-08.4,** [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html) and the first three moves of [step-08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html).
  `random_page` returns a `Page`, a pydantic model with a title and an extract. In
  `tests/test_wikipedia.py`, the test of the real Wikipedia gets a new name, and a new test checks an answer
  that is not a page. `random_page` also checks the language before it puts it in the address. smalldocs comes in, and `just docs check` counts the functions and classes that have
  their types, docments and docstrings. The library and the command get theirs.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.

## step-02 Tests, with mocks

[The code at step-02](https://github.com/rahuldave/smallwikiapp/tree/step-02)

```bash
just setup
```

The moves of this step add pytest and a first test, a recipe for the tests, and a fixture. Next comes a mock in
place of Wikipedia, with a test of the title. Then they add three more tests, and coverage on every run. One test asks the real Wikipedia, so the tests need
the network until step 06.

### step-02.1 pytest and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fec316ee50d27867f0dab60a755372ce1d1839d1) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7) shows what the move changes.

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

## step-05.5 Types in the tests

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/37ff4096c6af3750178af2e961cf2c61a6fa8d6a), the commit before step-05.5.

```bash
just setup
```

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1) shows what the move changes.

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
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/37ff4096c6af3750178af2e961cf2c61a6fa8d6a...77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/37ff4096c6af3750178af2e961cf2c61a6fa8d6a...77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/37ff4096c6af3750178af2e961cf2c61a6fa8d6a...77ef292e5c0f3aa6474f3a9a027ae3186d23ecc1#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

```bash
just lint
just types
```

Both commands pass. If `just lint` reports `I001`, the imports are not in the blocks that the code above shows.

## step-06 End to end, and CI

[The code at step-06](https://github.com/rahuldave/smallwikiapp/tree/step-06)

```bash
just setup
```

The moves of this step do three things. The tests that ask the real Wikipedia run only when you ask for them.
The project accepts every Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only on request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/49b28350bd9b8bb19f0b98431f81e523953eea26) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d0d10f6aeb1359ed5e93081dccde0435d9f7395d) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e8933c57a023759eeee6db0b3683ca8aa51a6b8e) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/0ca4b5a3e8f67d2394b5b96e001a706bf2df20e6) shows what the move changes.

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

## step-08.4 The tests documented

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367), the commit before step-08.4.

```bash
just setup
```

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
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367...632adbffca8dee5475b394b877bb642da3ed1aff#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367...632adbffca8dee5475b394b877bb642da3ed1aff#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/632adbffca8dee5475b394b877bb642da3ed1aff/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/42df8640d4b5d1bdd4e6b30befe47bd0d8b4a367...632adbffca8dee5475b394b877bb642da3ed1aff#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.
