# The walk through smallwikiapp, step by step

This file holds the notes of every step of a walk. timewalk shows the notes of the current step in the column on the
right of the page.

- **A command** is a line that starts with `$ `. A click on it types the command into the terminal of the
  step, and you press Enter to run it. With **run on click** on, a click also runs it.
- **Other tabs:** a line that starts with `runs$ ` goes to the **Runs** tab, for a command that takes a
  while. A line that starts with `main$ ` goes to the **Main** tab, in `repo/`.
- **A cue** is a line that starts with `> `. The notes column shows it shaded.
- **Edit** at the top of the column changes the notes of the step, and **Save** writes them into
  this file. Commit it to your fork to keep your notes.
- **`$ just setup` starts every step.** It is the project's own recipe, at the step. It makes the environment
  of the step, and what the step needs.
- **A move keeps your work.** Before a move, timewalk keeps your edits and commits in `worktree/` on a branch
  `timewalk/saved/<step>`, and the page says how to get them back. In a `worktree/` that an older timewalk made, a
  move with edits asks first, and stashes them.

## step-00 The project

$ just setup

A project needs a name, a Python and a command before it has code to run. It also needs to install the same way
on every machine. `uv init --package --python 3.13 --name wikiapp` made `pyproject.toml`, a package in
`src/wikiapp/`, and `.python-version`.

