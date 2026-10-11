<!-- Made by timewalk-tutorial from the notes of the walk. Do not edit it by hand: run timewalk-tutorial again. -->

# smallwikiapp, one move at a time

In watch mode, you read each move. The notes explain what it changed, and its commit holds the code. [The same tutorial in do mode](TUTORIAL-do.md).

This tutorial goes through the tagged steps of smallwikiapp, and the small commits between them. Each small
commit is a move, one action. The command at the end of a move shows what the move did. Every step starts from
the code of the step before, so every step starts with `just setup`. To take the tutorial in timewalk, where you
can watch each move or make it yourself, see the [README](https://github.com/rahuldave/smallwikiapp-walk#readme).

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

`just walk-update` in the class material makes this copy from
[the notes that timewalk reads](https://github.com/rahuldave/smallwikiapp-walk/blob/main/walks/tutorial/notes.md),
so do not edit it by hand.

- **Each step** links to the code at that step.
- **Each move** links to its commit, which shows what the move changed.
- **A command to run** is in a grey block marked `bash`, and the text under it says what the command prints.
- **Under "Files to read"**, each file links to the file as the move leaves it, and to its change in the commit.

Three small walks take parts of this tutorial. Each has its own site, for
[testing](https://rahuldave.com/smallwikiapp-walk/testing/),
[linting](https://rahuldave.com/smallwikiapp-walk/linting/) and
[docs](https://rahuldave.com/smallwikiapp-walk/docs/).

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e) shows what the move changes.

click makes command lines. requests gets pages over HTTP. Both packages go in the dependencies of wikiapp.

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

### step-01.2 Ask Wikipedia for a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0) shows what the move changes.

The new `src/wikiapp/console.py` is the first code of wikiapp, from 2024, with a docstring that says what the
command does. `@click.command()` makes `main` a command. The `main` of the original wikiapp had no `-> None`. The
`main` here keeps the annotation that `uv init` gave it at step-00.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb) shows what the move changes.

The User-Agent header says who sends the request. The policy of Wikimedia asks for the name of the program,
its version, and a way to reach the person who runs it. In `src/wikiapp/console.py`, a constant `USER_AGENT`
under `API_URL` gives these three things. The request sends it as a header.

The move changed this file:

- `src/wikiapp/console.py`: a constant `USER_AGENT`, and the request sends it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2dd3e2132565971092bffe6a438a36506f4161cb/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the header.
  - look at: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

```bash
uv run wikiapp
```

A title in green, and a paragraph. Each run prints another page.

### step-01.4 --version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c) shows what the move changes.

The package can read its own version from the installed package, which has the version in `pyproject.toml`.
`src/wikiapp/__init__.py` now sets `__version__` from the metadata of the installed package.
`src/wikiapp/console.py` imports `__version__`. The decorator `@click.version_option`, above `def main`, gives
the command the option `--version`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c) shows what the move changes.

The tests need pytest, but the package does not. A person who installs wikiapp should not get pytest. So
pytest goes in a dependency group of its own, `test`. uv installs the group `dev` by default, so `dev` includes
`test`.

The first test, in `tests/test_console.py`, runs the command and checks that it ends with exit code 0. click's
`CliRunner` runs a command in the same process as the test. It keeps the output and the exit code of the command.

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

A recipe `test` runs the tests. Its words go to pytest. `"$@"` is every word after `just test`, and the recipe
gives each word to pytest whole. `just test help` shows the recipe.

`just` prints each line of a recipe before it runs the line, if the line does not start with `@`. So `just test`
prints `uv run pytest "$@"`, the command that it ran.

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
function that pytest calls for each test that names it as a parameter. The fixture `runner` returns a
`CliRunner`, and `test_main_succeeds` takes the runner as its parameter.

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
pytest-mock can replace `requests.get` with a mock for the length of one test. It goes in the group `test`.

`mocker` is the fixture of pytest-mock. A new fixture, `mock_requests_get`, calls `mocker.patch("requests.get")`.
The call replaces the function, and puts it back after the test. The line `mock.return_value.__enter__.return_value.json.return_value = {` sets what the mock returns when
the code calls `response.json()` inside the `with` block. The mock returns a page with the title Lorem Ipsum. A
new test, `test_main_prints_title`, checks that the command prints that title.

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

A mock keeps a record of each call to it. Two tests check the request. `test_main_invokes_requests_get` checks
that the command calls `requests.get`, and `test_main_uses_correct_url` checks the address. `call_args[0]` is the
tuple of the positional arguments of the last call. Here it contains only the address. The header is a keyword
argument, in `call_args[1]`.

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
mock raises it. The test `test_main_fails_on_request_error` makes the mock raise, and checks that the command
ends with exit code 1.

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

pytest-cov measures which lines of the code the tests run. It goes in the group `test`, and pytest's settings,
at the end of `pyproject.toml`, turn coverage on for every run.

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

A new module, `src/wikiapp/wikipedia.py`, contains the address, the User-Agent and the function `random_page`.
`random_page` returns the answer from inside the `with` block. The original set `data` there, and returned it
after the block. The result is the same.

The constants and the request leave `src/wikiapp/console.py`, and `main` calls `random_page`.

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
wikipedia.py, in the next move, need the mock too. So the fixture `mock_requests_get` moves from
`tests/test_console.py` to a new file, `tests/conftest.py`.

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

Each language has its own Wikipedia, at LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, the address
has a placeholder for the language. `random_page` fills it, with English as the default.

The first test of the library, in `tests/test_wikipedia.py`, asks for a page in Spanish. It checks that the
address of the request contains `es.wikipedia.org`.

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

In `src/wikiapp/console.py`, a new option `--language`, or `-l`, comes between `@click.command()` and
`@click.version_option`. `main` takes a parameter `language`, and passes it on to `random_page`.

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
`src/wikiapp/wikipedia.py`, the class `WikipediaError` comes above `random_page`. The request is now in a `try`
block, and a `RequestException` becomes a `WikipediaError`.

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

`src/wikiapp/console.py` imports the error with `random_page`. `main` catches it, and raises the exception of
click in its place. click prints that exception as a message.

A new test, `test_main_prints_message_on_request_error`, makes the mock raise a `RequestException`. It checks
that the output contains `Error`. `tests/test_console.py` now imports `requests`.

In the original wikiapp, the library raised the exception of click itself, with a note to move it to the
console one day. In this move, the exception of click moves to console.py. wikipedia.py knows Wikipedia and
requests, and console.py knows click.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9) shows what the move changes.

ruff is a formatter and a linter in one program. It goes in a third dependency group, `lint`, which `dev`
includes.

ruff's settings, at the end of `pyproject.toml`, set lines of up to 100 characters. They also write out the
defaults of the formatter.

A recipe `fmt` runs the formatter. Its words go to `ruff format`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986) shows what the move changes.

