<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

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
When the library starts to return a pydantic model, one move renames a test, and the next adds one. The last move
documents the tests.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

Between its steps, the whole tutorial makes moves that this walk does not show:

- **Before step-05.5,** [step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) and the first four moves of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html).
  ruff formats the code and lints it, and the request gets a timeout of 10 seconds. ruff also formats the
  tests, moves their imports to the top and removes unused variables. `just check` fails when the tests run less
  than 90% of the code. `just check` runs every check, and pre-commit runs it as a git hook
  before each commit. ty checks the types, and `just types` runs it. ruff's `ANN` rules ask for a type on
  every parameter and return, and the code gets its types.
- **Before step-06,** the last move of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). `just check` runs `just types` too.
- **Before step-07.2,** the move [step-07.1](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html#step-07.1). pydantic comes in, and
  `wikipedia.py` gets `Page`, a pydantic model with a title and an extract.
- **Before step-08.4,** the last move of [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html) and the first three moves of
  [step-08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html). `random_page` checks the language before it puts it in the address. smalldocs
  comes in, and `just docs check` counts the functions and classes that have their types, docments and
  docstrings. The library and the command get theirs.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.

## step-02 Tests, with mocks

[The code at step-02](https://github.com/rahuldave/smallwikiapp/tree/step-02)

```bash
just setup
```

The moves of this step add pytest and a first test, a recipe for the tests, and a fixture. The fourth move puts a
mock in place of Wikipedia, with a test of the title. The last three moves add three more tests, and coverage on
every run. One test asks the real Wikipedia, so the tests need the network until step 06.

### step-02.1 pytest and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c) shows what the move changes.

Now we install pytest, the tool that runs the tests. The tests need pytest, but the package does not. A person who
installs wikiapp should not get pytest. So pytest goes in a dependency group of its own, `test`. uv installs the
group `dev` by default, so `dev` includes `test`.

Read the change of `pyproject.toml`.

Next we write the first test, in `tests/test_console.py`, which runs the command and checks that it ends with exit
code 0. click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code
of the command.

Open `tests/test_console.py`, a new file.

The move changes these files:

- `pyproject.toml`: 6 lines added; the groups `test` and `dev`.
- `tests/test_console.py`: 8 lines added; the first test.
- `uv.lock`: 73 lines added; pytest and what it needs.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the groups.
  - look at: `dev = [{ include-group = "test" }]`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/tests/test_console.py): a test that runs the command and checks its exit code.
  - look at: `assert result.exit_code == 0`

The change of `pyproject.toml`:

```diff
@@ -15,6 +15,12 @@ dependencies = [
 [project.scripts]
 wikiapp = "wikiapp.console:main"
 
+[dependency-groups]
+test = [
+    "pytest>=9.1.1",
+]
+dev = [{ include-group = "test" }]
+
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
```

```bash
uv run pytest
```

The result is `1 passed`. The test asks the real Wikipedia, so it needs the network.

### step-02.2 The recipe `just test`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a) shows what the move changes.

Now we add a recipe to the `justfile`, `test`, which runs the tests. The words after `just test` go to pytest.
`"$@"` stands for those words, and the recipe gives each word to pytest whole. `just test help` shows the recipe.

Read the change of `justfile`.

`just` prints each line of a recipe before it runs the line, if the line does not start with `@`. So `just test`
prints `uv run pytest "$@"`, the command that it ran.

The move changes one file:

- `justfile`: 6 lines added; the recipe `test`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/94970c50651566f11d5c9d017cb01004e240821a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/94970c50651566f11d5c9d017cb01004e240821a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `test *args:`

The change of `justfile`:

```diff
@@ -19,3 +19,9 @@ help *verb:
 [group('setup')]
 setup *args:
     @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
+
+# Run the tests. Extra arguments go to pytest: just test -k title
+[group('quality')]
+[no-exit-message]
+test *args:
+    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

```bash
just --show test
just test
```

The result is the same, `1 passed`.

### step-02.3 The runner as a fixture

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534) shows what the move changes.

Now we move the `CliRunner` into a fixture, `runner`, which returns it. Each test of the command needs a
`CliRunner`. A fixture is a function that pytest calls for each test that names it as a parameter. So
`test_main_succeeds` takes the runner as its parameter.

Read the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 6 lines added, 2 removed; the fixture `runner`, and `test_main_succeeds` takes the runner from it.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/cd31b8a082b8c3ecf168413a21e06b9888480534/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture, and the test that names it.
  - look at: `def test_main_succeeds(runner):`

The change of `tests/test_console.py`:

```diff
@@ -1,8 +1,12 @@
 import click.testing
+import pytest
+
+@pytest.fixture
+def runner():
+    return click.testing.CliRunner()
 
 from wikiapp import console
 
-def test_main_succeeds():
-    runner = click.testing.CliRunner()
+def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just test
```

The test passes as before, with `1 passed`. It still asks the real Wikipedia.

### step-02.4 A mock in place of Wikipedia

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5) shows what the move changes.

Now we replace `requests.get` with a mock in the tests. A test that needs the network fails on a train. Also, a
test cannot check the title of a random page. pytest-mock can replace `requests.get` with a mock for the length of
one test. It goes in the group `test`.

`mocker` is the fixture of pytest-mock. A new fixture, `mock_requests_get`, calls `mocker.patch("requests.get")`.
The call replaces the function, and puts it back after the test. The line `mock.return_value.__enter__.return_value.json.return_value = {` sets what the mock returns when
the code calls `response.json()` inside the `with` block. The mock returns a page with the title Lorem Ipsum. A
new test, `test_main_prints_title`, checks that the command prints that title.

Read the change of `pyproject.toml`. Find `mock = mocker.patch("requests.get")` in the change of
`tests/test_console.py`.

The move changes these files:

- `tests/test_console.py`: 13 lines added; the fixture of the mock, and a test of the title.
- `pyproject.toml`: 1 line added; pytest-mock in the group `test`.
- `uv.lock`: 22 lines added, 2 removed; the exact version of pytest-mock.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/2aaab1063eca2f40fbc281e2e038c18419ca88c5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture of the mock, and the new test.
  - look at: `mock = mocker.patch("requests.get")`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/2aaab1063eca2f40fbc281e2e038c18419ca88c5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/2aaab1063eca2f40fbc281e2e038c18419ca88c5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pytest-mock in the group `test`.
  - look at: `"pytest-mock>=3.16.0",`

The change of `tests/test_console.py`:

```diff
@@ -5,8 +5,21 @@ import pytest
 def runner():
     return click.testing.CliRunner()
 
+@pytest.fixture
+def mock_requests_get(mocker):
+    mock = mocker.patch("requests.get")
+    mock.return_value.__enter__.return_value.json.return_value = {
+        "title": "Lorem Ipsum",
+        "extract": "Lorem ipsum dolor sit amet",
+    }
+    return mock
+
 from wikiapp import console
 
+def test_main_prints_title(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert "Lorem Ipsum" in result.output
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `pyproject.toml`:

```diff
@@ -18,6 +18,7 @@ wikiapp = "wikiapp.console:main"
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
+    "pytest-mock>=3.16.0",
 ]
 dev = [{ include-group = "test" }]
 
```

```bash
just test -k title -v
```

The output shows `test_main_prints_title PASSED`, without the network.

### step-02.5 Tests of the request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f) shows what the move changes.

Now we add two tests of the request to `tests/test_console.py`. A mock keeps a record of each call to it.
`test_main_invokes_requests_get` checks that the command calls `requests.get`, and `test_main_uses_correct_url`
checks the address. `call_args[0]` is the tuple of the positional arguments of the last call. Here it contains
only the address. The header is a keyword argument, in `call_args[1]`.

Read the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 8 lines added; two tests of the request.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/d5b4cd09ab495ecb8043176f8cca3f9a657fe00f#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the code makes the request, to the right address.
  - look at: `assert mock_requests_get.called`

The change of `tests/test_console.py`:

```diff
@@ -20,6 +20,14 @@ def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
+def test_main_invokes_requests_get(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert mock_requests_get.called
+
+def test_main_uses_correct_url(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just test
```

The result is `4 passed`.

### step-02.6 A test of a failed request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7) shows what the move changes.

Now we add a test, `test_main_fails_on_request_error`, to `tests/test_console.py`. It makes the mock raise, and
checks that a failed request ends the command with exit code 1. A mock can raise an exception as well as return a
value. If `side_effect` is an exception, a call to the mock raises it.

Find `mock_requests_get.side_effect = Exception("Boom")` in the change of `tests/test_console.py`.

The move changes one file:

- `tests/test_console.py`: 5 lines added; a test that a failed request ends the command with exit code 1.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/16b52dc4f9ec6e997b6954efde180ba6d7f521c7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/16b52dc4f9ec6e997b6954efde180ba6d7f521c7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the mock raises.
  - look at: `mock_requests_get.side_effect = Exception("Boom")`

The change of `tests/test_console.py`:

```diff
@@ -28,6 +28,11 @@ def test_main_uses_correct_url(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
 
+def test_main_fails_on_request_error(runner, mock_requests_get):
+    mock_requests_get.side_effect = Exception("Boom")
+    result = runner.invoke(console.main)
+    assert result.exit_code == 1
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
just test
```

The result is `5 passed`.

### step-02.7 Coverage

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef) shows what the move changes.

Now we measure the coverage of the tests on every run. pytest-cov measures which lines of the code the tests run.
It goes in the group `test`, and pytest's settings, at the end of `pyproject.toml`, turn coverage on for every run.

Read the change of `pyproject.toml`.

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented out.
No test used them, so the project does not keep them.

The move changes these files:

- `pyproject.toml`: 6 lines added; pytest-cov in the group `test`, and pytest's settings.
- `uv.lock`: 102 lines added; pytest-cov and coverage.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/bed3c6029878c71bef05322712c388dfb8c058ef/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): coverage on every run.
  - look at: `addopts = "--cov=wikiapp --cov-report=term-missing"`

The change of `pyproject.toml`:

```diff
@@ -18,6 +18,7 @@ wikiapp = "wikiapp.console:main"
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
+    "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
 dev = [{ include-group = "test" }]
@@ -25,3 +26,8 @@ dev = [{ include-group = "test" }]
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
+
+[tool.pytest.ini_options]
+testpaths = ["tests"]
+# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
+addopts = "--cov=wikiapp --cov-report=term-missing"
```

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

Now we move the request into a new module, `src/wikiapp/wikipedia.py`, with the address, the User-Agent and a
function, `random_page`. `random_page` returns the answer from inside the `with` block. The original set `data`
there, and returned it after the block. The result is the same.

Open `src/wikiapp/wikipedia.py`, a new file.

Next we take the constants and the request out of `src/wikiapp/console.py`, and `main` calls `random_page`.

Find `data = random_page()` in the change of `src/wikiapp/console.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 10 lines added; a new file with the address, the User-Agent, and `random_page`.
- `src/wikiapp/console.py`: 6 lines added, 10 removed; `main` calls `random_page`.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/fec316ee50d27867f0dab60a755372ce1d1839d1/src/wikiapp/wikipedia.py): the code that talks to Wikipedia.
  - look at: `def random_page():`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/fec316ee50d27867f0dab60a755372ce1d1839d1/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/fec316ee50d27867f0dab60a755372ce1d1839d1#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): only the command stays.
  - look at: `data = random_page()`

The change of `src/wikiapp/console.py`:

```diff
@@ -1,22 +1,18 @@
 import click
 from wikiapp import __version__
-import requests
 import textwrap
 
-API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
-USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+from wikiapp.wikipedia import random_page
 
 @click.command()
 @click.version_option(version=__version__)
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
-    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
-        response.raise_for_status()
-        data = response.json()
-        title = data["title"]
-        extract = data["extract"]
-        click.secho(title, fg="green")
-        click.echo(textwrap.fill(extract))
+    data = random_page()
+    title = data["title"]
+    extract = data["extract"]
+    click.secho(title, fg="green")
+    click.echo(textwrap.fill(extract))
 
 if __name__=="__main__":
     main()
```

```bash
just test
```

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. wikipedia.py calls the function through the module, as `requests.get`, so it gets the mock.

### step-03.2 The mock moves to conftest.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e) shows what the move changes.

Now we share the mock with every test file. pytest reads `tests/conftest.py` before the tests, and every test file
can use a fixture in it. The tests of wikipedia.py, in the next move, need the mock too. So the fixture
`mock_requests_get` moves from `tests/test_console.py` to a new file, `tests/conftest.py`.

Open `tests/conftest.py`, a new file. Read the change of `tests/test_console.py`.

The move changes these files:

- `tests/conftest.py`: 10 lines added; a new file with the mock.
- `tests/test_console.py`: 9 lines removed; the mock is gone.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/conftest.py): the fixture, for every test file.
  - look at: `def mock_requests_get(mocker):`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture is gone, but the tests still name it.

The change of `tests/test_console.py`:

```diff
@@ -5,15 +5,6 @@ import pytest
 def runner():
     return click.testing.CliRunner()
 
-@pytest.fixture
-def mock_requests_get(mocker):
-    mock = mocker.patch("requests.get")
-    mock.return_value.__enter__.return_value.json.return_value = {
-        "title": "Lorem Ipsum",
-        "extract": "Lorem ipsum dolor sit amet",
-    }
-    return mock
-
 from wikiapp import console
 
 def test_main_prints_title(runner, mock_requests_get):
```

```bash
just test
```

The result is `5 passed`. pytest finds the fixture in conftest.py.

### step-03.3 A language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4) shows what the move changes.

Now we let `random_page` ask the Wikipedia of a language. Each language has its own Wikipedia, at
LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, the address has a placeholder for the language.
`random_page` fills it, with English as the default.

Read the change of `src/wikiapp/wikipedia.py`.

Then we write the first test of the library, in `tests/test_wikipedia.py`, which asks for a page in Spanish. It
checks that the address of the request contains `es.wikipedia.org`.

Open `tests/test_wikipedia.py`, a new file.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 3 lines added, 3 removed; `random_page` takes a language.
- `tests/test_wikipedia.py`: 6 lines added; a new file with a test that the language chooses the Wikipedia.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the placeholder, and the code that fills it.
  - look at: `def random_page(language="en"):`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/tests/test_wikipedia.py): the test uses the mock from conftest.py.
  - look at: `assert "es.wikipedia.org" in args[0]`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,10 +1,10 @@
 import requests
 
-API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
-def random_page():
+def random_page(language="en"):
     """Get a random page from Wikipedia."""
-    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
+    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
         response.raise_for_status()
         return response.json()
```

```bash
just test
```

The result is `6 passed`.

### step-03.4 wikiapp --language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f) shows what the move changes.

Now we let the user choose the language of the page. In `src/wikiapp/console.py`, a new option `--language`, or
`-l`, comes between `@click.command()` and `@click.version_option`. `main` takes a parameter `language`, and passes
it on to `random_page`.

Read the change of `src/wikiapp/console.py`.

click gives the value of the option to the parameter with the same name.

The move changes one file:

- `src/wikiapp/console.py`: 10 lines added, 2 removed; the option `--language`, or `-l`.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3bd5616ab15d6b2b526784e8b3b014bceef2548f/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3bd5616ab15d6b2b526784e8b3b014bceef2548f#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the option, which `main` gives to `random_page`.
  - look at: `data = random_page(language=language)`

The change of `src/wikiapp/console.py`:

```diff
@@ -5,10 +5,18 @@ import textwrap
 from wikiapp.wikipedia import random_page
 
 @click.command()
+@click.option(
+    "--language",
+    "-l",
+    default="en",
+    help="Gets random page from Wikipedia in given language",
+    metavar="LANG",
+    show_default=True,
+)
 @click.version_option(version=__version__)
-def main() -> None:
+def main(language) -> None:
     """Print the title and summary of a random Wikipedia page."""
-    data = random_page()
+    data = random_page(language=language)
     title = data["title"]
     extract = data["extract"]
     click.secho(title, fg="green")
```

```bash
uv run wikiapp --language fr
uv run wikiapp --help
```

The first command prints a French page. `--help` lists the option, its short form and its default.

### step-03.5 WikipediaError

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea) shows what the move changes.

