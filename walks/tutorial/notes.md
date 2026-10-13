# smallwikiapp, one move at a time

This tutorial goes through the tagged steps of smallwikiapp, and the small commits between them. Each small
commit is a move, one action. In do mode, you make each move yourself from its notes:

1. Type the code.
2. Run the command in the grey block.
3. Run the command at the end of the move, which shows what the move did.
4. Press **Done**.

In watch mode, **Show** checks out the commit of each move, and the notes explain what changed. Every step
starts from the code of the step before, so every step starts with `just setup`.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The notes are for timewalk. To read the tutorial on GitHub, open TUTORIAL-watch.md or TUTORIAL-do.md, beside
this file. Each comes from these notes, with the commands in code blocks and a link to the commit of every move.

- **A command** is a line that starts with `$ `. In timewalk, a click types it into the terminal at the step.
- **A grey block** is code to type, or a command that makes the move.
- **Under `files:`**, `diff PATH` is a file that the move changes, and `file PATH` is a file as the move leaves
  it. `show:` names the line to look at.

The items under `files:` are the files worth reading. The list before them names every file that the move
changed, and what happened to it.

## step-00 The project

$ just setup

The tutorial starts at step-00, so step-00 has no moves. `uv init --package --python 3.13 --name wikiapp` made
the shape of the project:

- `pyproject.toml`
- `src/wikiapp/__init__.py`, with a function `main`
- `.python-version`, with the Python version
- `README.md` and `.gitignore`

Then the author changed the project by hand. `main` moved to `src/wikiapp/console.py`. `pyproject.toml` got a
description, an author and a licence, and it names `wikiapp.console:main` as the command. `uv lock` wrote the
lockfile, `uv.lock`. The author also wrote the justfile and `LICENSE`, and wrote the README and `.gitignore` again, by hand.

`just setup` runs `uv sync --locked`. The command makes `.venv` with Python 3.13, from `.python-version`. It
installs exactly the packages that the lockfile names. Here, the only package is `wikiapp` itself.

$ cat pyproject.toml

The line under `[project.scripts]` makes `wikiapp` a command. The name is on the left. The function is on the
right, `main` in `src/wikiapp/console.py`. For now, `main` prints one line.

$ uv run wikiapp

$ cat src/wikiapp/console.py

The justfile is the interface of the project. `just` lists the tasks, and `just --show setup` shows the recipe
behind one task. `just help setup` shows the same recipe. Most steps add recipes to the justfile.

$ just

$ just --show setup

$ just --show help

$ just help setup

## step-01 A random page

$ just setup

The moves of step-01 add these things:

- the two packages that the command needs
- a request to Wikipedia for a page
- a header that Wikipedia now asks for
- the option `--version`

### step-01.1 click and requests

Now we add two packages, click and requests, to the dependencies of wikiapp. click makes command lines.
requests gets pages over HTTP.

do$ uv add click requests

::: watch
Read the change of `pyproject.toml`.
:::

The move changes these files:

- `pyproject.toml`: 4 lines added, 1 removed; the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: 176 lines added; the exact version of each, and of every package they need.

files:
- diff `pyproject.toml`: the dependencies of the package, which anyone who installs it gets.
  show: `"click>=8.5.0",`
- file `uv.lock`: the exact versions, for every platform.

$ uv tree --depth 1

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

::: do
If your versions are newer, your `uv.lock` differs from the one here, and the move is still correct.
:::

### step-01.2 Ask Wikipedia for a page

Now we make `main` ask Wikipedia for a random page, and print it.

`src/wikiapp/console.py` now has a command, as in the first commit of the original wikiapp, from 2024. Its
docstring is new, and says what the command does. `@click.command()` makes `main` a command. The `main` of the original wikiapp had no `-> None`. The
`main` here keeps the annotation that `uv init` gave it at step-00.

- `requests.get` asks the REST API of Wikipedia for the summary of a random page.
- `raise_for_status` raises an exception if the answer is an error.
- `response.json()` reads the answer as a dictionary.

`main` prints the title in green, and the summary wrapped to 70 columns.

::: do
Replace `src/wikiapp/console.py` with the code below.

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
:::

::: watch
Read the change of `src/wikiapp/console.py`.
:::

The move changes one file:

- `src/wikiapp/console.py`: 17 lines added, 2 removed; `main` asks Wikipedia for a page and prints it.

files:
- diff `src/wikiapp/console.py`: a request, and two lines printed.
  show: `with requests.get(API_URL) as response:`

$ uv run wikiapp

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. Wikipedia now refuses a request whose User-Agent header is the default of
a library. requests sends `python-requests/` and its version.

### step-01.3 A User-Agent

Now we send a User-Agent header with the request. The User-Agent header says who sends the request. The policy of
Wikimedia asks for the name of the program, its version, and a way to reach the person who runs it. In
`src/wikiapp/console.py`, a constant `USER_AGENT` under `API_URL` gives these three things.

::: do
In `src/wikiapp/console.py`, add a line under `API_URL`, and pass it as a header.

```python
USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```

```python
    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```
:::

::: watch
Find `USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"` in the change of
`src/wikiapp/console.py`.
:::

The move changes one file:

- `src/wikiapp/console.py`: 2 lines added, 1 removed; a constant `USER_AGENT`, and the request sends it.

files:
- diff `src/wikiapp/console.py`: the header.
  show: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

$ uv run wikiapp

A title in green, and a paragraph. Each run prints another page.

### step-01.4 --version

Now we let the command print its version. The package can read its own version from the installed package, which
has the version in `pyproject.toml`. `src/wikiapp/__init__.py` now sets `__version__` from the metadata of the
installed package. `src/wikiapp/console.py` imports `__version__`. The decorator `@click.version_option`, above
`def main`, gives the command the option `--version`.

::: do
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
:::

::: watch
Read the change of `src/wikiapp/__init__.py`, then the change of `src/wikiapp/console.py`.
:::

The move changes these files:

- `src/wikiapp/__init__.py`: 2 lines added; `__version__`, from the installed package.
- `src/wikiapp/console.py`: 2 lines added; the option `--version`.

files:
- diff `src/wikiapp/__init__.py`: the version, which Python reads when it imports the package.
  show: `__version__ = importlib.metadata.version(__name__ or __package__)`
- diff `src/wikiapp/console.py`: click's version option.
  show: `@click.version_option(version=__version__)`

$ uv run wikiapp --version

$ uv run wikiapp --help

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring. So the docstring of `main` is also help text, for a person who runs the command.

## step-02 Tests, with mocks

$ just setup

The moves of this step add pytest and a first test, a recipe for the tests, and a fixture. The fourth move puts a
mock in place of Wikipedia, with a test of the title. The last three moves add three more tests, and coverage on
every run. One test asks the real Wikipedia, so the tests need the network until step 06.

### step-02.1 pytest and the first test

Now we install pytest, the tool that runs the tests. The tests need pytest, but the package does not. A person who
installs wikiapp should not get pytest. So pytest goes in a dependency group of its own, `test`. uv installs the
group `dev` by default, so `dev` includes `test`.

::: do
In `pyproject.toml`, add the groups above `[build-system]`.

```toml
[dependency-groups]
test = []
dev = [{ include-group = "test" }]

```
:::

do$ uv add --group test pytest

::: watch
Read the change of `pyproject.toml`.
:::

Next we write the first test, in `tests/test_console.py`, which runs the command and checks that it ends with exit
code 0. click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code
of the command.

This first test is an end-to-end test. It runs the whole command, and the command asks the real Wikipedia. So a
failure can come from the code, from the network or from Wikipedia.

::: do
Make `tests/test_console.py`.

```python
import click.testing

from wikiapp import console

def test_main_succeeds():
    runner = click.testing.CliRunner()
    result = runner.invoke(console.main)
    assert result.exit_code == 0
```
:::

::: watch
Open `tests/test_console.py`, a new file.
:::

The move changes these files:

- `pyproject.toml`: 6 lines added; the groups `test` and `dev`.
- `tests/test_console.py`: 8 lines added; the first test.
- `uv.lock`: 73 lines added; pytest and what it needs.

files:
- diff `pyproject.toml`: the groups.
  show: `dev = [{ include-group = "test" }]`
- file `tests/test_console.py`: a test that runs the command and checks its exit code.
  show: `assert result.exit_code == 0`

$ uv run pytest

The result is `1 passed`. The test asks the real Wikipedia, so it needs the network.

### step-02.2 The recipe `just test`

Now we add a recipe to the `justfile`, `test`, which runs the tests. The words after `just test` go to pytest.
`"$@"` stands for those words, and the recipe gives each word to pytest whole. `just test help` shows the recipe.

::: do
Add the recipe at the end of the `justfile`.

```just

# Run the tests. Extra arguments go to pytest: just test -k title
[group('quality')]
[no-exit-message]
test *args:
    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```
:::

::: watch
Read the change of `justfile`.
:::

`just` prints each line of a recipe before it runs the line, if the line does not start with `@`. So `just test`
prints `uv run pytest "$@"`, the command that it ran.

The move changes one file:

- `justfile`: 6 lines added; the recipe `test`.

files:
- diff `justfile`: the recipe.
  show: `test *args:`

$ just --show test

$ just test

The result is the same, `1 passed`.

### step-02.3 The runner as a fixture

Now we move the `CliRunner` into a fixture, `runner`, which returns it. Each test of the command needs a
`CliRunner`. A fixture is a function that pytest calls for each test that names it as a parameter. So
`test_main_succeeds` takes the runner as its parameter.

::: do
Replace `tests/test_console.py` with the code below.

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
:::

::: watch
Read the change of `tests/test_console.py`.
:::

The move changes one file:

- `tests/test_console.py`: 6 lines added, 2 removed; the fixture `runner`, and `test_main_succeeds` takes the runner from it.

files:
- diff `tests/test_console.py`: the fixture, and the test that names it.
  show: `def test_main_succeeds(runner):`

$ just test

The test passes as before, with `1 passed`. It still asks the real Wikipedia.

### step-02.4 A mock in place of Wikipedia

Now we replace `requests.get` with a mock in the tests. A test that needs the network fails on a train. Also, a
test cannot check the title of a random page. pytest-mock can replace `requests.get` with a mock for the length of
one test. It goes in the group `test`.

`mocker` is the fixture of pytest-mock. A new fixture, `mock_requests_get`, calls `mocker.patch("requests.get")`.
The call replaces the function, and puts it back after the test. The line `mock.return_value.__enter__.return_value.json.return_value = {` sets what the mock returns when
the code calls `response.json()` inside the `with` block. The mock returns a page with the title Lorem Ipsum. A
new test, `test_main_prints_title`, checks that the command prints that title.

A test that uses the mock is a unit test of the command. It checks the command alone, without the network, so a
failure points at the command. `test_main_succeeds` still asks the real Wikipedia.