The formatter rewrites six files. It adds blank lines, puts spaces around `==`, and splits the lines longer than
100 characters.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e) shows what the move changes.

The linter checks the code against rules. A table at the end of `pyproject.toml` chooses the families of rules,
one family on each line. The tests may use `assert`. The rest of the code may not use it, because Python skips
every `assert` when it runs with `-O`.

A recipe `lint` runs the linter. Its words go to `ruff check`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf) shows what the move changes.

ruff can fix one of the five problems itself. `just lint --fix` sorts the imports of `console.py`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3ba5d239ff4f171c58d4249a33caafc510883b46) shows what the move changes.

In `tests/test_console.py`, `from wikiapp import console` moves up, under `import requests`. A reader looks for
imports there. wikiapp's own imports are a block of their own, after the installed packages, as `--fix` made them
in console.py.

In `test_main_invokes_requests_get` and `test_main_uses_correct_url`, no line reads the result. The two tests
check the mock, not the result. So the first line of each test is the call alone, without `result =`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/80c33d4cfaf4b157cd44482712e520c77378cf9c) shows what the move changes.

Without a timeout, requests waits as long as the server keeps the connection open. So the command can wait for
ever. The request in `src/wikiapp/wikipedia.py` now has `timeout=10`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a) shows what the move changes.

validate-pyproject checks `pyproject.toml` against the standard for it. It goes in the group `lint`. A recipe
`lint-config` checks the configuration with three commands. validate-pyproject checks `pyproject.toml`,
`uv lock --check` checks the lockfile, and `just --fmt --check --unstable` checks the `justfile`.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a45828b7972f3de77bd6a8d7a00a6b55833832cb) shows what the move changes.

The `justfile` exports the variable `UV_LOCKED`, under `set positional-arguments`. With it, every `uv run` of a
recipe refuses a lockfile that is out of date. Without it, `uv run` quietly updates the lockfile.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d) shows what the move changes.

A recipe `check` runs every check in order, and stops at the first check that fails. The order is the format,
the linter, the tests with a floor on the coverage, and the configuration.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db) shows what the move changes.

pre-commit installs a git hook. A git hook is a program that git runs before every commit. If the program
fails, git refuses the commit. pre-commit goes in the group `lint`.

The new file `.pre-commit-config.yaml` names the hooks. Three come from pre-commit's collection. They check for
valid YAML, large files and leftover merge-conflict markers. The last hook runs `just check`, so the hook and
the terminal run the same thing.

A recipe `hook`, after `setup` in the `justfile`, installs the hook. It is a recipe of its own, run once in each
clone, because `just setup` runs at every step and never touches git.

The move changed these files:

- `.pre-commit-config.yaml`: a new file, with the hooks.
- `justfile`: the recipe `hook`, which installs the hook.
- `pyproject.toml`: pre-commit in the group `lint`.
- `uv.lock`: the exact version of pre-commit, and of what it needs.