Now we make `random_page` raise an exception of the library when a request fails. If a request fails for any
reason, requests raises a `RequestException`. Code that uses the library should not need to know the exceptions of
requests. So the library raises an exception of its own. In `src/wikiapp/wikipedia.py`, the class `WikipediaError`
comes above `random_page`. The request is now in a `try` block, and a `RequestException` becomes a
`WikipediaError`.

Read the change of `src/wikiapp/wikipedia.py`.

`from error` keeps the original exception, so a traceback shows both exceptions.

The move changes one file:

- `src/wikiapp/wikipedia.py`: 9 lines added, 3 removed; the class `WikipediaError`, which `random_page` raises.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/56214d31141adcc3dab1ecdd7545b94b03c7f0ea/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/56214d31141adcc3dab1ecdd7545b94b03c7f0ea#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the exception, and the line that raises it.
  - look at: `raise WikipediaError(str(error)) from error`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -3,8 +3,14 @@ import requests
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
+class WikipediaError(Exception):
+    """Wikipedia could not give a page."""
+
 def random_page(language="en"):
     """Get a random page from Wikipedia."""
-    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
-        response.raise_for_status()
-        return response.json()
+    try:
+        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
+            response.raise_for_status()
+            return response.json()
+    except requests.RequestException as error:
+        raise WikipediaError(str(error)) from error
```

```bash
uv run wikiapp --language xx
```

There is no Wikipedia in the language `xx`, so the name `xx.wikipedia.org` does not resolve. The command ends in
a traceback, and the last line is the `WikipediaError`. No code catches the error yet.

### step-03.6 The command prints the error

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7) shows what the move changes.

Now we make `main` print a `WikipediaError` as a message. `src/wikiapp/console.py` imports the error with
`random_page`. `main` catches it, and raises the exception of click in its place. click prints that exception as a
message.

In the original wikiapp, the library raised the exception of click itself, with a note to move it to the
console one day. In this move, the exception of click moves to console.py. wikipedia.py knows Wikipedia and
requests, and console.py knows click.

Read the change of `src/wikiapp/console.py`.

Then we add a test, `test_main_prints_message_on_request_error`, which makes the mock raise a `RequestException`.
It checks that the output contains `Error`. `tests/test_console.py` now imports `requests`.

Find `mock_requests_get.side_effect = requests.RequestException` in the change of `tests/test_console.py`.

The move changes these files:

- `src/wikiapp/console.py`: 5 lines added, 2 removed; `main` catches WikipediaError.
- `tests/test_console.py`: 6 lines added; a test of the message.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the error becomes a message.
  - look at: `raise click.ClickException(str(error)) from error`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test.
  - look at: `assert "Error" in result.output`

The change of `src/wikiapp/console.py`:

```diff
@@ -2,7 +2,7 @@ import click
 from wikiapp import __version__
 import textwrap
 