do$ uv add --group test pytest-mock

::: do
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
:::

::: watch
Read the change of `pyproject.toml`. Find `mock = mocker.patch("requests.get")` in the change of
`tests/test_console.py`.
:::

The move changes these files:

- `tests/test_console.py`: 13 lines added; the fixture of the mock, and a test of the title.
- `pyproject.toml`: 1 line added; pytest-mock in the group `test`.
- `uv.lock`: 22 lines added, 2 removed; the exact version of pytest-mock.

files:
- diff `tests/test_console.py`: the fixture of the mock, and the new test.
  show: `mock = mocker.patch("requests.get")`
- diff `pyproject.toml`: pytest-mock in the group `test`.
  show: `"pytest-mock>=3.16.0",`

$ just test -k title -v

The output shows `test_main_prints_title PASSED`, without the network.

### step-02.5 Tests of the request

Now we add two tests of the request to `tests/test_console.py`. A mock keeps a record of each call to it.
`test_main_invokes_requests_get` checks that the command calls `requests.get`, and `test_main_uses_correct_url`
checks the address. `call_args[0]` is the tuple of the positional arguments of the last call. Here it contains
only the address. The header is a keyword argument, in `call_args[1]`.

::: do
Add the two tests to `tests/test_console.py`, after `test_main_prints_title`.

```python
def test_main_invokes_requests_get(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.called

def test_main_uses_correct_url(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
```
:::

::: watch
Read the change of `tests/test_console.py`.
:::

The move changes one file:

- `tests/test_console.py`: 8 lines added; two tests of the request.

files:
- diff `tests/test_console.py`: the code makes the request, to the right address.
  show: `assert mock_requests_get.called`

$ just test

The result is `4 passed`.

### step-02.6 A test of a failed request

Now we add a test, `test_main_fails_on_request_error`, to `tests/test_console.py`. It makes the mock raise, and
checks that a failed request ends the command with exit code 1. A mock can raise an exception as well as return a
value. If `side_effect` is an exception, a call to the mock raises it.

::: do
Add the test below to `tests/test_console.py`, before `test_main_succeeds`, with a blank line after it.

```python
def test_main_fails_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = Exception("Boom")
    result = runner.invoke(console.main)
    assert result.exit_code == 1
```
:::

::: watch
Find `mock_requests_get.side_effect = Exception("Boom")` in the change of `tests/test_console.py`.
:::

The move changes one file:

- `tests/test_console.py`: 5 lines added; a test that a failed request ends the command with exit code 1.

files:
- diff `tests/test_console.py`: the mock raises.
  show: `mock_requests_get.side_effect = Exception("Boom")`

$ just test

The result is `5 passed`.

### step-02.7 Coverage

Now we measure the coverage of the tests on every run. pytest-cov measures which lines of the code the tests run.
It goes in the group `test`, and pytest's settings, at the end of `pyproject.toml`, turn coverage on for every run.

do$ uv add --group test pytest-cov

::: do
Add the settings at the end of `pyproject.toml`.

```toml

[tool.pytest.ini_options]
testpaths = ["tests"]
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
addopts = "--cov=wikiapp --cov-report=term-missing"
```
:::

::: watch
Read the change of `pyproject.toml`.
:::

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented out.
No test used them, so the project does not keep them.

The move changes these files:

- `pyproject.toml`: 6 lines added; pytest-cov in the group `test`, and pytest's settings.
- `uv.lock`: 102 lines added; pytest-cov and coverage.

files:
- diff `pyproject.toml`: coverage on every run.
  show: `addopts = "--cov=wikiapp --cov-report=term-missing"`

$ just test

The table under the tests lists each file of `src/wikiapp`, its statements, and the lines that no test ran.
One line of `console.py` is missing. It is the call to `main` at the end, which runs only when you run the file
as a script.

## step-03 A library and an app

$ just setup

The code that asks Wikipedia moves into a module of its own, `wikipedia.py`. The module then gets a language
and an error of its own. The command, in `console.py`, uses the module. So wikipedia.py is a library that knows
nothing of the command line, and console.py is the app that uses it.

### step-03.1 random_page moves to wikipedia.py

Now we move the request into a new module, `src/wikiapp/wikipedia.py`, with the address, the User-Agent and a
function, `random_page`. `random_page` returns the answer from inside the `with` block. The original set `data`
there, and returned it after the block. The result is the same.

::: do
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
:::

::: watch
Open `src/wikiapp/wikipedia.py`, a new file.
:::

Next we take the constants and the request out of `src/wikiapp/console.py`, and `main` calls `random_page`.

::: do
Replace `src/wikiapp/console.py` with the code below.

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
:::

::: watch
Find `data = random_page()` in the change of `src/wikiapp/console.py`.
:::

The move changes these files:

- `src/wikiapp/wikipedia.py`: 10 lines added; a new file with the address, the User-Agent, and `random_page`.
- `src/wikiapp/console.py`: 6 lines added, 10 removed; `main` calls `random_page`.

files:
- file `src/wikiapp/wikipedia.py`: the code that talks to Wikipedia.
  show: `def random_page():`
- diff `src/wikiapp/console.py`: only the command stays.
  show: `data = random_page()`

$ just test

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. wikipedia.py calls the function through the module, as `requests.get`, so it gets the mock.

### step-03.2 The mock moves to conftest.py

Now we share the mock with every test file. pytest reads `tests/conftest.py` before the tests, and every test file
can use a fixture in it. The tests of wikipedia.py, in the next move, need the mock too. So the fixture
`mock_requests_get` moves from `tests/test_console.py` to a new file, `tests/conftest.py`.

In step-03.1, the request moved from `main` into `random_page`, in wikipedia.py, and `main` now calls it. Only
`requests.get` is a mock. So a test of the command that uses the mock runs two parts of the code together, the
command and the library. A test of parts together is an integration test. Since step-03.1, the four tests of the
command that use the mock are integration tests, and no longer unit tests.

::: do
Make `tests/conftest.py` with the mock in it.

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

Then delete the fixture `mock_requests_get` from `tests/test_console.py`, with the blank line after it.
:::

::: watch
Open `tests/conftest.py`, a new file. Read the change of `tests/test_console.py`.
:::

The move changes these files:

- `tests/conftest.py`: 10 lines added; a new file with the mock.
- `tests/test_console.py`: 9 lines removed; the mock is gone.

files:
- file `tests/conftest.py`: the fixture, for every test file.
  show: `def mock_requests_get(mocker):`
- diff `tests/test_console.py`: the fixture is gone, but the tests still name it.

$ just test

The result is `5 passed`. pytest finds the fixture in conftest.py.

### step-03.3 A language

Now we let `random_page` ask the Wikipedia of a language. Each language has its own Wikipedia, at
LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, the address has a placeholder for the language.
`random_page` fills it, with English as the default.

::: do
In `src/wikiapp/wikipedia.py`, replace the line `API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"`
with this one.

```python
API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
```

Then replace the first three lines of `random_page`, from `def random_page():` to the line `with requests.get`, with
these.

```python
def random_page(language="en"):
    """Get a random page from Wikipedia."""
    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
```
:::

::: watch
Read the change of `src/wikiapp/wikipedia.py`.
:::

Then we write the first test of the library, in `tests/test_wikipedia.py`, which asks for a page in Spanish. It
checks that the address of the request contains `es.wikipedia.org`. It calls `random_page` alone, with the mock,
so it is a unit test of the library.

::: do
Make `tests/test_wikipedia.py`.

```python
from wikiapp import wikipedia

def test_random_page_uses_given_language(mock_requests_get):
    wikipedia.random_page(language="es")
    args, _ = mock_requests_get.call_args
    assert "es.wikipedia.org" in args[0]
```
:::

::: watch
Open `tests/test_wikipedia.py`, a new file.
:::

The move changes these files:

- `src/wikiapp/wikipedia.py`: 3 lines added, 3 removed; `random_page` takes a language.
- `tests/test_wikipedia.py`: 6 lines added; a new file with a test that the language chooses the Wikipedia.

files:
- diff `src/wikiapp/wikipedia.py`: the placeholder, and the code that fills it.
  show: `def random_page(language="en"):`
- file `tests/test_wikipedia.py`: the test uses the mock from conftest.py.
  show: `assert "es.wikipedia.org" in args[0]`

$ just test

The result is `6 passed`.

### step-03.4 wikiapp --language

Now we let the user choose the language of the page. In `src/wikiapp/console.py`, a new option `--language`, or
`-l`, comes between `@click.command()` and `@click.version_option`. `main` takes a parameter `language`, and passes
it on to `random_page`.

::: do
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
:::

::: watch
Read the change of `src/wikiapp/console.py`.
:::

click gives the value of the option to the parameter with the same name.

The move changes one file:

- `src/wikiapp/console.py`: 10 lines added, 2 removed; the option `--language`, or `-l`.

files:
- diff `src/wikiapp/console.py`: the option, which `main` gives to `random_page`.
  show: `data = random_page(language=language)`

$ uv run wikiapp --language fr

$ uv run wikiapp --help

The first command prints a French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

Now we make `random_page` raise an exception of the library when a request fails. If a request fails for any
reason, requests raises a `RequestException`. Code that uses the library should not need to know the exceptions of
requests. So the library raises an exception of its own. In `src/wikiapp/wikipedia.py`, the class `WikipediaError`
comes above `random_page`. The request is now in a `try` block, and a `RequestException` becomes a
`WikipediaError`.

::: do
In `src/wikiapp/wikipedia.py`, add the class above `random_page`, and put the request in a `try` block.

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
:::

::: watch
Read the change of `src/wikiapp/wikipedia.py`.
:::

`from error` keeps the original exception, so a traceback shows both exceptions.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 9 lines added, 3 removed; the class `WikipediaError`, which `random_page` raises.

files:
- diff `src/wikiapp/wikipedia.py`: the exception, and the line that raises it.
  show: `raise WikipediaError(str(error)) from error`

$ uv run wikiapp --language xx

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback, and the last line is the `WikipediaError`. No code catches the error yet.

### step-03.6 The command prints the error

Now we make `main` print a `WikipediaError` as a message. `src/wikiapp/console.py` imports the error with
`random_page`. `main` catches it, and raises the exception of click in its place. click prints that exception as a
message.

In the original wikiapp, the library raised the exception of click itself, with a note to move it to the
console one day. In this move, the exception of click moves to console.py. wikipedia.py knows Wikipedia and
requests, and console.py knows click.

::: do
In `src/wikiapp/console.py`, replace the line `from wikiapp.wikipedia import random_page` with this one.

```python
from wikiapp.wikipedia import WikipediaError, random_page
```

In `main`, replace the line `data = random_page(language=language)` with these four lines.

```python
    try:
        data = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
```
:::

::: watch
Read the change of `src/wikiapp/console.py`.
:::