Files to read:
- [`.pre-commit-config.yaml`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/.pre-commit-config.yaml): three hooks from pre-commit's collection, then `just check`.
  - look at: `entry: just check`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe `hook`.
  - look at: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pre-commit in the group `lint`.
  - look at: `"pre-commit>=4.6.2",`

```bash
uv run pre-commit install
just --show hook
just hook
uv run pre-commit run --files .pre-commit-config.yaml
```

`uv run pre-commit install` prints `pre-commit installed at .git/hooks/pre-commit`, and `just hook` prints the
same line. The hook is in `.git/hooks`, and no step or move changes that folder. So the hook stays for the rest
of the tutorial. At a later step, `just hook` installs it once.

`pre-commit run` now runs every hook on the file named, as git will before a commit. The first time, it prints
`[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

With `--all-files`, pre-commit would check every file that git tracks. It would skip a new file until git tracks
it.

## step-05 Types

[The code at step-05](https://github.com/rahuldave/smallwikiapp/tree/step-05)

```bash
just setup
```

The six moves of this step add a type checker, and fix the one problem that it finds. Then a lint rule asks for
a type on every parameter and return. The last moves add the types, and put the type checker in `just check`.

### step-05.1 ty, and the recipe types

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e) shows what the move changes.

ty reads the code without running it. It finds code whose types cannot fit, for example a call whose
arguments cannot have the types that the function asks for. ty goes in the group `lint`.

A recipe `types` runs ty. It comes after the recipe `lint` in the `justfile`.

The move changed these files:

- `justfile`: the recipe `types`.
- `pyproject.toml`: ty in the group `lint`.
- `uv.lock`: the exact version of ty.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/68033d47be7dc34e8355c6812eede65f0eedcc7e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `types *args:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/68033d47be7dc34e8355c6812eede65f0eedcc7e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): ty in the group `lint`.
  - look at: `"ty>=0.0.86",`

```bash
uv run ty check
just --show types
just types
```

ty finds one problem, in `src/wikiapp/__init__.py`. The message is `Expected str, found str | None`. As far as
ty can tell, `__name__ or __package__` could be None. But `importlib.metadata.version` needs a string.

### step-05.2 The version of "wikiapp", by name

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2c744eaef504d1adcc7fba0938360d140ef49978) shows what the move changes.

`pyproject.toml` gives the name of the installed package, `wikiapp`. The last line of `src/wikiapp/__init__.py`
now asks for the version of that name, a string that is never None.

The move changed this file:

- `src/wikiapp/__init__.py`: the name, written out.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/2c744eaef504d1adcc7fba0938360d140ef49978/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2c744eaef504d1adcc7fba0938360d140ef49978#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): a string that is never None.
  - look at: `__version__ = importlib.metadata.version("wikiapp")`

```bash
just types
```

`All checks passed!`

### step-05.3 A type on every parameter and return

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/50af6273ec0db467642d539935422d0f4fc50991) shows what the move changes.

ty, the type checker that `just types` runs, checks the types that the code states. ruff's `ANN` rules make sure
that the code states a type for every parameter and return. One line in `select` of `pyproject.toml` turns them
on, after `"N"`.

The move changed this file:

- `pyproject.toml`: the rules `ANN`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/50af6273ec0db467642d539935422d0f4fc50991/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/50af6273ec0db467642d539935422d0f4fc50991#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"ANN", # annotations: every parameter and every return value has a type`

```bash
just lint --statistics
```

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). `just check` fails at this move and at the next move, and passes again at step-05.5. So the
git hook refuses to commit this move or the next. In the project's history, they are commits made past the hook.

### step-05.4 Types in the code

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/48523b8748a8bd60f80b73e1b2b2322eb616325b) shows what the move changes.

In `src/wikiapp/wikipedia.py`, `random_page` takes a string. It returns the JSON that Wikipedia sends, which is
a dictionary from strings to values of any kind. `Any` says that ty cannot check the values. The file imports
`Any` at the top, above `import requests`. The standard library is a block of its own.

In `src/wikiapp/console.py`, `main` takes the language as a string. Its return type, None, was already there.

The move changed these files:

- `src/wikiapp/wikipedia.py`: the types of `random_page`.
- `src/wikiapp/console.py`: the type of `main`'s parameter.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/48523b8748a8bd60f80b73e1b2b2322eb616325b/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48523b8748a8bd60f80b73e1b2b2322eb616325b#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the parameter and the return.
  - look at: `def random_page(language: str = "en") -> dict[str, Any]:`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/48523b8748a8bd60f80b73e1b2b2322eb616325b/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48523b8748a8bd60f80b73e1b2b2322eb616325b#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the parameter.
  - look at: `def main(language: str) -> None:`

```bash
just lint --statistics
```

The 22 problems that are left are all in the tests. They are 13 parameters and 9 returns.

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff) shows what the move changes.