[uv](https://docs.astral.sh/uv/) comes from Astral, and is written in Rust. It installs Python, makes the folder
`.venv` with the project's packages, and runs commands in `.venv`. It also writes the lockfile, a file that lists
the exact version of each package. One tool does the work of
pip, venv and pip-tools.

Then the author changed the project by hand. `main` went to `src/wikiapp/console.py`. `pyproject.toml` got a
description, an author and a licence, and names `wikiapp.console:main` as the command. `uv lock` wrote the
lockfile, `uv.lock`. The author also wrote the justfile, `LICENSE`, the README and `.gitignore`.

`just setup` runs `uv sync --locked`. It makes `.venv` with Python 3.13, from `.python-version`, and installs
exactly the packages that the lockfile names. Here, the only package is `wikiapp` itself.

$ cat pyproject.toml

The line under `[project.scripts]` makes `wikiapp` a command. The name is on the left. The function is on the
right, `main` in `src/wikiapp/console.py`. For now, `main` prints one line.

$ uv run wikiapp

$ cat src/wikiapp/console.py

The program [`just`](https://just.systems/) is a command runner. It runs the tasks of the project, and the justfile contains them.

A task is called a recipe. It has a name, and the commands that it runs. `just` alone lists the tasks, and
`just --show setup` shows the recipe behind one task. `just help setup` shows the same recipe. Later sections add
recipes to the justfile.

$ just

$ just --show setup

$ just --show help

$ just help setup

files:
- file `pyproject.toml`: the project, and the table `[project.scripts]` that makes the command `wikiapp`.
  show: `wikiapp = "wikiapp.console:main"`
- file `src/wikiapp/console.py`: `main`, which prints one line.
- file `src/wikiapp/__init__.py`: an empty file that makes `src/wikiapp` a package.
- file `justfile`: the recipes `help` and `setup`.
  show: `@{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}`
- file `.python-version`: the version of Python that uv installs, 3.13.
- file `uv.lock`: the exact packages, the same on every machine.
- file `README.md`: what the project is, and what you need to build it.
- file `.gitignore`: what git does not track, such as `.venv`.
- file `LICENSE`: the Apache License 2.0.

## step-01 A random page

$ just setup

The command prints a fixed line. It should ask Wikipedia for a random page and print it. We need two packages for
that, then the request, then a header that Wikipedia asks for, and last an option that prints the version.

### step-01.1 click and requests

The command needs two packages that Python does not have. click makes command lines, with options and help.
requests gets pages over HTTP. `uv add` puts both in the dependencies of wikiapp, and installs them in `.venv`. It
also chooses one version of each package that fits every range of versions, and writes the versions in the
lockfile, `uv.lock`. uv calls this choice resolving.

[click](https://click.palletsprojects.com/) comes from Pallets, who also make Flask. In click, the line `@click.command()` above a
function makes the function a command. Such a line is a decorator. Each option of the command becomes a parameter of
the function. [requests](https://requests.readthedocs.io/)
is a widely used library for HTTP. One call, `requests.get`, fetches a page.

do$ uv add click requests

::: watch
In `pyproject.toml`, the list `dependencies` was empty. Now it has `"click>=8.5.0",` and `"requests>=2.34.2",`,
each with the newest version as its lower bound. `uv.lock` has the exact version of each, and of every package
that they need.
:::

$ uv tree --depth 1

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

::: do
If your versions are newer, `uv add` writes them into `pyproject.toml` and `uv.lock`. Only those versions differ
from the ones here.
:::

files:
- diff `pyproject.toml`: the dependencies of the package, which anyone who installs it gets.
  show: `"click>=8.5.0",`
- diff `uv.lock`: the exact versions, for every platform.

### step-01.2 Ask Wikipedia for a page

`main` prints a fixed line. It must ask Wikipedia for a random page instead, and print the title and the summary.
The new `main` is the command of the first version of the original wikiapp, from 2024.

Its docstring, the text in triple quotes under `def main`, is new, and says what the command does. The `-> None`
after `main()` says that `main` returns no value. `uv init` wrote it, and this `main` keeps it. The `main` of the
original wikiapp did not have it.

- `@click.command()` makes `main` a command.
- `requests.get` asks the REST API of Wikipedia for the summary of a random page.
- `raise_for_status` raises an exception if the answer is an error.
- `response.json()` reads the answer as a dictionary.
- `click.secho` prints the title in green, and `textwrap.fill` wraps the summary to 70 columns.
- The last two lines call `main` when Python runs the file as a script. `uv run wikiapp` does not need them.

The patch writes `src/wikiapp/console.py` again.

patch$ src/wikiapp/console.py

::: do
Read the new `main` in the patch, from `@click.command()` down. The imports of click, requests and textwrap, and the
constant `API_URL`, are above it.
:::

::: watch
In `src/wikiapp/console.py`, the `print` is gone. The block `with requests.get(API_URL) as response:` asks
Wikipedia for the page, and the last two lines of the block print it.
:::

$ uv run wikiapp

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. A request carries headers, which are named lines of text sent with the
address. The header User-Agent names the program that sends the request. Wikipedia refuses a request whose
User-Agent is the default of a library. requests sends `python-requests/` and its version.

files:
- diff `src/wikiapp/console.py`: a request, and two lines printed.
  show: `with requests.get(API_URL) as response:`

### step-01.3 A User-Agent

Wikipedia refused the request, because its User-Agent named only the library requests, and not the program that
sent it. The policy of
Wikimedia asks for the name of the program, its version, and a way to reach the person who runs it. A constant
`USER_AGENT` gives these three things, and the request sends it as a header.

patch$ src/wikiapp/console.py

::: do
The patch adds `USER_AGENT` under the line `API_URL = ...`. It also changes the line of the request, so the request
sends the header.
:::

::: watch
In `src/wikiapp/console.py`, `USER_AGENT` is under `API_URL`. The request now passes it in
`headers={"User-Agent": USER_AGENT}`.
:::

$ uv run wikiapp

It prints a title in green, and a paragraph. Each run prints another page.

files:
- diff `src/wikiapp/console.py`: the header.
  show: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

### step-01.4 --version

A person who reports a bug must say which version they run, and the command cannot tell them. The package can read
its own version from the installed package, which has the version from `pyproject.toml`. So
`src/wikiapp/__init__.py` sets `__version__` from the metadata of the installed package. The decorator
`@click.version_option` gives the command the option `--version`, which prints it.

patch$ src/wikiapp/__init__.py

patch$ src/wikiapp/console.py

::: do
`src/wikiapp/__init__.py` was empty, and the patch gives it two lines. In `src/wikiapp/console.py`, the patch adds
`from wikiapp import __version__` under the line `import click`. It also adds `@click.version_option(...)` between
`@click.command()` and `def main`.
:::

::: watch
In `src/wikiapp/__init__.py`, `__version__` comes from `importlib.metadata`. In `src/wikiapp/console.py`,
`@click.version_option(version=__version__)` is under `@click.command()`.
:::

$ uv run wikiapp --version

$ uv run wikiapp --help

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring. So the docstring of `main` is also help text, for a person who runs the command.

files:
- diff `src/wikiapp/__init__.py`: the version, which Python reads when it imports the package.
  show: `__version__ = importlib.metadata.version(__name__ or __package__)`
- diff `src/wikiapp/console.py`: click's version option.
  show: `@click.version_option(version=__version__)`

## step-02 Tests, with mocks

$ just setup

We cannot tell whether `wikiapp` still works after a change, unless we run it by hand and read what it prints.
Tests run it for us. pytest finds the tests and runs them, and a recipe `just test` runs pytest.

The command asks the real Wikipedia, and a test cannot know which page comes back. So a mock takes the place of
`requests.get`, and returns a page that the tests know. Last, coverage shows which lines of the code the tests run.
One test still asks the real Wikipedia, so the tests need the network for now.

### step-02.1 uv installs every dependency group

The tests need pytest, but the package does not. A person who installs wikiapp should not get pytest. So the tools
of the project go in dependency groups. A dependency group is a list of packages in `pyproject.toml` that the
project needs while we work on it. A user of the package never gets them. The test tools go in a group `test`, and
later the linters and the docs tools get groups of their own.

uv installs only the group `dev` by default. The setting `default-groups = "all"` makes `uv sync` and `uv run`
install every group. So each later `uv add --group` needs no other change to `pyproject.toml`. A patch adds the
table `[tool.uv]` with this setting.

patch$ pyproject.toml

::: do
The change adds the table `[tool.uv]` to `pyproject.toml`. It has a comment and one setting.
:::

::: watch
At the end of `pyproject.toml`, the new table `[tool.uv]` has the line `default-groups = "all"`, with a comment
above it.
:::

The setting changes which groups uv installs, not which versions. So `uv.lock` still matches `pyproject.toml`.

$ uv lock --check

uv prints `Resolved 7 packages`, and no error. The project has no groups yet, so the setting changes nothing until a later move adds one.

files:
- diff `pyproject.toml`: the table `[tool.uv]`, so uv installs every dependency group.
  show: `default-groups = "all"`

### step-02.2 The first test

Nothing checks yet that the command works. The first test runs the command and checks that it ends with exit code
0. click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code of
the command.

This test is an end-to-end test. It runs the whole command, and the command asks the real Wikipedia. So a failure
can come from the code, from the network or from Wikipedia.

The test comes in a new file, `tests/test_console.py`, as a patch. The patch also makes the folder `tests`.

patch$ tests/test_console.py

::: do
Read the one test, `test_main_succeeds`, before you run it.
:::

::: watch
The new file `tests/test_console.py` has one test, `test_main_succeeds`. It runs `console.main` with a
`CliRunner`, and checks `result.exit_code`.
:::

pytest is not installed yet, so the test cannot run. `python -m pytest` uses the pytest of the project's `.venv`,
and never one from elsewhere.

$ uv run python -m pytest

The command fails on purpose. Python prints `No module named pytest`, and the exit code is 1. The next move installs pytest.

files:
- file `tests/test_console.py`: a test that runs the command and checks its exit code.
  show: `assert result.exit_code == 0`

### step-02.3 pytest, in the group test

The test needs pytest. `uv add --group test` writes pytest into a new group `test` of `pyproject.toml`, adds its
exact version to `uv.lock`, and installs it.

[pytest](https://docs.pytest.org/) is the test runner of most Python projects. It finds each function whose name
starts with `test_`, in the files whose names start with `test_`, and runs it. When an `assert` fails, it prints the
values on both sides.

do$ uv add --group test pytest

::: watch
At the end of `pyproject.toml`, the new table `[dependency-groups]` has the group `test`, with the line
`"pytest>=9.1.1",`. `uv.lock` has pytest 9.1.1, and iniconfig, packaging, pluggy and pygments, which pytest needs.
It also has colorama 0.4.6, which pytest needs on Windows.
:::

$ uv run pytest

pytest finds `tests/test_console.py`, and prints `collected 1 item` and `1 passed`. The test asks the real
Wikipedia, so it needs the network.

files:
- diff `pyproject.toml`: the group `test`, with pytest.
  show: `"pytest>=9.1.1",`
- diff `uv.lock`: pytest, and the packages that it needs.

### step-02.4 The recipe `just test`

The command that runs the tests is `uv run pytest`, with any options for pytest after it. A recipe `test` in the
justfile gives it a short name, `just test`. The words after `just test` go to pytest. `"$@"` stands for those
words, and the recipe gives each word to pytest whole. `just test help` shows the recipe.

patch$ justfile

::: do
The patch adds the recipe `test` at the end of the `justfile`, under the recipe `setup`, with a comment above it.
:::

::: watch
At the end of the `justfile`, the recipe `test *args:` runs `uv run pytest "$@"`, or shows itself for
`just test help`. The comment above it is what `just` lists for the recipe.
:::

`just` prints each line of a recipe before it runs the line, if the line does not start with `@`. So `just test`
prints `uv run pytest "$@"`, the command that it ran.

$ just --show test

$ just test

`just --show test` prints the comment and the recipe. `just test` prints `uv run pytest "$@"`, and then the same
result as before, `1 passed`.

files:
- diff `justfile`: the recipe `test`.
  show: `test *args:`

### step-02.5 The runner as a fixture

Each test of the command needs a `CliRunner`, and each would make its own. A fixture puts the code that makes it in one place.
A fixture is a function that pytest calls for each test that names it as a parameter. So a fixture `runner`
returns a `CliRunner`, and `test_main_succeeds` takes the runner as its parameter.

patch$ tests/test_console.py

::: do
The patch adds `import pytest` and the fixture `runner` above the line `from wikiapp import console`. It gives
`test_main_succeeds` the parameter `runner`, in place of its own `CliRunner`.
:::

::: watch
In `tests/test_console.py`, the fixture `runner` is above the test, under `@pytest.fixture`. The test now reads
`def test_main_succeeds(runner):`, and no longer makes a `CliRunner` itself.
:::

$ just test

The test passes as before, with `1 passed`. It still asks the real Wikipedia.

files:
- diff `tests/test_console.py`: the fixture, and the test that names it.
  show: `def test_main_succeeds(runner):`

### step-02.6 pytest-mock, in the group test

A test that needs the network fails on a train. Also, a test cannot check the title of a random page. A mock
solves both. pytest-mock replaces a function with a mock for the length of one test. Its fixture `mocker` does
this, and puts the function back after the test. pytest-mock goes in the group `test`.

[pytest-mock](https://pytest-mock.readthedocs.io/) is a plugin of pytest. Python's standard library already has
mocks, in `unittest.mock`. pytest-mock gives them to a test through a fixture, so each mock ends with its test.

do$ uv add --group test pytest-mock

::: watch
In `pyproject.toml`, the group `test` now has `"pytest-mock>=3.16.0",` under pytest. `uv.lock` has pytest-mock
3.16.0.
:::

$ just test

No test uses the mock yet, so the result is the same, `1 passed`.

files:
- diff `pyproject.toml`: pytest-mock in the group `test`.
  show: `"pytest-mock>=3.16.0",`
- diff `uv.lock`: the exact version of pytest-mock.

### step-02.7 A mock in place of Wikipedia

The mock now takes the place of `requests.get`. A new fixture, `mock_requests_get`, calls
`mocker.patch("requests.get")`. The line `mock.return_value.__enter__.return_value.json.return_value = {` sets
what the mock returns when the code calls `response.json()` inside the `with` block. The mock returns a page with
the title Lorem Ipsum.

A new test, `test_main_prints_title`, checks that the command prints that title.

A test that uses the mock is a unit test of the command. It checks the command alone, without the network, so a
failure points at the command. `test_main_succeeds` still asks the real Wikipedia.

patch$ tests/test_console.py

::: do
The patch adds the fixture `mock_requests_get` under the fixture `runner`. It adds `test_main_prints_title` above
`test_main_succeeds`.
:::

::: watch
In `tests/test_console.py`, the fixture `mock_requests_get` is under `runner`, with the line
`mock = mocker.patch("requests.get")`. The new test `test_main_prints_title` names both fixtures, and looks for
`"Lorem Ipsum"` in the output.
:::

$ just test -k title -v

pytest runs only the test whose name contains `title`. The output shows `test_main_prints_title PASSED` and
`1 passed, 1 deselected`, without the network.

files:
- diff `tests/test_console.py`: the fixture of the mock, and the new test.
  show: `mock = mocker.patch("requests.get")`

### step-02.8 Tests of the request

The test of the title shows what the command prints. It does not show that the command asks Wikipedia, or at
which address. A mock keeps a record of each call to it, and two tests read that record.
`test_main_invokes_requests_get` checks that the command calls `requests.get`, and `test_main_uses_correct_url`
checks the address.

`call_args[0]` contains the arguments that the last call gave in order, without a name. Here that is only the
address. The call gives the header by name, as `headers=...`, so the header is in `call_args[1]`.

patch$ tests/test_console.py

::: do
The patch adds the two tests after `test_main_prints_title`.
:::

::: watch
In `tests/test_console.py`, the two new tests are under `test_main_prints_title`. The first checks
`mock_requests_get.called`. The second compares `call_args[0]` with the address of a random English page.
:::

$ just test

The result is `4 passed`.

files:
- diff `tests/test_console.py`: two tests, that the command makes the request, and to the right address.
  show: `assert mock_requests_get.called`

### step-02.9 A test of a failed request

A request can fail, and nothing checks what the command does then. A mock can raise an exception as well as return
a value. If `side_effect` is an exception, a call to the mock raises it. A test,
`test_main_fails_on_request_error`, makes the mock raise, and checks that the command ends with exit code 1.

patch$ tests/test_console.py

::: do
The patch adds the test above `test_main_succeeds`.
:::

::: watch
In `tests/test_console.py`, the new test is above `test_main_succeeds`. Its first line,
`mock_requests_get.side_effect = Exception("Boom")`, makes the mock raise.
:::

$ just test

The result is `5 passed`.

files:
- diff `tests/test_console.py`: the mock raises.
  show: `mock_requests_get.side_effect = Exception("Boom")`

### step-02.10 pytest-cov, in the group test

The tests pass, but we do not know which lines of the code they run. pytest-cov measures that, when pytest gets the
option `--cov`. It goes in the group `test`.

[pytest-cov](https://pytest-cov.readthedocs.io/) is a plugin of pytest. It runs the tests under coverage.py, which
records each line that runs, and it prints the report at the end.

do$ uv add --group test pytest-cov

::: watch
In `pyproject.toml`, the group `test` has `"pytest-cov>=7.1.0",` between pytest and pytest-mock. `uv.lock` has
pytest-cov 7.1.0, and coverage 7.16.2, which it needs.
:::

$ just test --cov=wikiapp

Under the tests, a table lists each file of `src/wikiapp`, with its statements and the share of them that ran.
`console.py` has 18 statements. One of them did not run, so its line reads `94%`. The total is `95%`.

files:
- diff `pyproject.toml`: pytest-cov in the group `test`.
  show: `"pytest-cov>=7.1.0",`
- diff `uv.lock`: pytest-cov, and coverage, the package that it needs.

### step-02.11 Coverage on every run

A person can forget to type `--cov=wikiapp`. The settings of pytest in `pyproject.toml` give it options for
every run. They tell pytest to look for tests in `tests`, to measure coverage, and to list the lines that no test
ran.

patch$ pyproject.toml

::: do
The change adds the table `[tool.pytest.ini_options]` to `pyproject.toml`.
:::

::: watch
At the end of `pyproject.toml`, the new table `[tool.pytest.ini_options]` has `testpaths = ["tests"]`. Its line
`addopts` gives pytest the options `--cov=wikiapp --cov-report=term-missing` for every run.
:::

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented
out. No test used them, so the project does not keep them.

$ just test

The table under the tests now has a column `Missing`. `console.py` reads `94%`, and its missing line is 22. Line 22
is the call to `main` at the end, which runs only when you run the file as a script.

files:
- diff `pyproject.toml`: the settings of pytest. They name the folder of the tests, and turn coverage on for every run.
  show: `addopts = "--cov=wikiapp --cov-report=term-missing"`

## step-03 A library and an app

$ just setup

`main` asks Wikipedia for a page and prints it, all in one function. Other code cannot get a page without the
command line, and a test of the request must run the command. So the code that asks Wikipedia goes into a module of
its own, `wikipedia.py`. The module then gets a language, and an error of its own. The command, in `console.py`,
uses the module. So `wikipedia.py` is a library with no code for the command line, and `console.py` is the
app that uses it.

### step-03.1 random_page goes to wikipedia.py

The request is inside `main`, so only the command can ask Wikipedia for a page. A new module,
`src/wikiapp/wikipedia.py`, gets the address, the User-Agent and a function, `random_page`, which returns the page.
`random_page` returns the answer from inside the `with` block. The original wikiapp set `data` there, and returned it
after the block. The result is the same.

patch$ src/wikiapp/wikipedia.py

::: do
The patch makes the file `src/wikiapp/wikipedia.py`. Read its two constants, and `random_page`.
:::

::: watch
The new file `src/wikiapp/wikipedia.py` has the two constants, and `random_page`, which makes the request and
returns `response.json()`.
:::

The command keeps only what belongs to the command line, so it asks the library for the page.

patch$ src/wikiapp/console.py

::: do
The patch takes `import requests` and the two constants out of `src/wikiapp/console.py`. It imports
`random_page`, and `main` calls it in place of the request.
:::

::: watch
In `src/wikiapp/console.py`, `import requests` and the two constants are gone. `main` gets the page with
`data = random_page()`, and prints it as before.
:::

$ just test

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. `wikipedia.py` calls the function through the module, as `requests.get`, so it gets the mock.

files:
- file `src/wikiapp/wikipedia.py`: the code that talks to Wikipedia.
  show: `def random_page():`
- diff `src/wikiapp/console.py`: only the command stays.
  show: `data = random_page()`

### step-03.2 The mock goes to conftest.py

The tests of the library, which come next, need the mock too. Only the tests of `tests/test_console.py` can use
a fixture in that file. pytest reads `tests/conftest.py` before the tests, and every test file can use a fixture in it. So the
fixture `mock_requests_get` goes from `tests/test_console.py` to a new file, `tests/conftest.py`.

`main` calls `random_page`, and only `requests.get` is a mock. So a test of the command that uses the mock runs two
parts of the code together, the command and the library. A test of parts together is an integration test. Since
the library came out of `main`, the four tests of the command that use the mock are integration tests, and no
longer unit tests.

patch$ tests/conftest.py

patch$ tests/test_console.py

::: do
The first patch makes the file `tests/conftest.py`, with the fixture. The second deletes the fixture from
`tests/test_console.py`, from `@pytest.fixture` to `return mock`.
:::

::: watch
The new file `tests/conftest.py` has the fixture `mock_requests_get`. In `tests/test_console.py`, the fixture is
gone, and the tests still name it as a parameter.
:::

$ just test

The result is `5 passed`. pytest finds the fixture in `conftest.py`.

files:
- file `tests/conftest.py`: the fixture, for every test file.
  show: `def mock_requests_get(mocker):`
- diff `tests/test_console.py`: the fixture is gone, but the tests still name it.

### step-03.3 A language

`random_page` asks only the English Wikipedia. Each language has its own Wikipedia, at LANGUAGE.wikipedia.org. So
the address gets a placeholder for the language, and `random_page` fills it, with English as the default.

patch$ src/wikiapp/wikipedia.py

::: do
In `src/wikiapp/wikipedia.py`, the patch changes the line `API_URL = ...` and the first three lines of
`random_page`, from `def random_page():` to the line `with requests.get`.
:::

::: watch
In `src/wikiapp/wikipedia.py`, `API_URL` starts with `https://{language}.`. `random_page` takes `language="en"`,
and the request fills the placeholder with `API_URL.format(language=language)`.
:::

The first test of the library asks for a page in Spanish, and checks that the address of the request contains
`es.wikipedia.org`. It calls `random_page` alone, with the mock, so it is a unit test of the library.

patch$ tests/test_wikipedia.py

::: do
The patch makes the file `tests/test_wikipedia.py`, with one test.
:::

::: watch
The new file `tests/test_wikipedia.py` has one test. It calls `wikipedia.random_page(language="es")`, and reads
the address from `mock_requests_get.call_args`.
:::

$ just test

The result is `6 passed`.

files:
- diff `src/wikiapp/wikipedia.py`: the placeholder, and the code that fills it.
  show: `def random_page(language="en"):`
- file `tests/test_wikipedia.py`: the test uses the mock from `conftest.py`.
  show: `assert "es.wikipedia.org" in args[0]`

### step-03.4 wikiapp --language

The library takes a language, but a person who runs the command cannot choose one. A new option, `--language` or
`-l`, gives the language to `main`, and `main` passes it on to `random_page`. click gives the value of the option
to the parameter with the same name.

patch$ src/wikiapp/console.py

::: do
In `src/wikiapp/console.py`, the patch puts `@click.option(` and its six arguments between the line
`@click.command()` and the line `@click.version_option(version=__version__)`. It also changes the first three
lines of `main`, from `def main() -> None:` to `data = random_page()`.
:::

::: watch
In `src/wikiapp/console.py`, `@click.option(` and its six arguments are under `@click.command()`. `main` now takes
`language`, and calls `random_page(language=language)`.
:::

$ uv run wikiapp --language fr

$ uv run wikiapp --help

The first command prints a French page. `--help` lists the option, its short form and its default.

files:
- diff `src/wikiapp/console.py`: the option, which `main` gives to `random_page`.
  show: `data = random_page(language=language)`

### step-03.5 WikipediaError

If a request fails for any reason, requests raises a `RequestException`. Code that uses the library should not
need to know the exceptions of requests. So the library raises an exception of its own, `WikipediaError`. The
request goes in a `try` block, and a `RequestException` becomes a `WikipediaError`.

patch$ src/wikiapp/wikipedia.py

::: do
In `src/wikiapp/wikipedia.py`, the patch puts the class `WikipediaError` above `random_page`, and the request
inside a `try` block.
:::

::: watch
In `src/wikiapp/wikipedia.py`, the class `WikipediaError` is above `random_page`. The request is inside `try:`,
and the block `except requests.RequestException as error:` raises a `WikipediaError` in its place.
:::

`from error` keeps the original exception, so a traceback shows both exceptions.

$ uv run wikiapp --language xx

There is no Wikipedia in the language `xx`, so no server has the name `xx.wikipedia.org`. The command ends in a
traceback, and the last line is the `WikipediaError`. No code catches the error yet.

files:
- diff `src/wikiapp/wikipedia.py`: the exception, and the line that raises it.
  show: `raise WikipediaError(str(error)) from error`

### step-03.6 The command prints the error

A bad language ends the command in a traceback, which a person who runs it cannot use. `main` must print the error
as a message instead. `src/wikiapp/console.py` imports `WikipediaError` with `random_page`. `main` catches it, and
raises the exception of click, `click.ClickException`, in its place. click prints that exception as a message, and
ends with exit code 1.

In the original wikiapp, the library raised the exception of click itself, with a note to put it in the console
one day. Here the exception of click is in `console.py`. `wikipedia.py` imports requests, and only
`console.py` imports click.

patch$ src/wikiapp/console.py

::: do
In `src/wikiapp/console.py`, the patch adds `WikipediaError` to the line `from wikiapp.wikipedia import
random_page`. In `main`, it puts the line `data = random_page(language=language)` inside a `try` block.
:::

::: watch
In `src/wikiapp/console.py`, the import names `WikipediaError` too. In `main`, the call to `random_page` is in a
`try` block, and `except WikipediaError as error:` raises `click.ClickException(str(error))`.
:::

A test makes the mock raise a `RequestException`, and checks that the output contains `Error`. The test needs the
module `requests`, to name the exception.

patch$ tests/test_console.py

::: do
In `tests/test_console.py`, the patch adds `import requests` under the line `import pytest`. It adds the new test
before `test_main_succeeds`.
:::

::: watch
In `tests/test_console.py`, `import requests` is under `import pytest`. The new test
`test_main_prints_message_on_request_error` sets `mock_requests_get.side_effect = requests.RequestException`, and
looks for `"Error"` in the output.
:::

$ uv run wikiapp --language xx; echo "exit code $?"

$ just test

The first command prints `Error:` and the message in place of a traceback, then `exit code 1`. The tests give
`7 passed`.

files:
- diff `src/wikiapp/console.py`: the error becomes a message.
  show: `raise click.ClickException(str(error)) from error`
- diff `tests/test_console.py`: the test of the message.
  show: `assert "Error" in result.output`

## step-04 Format, lint, a hook

$ just setup

The tests check what the code does, and nothing checks how it is written. The code mixes styles, and a request can
wait for ever with no test to notice. A formatter writes every file in one style. A linter reads the code and
reports mistakes that the tests do not find. Each tool first shows what it would change, and then it makes the
change. Then a recipe checks the configuration, another runs every check, and a git hook runs them all before git
records a change.

The tests still need the network. `pre-commit` downloads its hooks from GitHub the first time it runs.

### step-04.1 ruff, in the group lint

The code has no one style, so a later change can mix a fix with a change of blank lines and quotes. A formatter
changes how the code looks, and never what it does. A linter finds problems in the code, such as a variable that
is never used, and changes nothing unless it is asked to. ruff is both, in one program. It goes in a second group
of dependencies, `lint`, next to the group `test`.

[ruff](https://docs.astral.sh/ruff/) comes from Astral, as uv does, and is written in Rust. It does the work of
older tools, such as Black for the format, and flake8 and isort for the lint, much faster.

do$ uv add --group lint ruff

::: watch
In `pyproject.toml`, the new group `lint` starts at line 27, above `test`, with the line `"ruff>=0.17.0",`.
`uv.lock` has the exact version of ruff.
:::

$ uv run ruff --version

It prints `ruff 0.17.0`, or a newer version. uv installs every group, so ruff is in the environment of the project, and nothing has
used it yet.

files:
- diff `pyproject.toml`: the group `lint`, with ruff in it.
  show: `"ruff>=0.17.0",`
- diff `uv.lock`: the exact version of ruff.

### step-04.2 The settings of ruff, and the recipe fmt

ruff needs its settings, in `pyproject.toml`. They allow lines of up to 100 characters, and write out
the defaults of the formatter, so that a reader sees them. A recipe `fmt` runs the formatter. The words after
`just fmt` go to `ruff format`.

patch$ pyproject.toml

patch$ justfile

::: do
In `pyproject.toml`, the change adds the tables `[tool.ruff]` and `[tool.ruff.format]`. In the `justfile`, it
adds the recipe `fmt` at the end.
:::

::: watch
At the end of `pyproject.toml`, the table `[tool.ruff]` on line 41 sets `line-length = 100`. The table
`[tool.ruff.format]` on line 46 gives the three defaults of the formatter, each with a comment. At the end of the
`justfile`, the recipe `fmt *args:` on line 32 runs `uv run ruff format`, with the words after `just fmt`.
:::

$ uv run ruff format --check

$ just --show fmt

$ just fmt --check

`--check` changes nothing. It shows what it would change in each file, and fails. It ends with `6 files would be
reformatted, 1 file already formatted`. It names the six files that it would
change. The recipe
runs the same command, and passes on the words after `just fmt`.

files:
- diff `pyproject.toml`: the settings of ruff.
  show: `line-length = 100`
- diff `justfile`: the recipe `fmt`.
  show: `fmt *args:`

### step-04.3 The code, formatted

`just fmt --check` found six files that do not follow the style. The formatter rewrites them. It adds blank lines,
puts spaces around `==`, and splits the lines longer than 100 characters.

do$ just fmt

::: watch
In `src/wikiapp/console.py`, two blank lines now come before `@click.command()` on line 8, and before
`if __name__ == "__main__":` on line 30. In `src/wikiapp/wikipedia.py`, the request was one line of more than 100
characters, and is now lines 14 to 16. In `tests/test_console.py`, two blank lines come around each function. The
long address in the test of the address is on line 27, a line of its own.
:::

$ just fmt --check

$ just test

The check prints `7 files already formatted`, and the tests pass as before, `7 passed`. One test asks the real Wikipedia, so the tests still need the network.

files:
- diff `src/wikiapp/console.py`: blank lines, and spaces around `==`.
  show: `if __name__ == "__main__":`
- diff `src/wikiapp/wikipedia.py`: blank lines, and the long request split into three lines.
  show: `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- diff `tests/test_console.py`: blank lines, and the long address split.
  show: `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`
- diff `src/wikiapp/__init__.py`: a blank line after the import.
- diff `tests/conftest.py`: two blank lines before the fixture.
- diff `tests/test_wikipedia.py`: two blank lines before the test.

### step-04.4 The linter's rules, and the recipe lint

The linter checks the code against rules, and it needs to know which. A table in `pyproject.toml`
chooses the families of rules. Each family is on a line of its own, with a comment that says why it is on. The
tests may use `assert`. The rest of the code may not, because Python skips every `assert` when it runs with `-O`.

A recipe `lint` runs the linter. The words after `just lint` go to `ruff check`.

patch$ pyproject.toml

patch$ justfile

::: do
In `pyproject.toml`, the change adds the tables `[tool.ruff.lint]` and `[tool.ruff.lint.per-file-ignores]`.
Read the comment beside each family of rules. In the `justfile`, it adds the recipe `lint` at the end.
:::

::: watch
At the end of `pyproject.toml`, `select = [` on line 54 lists nine families of rules. The last table lets the files
under `tests/` break the rule `S101`, which forbids `assert`, on line 68. At the end of the `justfile`, the recipe
`lint *args:` on line 38 runs `uv run ruff check`, with the words after `just lint`.
:::

$ uv run ruff check --statistics

$ just --show lint

$ just lint --statistics

The linter finds five problems, and fails. Each problem has its code.

- `I001`: the imports of `src/wikiapp/console.py` are out of order.
- `E402`: an import in `tests/test_console.py` comes below code.
- `F841`, twice: a variable is assigned and never used.
- `S113`: a request has no timeout.

A `[*]` marks the one problem that ruff can fix by itself, `I001`. ruff also has a fix for the two unused variables, and marks it unsafe,
because it may delete a comment on the line. It has no fix for the other two problems. So a person fixes those four
in the next two moves, and then ruff fixes the last one.

files:
- diff `pyproject.toml`: a family of rules on each line.
  show: `"tests/**" = ["S101"]`
- diff `justfile`: the recipe `lint`.
  show: `lint *args:`

### step-04.5 The tests' imports at the top, and no unused variables

Three of the five problems are in `tests/test_console.py`. The import of `console` comes below the fixture, where a
reader does not look for it. Two tests assign `result` and never read it. ruff has no fix for the import below the
code, and its fix for the unused variables is unsafe. So a person makes these fixes.

The import goes up, under `import requests`. wikiapp's own imports are a block of their own, after the installed
packages, which is the order that the rule `I001` asks for. The tests `test_main_invokes_requests_get` and
`test_main_uses_correct_url` check the mock, and not the result, so they need no `result =`.

patch$ tests/test_console.py

::: do
In `tests/test_console.py`, the patch moves `from wikiapp import console` up, under `import requests`, after a
blank line. In the two tests, it takes `result =` off the line `result = runner.invoke(console.main)`.
:::

::: watch
In `tests/test_console.py`, `from wikiapp import console` is now on line 5, under `import requests`, after a blank
line. It is gone from below the fixture. The first line of each of the two tests, lines 19 and 24, is now
`runner.invoke(console.main)` alone.
:::

$ just lint --statistics

$ just fmt --check

Two problems are left, `S113` and `I001`, and the linter still fails. The format is unchanged, and the check prints
`7 files already formatted`.

files:
- diff `tests/test_console.py`: the import goes up, and two lines lose `result =`.
  show: `from wikiapp import console`

### step-04.6 A timeout

Of the two problems left, `S113` comes from the family `S` of security rules. The request has no timeout, so
requests waits as long as the server keeps the connection open, and the command can wait for ever. No test had
found it. The request in `src/wikiapp/wikipedia.py` gets `timeout=10`, a number of seconds that the author of the project chose.

patch$ src/wikiapp/wikipedia.py

::: do
In `src/wikiapp/wikipedia.py`, the patch adds `timeout=10` at the end of the arguments of `requests.get(...)`.
:::

::: watch
In `src/wikiapp/wikipedia.py`, the arguments of `requests.get` on line 15 now end with `timeout=10`.
:::

If the server does not answer within 10 seconds, the request now raises an exception. `random_page` turns it
into a WikipediaError, as it does with every other error of requests.

$ just lint --statistics

One problem is left, `I001`, so the linter still fails. Its `[*]` says that ruff can fix it.

files:
- diff `src/wikiapp/wikipedia.py`: one more argument.
  show: `timeout=10`

### step-04.7 The linter sorts the imports

The last problem is the order of the imports of `src/wikiapp/console.py`. ruff can fix it safely, and `--fix`
makes only the fixes that ruff counts as safe. It puts the imports in three blocks. The standard library comes
first, then the packages installed, and then wikiapp's own.

do$ just lint --fix

::: watch
At the top of `src/wikiapp/console.py`, `import textwrap` is on line 1, `import click` on line 3, and
`from wikiapp import __version__` on line 5. A blank line comes between the blocks.
:::

$ just lint

`just lint --fix` reported `Found 1 error (1 fixed, 0 remaining).`, and exited with 0. Now `just lint` prints `All checks passed!`.

files:
- diff `src/wikiapp/console.py`: the imports, sorted.
  show: `from wikiapp import __version__`

### step-04.8 validate-pyproject, in the group lint

The tests and the linter check the code, and not the configuration. So an error in `pyproject.toml`, in the
lockfile or in the `justfile` passes them all. validate-pyproject checks `pyproject.toml` against the standard for
it. It goes in the group `lint`.

[validate-pyproject](https://validate-pyproject.readthedocs.io/) checks `pyproject.toml` against JSON schemas of
the standards that define the file.

do$ uv add --group lint validate-pyproject

::: watch
In `pyproject.toml`, the group `lint` now has `"validate-pyproject>=0.26",` on line 29, under ruff. `uv.lock` has
its exact version, and that of `fastjsonschema`, which it needs.
:::

$ uv run validate-pyproject --version

It prints `validate_pyproject 0.26`. Nothing runs it yet.

files:
- diff `pyproject.toml`: one package more in `lint`.
  show: `"validate-pyproject>=0.26",`
- diff `uv.lock`: the exact version of validate-pyproject, and of what it needs.

### step-04.9 The recipe lint-config

A recipe `lint-config` checks the configuration, with three commands. validate-pyproject checks
`pyproject.toml`. `uv lock --check` checks that the lockfile matches `pyproject.toml`. `just --fmt --check
--unstable` checks the `justfile`. The recipe runs the three commands, one on each line, and `set -e` stops it at
the first that fails.

patch$ justfile

::: do
The patch adds the recipe `lint-config` at the end of the `justfile`.
:::

::: watch
At the end of the `justfile`, the recipe `lint-config *args:` on line 44 runs the three commands, one on each line.
`set -e`, on line 46, stops it at the first that fails.
:::

$ uv run validate-pyproject pyproject.toml

$ uv lock --check

$ just --fmt --check --unstable

$ just --show lint-config

$ just lint-config

The three checks pass. validate-pyproject prints `Valid file: pyproject.toml`. `uv lock --check` prints
`Resolved 19 packages` and exits with 0, because the lockfile matches `pyproject.toml`. `just --fmt` prints
nothing, because the `justfile` is in the format of `just`.

files:
- diff `justfile`: the recipe, with its three checks.
  show: `uv run validate-pyproject pyproject.toml`

### step-04.10 Recipes refuse an old lockfile

When `pyproject.toml` changes and the lockfile does not, `uv run` writes a new lockfile and prints no warning. So
any recipe can change the lockfile, and the person who runs it does not see the change. The variable `UV_LOCKED`
makes every `uv run` refuse a lockfile that is out of date. The `justfile` exports it to every recipe.

patch$ justfile

::: do
In the `justfile`, the patch adds `export UV_LOCKED := "1"` under the line `set positional-arguments`, after a
blank line.
:::

::: watch
Near the top of the `justfile`, `export UV_LOCKED := "1"` is on line 6, under `set positional-arguments`.
:::

$ just --evaluate UV_LOCKED

It prints `1`. `just` puts the variable in the environment of every command of every recipe, so each `uv run`
sees it.

files:
- diff `justfile`: one line, which exports `UV_LOCKED` to every recipe.
  show: `export UV_LOCKED := "1"`

### step-04.11 The recipe check

There are now four checks, and a person must remember to run each. A recipe `check` runs them all in order, and
stops at the first that fails. The order is the format, the linter, the tests with a floor on the coverage, and
the configuration.

patch$ justfile

::: do
The patch adds the recipe `check` at the end of the `justfile`.
:::

::: watch
At the end of the `justfile`, the recipe `check *args:` on line 57 runs four recipes. The tests run with
`--cov-fail-under=90`, on line 63, so they fail if they run less than 90% of the statements.
:::

$ just --show check

$ just check

`just check` passes. The tests must run at least 90% of the statements, and the coverage is 96.77%.

files:
- diff `justfile`: the recipe, with its four checks.
  show: `just test -q --cov-fail-under=90`

### step-04.12 `pre-commit`, in the group lint

`just check` runs every check, but a person must remember to run it. A `pre-commit` hook is a program that git runs
before it records a change. If the program fails, git does not record the change. `pre-commit` installs such a hook, and
runs the checks that the file `.pre-commit-config.yaml` names. It goes in the group `lint`.

[pre-commit](https://pre-commit.com/) manages git hooks. A file lists the hooks, and `pre-commit` installs each in
an environment of its own, and runs them on the files of a change.

do$ uv add --group lint pre-commit

::: watch
In `pyproject.toml`, the group `lint` now starts with `"pre-commit>=4.7.0",`, on line 28. `uv.lock` has its exact
version, and those of the nine packages that it needs, such as `pyyaml` and `virtualenv`.
:::

$ uv run pre-commit --version

It prints `pre-commit 4.7.0`, or a newer version. No hook is installed yet.

files:
- diff `pyproject.toml`: `pre-commit` in the group `lint`.
  show: `"pre-commit>=4.7.0",`
- diff `uv.lock`: the exact version of `pre-commit`, and of what it needs.

### step-04.13 A git hook

`pre-commit` reads the hooks from a file, `.pre-commit-config.yaml`. Three come from `pre-commit`'s collection.
They check for valid YAML, large files and leftover merge-conflict markers. The last hook runs `just check`, so the
hook and the terminal run the same thing.

A recipe `hook` installs the hook, once in each clone. `hook` is a recipe of its own, because `just setup` runs
often and must not change files under `.git`. Once `just hook` installs the hook in a clone, it runs
`just check` before each `git commit` in that clone.

patch$ .pre-commit-config.yaml

patch$ justfile

::: do
The patch makes the file `.pre-commit-config.yaml`. Read the hook under `repo: local`, which runs `just check`. In
the `justfile`, the patch adds the recipe `hook` after the recipe `setup`.
:::

::: watch
In `.pre-commit-config.yaml`, the three hooks under `repo: https://github.com/pre-commit/pre-commit-hooks`, on
line 6, come from `pre-commit`'s collection. The hook under `repo: local` has the line `entry: just check`, on
line 17. In the `justfile`, the recipe `hook *args:` on line 27 comes after `setup`, in the group `setup`. It runs
`uv run pre-commit install`.
:::

$ uv run pre-commit install

$ just --show hook

$ just hook

$ uv run pre-commit run --files .pre-commit-config.yaml

`uv run pre-commit install` prints `pre-commit installed at .git/hooks/pre-commit`, and `just hook` prints the
same line. The hook is in `.git/hooks`, a folder that git does not track, so it stays installed for the rest of
the tutorial.

`pre-commit run` now runs every hook on the file named, as git does before it records a change. The first time on
a machine, it prints `[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

files:
- file `.pre-commit-config.yaml`: three hooks from `pre-commit`'s collection, then `just check`.
  show: `entry: just check`
- diff `justfile`: the recipe `hook`.
  show: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`

## step-05 Types

$ just setup

The tests run the code with the values that they choose, and Python checks no type before it runs a line. A call
with the wrong kind of value fails only when it runs. A type checker reads the code without running it, and finds
such calls. We add one, and fix the one problem that it finds. Then we write a type on every parameter and return,
so that it has something to check.

### step-05.1 ty, in the group lint

Nothing checks the types of the code yet. ty is a type checker. It reads the code without running it, and finds
calls whose arguments cannot have the types that the function asks for.
`uv add` puts ty in the group `lint`, with the other tools that check the code.

[ty](https://docs.astral.sh/ty/) is Astral's type checker, written in Rust, like uv and ruff. It is new, and does
the work of older checkers such as mypy and pyright.

do$ uv add --group lint ty

::: watch
In `pyproject.toml`, the group `lint` now has the line `"ty>=0.0.87",`, on line 30. `uv.lock` has the exact
version of ty.
:::

$ uv run ty --version

It prints `ty 0.0.87 (ea4c3d273 2026-10-13)`, or a newer version. Nothing runs it yet.

files:
- diff `pyproject.toml`: ty in the group `lint`.
  show: `"ty>=0.0.87",`
- diff `uv.lock`: the exact version of ty.

### step-05.2 The recipe types

A recipe `types` runs ty, as every other tool of the project runs through `just`. It goes after the recipe `lint`
in the `justfile`.

patch$ justfile

::: do
The patch puts the recipe `types` after the recipe `lint` and the blank line under it. Read its comment, which
`just` lists for the recipe.
:::

::: watch
In the `justfile`, the recipe `types *args:` on line 51 comes after `lint`. It runs `uv run ty check`, and passes
on any arguments.
:::

$ uv run ty check

$ just --show types

$ just types

ty finds one problem, in `src/wikiapp/__init__.py`, and ends with `Found 1 diagnostic`. The message is
``Expected `str`, found `str | None` ``. As far as ty can tell, `__name__ or __package__` could be None. But
`importlib.metadata.version` needs a string.

files:
- diff `justfile`: the recipe.
  show: `types *args:`

### step-05.3 The version of "wikiapp", by name

The name of the installed package is `wikiapp`, from `pyproject.toml`. The string `"wikiapp"` is never None, so
it can replace `__name__ or __package__`.

patch$ src/wikiapp/__init__.py

::: do
The patch changes the last line of `src/wikiapp/__init__.py`. It gives `importlib.metadata.version` the name
`"wikiapp"`.
:::

::: watch
In `src/wikiapp/__init__.py`, the last line now gives `importlib.metadata.version` the string `"wikiapp"`.
:::

$ just types

ty prints `All checks passed!`.

files:
- diff `src/wikiapp/__init__.py`: a string that is never None.
  show: `__version__ = importlib.metadata.version("wikiapp")`

### step-05.4 A type on every parameter and return

ty checks the types that the code states, and the code states almost none. ruff's rules `ANN` report each
parameter and each return without a type. So the linter checks that a type is written, and the type checker
checks that the type is right. The rules go in the list `select` in `pyproject.toml`.

patch$ pyproject.toml

::: do
The patch adds the line `"ANN"` to the list `select`, after the line with `"N"`.
:::

::: watch
In `pyproject.toml`, the list `select` now has `"ANN"` on line 67, after `"N"`.
:::

$ just lint --statistics

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). The next two moves add them, in the code and then in the tests.

files:
- diff `pyproject.toml`: one line.
  show: `"ANN", # annotations: every parameter and every return value has a type`

### step-05.5 Types in the code

The linter asks for types in `src/wikiapp/wikipedia.py` and `src/wikiapp/console.py`. `random_page` takes a
string. It returns the JSON that Wikipedia sends, which is a dictionary from strings to values of any kind. `Any`
says that ty cannot check the values. `Any` comes from the standard library, so its import is a block of its own,
above `import requests`.

patch$ src/wikiapp/wikipedia.py

::: do
The patch adds `from typing import Any` and a blank line above `import requests`. It also gives the line
`def random_page(language="en"):` its types.
:::

`main` takes the language as a string. Its return type, None, was already there.

patch$ src/wikiapp/console.py

::: do
The patch changes one line of `src/wikiapp/console.py`, the `def` line of `main`.
:::

::: watch
In `src/wikiapp/wikipedia.py`, line 1 imports `Any`. On line 13, `random_page` now takes a `str`, and returns a
`dict[str, Any]`. In `src/wikiapp/console.py`, on line 19, the parameter `language` of `main` is a `str`.
:::

$ just lint --statistics

22 problems are left, 13 parameters and 9 returns. The next move gives the tests their types.

files:
- diff `src/wikiapp/wikipedia.py`: the parameter and the return.
  show: `def random_page(language: str = "en") -> dict[str, Any]:`
- diff `src/wikiapp/console.py`: the parameter.
  show: `def main(language: str) -> None:`

### step-05.6 Types in the tests

The code has its types, and `just lint` still finds 22 missing in the tests. A test returns None. The return type
of a fixture is the type of what a test receives.

The mock of `requests.get` is a `Mock`. `mocker` is
pytest-mock's `MockerFixture`. The original wikiapp used its older name, `MockFixture`. So
`tests/conftest.py` imports `Mock` and `MockerFixture`, and its fixture states both types.

patch$ tests/conftest.py

::: do
The patch puts `from unittest.mock import Mock` at the top of `tests/conftest.py`, and
`from pytest_mock import MockerFixture` under `import pytest`. It also gives the `def` line of the fixture its types.
:::

::: watch
In `tests/conftest.py`, the fixture on line 8 now reads `def mock_requests_get(mocker: MockerFixture) -> Mock:`.
`Mock` comes from `unittest.mock`, and `MockerFixture` from `pytest_mock`, in the imports above it.
:::

The tests of the command need the same types. `tests/test_console.py` imports `Mock` and `CliRunner` by name,
in place of `import click.testing`. The fixture `runner` returns `CliRunner()`, so its return type is
`CliRunner`. In every test, `runner` is a `CliRunner`, `mock_requests_get` is a `Mock`, and the test returns
`None`.

patch$ tests/test_console.py

::: do
The patch changes the imports at the top of `tests/test_console.py`, and the `def` line of the fixture and of every test.
The bodies stay as they were, apart from `CliRunner()` in the fixture.
:::

::: watch
In `tests/test_console.py`, `from click.testing import CliRunner` on line 5 replaces `import click.testing`. The
fixture on line 11 reads `def runner() -> CliRunner:`, and each test names the types of its parameters and
returns `None`.
:::

The test of the library gets its types the same way.

patch$ tests/test_wikipedia.py

::: do
The patch adds `from unittest.mock import Mock` and a blank line at the top of `tests/test_wikipedia.py`, and gives
the `def` line of its test the types.
:::

::: watch
In `tests/test_wikipedia.py`, `Mock` comes in on line 1, and the test on line 6 states its types.
:::

$ just lint

$ just types

Both commands print `All checks passed!`.

$ just check

`just check` passes. pytest prints `7 passed`, and a coverage of 96.88%, above the floor of 90%.

files:
- diff `tests/conftest.py`: the fixture returns a Mock.
  show: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- diff `tests/test_console.py`: the runner is a CliRunner, and every test has its types.
  show: `def runner() -> CliRunner:`
- diff `tests/test_wikipedia.py`: the import of `Mock`, and the types of one test.
  show: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

### step-05.7 The recipe check runs the type checker

`just check` is what a person and the git hook run before git records a change, and it does not run ty yet. So a
change can break a type, and pass. The recipe `check` now runs `just types` after `just lint`, and its comment
names the types too.

patch$ justfile

::: do
The patch changes the comment above the recipe `check`, and puts `just types` under `just lint` in it.
:::

::: watch
In the `justfile`, the recipe `check` now runs `just types` on line 74, after `just lint`. Its comment, on line 65,
lists "types".
:::

$ just check

Every check passes, the type check among them. The coverage is 96.88%.

files:
- diff `justfile`: the comment, and one line in check.
  show: `just types`

## step-06 End to end, and CI

$ just setup

One test asks the real Wikipedia, so the tests fail without a network, and can fail when Wikipedia changes. We
run such tests only on request. Then the project accepts every version of Python from 3.11 on. GitHub
then runs the tests on three systems and four versions of Python after each push.

### step-06.1 The end-to-end test runs only on request

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. The other tests use the mock in place of Wikipedia, so they run without the network, and give
the same result on every run. A marker, `e2e`, which means end to end, sets the one test apart. Its new name says
so, `test_main_succeeds_in_production`.

patch$ tests/test_console.py

::: do
The patch puts the marker `@pytest.mark.e2e` above the last test of `tests/test_console.py`, and gives the test its
new name.
:::

::: watch
In `tests/test_console.py`, the last test has the marker `@pytest.mark.e2e`, and its new name.
:::

pytest must know the marker, and leave the e2e tests out of every run that does not ask for them.
`pyproject.toml` declares the marker in `markers`. The option `-m 'not e2e'` in `addopts` leaves the e2e tests out.

patch$ pyproject.toml

::: do
The change is in `[tool.pytest.ini_options]`. It replaces the comment and the line `addopts`,
and adds the line `markers`.
:::

::: watch
In `pyproject.toml`, `addopts` now ends with `-m 'not e2e'`, and the new line `markers` declares `e2e`.
:::

$ just test -q

$ just test -q -m e2e

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

files:
- diff `tests/test_console.py`: the test, marked.
  show: `@pytest.mark.e2e`
- diff `pyproject.toml`: the option `-m 'not e2e'`, and the marker `e2e` in `markers`, with a comment.
  show: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

### step-06.2 An end-to-end test of the library

The mocks return a dictionary with a title and an extract. If the real Wikipedia stops sending those two keys,
every test with a mock still passes, and the command fails. A second e2e test, from the original wikiapp, asks the
real Wikipedia for a page and checks the two keys. It is also a contract test. It checks that the real Wikipedia
still returns what the mocks return.

patch$ tests/test_wikipedia.py

::: do
The patch puts `import pytest` in a block of its own, between the import of `Mock` and the import of `wikipedia`.
It adds the new test at the end of the file.
:::

::: watch
At the end of `tests/test_wikipedia.py`, `test_random_page_returns_dictionary_in_production` has the marker
`e2e`. It checks that the page has `"title"` and `"extract"`. `import pytest` is in a block of its own.
:::

$ just test -q -m e2e

The output is `2 passed, 6 deselected`.

files:
- diff `tests/test_wikipedia.py`: the test.
  show: `assert "extract" in page`

### step-06.3 Any Python from 3.11 on

The project asks for Python 3.13, and nothing in it needs more than 3.11. `uv init` wrote
`requires-python = ">=3.13"`, because the command that made the project asked for Python 3.13. Python 3.10 reached
its end of life on 1 October 2026, so 3.11 is now the oldest Python that still gets security fixes. The line in
`pyproject.toml` now says 3.11.

patch$ pyproject.toml

::: do
The patch changes one line of `pyproject.toml`, line 9, `requires-python`.
:::

::: watch
In `pyproject.toml`, line 9 now says `requires-python = ">=3.11"`.
:::

The lockfile, `uv.lock`, was resolved for Python 3.13 and newer. It no longer matches `pyproject.toml`, and this
move leaves it so on purpose. Line 6 of the `justfile` sets `UV_LOCKED` to 1 for every recipe, so uv refuses a
lockfile that does not match, until the next move resolves the lockfile again.

$ uv lock --check

$ just test -q

`uv lock --check` prints `Resolved 31 packages`, and then an error. The lockfile `uv.lock` "needs to be
updated". Its hint is to run `uv lock`, and it exits with 1. `just test -q` stops with the same error, and runs
no test. Its error names `UV_LOCKED=1` where the first error named `--check`.

files:
- diff `pyproject.toml`: one line.
  show: `requires-python = ">=3.11"`

### step-06.4 The lockfile, for every Python from 3.11 on

The lockfile must match `pyproject.toml` again. `uv lock` resolves it for every version of Python from 3.11 on. It writes only
`uv.lock`.

do$ uv lock

::: do
`uv lock` prints `Resolved 31 packages` and `Added tomli v2.5.0`.
:::

::: watch
In `uv.lock`, line 3 now says `requires-python = ">=3.11"`. A wheel is a built package, the file that pip and uv
install. charset-normalizer, coverage and pyyaml contain compiled code, so they have one wheel for each version of
Python on each system. Each now lists its wheels for Python 3.11 and 3.12 too. Most of the new lines of `uv.lock`
are these wheels, and the entry of tomli.

An extra is a named set of optional dependencies of a package. pytest-cov now asks for coverage with its extra
`toml`, at line 443. That extra needs tomli, a new package from line 572.

A marker is a condition on where a package is installed, for example on the version of Python or on the system.
At line 427, colorama has the marker `sys_platform == 'win32'`, so uv installs it only on Windows. At line 304,
tomli has the marker `python_full_version <= '3.11'`, where `'3.11'` means 3.11.0. So uv writes tomli into the
lockfile, but installs it on none of the versions of Python that the project tests.
:::

The project still runs on 3.13, from `.python-version`. uv can also run the tests on 3.11.

$ uv lock --check

$ just test -q

$ uv run --isolated --python 3.11 python --version

$ uv run --isolated --python 3.11 pytest -q

`uv lock --check` prints only `Resolved 31 packages`, and `just test -q` prints `6 passed, 2 deselected` again.
`--python 3.11` chooses the version of Python. `--isolated` makes the environment temporary, so `.venv` does not
change. The third command prints
`Python 3.11.12`, and the tests print `6 passed, 2 deselected` on 3.11 too.

files:
- diff `uv.lock`: resolved for every version of Python from 3.11 on.

### step-06.5 GitHub runs the tests

The tests run only on the machine of the person who runs them, on one system and one version of Python. GitHub can run them
on its own machines after each push.

[GitHub Actions](https://docs.github.com/en/actions) is GitHub's service that runs jobs, such as tests, on GitHub's
machines. It is free for a public repository.

A GitHub Actions workflow is a file in `.github/workflows/`. GitHub runs its jobs on the events that its `on:`
names. The workflow `.github/workflows/test.yaml` names every push to main and every pull request, and has two
jobs. The job `tests` runs the tests on three systems and four versions of Python. The job `check` runs `just check` once.

Both jobs run pytest with the options in `pyproject.toml`, so they leave out the e2e tests. GitHub never runs the
e2e tests. A person runs them, with `just test -m e2e`.

patch$ .github/workflows/test.yaml

::: do
The patch makes the folder `.github/workflows`, and the whole file in it. Read the comment at its top, and the
matrix of the job `tests`.
:::

::: watch
The new file `.github/workflows/test.yaml` has the jobs `tests` and `check`. In `tests`, the matrix of three
values of `os` and four of `python` makes twelve jobs.
:::

The original wikiapp used pixi for the same work, with one environment for each version of Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

$ uv run pre-commit run check-yaml --files .github/workflows/test.yaml

The file is valid YAML. GitHub runs the workflow after a push. The **Actions** tab of the repository shows the
thirteen jobs. In a fork, GitHub runs no workflow until the owner turns the workflows on, on that tab. A later
part of the tutorial publishes the docs with GitHub Pages, and lists each setting that a fork needs.

files:
- file `.github/workflows/test.yaml`: the matrix of systems and versions of Python.
  show: `python: ["3.11", "3.12", "3.13", "3.14"]`

## step-07 A page with a shape

$ just setup

`random_page` returns the dictionary that Wikipedia sends, and the code uses its title and its extract.
Nothing checks that the dictionary has them. We give a page a shape, with a pydantic model. `random_page` returns a page of that shape, and an
answer that is not a page becomes an error like any other. Last, the code checks that the language is a language
code before it puts it into the address.

### step-07.1 pydantic

The command uses two of the many keys that Wikipedia sends. The code expects them to be there, with strings as
values, but nothing checks it. pydantic is a library that checks data against a model, and a model states the two
keys and their types in code. pydantic is a dependency of the package, as click and requests are, so `uv add` puts
it in `dependencies`.

[pydantic](https://docs.pydantic.dev/) is a widely used Python library. When the code makes a page from the data,
pydantic checks each value against the type that the model gives it. A value that does not fit raises an error.

do$ uv add pydantic

::: do
`uv add` installs pydantic and the four packages that it needs, among them pydantic-core and annotated-types. If a newer pydantic is out, `uv add` writes its version as the lower bound. That line then
differs from the one here, and so does `uv.lock`. `git diff` shows those two files, and only the versions in
them differ.
:::

::: watch
In `pyproject.toml`, the list `dependencies` now has `"pydantic>=2.14.1",` at line 12, between click and
requests. `uv.lock` has the exact version of pydantic, and of the four packages that it needs.
:::

$ uv run python -c "import pydantic; print(pydantic.VERSION)"

$ just test -q

The first command prints `2.14.1`. The tests print `6 passed, 2 deselected`, as before, because no code uses
pydantic yet.

files:
- diff `pyproject.toml`: pydantic, a dependency of the package.
  show: `"pydantic>=2.14.1",`
- diff `uv.lock`: the exact version of pydantic, and of what it needs.

### step-07.2 The model Page

The model `Page` is a class that inherits from pydantic's `BaseModel`. It has a title and an extract, both strings,
the two keys that the command uses. A `Page` made from a dictionary checks the two keys, and keeps only them.
Nothing uses `Page` yet.

patch$ src/wikiapp/wikipedia.py

::: do
The patch adds the import of `BaseModel` under the line `import requests`. It puts the class `Page` after the class
`WikipediaError`.
:::

::: watch
In `src/wikiapp/wikipedia.py`, the import of `BaseModel` is line 4, under `import requests`. The class `Page` is
lines 14 to 18, after `WikipediaError`, with its docstring and the two fields `title` and `extract`.
:::

$ uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"

$ uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails with
`1 validation error for Page`, and names the field `extract` with `Field required`.

files:
- diff `src/wikiapp/wikipedia.py`: the model.
  show: `class Page(BaseModel):`

### step-07.3 random_page returns a Page

The model exists, but `random_page` still returns the dictionary, and `main` still reads its keys. A misspelled key
of a dictionary shows up only when the program runs. The attributes of a `Page` have names that ty and an editor
know. So `random_page` returns a `Page` made from the answer, and `main` prints its attributes.

`random_page` passes the answer to `Page.model_validate`, which checks it against the model and makes the page.
The code no longer uses `Any`, so its import goes.

patch$ src/wikiapp/wikipedia.py

::: do
The patch deletes `from typing import Any` and the blank line under it. It changes the return type of
`random_page`, and its line `return response.json()`.
:::

::: watch
In `src/wikiapp/wikipedia.py`, see the `def` line `def random_page(language: str = "en") -> Page:` and the line
`return Page.model_validate(response.json())`.
:::

`main`, in `src/wikiapp/console.py`, prints `page.title` and `page.extract` in place of the two keys.

patch$ src/wikiapp/console.py

::: do
The patch changes the code under the docstring of `main`. It names the answer `page`, and prints its two attributes.
:::

The test that asks the real Wikipedia, in `tests/test_wikipedia.py`, checked two keys of the dictionary. It now
checks that the answer is a `Page`, and its new name, `test_random_page_returns_page_in_production`, says so. It
keeps its marker `e2e`.

patch$ tests/test_wikipedia.py

::: do
The patch replaces the last test of `tests/test_wikipedia.py`, and keeps its marker.
:::

::: watch
In `tests/test_wikipedia.py`, the two asserts on the keys are now one, on the type of the answer.
:::

$ just check

$ uv run wikiapp

`just check` passes, and the command prints a page as before.

files:
- diff `src/wikiapp/wikipedia.py`: the return.
  show: `return Page.model_validate(response.json())`
- diff `src/wikiapp/console.py`: attributes, not keys.
  show: `click.secho(page.title, fg="green")`
- diff `tests/test_wikipedia.py`: the e2e test checks for a Page.
  show: `assert isinstance(page, wikipedia.Page)`

### step-07.4 An answer that is not a page

An answer with no title is not a page. `model_validate` then raises the ValidationError of pydantic, and the command
would end with a traceback. `random_page` turns a failed request into a WikipediaError, and it should do the same
with an answer that is not a page. So its `except` catches ValidationError together with the exception of requests.

patch$ src/wikiapp/wikipedia.py

::: do
The patch adds `ValidationError` to the import from pydantic. It changes the line `except requests.RequestException as error:`
to catch both exceptions.
:::

::: watch
In `src/wikiapp/wikipedia.py`, see the line `except (requests.RequestException, ValidationError) as error:`, and
`ValidationError` in the import from pydantic.
:::

A test from the original wikiapp, `test_random_page_handles_validation_error`, checks it, at the end of
`tests/test_wikipedia.py`. The mock answers with an empty dictionary, `{}`, and `pytest.raises` expects a
WikipediaError.

patch$ tests/test_wikipedia.py

::: do
The patch adds the test at the end of `tests/test_wikipedia.py`, with two blank lines before it.
:::

$ just test -k validation

The output is `1 passed, 8 deselected`.

files:
- diff `src/wikiapp/wikipedia.py`: two exceptions caught.
  show: `except (requests.RequestException, ValidationError) as error:`
- diff `tests/test_wikipedia.py`: the test.
  show: `with pytest.raises(wikipedia.WikipediaError):`

### step-07.5 Only a language code goes into the address

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as `example.com/x?`
sends the request to example.com, with the User-Agent. The language code of every Wikipedia has only lower-case
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. So `random_page` checks the language against a pattern of such a
code first, before the `try`, and any other language raises a WikipediaError.

The pattern is a constant, `LANGUAGE`, made with the module `re`. No request goes out for a language that does
not match it.

patch$ src/wikiapp/wikipedia.py

::: do
The patch makes three changes to `src/wikiapp/wikipedia.py`. It puts `import re` and a blank line at the top, above
`import requests`. It adds `LANGUAGE` under the line `API_URL = ...`. It adds the check at the top of the body of
`random_page`, under its docstring and before the `try`.
:::

::: watch
In `src/wikiapp/wikipedia.py`, `LANGUAGE` is under `API_URL`, and `import re` is at the top. The check is the
first lines of `random_page`, from `if not LANGUAGE.fullmatch(language):`.
:::

$ uv run wikiapp --language 'example.com/x?'

$ just test -q

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%.

files:
- diff `src/wikiapp/wikipedia.py`: the code checks a language before it uses it.
  show: `if not LANGUAGE.fullmatch(language):`

## step-08 Docs from the code

$ just setup

A person who calls `random_page` must read its code to learn what it takes, what it returns and when it fails. We
document the code, and let a tool, smalldocs, write the reference from it. smalldocs also lists what has no
documentation, so `just check` can fail when a function has none. We document the library, the command and the tests. Then we
build a site with a front page, and name the tests and the docs in the README.

### step-08.1 smalldocs

The reference of a function gives its signature, what it does, and what each parameter is. The signature and the
types are in the code. The docstring says what the function does. A docment is the comment beside a parameter, a field
or a return type, and says what that thing is. Later moves put each parameter on a line of its own, so that its
docment can follow it on that line.

A reference that a tool writes from the code changes when the code changes. [smalldocs](https://docs.smallish.dev/) is that tool. It is a Python program that writes the reference, and builds a
website from it. It also lists what has no documentation.

smalldocs reads the signature, the docstring and the docments, and writes Markdown. It is a Python package, so uv
installs it like any other. It goes in a third dependency group, `docs`. uv sorts the groups by name, so `docs` comes before
`lint` and `test` in the file.

do$ uv add --group docs smalldocs

::: do
`uv add` installs smalldocs and the packages that it needs, among them fastcore, markdown-it-py and mdurl.
:::

::: watch
In `pyproject.toml`, the new group `docs` is lines 28 to 30, with the line `"smalldocs>=0.1.5",`. `uv.lock` has
the exact version of smalldocs, and of the packages that it needs.
:::

`default-groups = "all"`, at line 25 of `pyproject.toml`, makes uv install every dependency group. So
`just setup` installs smalldocs, with no other change.

$ uv run smalldocs --version

$ uv tree --only-group docs

The first command prints `smalldocs 0.1.5`, or a newer version. `uv tree` prints smalldocs `(group: docs)`, and under it fastcore,
markdown-it-py, mdit-py-plugins, pygments and pyyaml.

files:
- diff `pyproject.toml`: the group.
  show: `docs = [`
- diff `uv.lock`: the exact version of smalldocs, and of the packages that it needs.

### step-08.2 What is not documented

smalldocs is installed, but nothing tells it which package to document, and no recipe runs it. It needs a file of settings,
and the `justfile` a recipe `docs`. Then `just docs check` lists what has no documentation.

smalldocs reads its settings from `docs/_smalldocs.yml`. For now the file has one section, `api`, the reference.
It names the package to document, the address of its source, and the files of the tests to check. The file is new,
and comes whole, as a patch.

patch$ docs/_smalldocs.yml

::: do
Read the three keys under `api`, which are `packages`, `source` and `check`.
:::

::: watch
The new file `docs/_smalldocs.yml` has five lines. Line 3 names the package, `wikiapp`. Line 5 names the tests,
`tests/**/*.py`, which `check` also checks.
:::

A recipe `docs` runs `smalldocs api`, and gives it the words after `just docs`. `smalldocs api` has two commands
that we use here:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

patch$ justfile

::: do
The patch adds the recipe `docs` at the end of the `justfile`, with its comment and its two attributes.
:::

::: watch
The recipe `docs *args:` is at line 81, the end of the `justfile`. It also passes `--dir docs`, the folder of the
settings.
:::

$ uv run smalldocs api module wikipedia --dir docs

$ uv run smalldocs api check --dir docs

$ just --show docs

$ just docs check

`module` prints the reference of `wikipedia.py`, with empty descriptions. For each module and each test file,
`check` counts the functions and classes that are complete. It names every gap, and the five modules without a
docstring are among them. Then it fails with `1 of 15 functions, methods and classes are typed and documented`.
The one is `WikipediaError`, which needs only its docstring. Like
coverage, which counts the lines that the tests run, `check` counts what has documentation.

files:
- file `docs/_smalldocs.yml`: the package to document, and the tests to check.
  show: `packages: [wikiapp]`
- diff `justfile`: the recipe.
  show: `docs *args:`

### step-08.3 The library documented

The reference of `wikipedia.py` has empty descriptions, because the library has no docments and short
docstrings. We document it in four places:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

patch$ src/wikiapp/wikipedia.py

::: do
The patch adds the docstring of the module above the line `import re`. It puts a comment beside each field of `Page`.
It writes `random_page` again from its `def` line to the end of its docstring, with one parameter to a line.
:::

::: watch
In `src/wikiapp/wikipedia.py`, see the docstring at the top, the comments beside the fields of `Page`, and the
line `) -> Page:  # A page chosen at random`, the docment of the return.
:::

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

$ just docs module wikipedia

The tables now have their descriptions.

files:
- diff `src/wikiapp/wikipedia.py`: the comments are the documentation.
  show: `) -> Page:  # A page chosen at random`

### step-08.4 The command documented

The two other modules, `src/wikiapp/__init__.py` and `src/wikiapp/console.py`, have no docstring, and `main` has
no docment. `wikiapp --help` prints the docstring of `main` and the help of each option, so those are
documentation too.

Each of the two modules gets a docstring at the top, which says what the module is.

patch$ src/wikiapp/__init__.py

::: do
The patch adds the docstring at the top of `src/wikiapp/__init__.py`, with a blank line under it.
:::

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

The help of `--language` now says what a language is. It replaces the help of the original wikiapp, "Gets random
page from Wikipedia in given language". `main` has one parameter to a line, with its docment, and a docstring that
says what `main` prints. A function that returns None needs no docment for its return.

patch$ src/wikiapp/console.py

::: do
The patch adds the docstring of the module at the top of `src/wikiapp/console.py`. It changes the line `help=...` of
the option `--language`. It writes the line `def main(...)` again, and the docstring under it.
:::

::: watch
In `src/wikiapp/console.py`, the docment of `language` is
`# The language of the Wikipedia to ask, from --language`. The second paragraph of the docstring of `main` gives the colour of the title and the width of the
summary.
:::

$ just docs module console

$ uv run wikiapp --help

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

files:
- diff `src/wikiapp/__init__.py`: a docstring, which `help(wikiapp)` shows.
  show: `"""wikiapp: the title and summary of a random Wikipedia page."""`
- diff `src/wikiapp/console.py`: the docment, the docstring and the help.
  show: `language: str,  # The language of the Wikipedia to ask, from --language`

### step-08.5 The tests documented

`just docs check` still finds gaps in the tests. Each test file must say what it tests, and each fixture what it
returns. Each test says in one line what it checks. The docstring says in words what the asserts say in code. Each
parameter of a test has a docment, one parameter to a line.

Tests documented this way are documentation too. A reader learns from them what the code must do.

The fixture in `tests/conftest.py` gets a docstring for the file, a docment for its parameter and its return, and a
docstring of its own.

patch$ tests/conftest.py

::: do
The patch adds the docstring of the file at the top. It writes the line `def mock_requests_get(...)` again, with one
parameter to a line, and adds the docstring of the fixture.
:::

::: watch
In `tests/conftest.py`, see the docment of `mocker`, and the docment of the return after `-> Mock:`.
:::

`tests/test_console.py` has a fixture and six tests, and each gets the same pattern.

patch$ tests/test_console.py

::: do
The patch adds a docstring at the top of the file. Each test gets a docment on each parameter, one to a line, and a
docstring of one line. Read `test_main_prints_title` first. Its docstring is "The command prints the title of the
page." The fixture `runner` gets a docstring, and a docment beside its return type on its `def`
line.
:::

::: watch
In `tests/test_console.py`, the fixture `runner` also documents its return.
:::

The three tests of `tests/test_wikipedia.py` get the same pattern.

patch$ tests/test_wikipedia.py

::: do
The patch adds the docstring of the file at the top. The two tests that take the mock get one parameter to a line,
with its docment. Each of the three tests gets a docstring of one line, under its `def`.
:::

$ just docs check

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

files:
- diff `tests/conftest.py`: the fixture, documented.
  show: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- diff `tests/test_console.py`: seven functions.
  show: `"""The command prints the title of the page."""`
- diff `tests/test_wikipedia.py`: three tests.
  show: `"""The language chooses the Wikipedia that is asked."""`

### step-08.6 A site

The reference exists only as Markdown that `just docs module` prints. A reader wants a site, with a front page
that says what the project does, and a page of reference for each module. smalldocs also builds a site from
Markdown.

The site is in `docs/`. It has a front page, `index.qmd`, and a reference page for `console.py` and one
for `wikipedia.py`. Each build writes the reference pages from the code, before it builds the site. A name in
backticks, such as `random_page`, becomes a link to its entry.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site.

patch$ docs/_smalldocs.yml

::: do
The patch writes the first line, a comment, again, to say what `just docs` builds. Under it come the sections
`project` and `website`, and the keys `theme` and `toc`. A new comment above `api:` says what the reference is, and
the section `api` stays as it is.
:::

::: watch
In `docs/_smalldocs.yml`, the sidebar lists the front page, then the reference pages, in the line
`contents: api/*  # the reference pages, which each build makes from the code`.
:::

The front page, `docs/index.qmd`, is new. A `.qmd` file is Markdown, with a header between two `---` lines that
gives the title of the page.

The page says what the command prints, what each module does, and what the reference pages contain. The file is
new, and comes whole, as a patch.

patch$ docs/index.qmd

`just docs` with no words now builds the site, with `smalldocs render docs`. With words, it runs `smalldocs api`
as before. So the recipe is now a script of several lines.

patch$ justfile

::: do
The patch writes the recipe `docs` again, from its comment to its last line. Its body is now a script of `sh`, with
one line for `help`, one for no words, and one for words.
:::

::: watch
In the `justfile`, the recipe `docs` starts with `#!/usr/bin/env sh`. The line
`if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi` is the case with no words.
:::

$ uv run smalldocs render docs

$ just --show docs

$ just docs

$ grep -o 'href="api/wikipedia.html#random_page"' docs/_site/index.html | head -n 1

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. grep searches a file for a piece of text, and `-o` prints only the text that it finds. Here it finds the
link from `random_page` on the front page to its entry in `api/wikipedia.html`. The `|` passes what grep prints to
`head -n 1`, which keeps the first line, so the link prints once. Each build makes the site and the reference pages, and git ignores them.

files:
- diff `docs/_smalldocs.yml`: the site. The sidebar lists the front page, then the reference pages.
  show: `contents: api/*  # the reference pages, which each build makes from the code`
- file `docs/index.qmd`: the front page, written by hand.
  show: `Each build of the site makes the pages under Reference from the code.`
- diff `justfile`: with no words, `docs` builds the site.
  show: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

### step-08.7 The README names the tests and the docs

The README is the first page that a reader sees on GitHub. Its table of folders says where each part of the
project is, and it lists neither the tests nor the docs. The table gets rows for `tests/` and `docs/`. The row of
`src/wikiapp/` also says that `wikipedia.py` is the library and `console.py` the command.

patch$ README.md

::: do
The patch puts three rows in place of the row of `src/wikiapp/`, in the table of folders.
:::

$ grep -n -E 'tests/|docs/' README.md

`grep` prints the two new rows of the table.

files:
- diff `README.md`: the folders.
  show: `| The docs site. smalldocs makes its reference from the code |`

### step-08.8 The docs check in `just check`

Every function, parameter and field has documentation now, but no check fails when a new function has none. `just check` runs before
each `git commit`, through the git hook, so `just docs check` goes in it, after the tests. The comment above
`check` names the docs too.

patch$ justfile

::: do
The patch writes the comment above `check` again, with "docs" in it. In `check`, it adds the line `just docs check` under
the line `just test -q --cov-fail-under=90`.
:::

::: watch
In the `justfile`, `just docs check` is the line under `just test -q --cov-fail-under=90`, in `check`.
:::

$ just check

The docs check prints `15 of 15`. Now, when a function, a parameter or a field has no documentation, the git hook
fails, and git records no change. GitHub's job `check`, at lines 30 to 37 of `.github/workflows/test.yaml`, runs `just check`, so
it runs the docs check too.

files:
- diff `justfile`: the comment, and one line in `check`.
  show: `just docs check`

## step-08b The docs on GitHub Pages

$ just setup

Every job on GitHub installs every dependency group, with every tool of the project, though most jobs need only a
few. Also, the docs site exists only on the machine that builds it. So we make the job `tests` install the group `test`
alone. Then a new workflow builds the docs site with the group `docs` alone, and GitHub Pages publishes it.

### step-08b.1 The tests install the group test alone

The job `tests` runs twelve times on GitHub, and each run installs every group. So each run installs the linter, the type
checker, the git hook tools and smalldocs. pytest needs only the package and the group `test`, so this move makes
each run install only those.

The line `default-groups = "all"` in `pyproject.toml` makes uv install every group. `--no-default-groups` tells uv
to install none of them, and `--group test` then names the one group to install. The job `check`, at lines 30 to 37
of `.github/workflows/test.yaml`, still runs `just setup`, which installs every group. It needs every tool, since
`just check` runs them all.

patch$ .github/workflows/test.yaml

::: do
The patch changes the comment line that starts with `# tests:`, and the last line of the job `tests`, which was
`- run: uv run --locked pytest`.
:::

::: watch
The last line of the job `tests` now adds `--no-default-groups --group test`. The comment line `# tests:` at the top of
the file now ends with "each with the group test alone".
:::

$ uv run --isolated --locked --no-default-groups --group test pytest -q

$ uv run pre-commit run check-yaml --files .github/workflows/test.yaml

`--isolated` runs the command as the job does, in a temporary environment with the group `test` alone, and leaves
`.venv` as it is. The tests print `7 passed, 2 deselected`. The file is valid YAML.

files:
- diff `.github/workflows/test.yaml`: the comment, and the command of the job `tests`.
  show: `- run: uv run --locked --no-default-groups --group test pytest  # the package and its tests, no more`

### step-08b.2 A workflow that publishes the docs

`just docs` builds the docs site on one machine, and nobody else can read it. A second workflow,
`.github/workflows/docs.yaml`, builds the site on GitHub on every push to main, and GitHub Pages publishes it.

[GitHub Pages](https://docs.github.com/en/pages) publishes a website from a repository, free for a public one. A
workflow can build the site and give it to Pages.

The workflow has two jobs. The job `build`, from line 21, installs the package and the group `docs`, and runs
`smalldocs render docs`, the command behind `just docs`. It does not run `just docs`, because that recipe, at
line 85, runs `uv run` with no option, which installs every group. The job then gives the folder
`docs/_site` to Pages. The job `deploy`, from line 32, publishes it.

Lines 11 to 14, under `permissions`, let the workflow publish to Pages. Lines 16 to 18, under `concurrency`, stop
an older publish when a newer push starts one.

The file is new, and comes whole, as a patch.

patch$ .github/workflows/docs.yaml

::: do
Read the comment at the top, then the lines under `permissions`, `concurrency` and `jobs`.
:::

::: watch
In the new file `.github/workflows/docs.yaml`, the line
`- run: uv run --locked --no-default-groups --group docs smalldocs render docs` is the build of the site.
:::

The workflow runs only where two settings on GitHub allow it. The settings are not in any file of the project. Both
are on GitHub's website, and need no tool on your machine.

- **Actions.** GitHub turns off the workflows of a fork, until its owner turns them on, on the tab **Actions**.
- **Pages.** Under **Settings**, then **Pages**, the source of the site must be **GitHub Actions**.

GitHub then publishes the site at `https://OWNER.github.io/smallwikiapp/`, where OWNER is the name of the account
that owns the fork. The account rahuldave has a domain of its own. So the site of rahuldave/smallwikiapp is at
[rahuldave.com/smallwikiapp](https://rahuldave.com/smallwikiapp/).

In every fork, the links from the reference to the code go to rahuldave/smallwikiapp. Line 20 of
`docs/_smalldocs.yml` names that repository.

::: do
To publish the docs from your own fork of smallwikiapp, do these things on GitHub's website.

1. Fork https://github.com/rahuldave/smallwikiapp, if you have no fork of it yet.
2. In your fork, open the tab **Actions**, and turn the workflows on.
3. Open **Settings**, then **Pages**. Under **Source**, choose **GitHub Actions**.
4. Open **Actions**, and choose the workflow **Docs**. Press **Run workflow**, keep the branch `main`, and press the
   green **Run workflow** under it.
5. When the run ends, open `https://YOU.github.io/smallwikiapp/`, with the name of your account in place of YOU.

Your fork has the finished project, so the site shows its docs. The changes that you make in this tutorial stay
on your machine, and do not reach the fork. From then on, each push to the main branch of your fork builds the site
again.
:::

$ uv run pre-commit run check-yaml --files .github/workflows/docs.yaml

$ uv run --isolated --locked --no-default-groups --group docs smalldocs render docs

The file is valid YAML. The second command builds the site as the job does, with the group `docs` alone, and
prints `wrote 3 page(s) to docs/_site`. git ignores `docs/_site`.

files:
- file `.github/workflows/docs.yaml`: the site, built with the group `docs` alone, then published.
  show: `- run: uv run --locked --no-default-groups --group docs smalldocs render docs`

## step-09 The library as a package

$ just setup

The code that asks Wikipedia has no code for the command line, but another program can get it only by installing
wikiapp, with click. So we make it a package of its own, `wikirandom`, in the same repository. First comes an empty
package, with its dependencies and its README, then its code. Then the app uses the library, and drops requests
and pydantic, which it no longer imports. Last, the docs check counts the library too.

### step-09.1 An empty library, wikirandom

A second package needs its own folder, its own `pyproject.toml` and its own code. uv can make it inside the
project. The two packages then form a *workspace*, which has one lockfile and one `.venv` for both. `uv init`
makes the library, and each option writes one thing:

- `--lib` makes a library, with its code under `src/`, and no script to run.
- `--author-from none` writes no `authors`, so no name or email from git goes into the library.
- `--no-pin-python` asks for no `.python-version` file of the library's own. The project's file stays the only
  one.
- `--python ">=3.11"` writes `requires-python = ">=3.11"`, the same range as the app. Without it, uv writes
  `">=3.13"`, from the project's `.python-version`.
- `--description` writes the library's `description`, in place of uv's "Add your description here".

do$ uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom

uv makes the folder `packages/wikirandom/`, with what a library needs. It has its own `pyproject.toml`, an empty
README, and code with an example function, `hello`. An empty file, `py.typed`, tells a type checker that the
package has types.

In the project's `pyproject.toml`, uv adds the table `[tool.uv.workspace]`, at lines 27 to 30, with the library in
its list `members`.

::: do
Another version of uv writes another range for `uv_build` in line 10 of the library's `pyproject.toml`, so that
line can differ from the one here. If the line differs, the check of your files still passes, because it ignores
version numbers.
:::

::: watch
See `description` and `requires-python` in lines 4 and 6 of `packages/wikirandom/pyproject.toml`, and
`def hello() -> str:` in `packages/wikirandom/src/wikirandom/__init__.py`. In `pyproject.toml`, see
`"packages/wikirandom",` in line 29.
:::

`uv init` does not change `uv.lock`, so the lockfile does not list the new member yet. Line 6 of the `justfile`
sets `UV_LOCKED`, so after this move each recipe that runs uv refuses the lockfile, on purpose. The next move, `uv add`, resolves the lockfile again for the workspace.

$ uv lock --check

The command prints `Resolved 42 packages`, then an error that names `uv.lock`, and a hint to run `uv lock`. Its
exit code is 1. Before this move, the lockfile had 41 packages. The 42nd is `wikirandom`.

$ just test

`just test` prints its command, `uv run pytest`, then an error of uv that names `uv.lock` and `UV_LOCKED`, and the
hint to run `uv lock`. pytest does not run.

files:
- file `packages/wikirandom/pyproject.toml`: a package of its own, with its name, version, description, the
  versions of Python it accepts, and its build backend.
  show: `name = "wikirandom"`
- file `packages/wikirandom/README.md`: empty.
- file `packages/wikirandom/src/wikirandom/__init__.py`: uv's example function.
  show: `def hello() -> str:`
- file `packages/wikirandom/src/wikirandom/py.typed`: an empty file, which tells a type checker that the package
  has types.
- diff `pyproject.toml`: the workspace, with one member.
  show: `"packages/wikirandom",`

### step-09.2 requests and pydantic, for the library

The library's code will be the code of `src/wikiapp/wikipedia.py`, which imports requests and pydantic. So they
become the library's dependencies. `--package wikirandom` makes `uv add` change the library's `pyproject.toml`,
and not the app's. uv also resolves the lockfile again, for the whole workspace, so the lockfile now lists the
library.

do$ uv add --package wikirandom requests pydantic

::: watch
In `packages/wikirandom/pyproject.toml`, lines 7 to 10, the list `dependencies` has `"pydantic>=2.14.1",` and
`"requests>=2.34.2",`. In `uv.lock`, see the new table `[manifest]`, with the two members, and the new package
`wikirandom` at the end.
:::

$ uv lock --check

$ uv tree --package wikirandom

`uv lock --check` prints `Resolved 42 packages`, with no error, so the lockfile matches the project again. `uv tree` shows `wikirandom v0.1.0`, with `pydantic v2.14.1` and `requests v2.34.2` under it.

files:
- diff `packages/wikirandom/pyproject.toml`: its dependencies.
  show: `"pydantic>=2.14.1",`
- diff `uv.lock`: the two members of the workspace, and the library with its dependencies.

### step-09.3 The library's README

uv wrote an empty `README.md` for the library. It gets a heading, and a line that says what the library is. The
line also says that the command `wikiapp` will use it.

patch$ packages/wikirandom/README.md

::: do
The patch fills the empty file with the heading `# wikirandom`, a blank line, and the line of text.
:::

$ cat packages/wikirandom/README.md

The command prints the heading, and
``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``

files:
- file `packages/wikirandom/README.md`: a heading, and what the library is.
  show: ``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``

### step-09.4 The library gets a copy of wikipedia.py

The library has only uv's example function. Its code is the code of `src/wikiapp/wikipedia.py`. `cp` puts a copy
of that file in place of the example. The app does not use the library yet, and still has its own `wikipedia.py`.

do$ cp src/wikiapp/wikipedia.py packages/wikirandom/src/wikirandom/__init__.py

::: watch
`packages/wikirandom/src/wikirandom/__init__.py` loses `hello`, and gets the 41 lines of `wikipedia.py`.
:::

$ diff src/wikiapp/wikipedia.py packages/wikirandom/src/wikirandom/__init__.py

$ uv run --package wikirandom python -c "import wikirandom; print(wikirandom.USER_AGENT)"

`diff` prints nothing, because the two files are the same. The second command prints
`wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)`. The library still names the app in each request it
makes. `--package wikirandom` installs the library into the shared `.venv`, and runs the command there. The app
does not depend on the library yet, so a plain `uv run` would not install it.

files:
- diff `packages/wikirandom/src/wikirandom/__init__.py`: the code of `wikipedia.py`, in place of `hello`.
  show: `def random_page(`

### step-09.5 The library's docstring and User-Agent

The copy still describes the app. Its docstring says only "Wikipedia's REST API", and its User-Agent names
`wikiapp`. The docstring now says what the package is, and the User-Agent names `wikirandom`, the program that now
makes the request.

patch$ packages/wikirandom/src/wikirandom/__init__.py

::: do
The patch changes two lines, the docstring in line 1 and the line `USER_AGENT = ...` in line 10. Every other line
stays as `cp` left it.
:::

::: watch
In `packages/wikirandom/src/wikirandom/__init__.py`, see the docstring in line 1, and `USER_AGENT` in line 10.
The rest is `src/wikiapp/wikipedia.py`.
:::

$ uv run --package wikirandom python -c "import wikirandom; print(wikirandom.USER_AGENT)"

$ uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`. The second asks the
real Wikipedia, and prints the title of a French page, another one on each run.

files:
- diff `packages/wikirandom/src/wikirandom/__init__.py`: the docstring, and the User-Agent.
  show: `USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"`

### step-09.6 The app depends on wikirandom

The app and the library now each have a copy of the code that asks Wikipedia for a page. Before the app can import the library, the library must be
a dependency of the app.

do$ uv add wikirandom

wikirandom is a member of the workspace, so `uv add` also writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`. uv then installs the library from `packages/wikirandom`, and not from PyPI. It installs it
editable. An editable install points `.venv` at the library's folder, so an edit to the library reaches the app at
once, with no new install.

::: watch
In `pyproject.toml`, see `"wikirandom",` in line 14, at the end of `dependencies`, and the table
`[tool.uv.sources]` in lines 33 and 34.
:::

$ uv run python -c "import wikirandom; print(wikirandom.__file__)"

`uv add` installed the library, and the app now depends on it, so Python finds it under a plain `uv run`. The
command prints a path that ends with
`packages/wikirandom/src/wikirandom/__init__.py`, the file in the repository, not a copy.

files:
- diff `pyproject.toml`: the app depends on the library, from the workspace.
  show: `wikirandom = { workspace = true }`
- diff `uv.lock`: the app's dependencies have wikirandom.

### step-09.7 The app uses wikirandom

The app must use the library, and drop its own `src/wikiapp/wikipedia.py`. Its tests then test the library,
coverage measures both packages, and the README and the docs say that there are two packages. `rm` deletes the
app's file, and there is one patch for each of the six other files.

do$ rm src/wikiapp/wikipedia.py

`src/wikiapp/console.py` imports from the library. The import goes with the installed packages, under
`import click`, so the lines are already in ruff's order. `tests/test_wikipedia.py` keeps its name for now, and
tests the library. Each `wikipedia.` becomes `wikirandom.`, and the file imports `wikirandom` under `import pytest`.
The host `es.wikipedia.org` in the first test stays as it was.

Coverage measured `wikiapp` alone, and must measure both packages. Last, three files must say that there are two
packages, and that the app uses the library. They are the README, the front page of the docs and the library's
README.

patch$ src/wikiapp/console.py
patch$ tests/test_wikipedia.py
patch$ pyproject.toml
patch$ README.md
patch$ docs/index.qmd
patch$ packages/wikirandom/README.md

::: do
In `src/wikiapp/console.py`, the patch deletes the import from `wikiapp.wikipedia`, and puts
`from wikirandom import WikipediaError, random_page` under `import click`, in line 6. In
`tests/test_wikipedia.py`, read the docstring in line 1, the import in line 6, and each call that now starts with
`wikirandom.`. In `pyproject.toml`, the patch changes the first line of the comment above `addopts`, and adds
`--cov=wikirandom` to the line `addopts`. In `README.md`, it puts two rows in place of the row of `src/wikiapp/` in
the table of folders. In `docs/index.qmd`, it rewrites the paragraph about the modules. In
`packages/wikirandom/README.md`, "will use" becomes "uses".
:::

::: watch
In `src/wikiapp/console.py`, the import of line 6 now comes from `wikirandom`. In `tests/test_wikipedia.py`,
every call starts with `wikirandom.`. In `pyproject.toml`, see `--cov=wikirandom` in line 57. `README.md` has a
row for `packages/wikirandom/` in line 34. In `docs/index.qmd`, see the paragraph that starts in line 19 with
`The code has two packages, in one repository:`. `packages/wikirandom/README.md` now says that `wikiapp` uses the
library.
:::

$ just test -q

$ uv tree --depth 2

$ just docs check

$ just docs

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`, and no longer `src/wikiapp/wikipedia.py`. `uv tree` shows that
wikirandom needs pydantic and requests, and that wikiapp still lists them too, beside click and wikirandom. The
app no longer imports them, so the next move removes them. `just docs check` still counts the app and the tests
alone, 12 of 12. `just docs` writes 2 pages, the front page and the reference page of the app, because the
settings of the site name only the app.

files:
- diff `src/wikiapp/console.py`: one import.
  show: `from wikirandom import WikipediaError, random_page`
- diff `src/wikiapp/wikipedia.py`: deleted. Its code is in the library.
- diff `tests/test_wikipedia.py`: the same three tests, of the library.
  show: `wikirandom.random_page(language="es")`
- diff `pyproject.toml`: coverage measures both packages.
  show: `addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"`
- diff `README.md`: one row more, and the `src/wikiapp/` row says the app.
  show: `| The library the app uses: a random page of Wikipedia. A package of its own |`
- diff `docs/index.qmd`: two packages.
  show: `The code has two packages, in one repository:`
- diff `packages/wikirandom/README.md`: the library's README says that the app uses it.
  show: ``A random page of Wikipedia, in any language. The command `wikiapp` uses this library.``

### step-09.8 The app no longer needs requests and pydantic

The app no longer imports pydantic. Of its files, only `tests/test_console.py` imports requests, in line 6, and
requests now comes with wikirandom. So the two leave the app's dependencies. The library still depends on them, so
the lockfile keeps them.

do$ uv remove requests pydantic

::: watch
In `pyproject.toml`, lines 10 to 13, `dependencies` now lists `"click>=8.5.0",` and `"wikirandom",` alone.
:::

$ uv tree --invert --package requests

$ just test -q

`uv tree --invert` shows who needs requests. After uv's line `Resolved 42 packages`, it prints `requests v2.34.2`, then `wikirandom v0.1.0`
under it, and `wikiapp v0.1.0` under that. The app gets requests only through the library. The tests still print
`7 passed, 2 deselected`.

files:
- diff `pyproject.toml`: the app's dependencies are click and wikirandom.
- diff `uv.lock`: the app no longer depends on pydantic and requests by itself.

### step-09.9 The tests of the library are named for it

`tests/test_wikipedia.py` tests wikirandom, and its name should say so. `mv` renames the file, and changes none of
its lines.

do$ mv tests/test_wikipedia.py tests/test_wikirandom.py

$ just docs check

The docs check lists the file under its new name, `tests/test_wikirandom.py   3 of   3`.

files:
- file `tests/test_wikirandom.py`: the tests of the library, under their new name. No line changes.

### step-09.10 The docs check counts the library

The settings of the site, `docs/_smalldocs.yml`, name only `wikiapp`, so the docs and their check leave out the
library. The line `packages:` in the section `api` must name both.

patch$ docs/_smalldocs.yml

::: do
The patch changes one line, `packages:` in the section `api`, in line 19.
:::

::: watch
In `docs/_smalldocs.yml`, line 19, `packages:` lists `wikiapp` and `wikirandom`.
:::

$ just docs check

$ just docs

$ grep -o 'href="api/wikirandom.html#random_page"' docs/_site/index.html | head -n 1

$ just check

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and grep finds the link from `random_page` on the front page to its entry in `api/wikirandom.html`.
`just check` passes.

files:
- diff `docs/_smalldocs.yml`: the list of packages.
  show: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

## step-10 Build

$ just setup

Nobody can install the two packages without this repository, because nothing builds them into the files that pip
and uv install. So we build each package into a wheel and a source archive, and read what the wheels say. Then the
app says which versions of the library it accepts, and `just lint-config` checks the library's `pyproject.toml`
too. Both packages say their licence and where their source is. Last, the library's User-Agent says the version
that is installed.

### step-10.1 The recipe `build`

A package goes to PyPI as two files, a wheel and a source archive. pip and uv install the wheel. `uv build
--all-packages` builds both for every package of the workspace, into `dist/`. `.gitignore` already lists `dist/`.
A recipe `build`, at the end of the `justfile`, runs it.

patch$ justfile

::: do
The patch adds the recipe `build`, with its comment, at the end of the `justfile`.
:::

::: watch
The recipe `build` at the end of the `justfile` is in the group `setup`, and `just build help` explains it.
:::

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

files:
- diff `justfile`: the recipe `build`.
  show: `build *args:`

### step-10.2 The app needs wikirandom 0.1

The app's wheel says that the app needs `wikirandom`, of any version. A later release that changes the library
could break the app. The app works with wikirandom 0.1.0, so its dependency gets the range
`>=0.1.0,<0.2`. `<0.2` keeps out 0.2 and later.

do$ uv add "wikirandom>=0.1.0,<0.2"

The range changes only the metadata of the app's wheel, and uv installs the same code as before. In `pyproject.toml`,
the table `[tool.uv.sources]` tells uv to take wikirandom from the workspace. `[tool.uv.workspace]` names the folder `packages/wikirandom` as a member of the
workspace, so uv installs the library from that folder.

$ just build

$ unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

files:
- diff `pyproject.toml`: one line, the range of versions.
  show: `"wikirandom>=0.1.0,<0.2",`

### step-10.3 lint-config checks both pyproject.toml files

The repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. A mistake in the
library's file would reach a build unseen. The recipe `lint-config` now gives validate-pyproject both files.

patch$ justfile

::: do
The patch changes one line of the recipe `lint-config`, the line that runs `validate-pyproject`.
:::

$ just lint-config

`just lint-config` prints `Valid file` twice, once for each file.

files:
- diff `justfile`: two files.
  show: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

### step-10.4 A licence for the library, and a repository link for both

The library's wheel has no licence and no author, and neither package says where its source is. PyPI shows all
three on the page of a package. The library gets a copy of the project's `LICENSE`.

do$ cp LICENSE packages/wikirandom/LICENSE

Its `pyproject.toml` gives the licence and the author in `[project]`, as the app's `pyproject.toml` does. Both
`pyproject.toml` files name the repository, in a table `[project.urls]`.

patch$ packages/wikirandom/pyproject.toml
patch$ pyproject.toml

::: do
In `packages/wikirandom/pyproject.toml`, the change adds the licence, its file and the author to `[project]`, and
the table `[project.urls]`. The app's `pyproject.toml` gets the same table.
:::

::: watch
In `packages/wikirandom/pyproject.toml`, see `license = "Apache-2.0"` under `readme`. The table `[project.urls]`
is after `dependencies` there, and after `[project.scripts]` in the app's `pyproject.toml`.
:::

$ just build

$ unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA

The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

files:
- diff `packages/wikirandom/pyproject.toml`: what PyPI would show.
  show: `license = "Apache-2.0"`
- diff `pyproject.toml`: the app's repository.
  show: `[project.urls]`
- file `packages/wikirandom/LICENSE`: the same Apache-2.0 licence as the app's.
  show: `Apache License`

### step-10.5 The User-Agent says the installed version

The library's User-Agent says `0.1.0`, written by hand. After a change of the version in
`packages/wikirandom/pyproject.toml`, it would still say `0.1.0`. So the library reads its version from the
installed package, as `wikiapp --version` does. `VERSION` is the installed version, and `USER_AGENT` contains it.

patch$ packages/wikirandom/src/wikirandom/__init__.py

::: do
The patch adds `import importlib.metadata` above `import re`, and puts two lines, `VERSION = ...` and
`USER_AGENT = ...`, in place of the old `USER_AGENT = ...`.
:::

::: watch
In `packages/wikirandom/src/wikirandom/__init__.py`, see `VERSION = importlib.metadata.version("wikirandom")`,
which runs once, when Python imports the package. `USER_AGENT` is an f-string with `{VERSION}` in it.
:::

$ uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"

$ just check

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.

files:
- diff `packages/wikirandom/src/wikirandom/__init__.py`: the version now comes from one place, the library's
  `pyproject.toml`.
  show: `VERSION = importlib.metadata.version("wikirandom")`