Then we add a test, `test_main_prints_message_on_request_error`, which makes the mock raise a `RequestException`.
It checks that the output contains `Error`. `tests/test_console.py` now imports `requests`.

::: do
Add the test to `tests/test_console.py`, before `test_main_succeeds`, with a blank line after it. Put
`import requests` under `import pytest`.

```python
def test_main_prints_message_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = requests.RequestException
    result = runner.invoke(console.main)
    assert "Error" in result.output
```
:::

::: watch
Find `mock_requests_get.side_effect = requests.RequestException` in the change of `tests/test_console.py`.
:::

The move changes these files:

- `src/wikiapp/console.py`: 5 lines added, 2 removed; `main` catches WikipediaError.
- `tests/test_console.py`: 6 lines added; a test of the message.

files:
- diff `src/wikiapp/console.py`: the error becomes a message.
  show: `raise click.ClickException(str(error)) from error`
- diff `tests/test_console.py`: the test.
  show: `assert "Error" in result.output`

$ uv run wikiapp --language xx; echo "exit code $?"

$ just test

The first command prints `Error:` and the message in place of a traceback, then `exit code 1`. The tests give
`7 passed`.

## step-04 Format, lint, a hook

$ just setup

The ten moves of this step add a formatter, and then the changes that it makes. Next, a linter finds five
problems, and the next three moves fix them. Then a recipe checks the configuration, `uv run` stops updating the
lockfile, and another recipe runs every check. Last, a git hook runs every check before each commit.

A tool comes in one move, and its changes come in the next move. So you see what the tool would change before it
changes anything. The tests still need the network. Also, pre-commit downloads its hooks from GitHub the first
time.

### step-04.1 ruff, and the recipe fmt

Now we add ruff, a formatter and a linter in one program, to a third dependency group, `lint`, which `dev`
includes.

A formatter changes how the code looks, and never what it does. A linter finds problems in the code, such as a
variable that is never used. It changes nothing unless it is asked to.

::: do
In `pyproject.toml`, change the line `dev = ...`, and add the group.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }]
lint = []
```
:::

do$ uv add --group lint ruff

::: watch
Find `dev = [{ include-group = "test" }, { include-group = "lint" }]` in the change of `pyproject.toml`.
:::

Next we give ruff its settings, at the end of `pyproject.toml`. They set lines of up to 100 characters, and
write out the defaults of the formatter.

::: do
Add the settings at the end of `pyproject.toml`.

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
:::

::: watch
Find `line-length = 100` in the change of `pyproject.toml`.
:::

Then we add a recipe `fmt`, which runs the formatter. The words after `just fmt` go to `ruff format`.

::: do
Add a recipe at the end of the `justfile`.

```just

# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
[group('quality')]
[no-exit-message]
fmt *args:
    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```
:::

::: watch
Find `fmt *args:` in the change of `justfile`.
:::

The move changes these files:

- `pyproject.toml`: 15 lines added, 1 removed; the group `lint`, and ruff's settings.
- `justfile`: 6 lines added; the recipe `fmt`.
- `uv.lock`: 31 lines added; ruff.

files:
- diff `pyproject.toml`: the group and the settings.
  show: `line-length = 100`
- diff `justfile`: the recipe.
  show: `fmt *args:`

$ uv run ruff format --check

$ just --show fmt

$ just fmt --check

`--check` changes nothing. It lists the files that it would change, and fails. It prints `6 files would be
reformatted, 1 file already formatted`. The seventh file is the README. The recipe runs the same command, and
passes on the words after `just fmt`.

### step-04.2 The code, formatted

Now we run the formatter, which rewrites six files. It adds blank lines, puts spaces around `==`, and splits the
lines longer than 100 characters.

do$ just fmt

::: watch
Find `if __name__ == "__main__":` in the change of `src/wikiapp/console.py`. Then read the changes of
`src/wikiapp/wikipedia.py` and `tests/test_console.py`.
:::

The move changes these files:

- `src/wikiapp/__init__.py`: 1 line added; a blank line after the import.
- `src/wikiapp/console.py`: 3 lines added, 1 removed; two blank lines before the command and before `if __name__`, and spaces around `==`.
- `src/wikiapp/wikipedia.py`: 5 lines added, 1 removed; two blank lines around the class, and the request, longer than 100 characters, split.
- `tests/conftest.py`: 1 line added; two blank lines before the fixture.
- `tests/test_console.py`: 11 lines added, 1 removed; two blank lines around each function, and the line longer than 100 characters split.
- `tests/test_wikipedia.py`: 1 line added; two blank lines before the test.

files:
- diff `src/wikiapp/console.py`: blank lines, and spaces around `==`.
  show: `if __name__ == "__main__":`
- diff `src/wikiapp/wikipedia.py`: the long line of the request, split into three.
  show: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- diff `tests/test_console.py`: blank lines, and the long address split.
  show: `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`

$ just fmt --check

$ just test

The check prints `7 files already formatted`, and the tests pass as before. The formatter changes how the code
looks, and never what it does. One test asks the real Wikipedia, so the tests need the network until step 06.

### step-04.3 The linter's rules, and the recipe lint

Now we choose the linter's rules, in a table at the end of `pyproject.toml`. The linter checks the code against
rules, and the table chooses the families of rules, one family on each line. The tests may use `assert`. The rest
of the code may not use it, because Python skips every `assert` when it runs with `-O`.

::: do
At the end of `pyproject.toml`, choose the families of rules, and let the tests use `assert`.

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
:::

::: watch
Find `select = [` and `"tests/**" = ["S101"]` in the change of `pyproject.toml`.
:::

Next we add a recipe `lint`, which runs the linter. The words after `just lint` go to `ruff check`.

::: do
Add a recipe at the end of the `justfile`.

```just

# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
[group('quality')]
[no-exit-message]
lint *args:
    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```
:::

::: watch
Find `lint *args:` in the change of `justfile`.
:::

The move changes these files:

- `pyproject.toml`: 18 lines added; the rules.
- `justfile`: 6 lines added; the recipe `lint`.

files:
- diff `pyproject.toml`: a family of rules on each line.
  show: `"tests/**" = ["S101"]`
- diff `justfile`: the recipe.
  show: `lint *args:`

$ uv run ruff check --statistics

$ just --show lint

$ just lint --statistics

The linter finds five problems, each with its code:

- `I001`: the imports of console.py are out of order.
- `E402`: an import in test_console.py comes below code.
- `F841`, twice: a variable is assigned and never used.
- `S113`: a request has no timeout.

`just lint` shows each problem with its lines. `uv run ruff rule S113` explains a code.

### step-04.4 The linter sorts the imports

Now we let ruff fix the one problem of the five that it can fix safely. `just lint --fix` sorts the imports of
`console.py`. The command still ends with exit code 1, because four problems are left.

`--fix` makes only the fixes that ruff counts as safe, and the order of imports is one of them. ruff also has a
fix for the two unused variables. It marks that fix unsafe, because it may delete a comment on the line. It has no
fix for the other two problems. So a person decides about the other four.

do$ just lint --fix

::: watch
Find `from wikiapp import __version__` in the change of `src/wikiapp/console.py`.
:::

The move changes one file:

- `src/wikiapp/console.py`: 3 lines added, 2 removed; the imports in three blocks, which are the standard library, the packages
  installed, and then wikiapp's own.

files:
- diff `src/wikiapp/console.py`: the imports, sorted.
  show: `from wikiapp import __version__`

$ just lint --statistics

`just lint --fix` reported `Found 5 errors (1 fixed, 4 remaining)` and failed. Four problems are left, and a
person must fix them.

### step-04.5 The tests' imports at the top, and no unused variables

Now we move `from wikiapp import console` up in `tests/test_console.py`, under `import requests`. A reader looks
for imports there. wikiapp's own imports are a block of their own, after the installed packages, as `--fix` made
them in console.py.

A person makes the fixes of this move. The linter names each problem and its lines, and the person decides how
to fix it. ruff has no fix for the import below the code, and its fix for the unused variables is unsafe.

::: do
In `tests/test_console.py`, move `from wikiapp import console` up, under `import requests`. Put a blank line
between the two imports. Where the import was, delete it and the two blank lines after it. The functions are then
two blank lines apart.
:::

::: watch
Find `from wikiapp import console` in the change of `tests/test_console.py`.
:::

Next we drop `result =` in `test_main_invokes_requests_get` and `test_main_uses_correct_url`, since no line reads
the result. The two tests check the mock, not the result.

::: do
Make the first line of each of the two tests the call alone.

```python
    runner.invoke(console.main)
```
:::

::: watch
Find `runner.invoke(console.main)` twice in the change of `tests/test_console.py`.
:::

The move changes one file:

- `tests/test_console.py`: 4 lines added, 5 removed; the import at the top, and two assignments gone.

files:
- diff `tests/test_console.py`: the import moves, and two lines lose `result =`.
  show: `from wikiapp import console`

$ just lint --statistics

$ just fmt --check

One problem is left, `S113`. The format is unchanged, and the check prints `7 files already formatted`.

### step-04.6 A timeout

Now we give the request a timeout, because without one, requests waits as long as the server keeps the
connection open. So the command can wait for ever. The request in `src/wikiapp/wikipedia.py` now has `timeout=10`.

The linter asked for it, with the rule `S113`, from the family `S` of security rules. The linter found a problem
that no test had found. A person chose the number of seconds.

::: do
In `src/wikiapp/wikipedia.py`, add `timeout=10` to the request.

```python
        with requests.get(
            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
        ) as response:
```
:::

::: watch
Find `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10` in the change of
`src/wikiapp/wikipedia.py`.
:::

If the server does not answer within 10 seconds, the request now raises an exception. `random_page` turns it
into a WikipediaError, as it does with every other error of requests.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 1 line added, 1 removed; the timeout.

files:
- diff `src/wikiapp/wikipedia.py`: one more argument.
  show: `timeout=10`

$ just lint

`All checks passed!`

### step-04.7 The recipe lint-config

Now we add validate-pyproject to the group `lint`, and a recipe `lint-config` that checks the configuration.
The recipe runs three commands. validate-pyproject checks `pyproject.toml` against the standard for it,
`uv lock --check` checks the lockfile, and `just --fmt --check --unstable` checks the `justfile`.

These commands check the configuration, not the code. An error in `pyproject.toml`, in the lockfile or in the
`justfile` can pass every test and the linter.

do$ uv add --group lint validate-pyproject

::: do
Add a recipe at the end of the `justfile`.

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
:::

::: watch
Find `"validate-pyproject>=0.26",` in the change of `pyproject.toml`. Then find `lint-config *args:` in the
change of `justfile`.
:::

The move changes these files:

- `justfile`: 11 lines added; the recipe `lint-config`.
- `pyproject.toml`: 1 line added; validate-pyproject in the group `lint`.
- `uv.lock`: 28 lines added, 1 removed; the exact version of validate-pyproject, and of what it needs.

files:
- diff `justfile`: the recipe, with its three checks.
  show: `uv run validate-pyproject pyproject.toml`
- diff `pyproject.toml`: one package more in `lint`.
  show: `"validate-pyproject>=0.26",`

$ uv run validate-pyproject pyproject.toml

$ uv lock --check

$ just --fmt --check --unstable

$ just --show lint-config

$ just lint-config

The three checks pass. validate-pyproject prints `Valid file: pyproject.toml`. `uv lock --check` prints
`Resolved 19 packages` and exits with 0, because the lockfile matches `pyproject.toml`.

### step-04.8 A locked lockfile

Now we export the variable `UV_LOCKED` from the `justfile`, under `set positional-arguments`. With it, every `uv
run` of a recipe refuses a lockfile that is out of date. Without it, `uv run` quietly updates the lockfile.

::: do
In the `justfile`, under `set positional-arguments`, add the line below.

```just

export UV_LOCKED := "1"
```
:::

::: watch
Find `export UV_LOCKED := "1"` in the change of `justfile`.
:::

The move changes one file:

- `justfile`: 2 lines added; the variable `UV_LOCKED`, exported to every recipe.

files:
- diff `justfile`: one line.
  show: `export UV_LOCKED := "1"`

$ just --evaluate UV_LOCKED

It prints `1`. `just` puts the variable in the environment of every command of every recipe, so each `uv run`
sees it.

### step-04.9 The recipe check

Now we add a recipe `check`, which runs every check in order. It stops at the first check that fails. The order is
the format, the linter, the tests with a floor on the coverage, and the configuration.

::: do
Add a recipe at the end of the `justfile`.

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
:::

::: watch
Find `just test -q --cov-fail-under=90` in the change of `justfile`.
:::

The move changes one file:

- `justfile`: 12 lines added; the recipe `check`.

files:
- diff `justfile`: the recipe, with its four checks.
  show: `just test -q --cov-fail-under=90`

$ just --show check

$ just check

`just check` passes. The tests must run at least 90% of the statements, and the coverage is 96.77%.

### step-04.10 A git hook

Now we add pre-commit, which installs a git hook, to the group `lint`. A git hook is a program that git runs
before every commit. If the program fails, git refuses the commit.

`just check` is a gate that a person must remember to run. Once `just hook` installs the hook in a clone, the
hook runs it by itself, before each commit in that clone.

do$ uv add --group lint pre-commit

::: watch
Find `"pre-commit>=4.6.2",` in the change of `pyproject.toml`.
:::

Next we make `.pre-commit-config.yaml`, a new file that names the hooks. Three come from pre-commit's collection.
They check for valid YAML, large files and leftover merge-conflict markers. The last hook runs `just check`, so the
hook and the terminal run the same thing.

::: do
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
:::

::: watch
Open `.pre-commit-config.yaml`, a new file. Find `entry: just check` in it.
:::

Then we add a recipe `hook`, after `setup` in the `justfile`, which installs the hook. It is a recipe of its own,
run once in each clone, because `just setup` runs at every step and never touches git.

::: do
In the `justfile`, after `setup` and the blank line under it, add the recipe `hook`, with a blank line after it.

```just
# Install the git hook: just check before every commit. Once per clone; just setup never touches git
[group('setup')]
hook *args:
    @{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}
```
:::

::: watch
Find `hook *args:` in the change of `justfile`.
:::

The move changes these files:

- `.pre-commit-config.yaml`: 20 lines added; a new file, with the hooks.
- `justfile`: 5 lines added; the recipe `hook`, which installs the hook.
- `pyproject.toml`: 1 line added; pre-commit in the group `lint`.
- `uv.lock`: 138 lines added; the exact version of pre-commit, and of what it needs.

files:
- file `.pre-commit-config.yaml`: three hooks from pre-commit's collection, then `just check`.
  show: `entry: just check`
- diff `justfile`: the recipe `hook`.
  show: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`
- diff `pyproject.toml`: pre-commit in the group `lint`.
  show: `"pre-commit>=4.6.2",`

$ uv run pre-commit install

$ just --show hook

$ just hook

$ uv run pre-commit run --files .pre-commit-config.yaml

`uv run pre-commit install` prints `pre-commit installed at .git/hooks/pre-commit`, and `just hook` prints the
same line. The hook is in `.git/hooks`, and no step or move changes that folder. The hook stays installed for the
rest of the tutorial.

`pre-commit run` now runs every hook on the file named, as git will before a commit. The first time on a machine, it
prints `[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

With `--all-files`, pre-commit would check every file that git tracks. It would skip a new file until git tracks
it.

## step-05 Types

$ just setup

The six moves of this step add a type checker, and fix the one problem that it finds. Then a lint rule asks for
a type on every parameter and return. The last moves add the types, and put the type checker in `just check`.

### step-05.1 ty, and the recipe types

Now we add ty, a type checker, to the group `lint`. ty reads the code without running it. It finds code whose
types cannot fit, for example a call whose arguments cannot have the types that the function asks for.

do$ uv add --group lint ty

::: watch
Find `"ty>=0.0.86",` in the change of `pyproject.toml`.
:::

Next we add a recipe `types`, which runs ty, after the recipe `lint` in the `justfile`.

::: do
In the `justfile`, after the recipe `lint` and the blank line under it, add the recipe `types`, with a blank line
after it.

```just
# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
[group('quality')]
[no-exit-message]
types *args:
    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}