Since step-05.3, ruff's `ANN` rules ask for a type on every parameter and return. The code has its types, and
`just lint` finds 22 missing in the tests.

The return type of a fixture is the type of what a test receives. The runner is a `CliRunner`, and the mock of
`requests.get` is a `Mock`. `mocker` is pytest-mock's `MockerFixture`, the name that replaced the original
wikiapp's `MockFixture`. `tests/conftest.py` now imports `Mock` and `MockerFixture`, and its fixture states both
types.

A test returns None. `tests/test_console.py` imports `Mock` and `CliRunner` by name. The fixture `runner` returns
`CliRunner()`, and every function has its types. `tests/test_wikipedia.py` imports `Mock` at the top, and its
test has its types.

The move changed these files:

- `tests/conftest.py`: the types of the fixture.
- `tests/test_console.py`: the types of the fixture and of every test.
- `tests/test_wikipedia.py`: the types of the test.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

```bash
just lint
just types
```

Both commands pass.

### step-05.6 The recipe check runs the type checker

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d) shows what the move changes.

The recipe `check` in the `justfile` now runs `just types` after `just lint`. Its comment names the types too.

The move changed this file:

- `justfile`: `check` runs the type checker.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/41990df7638f0964c66bf4e4433ffc4f5b6a026d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5) shows what the move changes.

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. In `tests/test_console.py`, it now has the marker `e2e`, which means end to end. Its new
name says so, `test_main_succeeds_in_production`. `pyproject.toml` declares the marker in `markers`. The option
`-m 'not e2e'` in `addopts` leaves the e2e tests out of every run that does not ask for them.

The move changed these files:

- `tests/test_console.py`: the marker, and the name.
- `pyproject.toml`: the marker, declared, and the e2e tests left out of a plain run.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/4ccfe3566846e64d7383837ef3e936e151c6c9d5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test, marked.
  - look at: `@pytest.mark.e2e`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4ccfe3566846e64d7383837ef3e936e151c6c9d5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the option `-m 'not e2e'`.
  - look at: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

```bash
just test -q
just test -q -m e2e
```

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

### step-06.2 An end-to-end test of the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41e5681a18bc9975f383d1520b8781c4e836e90d) shows what the move changes.

The mocks return a dictionary with a title and an extract. A second e2e test, from the original wikiapp,
checks that the real Wikipedia still returns the same keys. It is
`test_random_page_returns_dictionary_in_production`, at the end of `tests/test_wikipedia.py`. The file now
imports pytest, in a block of its own.

The move changed this file:

- `tests/test_wikipedia.py`: an e2e test.

Files to read:
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/41e5681a18bc9975f383d1520b8781c4e836e90d/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/41e5681a18bc9975f383d1520b8781c4e836e90d#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `assert "extract" in page`

```bash
just test -q -m e2e
```

The output is `2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761) shows what the move changes.

`uv init` wrote `requires-python = ">=3.13"`, because the command asked for Python 3.13. Nothing here needs
more than 3.11. Python 3.10 reached its end of life on 1 October 2026, so 3.11 is now the oldest Python that
still gets security fixes. The line in `pyproject.toml` now says 3.11, and uv solves the lockfile again.

The project still runs on 3.13, from `.python-version`.

The move changed these files:

- `pyproject.toml`: the oldest Python that the project accepts.
- `uv.lock`: solved for every Python from 3.11 on.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/15ba9fa843e3f055dac9c8f1a844b7382858b761/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `requires-python = ">=3.11"`

```bash
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`--isolated` makes a temporary environment with Python 3.11, and does not change `.venv`. The tests pass on
3.11.

### step-06.4 GitHub runs the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d3f84ea883f0e41f64fb397f436c89e372c83bff) shows what the move changes.

A GitHub Actions workflow is a file in `.github/workflows/`. GitHub runs the jobs of the workflow on every push
to main and on every pull request. The workflow `.github/workflows/test.yaml` has two jobs. The job `tests` runs
the tests on three systems and four Pythons. The job `check` runs `just check` once.

The original wikiapp used pixi for the same work, with one environment for each Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

The move changed this file:

- `.github/workflows/test.yaml`: a new file with two jobs. GitHub runs one of the jobs twelve times.