-from wikiapp.wikipedia import random_page
+from wikiapp.wikipedia import WikipediaError, random_page
 
 @click.command()
 @click.option(
@@ -16,7 +16,10 @@ from wikiapp.wikipedia import random_page
 @click.version_option(version=__version__)
 def main(language) -> None:
     """Print the title and summary of a random Wikipedia page."""
-    data = random_page(language=language)
+    try:
+        data = random_page(language=language)
+    except WikipediaError as error:
+        raise click.ClickException(str(error)) from error
     title = data["title"]
     extract = data["extract"]
     click.secho(title, fg="green")
```

The change of `tests/test_console.py`:

```diff
@@ -1,5 +1,6 @@
 import click.testing
 import pytest
+import requests
 
 @pytest.fixture
 def runner():
@@ -24,6 +25,11 @@ def test_main_fails_on_request_error(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
+def test_main_prints_message_on_request_error(runner, mock_requests_get):
+    mock_requests_get.side_effect = requests.RequestException
+    result = runner.invoke(console.main)
+    assert "Error" in result.output
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

```bash
uv run wikiapp --language xx; echo "exit code $?"
just test
```

The first command prints `Error:` and the message in place of a traceback, then `exit code 1`. The tests give
`7 passed`.

## step-05.5 Types in the tests

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/48523b8748a8bd60f80b73e1b2b2322eb616325b), the commit before step-05.5.

```bash
just setup
```

### step-05.5 Types in the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8f6e8938925501f9c1bc198818fbd8fab7b647ff) shows what the move changes.

Now we add the types to the tests, first to the fixture in `tests/conftest.py`. Since step-05.3, ruff's `ANN`
rules ask for a type on every parameter and return. The code has its types, and `just lint` finds 22 missing in
the tests.

The return type of a fixture is the type of what a test receives. The mock of `requests.get` is a `Mock`.
`mocker` is pytest-mock's `MockerFixture`, the name that replaced the original wikiapp's `MockFixture`.
`tests/conftest.py` now imports `Mock` and `MockerFixture`, and its fixture states both types.

Find `def mock_requests_get(mocker: MockerFixture) -> Mock:` in the change of `tests/conftest.py`.

Next we add the types to `tests/test_console.py` and `tests/test_wikipedia.py`. A test returns None.
`tests/test_console.py` imports `Mock` and `CliRunner` by name. The fixture `runner` returns `CliRunner()`, so its
return type is `CliRunner`. Every function has its types. `tests/test_wikipedia.py` imports `Mock` at the top, and
its test has its types.

Read the change of `tests/test_console.py`. Then find
`def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:` in the change of
`tests/test_wikipedia.py`.

The move changes these files:

- `tests/conftest.py`: 4 lines added, 1 removed; the types of the fixture.
- `tests/test_console.py`: 11 lines added, 9 removed; the types of the fixture and of every test.
- `tests/test_wikipedia.py`: 3 lines added, 1 removed; the types of the test.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/48523b8748a8bd60f80b73e1b2b2322eb616325b...8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture returns a Mock.
  - look at: `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/48523b8748a8bd60f80b73e1b2b2322eb616325b...8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the runner is a CliRunner.
  - look at: `def runner() -> CliRunner:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8f6e8938925501f9c1bc198818fbd8fab7b647ff/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/48523b8748a8bd60f80b73e1b2b2322eb616325b...8f6e8938925501f9c1bc198818fbd8fab7b647ff#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): one test.
  - look at: `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

The change of `tests/conftest.py`:

```diff
@@ -1,8 +1,11 @@
+from unittest.mock import Mock
+
 import pytest
+from pytest_mock import MockerFixture
 
 
 @pytest.fixture
-def mock_requests_get(mocker):
+def mock_requests_get(mocker: MockerFixture) -> Mock:
     mock = mocker.patch("requests.get")
     mock.return_value.__enter__.return_value.json.return_value = {
         "title": "Lorem Ipsum",
```

The change of `tests/test_console.py`:

```diff
@@ -1,44 +1,46 @@
-import click.testing
+from unittest.mock import Mock
+
 import pytest
 import requests
+from click.testing import CliRunner
 
 from wikiapp import console
 
 
 @pytest.fixture
-def runner():
-    return click.testing.CliRunner()
+def runner() -> CliRunner:
+    return CliRunner()
 
 
-def test_main_prints_title(runner, mock_requests_get):
+def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
-def test_main_invokes_requests_get(runner, mock_requests_get):
+def test_main_invokes_requests_get(runner: CliRunner, mock_requests_get: Mock) -> None:
     runner.invoke(console.main)
     assert mock_requests_get.called
 
 
-def test_main_uses_correct_url(runner, mock_requests_get):
+def test_main_uses_correct_url(runner: CliRunner, mock_requests_get: Mock) -> None:
     runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
 
 
-def test_main_fails_on_request_error(runner, mock_requests_get):
+def test_main_fails_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
 
-def test_main_prints_message_on_request_error(runner, mock_requests_get):
+def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
 
-def test_main_succeeds(runner):
+def test_main_succeeds(runner: CliRunner) -> None:
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -1,7 +1,9 @@
+from unittest.mock import Mock
+
 from wikiapp import wikipedia
 
 
-def test_random_page_uses_given_language(mock_requests_get):
+def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
```

```bash
just lint
just types
```

Both commands pass.

## step-06 End to end, and CI

[The code at step-06](https://github.com/rahuldave/smallwikiapp/tree/step-06)

```bash
just setup
```

The moves of this step do three things. The tests that ask the real Wikipedia run only when you ask for them.
The project accepts every Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

### step-06.1 The end-to-end test runs only on request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5) shows what the move changes.

Now we mark the test that asks the real Wikipedia, so that it runs only on request.

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. In `tests/test_console.py`, it now has the marker `e2e`, which means end to end. Its new
name says so, `test_main_succeeds_in_production`. `pyproject.toml` declares the marker in `markers`. The option
`-m 'not e2e'` in `addopts` leaves the e2e tests out of every run that does not ask for them.

Find `@pytest.mark.e2e` in the change of `tests/test_console.py`. Then read the change of `pyproject.toml`.

The move changes these files:

- `tests/test_console.py`: 2 lines added, 1 removed; the marker, and the name.
- `pyproject.toml`: 5 lines added, 2 removed; the marker, declared, and the e2e tests left out of a plain run.

Files to read:
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/4ccfe3566846e64d7383837ef3e936e151c6c9d5/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test, marked.
  - look at: `@pytest.mark.e2e`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4ccfe3566846e64d7383837ef3e936e151c6c9d5/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the option `-m 'not e2e'`.
  - look at: `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`

The change of `tests/test_console.py`:

```diff
@@ -41,6 +41,7 @@ def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_g
     assert "Error" in result.output
 
 
-def test_main_succeeds(runner: CliRunner) -> None:
+@pytest.mark.e2e
+def test_main_succeeds_in_production(runner: CliRunner) -> None:
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

The change of `pyproject.toml`:

```diff
@@ -35,8 +35,11 @@ build-backend = "uv_build"
 
 [tool.pytest.ini_options]
 testpaths = ["tests"]
-# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
-addopts = "--cov=wikiapp --cov-report=term-missing"
+# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
+# marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
+# just test -m e2e
+addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
+markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
 
 [tool.ruff]
 # The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
```

```bash
just test -q
just test -q -m e2e
```

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

### step-06.2 An end-to-end test of the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41e5681a18bc9975f383d1520b8781c4e836e90d) shows what the move changes.

Now we add an end-to-end test of the library, `random_page`. The mocks return a dictionary with a title and an
extract. A second e2e test, from the original wikiapp, checks that the real Wikipedia still returns the same keys.
It is `test_random_page_returns_dictionary_in_production`, at the end of `tests/test_wikipedia.py`. The file now
imports pytest, in a block of its own.

Find `def test_random_page_returns_dictionary_in_production() -> None:` in the change of `tests/test_wikipedia.py`.

The move changes one file:

- `tests/test_wikipedia.py`: 9 lines added; an e2e test.

Files to read:
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/41e5681a18bc9975f383d1520b8781c4e836e90d/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/41e5681a18bc9975f383d1520b8781c4e836e90d#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `assert "extract" in page`

The change of `tests/test_wikipedia.py`:

```diff
@@ -1,5 +1,7 @@
 from unittest.mock import Mock
 
+import pytest
+
 from wikiapp import wikipedia
 
 
@@ -7,3 +9,10 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
+
+
+@pytest.mark.e2e
+def test_random_page_returns_dictionary_in_production() -> None:
+    page = wikipedia.random_page()
+    assert "title" in page
+    assert "extract" in page
```

```bash
just test -q -m e2e
```

The output is `2 passed, 6 deselected`.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761) shows what the move changes.

Now we let the project accept every Python from 3.11 on. `uv init` wrote `requires-python = ">=3.13"`, because the
command asked for Python 3.13. Nothing here needs more than 3.11. Python 3.10 reached its end of life on 1 October
2026, so 3.11 is now the oldest Python that still gets security fixes. The line in `pyproject.toml` now says 3.11,
and uv solves the lockfile again.

Find `requires-python = ">=3.11"` in the change of `pyproject.toml`.

The project still runs on 3.13, from `.python-version`.

The move changes these files:

- `pyproject.toml`: 1 line added, 1 removed; the oldest Python that the project accepts.
- `uv.lock`: 160 lines added, 2 removed; solved for every Python from 3.11 on.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/15ba9fa843e3f055dac9c8f1a844b7382858b761/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `requires-python = ">=3.11"`

The change of `pyproject.toml`:

```diff
@@ -6,7 +6,7 @@ readme = "README.md"
 license = "Apache-2.0"
 license-files = ["LICENSE"]
 authors = [{ name = "Rahul Dave" }]
-requires-python = ">=3.13"
+requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
     "requests>=2.34.2",
```

```bash
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`--isolated` makes a temporary environment with Python 3.11, and does not change `.venv`. The tests pass on
3.11.

### step-06.4 GitHub runs the tests

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d3f84ea883f0e41f64fb397f436c89e372c83bff) shows what the move changes.

Now we add a GitHub Actions workflow, which runs the tests on the machines of GitHub. A GitHub Actions workflow is
a file in `.github/workflows/`. GitHub runs the jobs of the workflow on every push to main and on every pull
request. The workflow `.github/workflows/test.yaml` has two jobs. The job `tests` runs the tests on three systems
and four Pythons. The job `check` runs `just check` once.

Open `.github/workflows/test.yaml`, a new file. Find `python: ["3.11", "3.12", "3.13", "3.14"]` in it.

The original wikiapp used pixi for the same work, with one environment for each Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

The move changes one file:

- `.github/workflows/test.yaml`: 37 lines added; a new file with two jobs. GitHub runs one of the jobs twelve times.

Files to read:
- [`.github/workflows/test.yaml`](https://github.com/rahuldave/smallwikiapp/blob/d3f84ea883f0e41f64fb397f436c89e372c83bff/.github/workflows/test.yaml): the matrix of systems and Pythons.
  - look at: `python: ["3.11", "3.12", "3.13", "3.14"]`

```bash
uv run pre-commit run check-yaml --files .github/workflows/test.yaml
```

The file is valid YAML. GitHub runs the workflow after a push. The **Actions** tab of the repository shows the
thirteen jobs.

## step-07.2 to step-07.3

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8), the commit before step-07.2.

```bash
just setup
```

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a) shows what the move changes.

Now we make `random_page`, in `src/wikiapp/wikipedia.py`, return a Page made from the answer. The code no longer
uses `Any`, so its import and the blank line under it are gone.

Find `return Page.model_validate(response.json())` in the change of `src/wikiapp/wikipedia.py`.

Next we make `main`, in `src/wikiapp/console.py`, print the attributes of the page. ty and an editor know the names
of the attributes. A misspelled key of a dictionary shows up only when the program runs.

Find `click.secho(page.title, fg="green")` in the change of `src/wikiapp/console.py`.

Then we rename the e2e test in `tests/test_wikipedia.py` to `test_random_page_returns_page_in_production`, with the
same marker. Its new name says that it checks for a Page. Its two asserts on the keys become one,
`assert isinstance(page, wikipedia.Page)`.

Find `assert isinstance(page, wikipedia.Page)` in the change of `tests/test_wikipedia.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 2 lines added, 4 removed; returns a Page.
- `src/wikiapp/console.py`: 3 lines added, 5 removed; prints the attributes of the Page.
- `tests/test_wikipedia.py`: 2 lines added, 3 removed; the e2e test.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the return.
  - look at: `return Page.model_validate(response.json())`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): attributes, not keys.
  - look at: `click.secho(page.title, fg="green")`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3b24928689614ab7cd0de47f722d95742cc7bb4a/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the e2e test checks for a Page.
  - look at: `assert isinstance(page, wikipedia.Page)`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,5 +1,3 @@