```
:::

::: watch
Find `types *args:` in the change of `justfile`.
:::

The move changes these files:

- `justfile`: 6 lines added; the recipe `types`.
- `pyproject.toml`: 1 line added; ty in the group `lint`.
- `uv.lock`: 29 lines added; the exact version of ty.

files:
- diff `justfile`: the recipe.
  show: `types *args:`
- diff `pyproject.toml`: ty in the group `lint`.
  show: `"ty>=0.0.86",`

$ uv run ty check

$ just --show types

$ just types

ty finds one problem, in `src/wikiapp/__init__.py`. The message is `Expected str, found str | None`. As far as
ty can tell, `__name__ or __package__` could be None. But `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

Now we ask for the version of `wikiapp` by name, in the last line of `src/wikiapp/__init__.py`.
`pyproject.toml` gives the name of the installed package, `wikiapp`. The name is a string that is never None.

::: do
Change the last line of `src/wikiapp/__init__.py`.

```python
__version__ = importlib.metadata.version("wikiapp")
```
:::

::: watch
Find `__version__ = importlib.metadata.version("wikiapp")` in the change of `src/wikiapp/__init__.py`.
:::

The move changes one file:

- `src/wikiapp/__init__.py`: 1 line added, 1 removed; the name, written out.

files:
- diff `src/wikiapp/__init__.py`: a string that is never None.
  show: `__version__ = importlib.metadata.version("wikiapp")`

$ just types

`All checks passed!`

### step-05.3 A type on every parameter and return

Now we turn on ruff's `ANN` rules, with one line in the list `select` in `pyproject.toml`, after `"N"`. ty, the
type checker that `just types` runs, checks the types that the code states. The `ANN` rules make sure that the code
states a type for every parameter and return.

So the linter checks that a type is written, and the type checker checks that the type is right.

::: do
In `pyproject.toml`, add a line to `select`, after `"N"`.

```toml
    "ANN", # annotations: every parameter and every return value has a type
```
:::

::: watch
Find `"ANN", # annotations: every parameter and every return value has a type` in the change of
`pyproject.toml`.
:::

The move changes one file:

- `pyproject.toml`: 1 line added; the rules `ANN`.

files:
- diff `pyproject.toml`: one line.
  show: `"ANN", # annotations: every parameter and every return value has a type`

$ just lint --statistics

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). `just check` fails at this move and at the next move, and passes again at step-05.5. So the
git hook would refuse a commit of this move or of the next.

### step-05.4 Types in the code

Now we add the types to the code, in `src/wikiapp/wikipedia.py` and `src/wikiapp/console.py`.

In `src/wikiapp/wikipedia.py`, `random_page` takes a string. It returns the JSON that Wikipedia sends, which is
a dictionary from strings to values of any kind. `Any` says that ty cannot check the values. The file imports
`Any` at the top, above `import requests`. The standard library is a block of its own.

In `src/wikiapp/console.py`, `main` takes the language as a string. Its return type, None, was already there.

::: do
Import `Any` at the top of `src/wikiapp/wikipedia.py`, above `import requests`, with a blank line between them.
Then give `random_page` its types.

```python
from typing import Any
```

```python
def random_page(language: str = "en") -> dict[str, Any]:
```

In `src/wikiapp/console.py`, give the parameter of `main` its type.

```python
def main(language: str) -> None:
```
:::

::: watch
Find `def random_page(language: str = "en") -> dict[str, Any]:` in the change of `src/wikiapp/wikipedia.py`.
Then find `def main(language: str) -> None:` in the change of `src/wikiapp/console.py`.
:::

The move changes these files:

- `src/wikiapp/wikipedia.py`: 3 lines added, 1 removed; the types of `random_page`.
- `src/wikiapp/console.py`: 1 line added, 1 removed; the type of `main`'s parameter.

files:
- diff `src/wikiapp/wikipedia.py`: the parameter and the return.
  show: `def random_page(language: str = "en") -> dict[str, Any]:`
- diff `src/wikiapp/console.py`: the parameter.
  show: `def main(language: str) -> None:`

$ just lint --statistics

The 22 problems that are left are all in the tests. They are 13 parameters and 9 returns.

### step-05.5 Types in the tests

Now we add the types to the tests, first to the fixture in `tests/conftest.py`. Since step-05.3, ruff's `ANN`
rules ask for a type on every parameter and return. The code has its types, and `just lint` finds 22 missing in
the tests.

The return type of a fixture is the type of what a test receives. The mock of `requests.get` is a `Mock`.
`mocker` is pytest-mock's `MockerFixture`, the name that replaced the original wikiapp's `MockFixture`.
`tests/conftest.py` now imports `Mock` and `MockerFixture`, and its fixture states both types.

::: do
Replace `tests/conftest.py` with this file.

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
:::

::: watch
Find `def mock_requests_get(mocker: MockerFixture) -> Mock:` in the change of `tests/conftest.py`.
:::

Next we add the types to `tests/test_console.py` and `tests/test_wikipedia.py`. A test returns None.
`tests/test_console.py` imports `Mock` and `CliRunner` by name. The fixture `runner` returns `CliRunner()`, so its
return type is `CliRunner`. Every function has its types. `tests/test_wikipedia.py` imports `Mock` at the top, and
its test has its types.