Files to read:
- [`.github/workflows/test.yaml`](https://github.com/rahuldave/smallwikiapp/blob/d3f84ea883f0e41f64fb397f436c89e372c83bff/.github/workflows/test.yaml): the matrix of systems and Pythons.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8) shows what the move changes.

The command uses two of the many keys that Wikipedia sends. Until now, the code expects these keys to be there,
with strings as values, but nothing checks it. A pydantic model states the two keys and their types in code.
pydantic is a dependency of the package, as click and requests are.

In `src/wikiapp/wikipedia.py`, the class `Page` comes after `WikipediaError`. It has a title and an extract, both
strings. The file imports `BaseModel` under `import requests`.

The move changed these files:

- `src/wikiapp/wikipedia.py`: the class `Page`.
- `pyproject.toml`: pydantic, a dependency of the package, as click and requests are.
- `uv.lock`: the exact version of pydantic, and of what it needs.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the model.
  - look at: `class Page(BaseModel):`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pydantic, a dependency of the package.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"
```

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails
with a ValidationError, because `extract` is missing.

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a) shows what the move changes.

In `src/wikiapp/wikipedia.py`, `random_page` makes a Page of the answer and returns the Page. The code no
longer uses `Any`, so its import and the blank line under it are gone.

In `src/wikiapp/console.py`, `main` prints the attributes of the page. ty and an editor know the names of the
attributes. A misspelled key of a dictionary shows up only when the program runs.

In `tests/test_wikipedia.py`, the e2e test is now `test_random_page_returns_page_in_production`, with the same
marker. Its new name says that it checks for a Page.

The move changed these files:

- `src/wikiapp/wikipedia.py`: returns a Page.
- `src/wikiapp/console.py`: prints the attributes of the Page.
- `tests/test_wikipedia.py`: the e2e test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the return.
  - look at: `return Page.model_validate(response.json())`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): attributes, not keys.
  - look at: `click.secho(page.title, fg="green")`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the e2e test checks for a Page.
  - look at: `assert isinstance(page, wikipedia.Page)`

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703) shows what the move changes.

When the answer has no title, `model_validate` raises the ValidationError of pydantic. `random_page` turns it
into a WikipediaError, as it does with a failed request. In `src/wikiapp/wikipedia.py`, the `except` catches
ValidationError together with the exception of requests.

A test from the original wikiapp, `test_random_page_handles_validation_error`, is at the end of
`tests/test_wikipedia.py`. In the test, the mock answers with an empty dictionary.

The move changed these files:

- `src/wikiapp/wikipedia.py`: a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: a test of the ValidationError.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8ef59a76a8988b6ef39a36c630e5785be2573703/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): two exceptions caught.
  - look at: `except (requests.RequestException, ValidationError) as error:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8ef59a76a8988b6ef39a36c630e5785be2573703/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `with pytest.raises(wikipedia.WikipediaError):`

```bash
just test -k validation
```

The output is `1 passed, 8 deselected`.

### step-07.4 Only a language code goes into the address

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc) shows what the move changes.

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as
`example.com/x?` sends the request to example.com, with the User-Agent. The code of every Wikipedia has only
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. In `src/wikiapp/wikipedia.py`, a pattern
`LANGUAGE` under `API_URL` matches such a code. `random_page` checks the language first, before the `try`. Any
other language raises a WikipediaError.

The move changed this file:

- `src/wikiapp/wikipedia.py`: the pattern, and the check.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the code checks a language before it uses it.
  - look at: `if not LANGUAGE.fullmatch(language):`

```bash
uv run wikiapp --language 'example.com/x?'
just test -q
```

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%. A drop in coverage is
something to know about. The tutorial adds no test to hide it.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/91672a67fa32e65564ae2fe7179d7e53e5923371) shows what the move changes.

The reference of a function gives its signature, what it does, and what each parameter is. The signature and
the types are in the code. The docstring says what the function does. A docment says what each parameter is. A
docment is the comment beside a parameter, with one parameter to a line.

The block below shows `random_page` with its docments, as the next move writes them. This move does not change
`random_page`.

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
```

smalldocs reads all three, and writes the reference as Markdown. It is a Python package, so uv installs it like
any other. smalldocs goes in a fourth dependency group, `docs`, and `dev` includes that group.

smalldocs reads its settings from `docs/_smalldocs.yml`. For now the file has one section, `api`, the
reference. It names the package to document, the address of its source, and the files of the tests to check.

`smalldocs api` has two commands that this step uses:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

A recipe `docs`, at the end of the `justfile`, gives its words to `smalldocs api`.

The move changed these files:

- `docs/_smalldocs.yml`: a new file, with the settings of the reference.
- `justfile`: the recipe `docs`.
- `pyproject.toml`: the group `docs`, with smalldocs.
- `uv.lock`: the exact version of smalldocs and of the packages it needs.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/91672a67fa32e65564ae2fe7179d7e53e5923371/docs/_smalldocs.yml): the package to document, and the tests to check.
  - look at: `packages: [wikiapp]`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/91672a67fa32e65564ae2fe7179d7e53e5923371/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/91672a67fa32e65564ae2fe7179d7e53e5923371#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/91672a67fa32e65564ae2fe7179d7e53e5923371/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/91672a67fa32e65564ae2fe7179d7e53e5923371#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e76be496f0f78f882605ca4b8a12eedf0b5b1ca9) shows what the move changes.

`src/wikiapp/wikipedia.py` gets these:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

The move changed this file:

- `src/wikiapp/wikipedia.py`: a docstring for the module, docments, and a longer docstring.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/e76be496f0f78f882605ca4b8a12eedf0b5b1ca9/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/e76be496f0f78f882605ca4b8a12eedf0b5b1ca9#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the comments are the documentation.
  - look at: `) -> Page:  # A page chosen at random`