-from typing import Any
-
 import requests
 from pydantic import BaseModel
 
@@ -18,13 +16,13 @@ class Page(BaseModel):
     extract: str
 
 
-def random_page(language: str = "en") -> dict[str, Any]:
+def random_page(language: str = "en") -> Page:
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
             API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
         ) as response:
             response.raise_for_status()
-            return response.json()
+            return Page.model_validate(response.json())
     except requests.RequestException as error:
         raise WikipediaError(str(error)) from error
```

The change of `src/wikiapp/console.py`:

```diff
@@ -19,13 +19,11 @@ from wikiapp.wikipedia import WikipediaError, random_page
 def main(language: str) -> None:
     """Print the title and summary of a random Wikipedia page."""
     try:
-        data = random_page(language=language)
+        page = random_page(language=language)
     except WikipediaError as error:
         raise click.ClickException(str(error)) from error
-    title = data["title"]
-    extract = data["extract"]
-    click.secho(title, fg="green")
-    click.echo(textwrap.fill(extract))
+    click.secho(page.title, fg="green")
+    click.echo(textwrap.fill(page.extract))
 
 
 if __name__ == "__main__":
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -12,7 +12,6 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 
 
 @pytest.mark.e2e
-def test_random_page_returns_dictionary_in_production() -> None:
+def test_random_page_returns_page_in_production() -> None:
     page = wikipedia.random_page()