::: do
In `tests/test_console.py`, replace the lines from the top to the line `def test_main_prints_title`, that line
included, with the code below. `import click.testing` goes, and `Mock` and `CliRunner` come in by name. Then give
every other test its types. Each parameter `runner` is a `CliRunner`, each `mock_requests_get` is a `Mock`, and
each test returns `None`.

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

In `tests/test_wikipedia.py`, put `from unittest.mock import Mock` at the top, with a blank line
after it, and give the test its types.

```python
def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
```
:::

::: watch
Read the change of `tests/test_console.py`. Then find
`def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:` in the change of
`tests/test_wikipedia.py`.
:::

The move changes these files:

- `tests/conftest.py`: 4 lines added, 1 removed; the types of the fixture.
- `tests/test_console.py`: 11 lines added, 9 removed; the types of the fixture and of every test.
- `tests/test_wikipedia.py`: 3 lines added, 1 removed; the types of the test.

files:
- diff `tests/conftest.py`: the fixture returns a Mock.
  show: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- diff `tests/test_console.py`: the runner is a CliRunner.
  show: `def runner() -> CliRunner:`
- diff `tests/test_wikipedia.py`: one test.
  show: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

$ just lint

$ just types

Both commands pass.

::: do
If `just lint` reports `I001`, the imports are not in their blocks. Lines 1 to 7 of `tests/test_console.py` show
the blocks, the standard library first, then the other packages, then wikiapp.
:::

### step-05.6 The recipe check runs the type checker

Now we put the type checker in the recipe `check` of the `justfile`, after `just lint`. The comment of `check`
names the types too.

::: do
In the `justfile`, in `check`, run `just types` after `just lint`. Also add the types to the comment of `check`.

```just
# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
```

```just
    just lint
    just types
```
:::

::: watch
Find `just types` in the change of `justfile`, and the comment of `check` above it.
:::

The move changes one file:

- `justfile`: 2 lines added, 1 removed; `check` runs the type checker.

files:
- diff `justfile`: the comment, and one line in check.
  show: `just types`

$ just check

Every check passes, the type check among them. The coverage is 96.88%.

## step-06 End to end, and CI

$ just setup

The moves of this step do three things. The tests that ask the real Wikipedia run only when you ask for them.
The project accepts every Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only on request

Now we mark the test that asks the real Wikipedia, so that it runs only on request.

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. In `tests/test_console.py`, it now has the marker `e2e`, which means end to end. Its new
name says so, `test_main_succeeds_in_production`. `pyproject.toml` declares the marker in `markers`. The option
`-m 'not e2e'` in `addopts` leaves the e2e tests out of every run that does not ask for them.

The other tests use the mock in place of Wikipedia. They run without the network, and give the same result on
every run.

::: do
In `tests/test_console.py`, mark the test `e2e`, and give it the new name.

```python
@pytest.mark.e2e
def test_main_succeeds_in_production(runner: CliRunner) -> None:
```

In `pyproject.toml`, replace the comment and the line `addopts`.

```toml
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
# marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
# just test -m e2e
addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
```
:::

::: watch
Find `@pytest.mark.e2e` in the change of `tests/test_console.py`. Then read the change of `pyproject.toml`.
:::

The move changes these files:

- `tests/test_console.py`: 2 lines added, 1 removed; the marker, and the name.
- `pyproject.toml`: 5 lines added, 2 removed; the marker, declared, and the e2e tests left out of a plain run.

files:
- diff `tests/test_console.py`: the test, marked.
  show: `@pytest.mark.e2e`
- diff `pyproject.toml`: the option `-m 'not e2e'`.
  show: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

$ just test -q

$ just test -q -m e2e

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

### step-06.2 An end-to-end test of the library

Now we add an end-to-end test of the library, `random_page`. The mocks return a dictionary with a title and an
extract. A second e2e test, from the original wikiapp, checks that the real Wikipedia still returns the same keys.
It is `test_random_page_returns_dictionary_in_production`, at the end of `tests/test_wikipedia.py`. The file now
imports pytest, in a block of its own.

This test is also a contract test. It checks that the real Wikipedia still returns the two keys that the mocks
return.

::: do
Add the test at the end of `tests/test_wikipedia.py`. Put `import pytest` in a block of its own between
`from unittest.mock import Mock` and `from wikiapp import wikipedia`, with a blank line on each side.

```python


@pytest.mark.e2e
def test_random_page_returns_dictionary_in_production() -> None:
    page = wikipedia.random_page()
    assert "title" in page
    assert "extract" in page
```
:::

::: watch
Find `def test_random_page_returns_dictionary_in_production() -> None:` in the change of `tests/test_wikipedia.py`.
:::

The move changes one file:

- `tests/test_wikipedia.py`: 9 lines added; an e2e test.

files:
- diff `tests/test_wikipedia.py`: the test.
  show: `assert "extract" in page`

$ just test -q -m e2e

The output is `2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

Now we let the project accept every Python from 3.11 on. `uv init` wrote `requires-python = ">=3.13"`, because the
command asked for Python 3.13. Nothing here needs more than 3.11. Python 3.10 reached its end of life on 1 October
2026, so 3.11 is now the oldest Python that still gets security fixes. The line in `pyproject.toml` now says 3.11,
and uv solves the lockfile again.

::: do
In `pyproject.toml`, change the line.

```toml
requires-python = ">=3.11"
```
:::

do$ uv lock

::: watch
Find `requires-python = ">=3.11"` in the change of `pyproject.toml`.
:::

The project still runs on 3.13, from `.python-version`.

The move changes these files:

- `pyproject.toml`: 1 line added, 1 removed; the oldest Python that the project accepts.
- `uv.lock`: 160 lines added, 2 removed; solved for every Python from 3.11 on.

files:
- diff `pyproject.toml`: one line.
  show: `requires-python = ">=3.11"`

$ uv run --isolated --python 3.11 python --version

$ uv run --isolated --python 3.11 pytest -q

`--isolated` makes a temporary environment with Python 3.11, and does not change `.venv`. The tests pass on
3.11.

### step-06.4 GitHub runs the tests

Now we add a GitHub Actions workflow, which runs the tests on the machines of GitHub. A GitHub Actions workflow is
a file in `.github/workflows/`. GitHub runs the jobs of the workflow on every push to main and on every pull
request. The workflow `.github/workflows/test.yaml` has two jobs. The job `tests` runs the tests on three systems
and four Pythons. The job `check` runs `just check` once.

Both jobs run pytest with the options in `pyproject.toml`, so they leave out the e2e tests. GitHub runs the unit
tests and the integration tests on every push to main and every pull request. GitHub never runs the e2e tests. A
person runs them, with `just test -m e2e`.

::: do
Make `.github/workflows/test.yaml`.

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
:::

::: watch
Open `.github/workflows/test.yaml`, a new file. Find `python: ["3.11", "3.12", "3.13", "3.14"]` in it.
:::

The original wikiapp used pixi for the same work, with one environment for each Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

The move changes one file:

- `.github/workflows/test.yaml`: 37 lines added; a new file with two jobs. GitHub runs one of the jobs twelve times.

files:
- file `.github/workflows/test.yaml`: the matrix of systems and Pythons.
  show: `python: ["3.11", "3.12", "3.13", "3.14"]`

$ uv run pre-commit run check-yaml --files .github/workflows/test.yaml

The file is valid YAML. GitHub runs the workflow after a push. The **Actions** tab of the repository shows the
thirteen jobs.

## step-07 A page with a shape

$ just setup

The moves of this step give a page a shape. A pydantic model says what a page is, and `random_page` returns
one. An answer that is not a page becomes an error like any other. The last move checks that the language is a
language code.

### step-07.1 The model Page

Now we add pydantic, a library that checks data against a model. The command uses two of the many keys that
Wikipedia sends. Until now, the code expects these keys to be there, with strings as values, but nothing checks it.
A pydantic model states the two keys and their types in code. pydantic is a dependency of the package, as click and
requests are.

do$ uv add pydantic

::: do
If a newer pydantic is out, `uv add` writes its version as the lower bound, so that line differs from the commit.
timewalk still finds that your files match, since it compares `pyproject.toml` without the versions.
:::

::: watch
Find `"pydantic>=2.14.0",` in the change of `pyproject.toml`.
:::

Next we write the model `Page` in `src/wikiapp/wikipedia.py`, after `WikipediaError`. It has a title and an
extract, both strings. The file imports `BaseModel` under `import requests`.

::: do
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
:::

::: watch
Find `from pydantic import BaseModel` and `class Page(BaseModel):` in the change of `src/wikiapp/wikipedia.py`.
:::

The move changes these files:

- `src/wikiapp/wikipedia.py`: 8 lines added; the class `Page`.
- `pyproject.toml`: 1 line added; pydantic, a dependency of the package, as click and requests are.
- `uv.lock`: 180 lines added; the exact version of pydantic, and of what it needs.

files:
- diff `src/wikiapp/wikipedia.py`: the model.
  show: `class Page(BaseModel):`
- diff `pyproject.toml`: pydantic, a dependency of the package.
  show: `"pydantic>=2.14.0",`

$ uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"

$ uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails
with a ValidationError, because `extract` is missing.

### step-07.2 random_page returns a Page

Now we make `random_page`, in `src/wikiapp/wikipedia.py`, return a Page made from the answer. The code no longer
uses `Any`, so its import and the blank line under it are gone.

::: do
In `src/wikiapp/wikipedia.py`, delete the import of `Any`, and the blank line under it. Then change the return
type of `random_page`, and its `return` line.

```python
def random_page(language: str = "en") -> Page:
```

```python
            return Page.model_validate(response.json())
```
:::

::: watch
Find `return Page.model_validate(response.json())` in the change of `src/wikiapp/wikipedia.py`.
:::

Next we make `main`, in `src/wikiapp/console.py`, print the attributes of the page. ty and an editor know the names
of the attributes. A misspelled key of a dictionary shows up only when the program runs.

::: do
In `src/wikiapp/console.py`, replace the code under the docstring of `main` with the code below.

```python
    try:
        page = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
    click.secho(page.title, fg="green")
    click.echo(textwrap.fill(page.extract))
```
:::

::: watch
Find `click.secho(page.title, fg="green")` in the change of `src/wikiapp/console.py`.
:::

Then we rename the e2e test in `tests/test_wikipedia.py` to `test_random_page_returns_page_in_production`, with the
same marker. Its new name says that it checks for a Page. Its two asserts on the keys become one,
`assert isinstance(page, wikipedia.Page)`.

::: do
In `tests/test_wikipedia.py`, replace the e2e test `test_random_page_returns_dictionary_in_production`, with its
marker, by the code below.

```python
@pytest.mark.e2e
def test_random_page_returns_page_in_production() -> None:
    page = wikipedia.random_page()
    assert isinstance(page, wikipedia.Page)