```bash
just docs module wikipedia
```

The tables now have their descriptions.

### step-08.3 The command documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0) shows what the move changes.

`src/wikiapp/__init__.py` and `src/wikiapp/console.py` each get a docstring at the top.

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

`wikiapp --help` prints the docstring of `main` and the help of each option, so those are documentation too. The
help of `--language` now says what a language is. It replaces the help of the original wikiapp, "Gets random
page from Wikipedia in given language". `main` has one parameter to a line, with its docment, and a docstring
that says what `main` prints. A function that returns None needs no docment for its return.

The move changed these files:

- `src/wikiapp/__init__.py`: a docstring for the module.
- `src/wikiapp/console.py`: a docstring for the module, the documentation of `main`, and the help of `--language`.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the docment, the docstring and the help.
  - look at: `language: str,  # The language of the Wikipedia to ask, from --language`

```bash
just docs module console
uv run wikiapp --help
```

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b) shows what the move changes.

A docment is the comment beside a parameter, or after the colon of the `def` line for the return.
`just docs check`, from step-08.1, counts the functions and classes that have their types, docments and
docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. Each parameter of a test has a docment, one
parameter to a line, and `tests/test_console.py` shows the pattern best.

The move changed these files:

- `tests/conftest.py`: a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: a docstring for the file, the fixture and each test, and a docment for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
  - look at: `"""The language chooses the Wikipedia that is asked."""`

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c227651912e42c6e5b04771df7dcfba18b7a3538) shows what the move changes.

smalldocs also makes a website from Markdown. The site is in `docs/`. It has a front page, `index.qmd`, and a
reference page for each module. Each build writes the reference pages from the code, before it builds the site.
A name in backticks, such as `random_page`, becomes a link to its entry.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site. The front page, `docs/index.qmd`, is
new. A `.qmd` file is Markdown, with a header between two `---` lines that gives the title of the page.

`just docs` with no words builds the site, with `smalldocs render docs`. With words, it runs `smalldocs api` as
before. The recipe is now a script of several lines.

The move changed these files:

- `docs/_smalldocs.yml`: the settings of the site above the section `api`, and a comment above `api`. The
  comment at the top now says that `just docs` builds the site.
- `docs/index.qmd`: a new file, the front page.
- `justfile`: with no words, `docs` builds the site, and its comment says so. The recipe is now a script of
  several lines.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/c227651912e42c6e5b04771df7dcfba18b7a3538/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/c227651912e42c6e5b04771df7dcfba18b7a3538#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the site. The sidebar lists the front page, then the reference pages.
  - look at: `contents: api/*  # the reference pages, which each build makes from the code`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/c227651912e42c6e5b04771df7dcfba18b7a3538/docs/index.qmd): the front page, written by hand.
  - look at: `Each build of the site makes the pages under Reference from the code.`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c227651912e42c6e5b04771df7dcfba18b7a3538/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/c227651912e42c6e5b04771df7dcfba18b7a3538#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): with no words, `docs` builds the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

```bash
uv run smalldocs render docs
just --show docs
just docs
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. On the front page, `random_page` is a link to its entry. Each build makes the site and the reference
pages, and git ignores them.

### step-08.6 The README names the tests and the docs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/e17e12b81330187da0dc5eb6d1ff9f3e6964dcab) shows what the move changes.

The README gets `tests/` and `docs/` among the folders. It also says that `wikipedia.py` is the library and
`console.py` the command.

The move changed this file:

- `README.md`: rows for `tests/` and `docs/`, and the `src/wikiapp/` row names the library and the command.

Files to read:
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/e17e12b81330187da0dc5eb6d1ff9f3e6964dcab/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/e17e12b81330187da0dc5eb6d1ff9f3e6964dcab#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): the folders.
  - look at: `| The docs site. smalldocs makes its reference from the code |`

```bash
grep -n -E 'tests/|docs/' README.md
```

`grep` prints the two new rows of the table.

### step-08.7 The docs check in `just check`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/f806ffc14ec8d49a03fae320c10058db6d723f5e) shows what the move changes.

`check` now runs `just docs check` after the tests, and the comment above it names the docs among the checks.

The move changed this file:

- `justfile`: the docs check in `check`, and the comment.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/f806ffc14ec8d49a03fae320c10058db6d723f5e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/f806ffc14ec8d49a03fae320c10058db6d723f5e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in `check`.
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
makes an empty package. The next moves add the code, and make the app use the library. The README and the front
page of the docs change with the app. The last move makes the docs check count the library. Any other program
could then install wikirandom without wikiapp and click.

### step-09.1 An empty library, wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/7a3ba49a14ea0f4e049e19ecb934346025e354cb) shows what the move changes.

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
`.python-version`. The library's `pyproject.toml` then gets Python 3.11, as the app has, and a description. Its
README gets a heading and one line of what it is.

`uv lock` makes the lockfile again, for the workspace of two packages.

The move changed these files:

- `packages/wikirandom/pyproject.toml`: new. It has the package's name, version and description, and uv_build.
- `packages/wikirandom/README.md`: new. It says what the library is.
- `packages/wikirandom/src/wikirandom/__init__.py`: new. It has uv's example function, `hello`.
- `packages/wikirandom/src/wikirandom/py.typed`: new and empty. It tells ty and other checkers that the package has types.
- `pyproject.toml`: the workspace, with one member.
- `uv.lock`: the second package.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/7a3ba49a14ea0f4e049e19ecb934346025e354cb/packages/wikirandom/pyproject.toml): a package of its own.
  - look at: `name = "wikirandom"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/7a3ba49a14ea0f4e049e19ecb934346025e354cb/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/7a3ba49a14ea0f4e049e19ecb934346025e354cb#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the workspace.
  - look at: `"packages/wikirandom",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"
```