-    assert "title" in page
-    assert "extract" in page
+    assert isinstance(page, wikipedia.Page)
```

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

### step-07.3 An answer that is not a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703) shows what the move changes.

Now we make `random_page` catch an answer that is not a page. When the answer has no title, `model_validate` raises
the ValidationError of pydantic. `random_page` turns it into a WikipediaError, as it does with a failed request. In
`src/wikiapp/wikipedia.py`, the `except` catches ValidationError together with the exception of requests.

Find `except (requests.RequestException, ValidationError) as error:` in the change of `src/wikiapp/wikipedia.py`.

Next we add a test from the original wikiapp, `test_random_page_handles_validation_error`, at the end of
`tests/test_wikipedia.py`. In the test, the mock answers with an empty dictionary.

Find `def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:` in the change of
`tests/test_wikipedia.py`.

The move changes these files:

- `src/wikiapp/wikipedia.py`: 2 lines added, 2 removed; a ValidationError is a WikipediaError too.
- `tests/test_wikipedia.py`: 6 lines added; a test of the ValidationError.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8ef59a76a8988b6ef39a36c630e5785be2573703/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): two exceptions caught.
  - look at: `except (requests.RequestException, ValidationError) as error:`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/8ef59a76a8988b6ef39a36c630e5785be2573703/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/8ef59a76a8988b6ef39a36c630e5785be2573703#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): the test.
  - look at: `with pytest.raises(wikipedia.WikipediaError):`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,5 +1,5 @@
 import requests
-from pydantic import BaseModel
+from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
@@ -24,5 +24,5 @@ def random_page(language: str = "en") -> Page:
         ) as response:
             response.raise_for_status()
             return Page.model_validate(response.json())
-    except requests.RequestException as error:
+    except (requests.RequestException, ValidationError) as error:
         raise WikipediaError(str(error)) from error
```