```
:::

::: watch
Find `assert isinstance(page, wikipedia.Page)` in the change of `tests/test_wikipedia.py`.
:::

The move changes these files:

- `src/wikiapp/wikipedia.py`: 2 lines added, 4 removed; returns a Page.
- `src/wikiapp/console.py`: 3 lines added, 5 removed; prints the attributes of the Page.
- `tests/test_wikipedia.py`: 2 lines added, 3 removed; the e2e test.

files:
- diff `src/wikiapp/wikipedia.py`: the return.
  show: `return Page.model_validate(response.json())`
- diff `src/wikiapp/console.py`: attributes, not keys.
  show: `click.secho(page.title, fg="green")`
- diff `tests/test_wikipedia.py`: the e2e test checks for a Page.
  show: `assert isinstance(page, wikipedia.Page)`

$ just check

$ uv run wikiapp

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

Now we make `random_page` catch an answer that is not a page. When the answer has no title, `model_validate` raises
the ValidationError of pydantic. `random_page` turns it into a WikipediaError, as it does with a failed request. In
`src/wikiapp/wikipedia.py`, the `except` catches ValidationError together with the exception of requests.

::: do
In `src/wikiapp/wikipedia.py`, import ValidationError, and catch it together with the exception of requests.

```python
from pydantic import BaseModel, ValidationError
```

```python
    except (requests.RequestException, ValidationError) as error:
```
:::

::: watch
Find `except (requests.RequestException, ValidationError) as error:` in the change of `src/wikiapp/wikipedia.py`.
:::

Next we add a test from the original wikiapp, `test_random_page_handles_validation_error`, at the end of
`tests/test_wikipedia.py`. In the test, the mock answers with an empty dictionary.

::: do
Add the test at the end of `tests/test_wikipedia.py`.

```python


def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
    with pytest.raises(wikipedia.WikipediaError):
        wikipedia.random_page()
```
:::

::: watch
Find `def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:` in the change of
`tests/test_wikipedia.py`.
:::

The move changes these files:

- `src/wikiapp/wikipedia.py`: 2 lines added, 2 removed; a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: 6 lines added; a test of the ValidationError.

files:
- diff `src/wikiapp/wikipedia.py`: two exceptions caught.
  show: `except (requests.RequestException, ValidationError) as error:`
- diff `tests/test_wikipedia.py`: the test.
  show: `with pytest.raises(wikipedia.WikipediaError):`

$ just test -k validation

The output is `1 passed, 8 deselected`.

### step-07.4 Only a language code goes into the address

Now we check, in `random_page`, that the language is a language code before it goes into the address.

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as
`example.com/x?` sends the request to example.com, with the User-Agent. The code of every Wikipedia has only
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. In `src/wikiapp/wikipedia.py`, a pattern
`LANGUAGE` under `API_URL` matches such a code. `random_page` checks the language first, before the `try`. Any
other language raises a WikipediaError.

::: do
In `src/wikiapp/wikipedia.py`, import `re` at the top, in a block of its own above `import requests`. Add a
pattern under `API_URL`.

```python
import re

```

```python
LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
```

Add the check at the top of the body of `random_page`, under its docstring and before the `try`.

```python
    if not LANGUAGE.fullmatch(language):
        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
```
:::

::: watch
Find `LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens` and
`if not LANGUAGE.fullmatch(language):` in the change of `src/wikiapp/wikipedia.py`.
:::

The move changes one file:

- `src/wikiapp/wikipedia.py`: 5 lines added; the pattern, and the check.

files:
- diff `src/wikiapp/wikipedia.py`: the code checks a language before it uses it.
  show: `if not LANGUAGE.fullmatch(language):`

$ uv run wikiapp --language 'example.com/x?'

$ just test -q

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%. A drop in coverage is
something to know about. The tutorial adds no test to hide it.

## step-08 Docs from the code

$ just setup

The moves of this step add documentation:

- smalldocs, which makes the reference from the code, and says what has no documentation
- the documentation of the library, of the command and of the tests
- a site
- the tests and the docs in the README's table of folders
- the check of the documentation in `just check`

### step-08.1 smalldocs

Now we add smalldocs, which writes the reference from the code and lists what has no documentation. The reference
of a function gives its signature, what it does, and what each parameter is. The signature and the types are in the
code. The docstring says what the function does. A docment says what each parameter is. A docment is the comment
beside a parameter, with one parameter to a line.

The reference is documentation for a person who calls the code. smalldocs makes it from the code, so it changes
when the code changes.

The block below shows `random_page` with its docments, as the next move writes them. This move does not change
`random_page`.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

::: do
The block above is only to read.
:::

smalldocs reads all three, and writes Markdown. It is a Python package, so uv installs it like
any other. smalldocs goes in a fourth dependency group, `docs`, and `dev` includes that group.

::: do
In `pyproject.toml`, change the line `dev = ...`, and add the group on the line after it.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```
:::

do$ uv add --group docs smalldocs

::: watch
Read the change of `pyproject.toml`.
:::

Next we write `docs/_smalldocs.yml`, the file of settings that smalldocs reads. For now the file has one section,
`api`, the reference. It names the package to document, the address of its source, and the files of the tests to
check.

::: do
Make `docs/_smalldocs.yml` with the lines below.

```yaml
# The settings of smalldocs. `api` is the reference, made from the code of the packages
api:
  packages: [wikiapp]
  source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
  check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```
:::

::: watch
Open `docs/_smalldocs.yml`, a new file.
:::

Then we add a recipe `docs`, at the end of the `justfile`. `just docs` runs `smalldocs api`, and gives it the words
after `just docs`. `smalldocs api` has two commands that this step uses:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

::: do
Add the recipe at the end of the `justfile`.

```just

# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
[group('docs')]
[no-exit-message]
docs *args:
    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```
:::

::: watch
Find `docs *args:` in the change of `justfile`.
:::

The move changes these files:

- `docs/_smalldocs.yml`: 5 lines added; a new file, with the settings of the reference.
- `justfile`: 6 lines added; the recipe `docs`.
- `pyproject.toml`: 4 lines added, 1 removed; the group `docs`, with smalldocs.
- `uv.lock`: 64 lines added; the exact version of smalldocs and of the packages it needs.

files:
- file `docs/_smalldocs.yml`: the package to document, and the tests to check.
  show: `packages: [wikiapp]`
- diff `pyproject.toml`: the group.
  show: `docs = [`
- diff `justfile`: the recipe.
  show: `docs *args:`

$ uv run smalldocs api module wikipedia --dir docs

$ uv run smalldocs api check --dir docs

$ just --show docs

$ just docs check

`module` prints the reference of `wikipedia.py`, with empty descriptions. For each module and each test file,
`check` counts the functions and classes that are complete. Then it lists every gap, and fails with `1 of 15
functions, methods and classes are typed and documented`. The one is `WikipediaError`, which needs only its
docstring. Above the total, `check` names every gap, and the five modules without a docstring are among them. Like
coverage, which counts the lines that the tests run, `check` counts what has documentation.

### step-08.2 The library documented

Now we document the library, `src/wikiapp/wikipedia.py`, with four additions:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

::: do
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
:::

::: watch
Find `) -> Page:  # A page chosen at random` in the change of `src/wikiapp/wikipedia.py`.
:::

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 12 lines added, 4 removed; a docstring for the module, docments, and a longer docstring.

files:
- diff `src/wikiapp/wikipedia.py`: the comments are the documentation.
  show: `) -> Page:  # A page chosen at random`

$ just docs module wikipedia

The tables now have their descriptions.

### step-08.3 The command documented

Now we give `src/wikiapp/__init__.py` and `src/wikiapp/console.py` each a docstring at the top.

::: do
Add a docstring at the top of `src/wikiapp/__init__.py` and of `src/wikiapp/console.py`.

```python
"""wikiapp: the title and summary of a random Wikipedia page."""

```

```python
"""The wikiapp command."""

```
:::

::: watch
Find `"""wikiapp: the title and summary of a random Wikipedia page."""` in the change of
`src/wikiapp/__init__.py`. Then find `"""The wikiapp command."""` in the change of `src/wikiapp/console.py`.
:::

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

Next we document `main` and its option `--language`. `wikiapp --help` prints the docstring of `main` and the help
of each option, so those are documentation too. The help of `--language` now says what a language is. It replaces
the help of the original wikiapp, "Gets random page from Wikipedia in given language". `main` has one parameter to
a line, with its docment, and a docstring that says what `main` prints. A function that returns None needs no
docment for its return.

::: do
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
:::

::: watch
Find `help="The language of the Wikipedia to ask, as its code: en, fr, es",` in the change of
`src/wikiapp/console.py`. Then find `language: str,  # The language of the Wikipedia to ask, from --language` in
the change of `src/wikiapp/console.py`.
:::

The move changes these files:

- `src/wikiapp/__init__.py`: 2 lines added; a docstring for the module.
- `src/wikiapp/console.py`: 10 lines added, 3 removed; a docstring for the module, the documentation of `main`, and the help of `--language`.

files:
- diff `src/wikiapp/__init__.py`: a docstring, which `help(wikiapp)` shows.
  show: `"""wikiapp: the title and summary of a random Wikipedia page."""`
- diff `src/wikiapp/console.py`: the docment, the docstring and the help.
  show: `language: str,  # The language of the Wikipedia to ask, from --language`

$ just docs module console

$ uv run wikiapp --help

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

### step-08.4 The tests documented

Now we document the tests, so that `just docs check` finds no gap. A docment is the comment beside a parameter, or
after the colon of the `def` line for the return. `just docs check`, from step-08.1, counts the functions and
classes that have their types, docments and docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. Each parameter of a test has a docment, one
parameter to a line, and `tests/test_console.py` shows the pattern best.

Tests documented this way are documentation too. A reader learns from them what the code must do.

::: do
The three files are long to type, so take them with **Apply the whole move** in timewalk, or from the move's
commit on GitHub. The test below shows the pattern.

```python
def test_main_prints_title(
    runner: CliRunner,  # The runner from the fixture
    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
) -> None:
    """The command prints the title of the page."""
```
:::

::: watch
Read the changes of `tests/conftest.py`, `tests/test_console.py` and `tests/test_wikipedia.py`. Find
`"""The command prints the title of the page."""` in the change of `tests/test_console.py`.
:::

The move changes these files:

- `tests/conftest.py`: 6 lines added, 1 removed; a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: 33 lines added, 7 removed; docstrings for the file, the fixture and each test, and docments for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: 11 lines added, 2 removed; a docstring for the file and each test, and a docment for each parameter.

files:
- diff `tests/conftest.py`: the fixture, documented.
  show: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- diff `tests/test_console.py`: seven functions.
  show: `"""The command prints the title of the page."""`
- diff `tests/test_wikipedia.py`: three tests.
  show: `"""The language chooses the Wikipedia that is asked."""`

$ just docs check

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