The command prints `Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`,
and runs the command there. The app does not depend on the library yet, so a plain `uv run` would not install it.

### step-09.2 The code goes into wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/edc2553f27cbaa3ebd3e97452dd74763e0a485e2) shows what the move changes.

The library needs requests and pydantic. `packages/wikirandom/src/wikirandom/__init__.py` now contains the code of
`src/wikiapp/wikipedia.py`. Its docstring says what the package is. Its User-Agent names the program that makes
the request.

The move changed these files:

- `packages/wikirandom/src/wikirandom/__init__.py`: the code of wikipedia.py.
- `packages/wikirandom/pyproject.toml`: requests and pydantic, which are the library's dependencies.
- `uv.lock`: the library's dependencies.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/edc2553f27cbaa3ebd3e97452dd74763e0a485e2/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/edc2553f27cbaa3ebd3e97452dd74763e0a485e2#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the library.
  - look at: `def random_page(`
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/edc2553f27cbaa3ebd3e97452dd74763e0a485e2/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/edc2553f27cbaa3ebd3e97452dd74763e0a485e2#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): its dependencies.
  - look at: `"pydantic>=2.14.0",`

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The command prints the title of a French page. The app still has its own `wikipedia.py`, and does not use the
library yet.

### step-09.3 The app uses wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482) shows what the move changes.

The library becomes a dependency of the app. requests and pydantic leave the app's dependencies, because the app
no longer imports them. Because wikirandom is a member of the workspace, `uv add` writes
`wikirandom = { workspace = true }` under `[tool.uv.sources]`. So uv installs the library from
`packages/wikirandom` as an editable package, and not from PyPI. `src/wikiapp/console.py` imports from the
library. ruff sorts the import with the installed packages, under `import click`.

`src/wikiapp/wikipedia.py` goes, and `tests/test_wikipedia.py` becomes `tests/test_wikirandom.py`.

The renamed file tests the library. Its docstring is `Tests of the library, wikirandom.`, and it imports
`wikirandom` under `import pytest`. Its tests call `wikirandom.random_page`, `wikirandom.Page` and
`wikirandom.WikipediaError`. The host `es.wikipedia.org` in the first test stays as it was.

Coverage, in `pyproject.toml`, measures both packages.

The README gets a row for the library, and the front page of the site, `docs/index.qmd`, now says that the
repository contains two packages.
The library's README now says that the app uses the library, and no longer that it will.

The move changed these files:

- `pyproject.toml`: wikirandom in, requests and pydantic out. The source of wikirandom is the workspace, and coverage measures both packages.
- `uv.lock`: the app's dependencies are now click and wikirandom.
- `src/wikiapp/console.py`: imports from wikirandom.
- `src/wikiapp/wikipedia.py`: deleted.
- `tests/test_wikirandom.py`: renamed from `tests/test_wikipedia.py`, and it tests wikirandom.
- `README.md`: a row for the library, and the `src/wikiapp/` row says the app.
- `docs/index.qmd`: two packages, the library and the app.
- `packages/wikirandom/README.md`: says that wikiapp uses the library now.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app depends on the library.
  - look at: `wikirandom = { workspace = true }`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): one import.
  - look at: `from wikirandom import WikipediaError, random_page`