The change of `tests/test_wikipedia.py`:

```diff
@@ -15,3 +15,9 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 def test_random_page_returns_page_in_production() -> None:
     page = wikipedia.random_page()
     assert isinstance(page, wikipedia.Page)
+
+
+def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
+    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
+    with pytest.raises(wikipedia.WikipediaError):
+        wikipedia.random_page()
```

```bash
just test -k validation
```

The output is `1 passed, 8 deselected`.

## step-08.4 The tests documented

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0), the commit before step-08.4.

```bash
just setup
```

### step-08.4 The tests documented

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b) shows what the move changes.

Now we document the tests, so that `just docs check` finds no gap. A docment is the comment beside a parameter, or
after the colon of the `def` line for the return. `just docs check`, from step-08.1, counts the functions and
classes that have their types, docments and docstrings.

Each test file says what it tests, and each fixture says what it returns. Each test says in one line what it
checks. The docstrings say in words what the asserts say in code. Each parameter of a test has a docment, one
parameter to a line, and `tests/test_console.py` shows the pattern best.

Read the changes of `tests/conftest.py`, `tests/test_console.py` and `tests/test_wikipedia.py`. Find
`"""The command prints the title of the page."""` in the change of `tests/test_console.py`.

The move changes these files:

- `tests/conftest.py`: 6 lines added, 1 removed; a docstring for the file and the fixture, and docments for its parameter and return.
- `tests/test_console.py`: 33 lines added, 7 removed; docstrings for the file, the fixture and each test, and docments for each parameter
  and the fixture's return.
- `tests/test_wikipedia.py`: 11 lines added, 2 removed; a docstring for the file and each test, and a docment for each parameter.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/conftest.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0...d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-e52e4ddd58b7ef887ab03c04116e676f6280b824ab7469d5d3080e5cba4f2128): the fixture, documented.
  - look at: `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0...d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): seven functions.
  - look at: `"""The command prints the title of the page."""`
- [`tests/test_wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b/tests/test_wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/2b6ea2dc44cbad7957e6c4ea8268a6db8c3f98d0...d1cc2ef9f787d8ab6bb98e782eea5e7723726d9b#diff-7c364f41c3f9111bc3b1f70b78b315206e7ee9e4baa4bda340fd54919d4d1f7d): three tests.
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