### step-08.5 A site

Now we make a docs site, because smalldocs also makes a website from Markdown. The site is in `docs/`. It has a
front page, `index.qmd`, and a reference page for `console.py` and one for `wikipedia.py`. Each build writes the reference pages from the code,
before it builds the site. A name in backticks, such as `random_page`, becomes a link to its entry.

The front page is a written page, for a person who wants to know what the project does. The reference pages say
what each name does. The site has both kinds.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site. The front page, `docs/index.qmd`, is
new. A `.qmd` file is Markdown, with a header between two `---` lines that gives the title of the page.

::: do
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

The front page is long to type, so take `docs/index.qmd` with **Apply this file** in timewalk, or from the
move's commit on GitHub.
:::

::: watch
Find `contents: api/*  # the reference pages, which each build makes from the code` in the change of
`docs/_smalldocs.yml`. Then open `docs/index.qmd`, a new file.
:::

Next we change the recipe `docs`, so that `just docs` with no words builds the site, with `smalldocs render docs`.
With words, it runs `smalldocs api` as before. The recipe is now a script of several lines.

::: do
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
:::

::: watch
Find `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi` in the change of `justfile`.
:::

The move changes these files:

- `docs/_smalldocs.yml`: 17 lines added, 1 removed; the settings of the site above the section `api`, and a comment above `api`. The
  comment at the top now says that `just docs` builds the site.
- `docs/index.qmd`: 35 lines added; a new file, the front page.
- `justfile`: 5 lines added, 2 removed; with no words, `docs` builds the site, and its comment says so. The recipe is now a script of
  several lines.

files:
- diff `docs/_smalldocs.yml`: the site. The sidebar lists the front page, then the reference pages.
  show: `contents: api/*  # the reference pages, which each build makes from the code`
- file `docs/index.qmd`: the front page, written by hand.
  show: `Each build of the site makes the pages under Reference from the code.`
- diff `justfile`: with no words, `docs` builds the site.
  show: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

$ uv run smalldocs render docs

$ just --show docs

$ just docs

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. On the front page, `random_page` is a link to its entry. Each build makes the site and the reference
pages, and git ignores them.

### step-08.6 The README names the tests and the docs

Now we bring the table of folders in the README up to date. The README gets `tests/` and `docs/` among the
folders. It also says that `wikipedia.py` is the library and `console.py` the command.

The README is the first page that a reader sees on GitHub. Its table of folders says where each part of the
project is.

::: do
Take the README with **Apply this file** in timewalk, or from the move's commit on GitHub. Or copy the rows
below, in place of the `src/wikiapp/` row.

```markdown
| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
| `tests/` | The tests. `just test` runs them |
| `docs/` | The docs site. smalldocs makes its reference from the code |
```
:::

::: watch
Read the change of `README.md`.
:::

The move changes one file:

- `README.md`: 3 lines added, 1 removed; rows for `tests/` and `docs/`, and the `src/wikiapp/` row names the library and the command.

files:
- diff `README.md`: the folders.
  show: `| The docs site. smalldocs makes its reference from the code |`

$ grep -n -E 'tests/|docs/' README.md

`grep` prints the two new rows of the table.

### step-08.7 The docs check in `just check`

Now we add `just docs check` to the recipe `check`, after the tests, and name the docs in the comment above it.

::: do
In the `justfile`, replace the comment above `check` with the line below.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

Then, in `check`, add `just docs check` after the line of the tests.

```just
    just test -q --cov-fail-under=90
    just docs check
```
:::

::: watch
Find `just docs check` in the change of `justfile`, and read the new comment above `check`.
:::

The move changes one file:

- `justfile`: 2 lines added, 1 removed; the docs check in `check`, and the comment.

files:
- diff `justfile`: the comment, and one line in `check`.
  show: `just docs check`

$ just check

The docs check prints `15 of 15`. Now the git hook refuses a commit that leaves a function, a parameter or a
field without documentation. GitHub's job `check`, at lines 30 to 37 of `.github/workflows/test.yaml`, runs
`just check`, so it runs the docs check too.

## step-09 The library as a package

$ just setup

The code that asks Wikipedia becomes a package of its own, `wikirandom`, in the same repository. The first move
makes an empty package. The next moves add the code, and make the app use the library. The README and the front
page of the docs change with the app. The last move makes the docs check count the library. Any other program
could then install wikirandom without wikiapp and click.

### step-09.1 An empty library, wikirandom

Now we make an empty library, `wikirandom`, as a second package in `packages/wikirandom`.
uv can make a second package inside a project. The two packages then form a *workspace*, which has one lockfile
and one `.venv` for both. `uv init --lib --author-from none packages/wikirandom` makes the library.
`--author-from none` keeps uv from writing the author's name and email from git into the library's
`pyproject.toml`.

uv makes `packages/wikirandom/`, with these files in it:

- `pyproject.toml`, the library's own
- `README.md`, empty
- `src/wikirandom/__init__.py`, with an example function, `hello`
- `src/wikirandom/py.typed`, the mark that tells a type checker that the package has types

In the project's `pyproject.toml`, uv adds `[tool.uv.workspace]`. uv copies the Python version from
`.python-version`.

do$ uv init --lib --author-from none packages/wikirandom

::: do
Another version of uv writes another range for `uv_build` in the library's `pyproject.toml`, so that line differs
from the commit. timewalk still finds that your files match, since it compares the file without the versions.
:::

::: watch
Open `packages/wikirandom/src/wikirandom/__init__.py`, a new file. Find `[tool.uv.workspace]` in the change of
`pyproject.toml`.
:::

Next we give the library's `pyproject.toml` Python 3.11, as the app has, and a description. Its `README.md` gets a
heading and one line of what it is.

::: do
In `packages/wikirandom/pyproject.toml`, replace the lines `description` and `requires-python` that `uv init` wrote
with the lines below.

```toml
description = "A random page of Wikipedia, in any language"
```

```toml
requires-python = ">=3.11"
```

Replace `packages/wikirandom/README.md` with a heading and one line of what it is.

```markdown
# wikirandom

A random page of Wikipedia, in any language. The command `wikiapp` will use this library.
```
:::

::: watch
Find `requires-python = ">=3.11"` in `packages/wikirandom/pyproject.toml`, a new file. Open
`packages/wikirandom/README.md`, a new file.
:::

Then we make the lockfile again with `uv lock`, for the workspace of two packages.

do$ uv lock

The move changes these files:

- `packages/wikirandom/pyproject.toml`: 11 lines added; new. It has the package's name, version and description, and uv_build.
- `packages/wikirandom/README.md`: 3 lines added; new. It says what the library is.
- `packages/wikirandom/src/wikirandom/__init__.py`: 2 lines added; new. It has uv's example function, `hello`.
- `packages/wikirandom/src/wikirandom/py.typed`: new and empty. It tells ty and other checkers that the package has types.
- `pyproject.toml`: 5 lines added; the workspace, with one member.
- `uv.lock`: 11 lines added; the second package.

files:
- file `packages/wikirandom/pyproject.toml`: a package of its own.
  show: `name = "wikirandom"`
- file `packages/wikirandom/README.md`: a heading, and what the library is.
  show: ``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``
- file `packages/wikirandom/src/wikirandom/__init__.py`: uv's example function.
  show: `def hello() -> str:`
- diff `pyproject.toml`: the workspace.
  show: `"packages/wikirandom",`

$ uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"

The command prints `Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`,
and runs the command there. The app does not depend on the library yet, so a plain `uv run` would not install it.

### step-09.2 The code goes into wikirandom

Now we give the library the code of `src/wikiapp/wikipedia.py`, and the packages that the code imports.
The library needs requests and pydantic. `packages/wikirandom/src/wikirandom/__init__.py` now contains the code of
`src/wikiapp/wikipedia.py`. Its docstring says what the package is. Its User-Agent names the program that makes
the request.

do$ uv add --package wikirandom requests pydantic

::: do
Replace `packages/wikirandom/src/wikirandom/__init__.py` with the code of `src/wikiapp/wikipedia.py`. Change its
docstring to say what the package is. Change its User-Agent to name the program that makes the request.

```python
"""wikirandom: a random page of Wikipedia, in any language, from its REST API."""
```

```python
USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```
:::

::: watch
Read the change of `packages/wikirandom/pyproject.toml`. Find
`USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"` in the change of
`packages/wikirandom/src/wikirandom/__init__.py`.
:::

The move changes these files:

- `packages/wikirandom/src/wikirandom/__init__.py`: 41 lines added, 2 removed; the code of wikipedia.py.
- `packages/wikirandom/pyproject.toml`: 4 lines added, 1 removed; requests and pydantic, which are the library's dependencies.
- `uv.lock`: 10 lines added; the library's dependencies.

files:
- diff `packages/wikirandom/src/wikirandom/__init__.py`: the library.
  show: `def random_page(`
- diff `packages/wikirandom/pyproject.toml`: its dependencies.
  show: `"pydantic>=2.14.0",`

$ uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"

The command prints the title of a French page. The app still has its own `wikipedia.py`, and does not use the
library yet.

### step-09.3 The app uses wikirandom

Now we make the library a dependency of the app, in place of requests and pydantic. In the app's code, only
`src/wikiapp/wikipedia.py` imports those two, and it goes later in the move. `tests/test_console.py` still imports
requests, which now comes with wikirandom.

Because wikirandom is a member of the workspace, `uv add` writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`. So uv installs the library from `packages/wikirandom`, and not from PyPI. A change to the
library's code then takes effect in the app with no new install. `src/wikiapp/console.py` imports from the
library. The import goes with the installed packages, under `import click`, so the lines are already in ruff's
order.

do$ uv add wikirandom
do$ uv remove requests pydantic

::: do
In `src/wikiapp/console.py`, import from the library, in place of the import from `wikiapp.wikipedia`.

```python
import click
from wikirandom import WikipediaError, random_page

from wikiapp import __version__
```
:::

::: watch
Find `wikirandom = { workspace = true }` in the change of `pyproject.toml`. Find
`from wikirandom import WikipediaError, random_page` in the change of `src/wikiapp/console.py`.
:::

Next we delete `src/wikiapp/wikipedia.py`, and rename `tests/test_wikipedia.py` to `tests/test_wikirandom.py`.

do$ git rm src/wikiapp/wikipedia.py
do$ git mv tests/test_wikipedia.py tests/test_wikirandom.py

Next we make the renamed file, `tests/test_wikirandom.py`, test the library.
Its docstring is `Tests of the library, wikirandom.`, and it imports
`wikirandom` under `import pytest`. Its tests call `wikirandom.random_page`, `wikirandom.Page` and
`wikirandom.WikipediaError`. The host `es.wikipedia.org` in the first test stays as it was.

::: do
Make `tests/test_wikirandom.py` test the library.

- Change its docstring to `Tests of the library, wikirandom.`
- Put `import wikirandom` under `import pytest`, in place of `from wikiapp import wikipedia` and the blank line
  before it.
- Change `wikipedia.random_page`, `wikipedia.Page` and `wikipedia.WikipediaError` to `wikirandom.random_page`,
  `wikirandom.Page` and `wikirandom.WikipediaError`.

Keep the host `es.wikipedia.org` in the first test as it is.
:::

::: watch
Open `tests/test_wikirandom.py`, the file renamed from `tests/test_wikipedia.py`. Find `import wikirandom` in
it.
:::

Then we make coverage, in `pyproject.toml`, measure both packages.

::: do
In `pyproject.toml`, make coverage measure both packages. Replace the first line of the comment above
`addopts`, and the line `addopts`, with the lines below.

```toml
# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
```

```toml
addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
```
:::

::: watch
Find `addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"` in the change of
`pyproject.toml`.
:::