- [`tests/test_wikirandom.py`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/tests/test_wikirandom.py): the same three tests.
  - look at: `wikirandom.random_page(language="es")`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/README.md), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): one row more, and the `src/wikiapp/` row says the app.
  - look at: `| The library the app uses: a random page of Wikipedia. A package of its own |`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482/docs/index.qmd), [its change](https://github.com/rahuldave/smallwikiapp/commit/21b69a2c7ff628cf5726eec4eb986c7f3e8a6482#diff-bfcaadbc044f4848960f04c96f4ac5930e20671e52514c04dd8347ff6f79ca7b): two packages.
  - look at: `The code has two packages, in one repository:`

```bash
just test -q
uv tree --depth 2
just docs check
just docs
```

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`. `uv tree` shows that wikiapp needs click and wikirandom, and
that wikirandom needs requests and pydantic. `just docs check` still counts the app and the tests alone, 12 of 12. `just docs`
writes 2 pages, the front page and the reference page of the app. The front page names both packages, but
`random_page` is not yet a link, because the settings of the site name only the app. The next move adds the
library to the settings.

### step-09.4 The docs check counts the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a248f43de21ce0b11b11c2b31e8e8e656c2ba465) shows what the move changes.

Since step-09.3, the app uses the library `wikirandom`, a package of its own in `packages/wikirandom`. But
`docs/_smalldocs.yml` names only `wikiapp`. The line `packages:` in the section `api` now names both.

The move changed this file:

- `docs/_smalldocs.yml`: two packages.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/a248f43de21ce0b11b11c2b31e8e8e656c2ba465/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/commit/a248f43de21ce0b11b11c2b31e8e8e656c2ba465#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the list.
  - look at: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

```bash
just docs check
just docs
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and on the front page, `random_page` is now a link to its entry. `just check` passes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/14aed169df3350fa2bf674e896bdf6921cf4efcf) shows what the move changes.

`uv build --all-packages` builds every package of the workspace into `dist/`, which `.gitignore` lists. The
recipe `build`, at the end of the `justfile`, runs it.

The move changed this file:

- `justfile`: the recipe `build`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/14aed169df3350fa2bf674e896bdf6921cf4efcf/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/14aed169df3350fa2bf674e896bdf6921cf4efcf#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29) shows what the move changes.

The app's wheel says that the app needs `wikirandom`, of any version. An install from PyPI would take any package
that anyone publishes under that name. The app now gives the range of versions that it was built and tested with.

Nothing else changes in the workspace. `[tool.uv.sources]` still installs the library from
`packages/wikirandom`.

The move changed this file:

- `pyproject.toml`: a version range on wikirandom.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"wikirandom>=0.1.0,<0.2",`

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

### step-10.3 lint-config checks both pyproject.toml files

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5680a827b9d6a412d145df259dd161119c4cd776) shows what the move changes.

Since step 09, the repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. The
recipe `lint-config` now gives validate-pyproject both files.

The move changed this file:

- `justfile`: `lint-config` checks both files.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5680a827b9d6a412d145df259dd161119c4cd776/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/5680a827b9d6a412d145df259dd161119c4cd776#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.

### step-10.4 A licence and a repository link for both

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2aebc089ca4228042b83c2158c10484a3b495800) shows what the move changes.

The library's wheel has no licence, and neither package says where its source is. The library gets a copy of the
project's `LICENSE`. Its `pyproject.toml` gives the licence and the author under `readme`, as the app's
`pyproject.toml` does. Both `pyproject.toml` files now name the repository, in `[project.urls]`. PyPI shows it on
the package's page.

The move changed these files:

- `packages/wikirandom/LICENSE`: new. It has the same licence as the app.
- `packages/wikirandom/pyproject.toml`: the licence, the author, the repository.
- `pyproject.toml`: the repository.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aebc089ca4228042b83c2158c10484a3b495800/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aebc089ca4228042b83c2158c10484a3b495800#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): what PyPI would show.
  - look at: `license = "Apache-2.0"`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aebc089ca4228042b83c2158c10484a3b495800/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aebc089ca4228042b83c2158c10484a3b495800#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app's repository.
  - look at: `[project.urls]`
- [`packages/wikirandom/LICENSE`](https://github.com/rahuldave/smallwikiapp/blob/2aebc089ca4228042b83c2158c10484a3b495800/packages/wikirandom/LICENSE): the same Apache-2.0 licence as the app's.
  - look at: `Apache License`

```bash
just build
unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA
```

The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

### step-10.5 The User-Agent says the installed version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1c85536347dae57de53a25fc84b7797180a6ae27) shows what the move changes.

The User-Agent says `0.1.0`, written by hand. It would still say `0.1.0` after a change of the version in
`packages/wikirandom/pyproject.toml`. `packages/wikirandom/src/wikirandom/__init__.py` now reads the version
from the installed package, as `wikiapp --version` does. `import importlib.metadata` comes above `import re`, in
the same block. `VERSION` is the installed version, and `USER_AGENT` contains it.

The move changed this file:

- `packages/wikirandom/src/wikirandom/__init__.py`: the package reads its version once, when Python imports it.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/1c85536347dae57de53a25fc84b7797180a6ae27/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/1c85536347dae57de53a25fc84b7797180a6ae27#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the version now comes from one place, pyproject.toml.
  - look at: `VERSION = importlib.metadata.version("wikirandom")`

```bash
uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"
just check
```

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.