Last, we add a row for the library to `README.md`, and make the front page, `docs/index.qmd`, name two
packages.
The library's README now says that the app uses the library, and no longer that it will.

::: do
In `README.md`, replace the `src/wikiapp/` row of the table of folders with the two rows below.

```markdown
| `src/wikiapp/` | The app. `console.py` is the `wikiapp` command |
| `packages/wikirandom/` | The library the app uses: a random page of Wikipedia. A package of its own |
```

The front page is long to type, so take `docs/index.qmd` with **Apply this file** in timewalk, or from the
move's commit on GitHub.

In `packages/wikirandom/README.md`, replace the line under the heading with the line below.

```markdown
A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```
:::

::: watch
Read the change of `README.md`, of `docs/index.qmd` and of `packages/wikirandom/README.md`.
:::

The move changes these files:

- `pyproject.toml`: 6 lines added, 4 removed; wikirandom in, requests and pydantic out. The source of wikirandom is the workspace, and coverage measures both packages.
- `uv.lock`: 2 lines added, 4 removed; the app's dependencies are now click and wikirandom.
- `src/wikiapp/console.py`: 1 line added, 1 removed; imports from wikirandom.
- `src/wikiapp/wikipedia.py`: deleted, 41 lines.
- `tests/test_wikirandom.py`: 7 lines added, 8 removed; renamed from `tests/test_wikipedia.py`, and it tests wikirandom.
- `README.md`: 2 lines added, 1 removed; a row for the library, and the `src/wikiapp/` row says the app.
- `docs/index.qmd`: 8 lines added, 7 removed; two packages, the library and the app.
- `packages/wikirandom/README.md`: 1 line added, 1 removed; says that wikiapp uses the library now.

files:
- diff `pyproject.toml`: the app depends on the library.
  show: `wikirandom = { workspace = true }`
- diff `src/wikiapp/console.py`: one import.
  show: `from wikirandom import WikipediaError, random_page`
- file `tests/test_wikirandom.py`: the same three tests.
  show: `wikirandom.random_page(language="es")`
- diff `README.md`: one row more, and the `src/wikiapp/` row says the app.
  show: `| The library the app uses: a random page of Wikipedia. A package of its own |`
- diff `docs/index.qmd`: two packages.
  show: `The code has two packages, in one repository:`
- diff `packages/wikirandom/README.md`: the library's README says that the app uses it.
  show: ``A random page of Wikipedia, in any language. The command `wikiapp` uses this library.``

$ just test -q

$ uv tree --depth 2

$ just docs check

$ just docs

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`. `uv tree` shows that wikiapp needs click and wikirandom, and
that wikirandom needs requests and pydantic. `just docs check` still counts the app and the tests alone, 12 of 12. `just docs`
writes 2 pages, the front page and the reference page of the app. The front page names both packages, but
`random_page` is not yet a link, because the settings of the site name only the app. The next move adds the
library to the settings.

### step-09.4 The docs check counts the library

Now we make the docs check count the library, in `docs/_smalldocs.yml`.
Since step-09.3, the app uses the library `wikirandom`, a package of its own in `packages/wikirandom`. But
`docs/_smalldocs.yml` names only `wikiapp`. The line `packages:` in the section `api` now names both.

::: do
In `docs/_smalldocs.yml`, change the line `packages:` in the section `api`, so that it names both.

```yaml
  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
```
:::

::: watch
Read the change of `docs/_smalldocs.yml`.
:::

The move changes one file:

- `docs/_smalldocs.yml`: 1 line added, 1 removed; two packages.

files:
- diff `docs/_smalldocs.yml`: the list.
  show: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

$ just docs check

$ just docs

$ just check

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and on the front page, `random_page` is now a link to its entry. `just check` passes.

## step-10 Build

$ just setup

The moves of this step build each package into a wheel, the file that pip and uv install. Then the app says
which versions of the library it accepts, and `just lint-config` checks the library's `pyproject.toml` too.
Both packages say their licence and where their source is. Last, the
library's User-Agent says the version that is installed.

### step-10.1 The recipe `build`

Now we add a recipe, `build`, at the end of the `justfile`, that builds both packages. It runs
`uv build --all-packages`, which builds every package of the workspace into `dist/`. `.gitignore` lists `dist/`.

::: do
Add the recipe at the end of the `justfile`.

```just

# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
[group('setup')]
[no-exit-message]
build *args:
    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```
:::

::: watch
Read the change of `justfile`.
:::

The move changes one file:

- `justfile`: 6 lines added; the recipe `build`.

files:
- diff `justfile`: the recipe.
  show: `build *args:`

$ uv build --all-packages

$ just --show build

$ just build

$ unzip -l dist/wikiapp-0.1.0-py3-none-any.whl

$ unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA

`dist/` now has a source archive, `.tar.gz`, and a wheel, `.whl`, for each package. The app's wheel contains
`wikiapp/` and its metadata, which says that the app needs click and wikirandom. The metadata does not say which
version of wikirandom, because `uv add wikirandom` in a workspace writes no version. An install from PyPI would
get any package that PyPI has under that name. Today PyPI has none, so wikirandom would have to be published
first.

### step-10.2 The app needs wikirandom 0.1

Now we give the app's dependency on wikirandom a range of versions, `>=0.1.0,<0.2`. Until now, the app's wheel
says that the app needs `wikirandom`, of any version. An install from PyPI would take any package that anyone
publishes under that name. The app works with wikirandom 0.1.0, and `<0.2` keeps out a later release that may
change the library.

do$ uv add "wikirandom>=0.1.0,<0.2"

::: watch
Find `"wikirandom>=0.1.0,<0.2",` in the change of `pyproject.toml`.
:::

Nothing else changes in the workspace. uv still installs the library from `packages/wikirandom`, as
`[tool.uv.sources]` says.

The move changes one file:

- `pyproject.toml`: 1 line added, 1 removed; a version range on wikirandom.

files:
- diff `pyproject.toml`: one line.
  show: `"wikirandom>=0.1.0,<0.2",`

$ just build

$ unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

### step-10.3 lint-config checks both pyproject.toml files

Now we make `just lint-config` check the library's `pyproject.toml` too.
Since step 09, the repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. The
recipe `lint-config` now gives validate-pyproject both files.

::: do
In the `justfile`, in `lint-config`, replace the line `uv run validate-pyproject pyproject.toml` with the line
below.

```just
    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
```
:::

::: watch
Read the change of `justfile`.
:::

The move changes one file:

- `justfile`: 1 line added, 1 removed; `lint-config` checks both files.

files:
- diff `justfile`: two files.
  show: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

$ just lint-config

`just lint-config` prints `Valid file` twice, once for each file.

### step-10.4 A licence and a repository link for both

Now we give the library a licence and an author, and both packages a link to the repository.
The library's wheel has no licence, and neither package says where its source is. The library gets a copy of the
project's `LICENSE`. Its `pyproject.toml` gives the licence and the author under `readme`, as the app's
`pyproject.toml` does. Both `pyproject.toml` files now name the repository, in `[project.urls]`. PyPI shows it on
the package's page.

do$ cp LICENSE packages/wikirandom/LICENSE

::: do
In `packages/wikirandom/pyproject.toml`, under `readme`, give the licence and the author.

```toml
license = "Apache-2.0"
license-files = ["LICENSE"]
authors = [{ name = "Rahul Dave" }]
```

Add the repository to both `pyproject.toml` files. In the library's file, put it after the list `dependencies`,
so that one blank line comes before it and one after it. In the app's file, put it after the line
`wikiapp = "wikiapp.console:main"` of `[project.scripts]`.

```toml

[project.urls]
Repository = "https://github.com/rahuldave/smallwikiapp"
```
:::

::: watch
Open `packages/wikirandom/LICENSE`, a new file. Read the change of `packages/wikirandom/pyproject.toml` and of
`pyproject.toml`.
:::

The move changes these files:

- `packages/wikirandom/LICENSE`: 202 lines added; new. It has the same licence as the app.
- `packages/wikirandom/pyproject.toml`: 6 lines added; the licence, the author, the repository.
- `pyproject.toml`: 3 lines added; the repository.

files:
- diff `packages/wikirandom/pyproject.toml`: what PyPI would show.
  show: `license = "Apache-2.0"`
- diff `pyproject.toml`: the app's repository.
  show: `[project.urls]`
- file `packages/wikirandom/LICENSE`: the same Apache-2.0 licence as the app's.
  show: `Apache License`

$ just build

$ unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA

The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

### step-10.5 The User-Agent says the installed version

Now we make the library's User-Agent say the installed version.
The User-Agent says `0.1.0`, written by hand. It would still say `0.1.0` after a change of the version in
`packages/wikirandom/pyproject.toml`. `packages/wikirandom/src/wikirandom/__init__.py` now reads the version
from the installed package, as `wikiapp --version` does. `import importlib.metadata` comes above `import re`, in
the same block. `VERSION` is the installed version, and `USER_AGENT` contains it.

::: do
In `packages/wikirandom/src/wikirandom/__init__.py`, add `import importlib.metadata` above `import re`, in the
same block. Then replace the line `USER_AGENT`.

```python
import importlib.metadata
import re
```

```python
VERSION = importlib.metadata.version("wikirandom")
USER_AGENT = f"wikirandom/{VERSION} (https://github.com/rahuldave/smallwikiapp)"
```
:::

::: watch
Find `import importlib.metadata` and `VERSION = importlib.metadata.version("wikirandom")` in the change of
`packages/wikirandom/src/wikirandom/__init__.py`.
:::

The move changes one file:

- `packages/wikirandom/src/wikirandom/__init__.py`: 3 lines added, 1 removed; the package reads its version once, when Python imports it.

files:
- diff `packages/wikirandom/src/wikirandom/__init__.py`: the version now comes from one place, pyproject.toml.
  show: `VERSION = importlib.metadata.version("wikirandom")`

$ uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"

$ just check

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.
