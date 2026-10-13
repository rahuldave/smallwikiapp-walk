<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

# Testing smallwikiapp, one move at a time

In do mode, you make each move yourself. The notes give every line to type, every command and every file. [The same tutorial in watch mode](TUTORIAL-watch.md).

This walk takes the moves about tests out of the whole tutorial of smallwikiapp. `wikiapp` is a small command
that prints the title and the summary of a random Wikipedia page. The walk starts with the project, which `uv init`
began, for Python 3.13. Then the command gets its code, and the tests come after it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has thirteen stops. Each stop takes a whole step, one move, or a few moves in a row:

1. **The project** (step-00)
2. **The command under test** (step-01)
3. **pytest and a first test** (step-02.1 to step-02.2)
4. **Fixtures and mocks** (step-02.3 to step-02.6)
5. **Coverage** (step-02.7)
6. **A shared mock in conftest.py** (step-03.2)
7. **A test of the language** (step-03.3)
8. **A test of an error message** (step-03.6)
9. **`just check`, with a coverage floor** (step-04.9)
10. **End-to-end tests, on request** (step-06.1 to step-06.2)
11. **The tests on GitHub** (step-06.3 to step-06.4)
12. **Tests of a model** (step-07.2 to step-07.3)
13. **A drop in coverage** (step-07.4)

Where the whole tutorial makes moves that this walk leaves out, the next stop says what they did. The stop
starts from their code.

**Kinds of tests**

The walk names each kind of test where it first comes in. The tutorial adds no test for the sake of a kind.

| Kind | What it checks | Where |
|---|---|---|
| End to end | The code against the real Wikipedia, with no mock | Stop 3. From stop 10, it runs only when you ask for it |
| Unit | One part of the code alone, with a mock in place of the network | Stop 4 for the command, until the code splits in two. Stop 7 for the library |
| Integration | The command and the library together, with only the network a mock | Stop 6. The unit tests of the command become integration tests |
| Contract | That the real Wikipedia still answers as the mocks do | Stop 10 |

## step-00 The project

[The code at step-00](https://github.com/rahuldave/smallwikiapp/tree/step-00)

This stop is all of step-00. It shows what `uv init` made, and the command `wikiapp`. The justfile lists the
tasks of the project.

```bash
just setup
```

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

## step-01 The command under test

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/ae86cb7d116c4103832edf25ab3a7a9077583830), the commit before step-01.1. [The code at step-01](https://github.com/rahuldave/smallwikiapp/tree/step-01) is the code after its moves.

This stop is all of step-01. The command asks Wikipedia for a random page, and prints its title and summary. It
sends a User-Agent, and has an option `--version`. The tests of the next stops test this command.

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

Now we add two packages, click and requests, to the dependencies of wikiapp. click makes command lines.
requests gets pages over HTTP.

```bash
uv add click requests
```

The move changes these files:

- `pyproject.toml`: 4 lines added, 1 removed; the two packages in `dependencies`, each with the newest version as its lower bound.
- `uv.lock`: 176 lines added; the exact version of each, and of every package they need.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/commit/1efd5611b90ac42a697374b0ca0449d5a880773e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the dependencies of the package, which anyone who installs it gets.
  - look at: `"click>=8.5.0",`
- [`uv.lock`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/uv.lock): the exact versions, for every platform.

The change of `pyproject.toml`:

```diff
@@ -7,7 +7,10 @@ license = "Apache-2.0"
 license-files = ["LICENSE"]
 authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.13"
-dependencies = []
+dependencies = [
+    "click>=8.5.0",
+    "requests>=2.34.2",
+]
 
 [project.scripts]
 wikiapp = "wikiapp.console:main"
```

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

If your versions are newer, your `uv.lock` differs from the one here, and the move is still correct.

### step-01.2 Ask Wikipedia for a page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0) shows what the move changes.

Now we make `main` ask Wikipedia for a random page, and print it.

`src/wikiapp/console.py` now has a command, as in the first commit of the original wikiapp, from 2024. Its
docstring is new, and says what the command does. `@click.command()` makes `main` a command. The `main` of the original wikiapp had no `-> None`. The
`main` here keeps the annotation that `uv init` gave it at step-00.

- `requests.get` asks the REST API of Wikipedia for the summary of a random page.
- `raise_for_status` raises an exception if the answer is an error.
- `response.json()` reads the answer as a dictionary.

`main` prints the title in green, and the summary wrapped to 70 columns.

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

The move changes one file:

- `src/wikiapp/console.py`: 17 lines added, 2 removed; `main` asks Wikipedia for a page and prints it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/a46ba5420b43d7ea47508ae393977935e7bd8bd0/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/a46ba5420b43d7ea47508ae393977935e7bd8bd0#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): a request, and two lines printed.
  - look at: `with requests.get(API_URL) as response:`

The change of `src/wikiapp/console.py`:

```diff
@@ -1,4 +1,19 @@
+import click
+import requests
+import textwrap
 
+API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+
+@click.command()
 def main() -> None:
-    """Print a line, until there is a page to print."""
-    print("Hello from wikiapp!")
+    """Print the title and summary of a random Wikipedia page."""
+    with requests.get(API_URL) as response:
+        response.raise_for_status()
+        data = response.json()
+        title = data["title"]
+        extract = data["extract"]
+        click.secho(title, fg="green")
+        click.echo(textwrap.fill(extract))
+
+if __name__=="__main__":
+    main()
```

```bash
uv run wikiapp
```

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. Wikipedia now refuses a request whose User-Agent header is the default of
a library. requests sends `python-requests/` and its version.

### step-01.3 A User-Agent

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb) shows what the move changes.

Now we send a User-Agent header with the request. The User-Agent header says who sends the request. The policy of
Wikimedia asks for the name of the program, its version, and a way to reach the person who runs it. In
`src/wikiapp/console.py`, a constant `USER_AGENT` under `API_URL` gives these three things.

In `src/wikiapp/console.py`, add a line under `API_URL`, and pass it as a header.

```python
USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
```

```python
    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```

The move changes one file:

- `src/wikiapp/console.py`: 2 lines added, 1 removed; a constant `USER_AGENT`, and the request sends it.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/2dd3e2132565971092bffe6a438a36506f4161cb/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/2dd3e2132565971092bffe6a438a36506f4161cb#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the header.
  - look at: `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

The change of `src/wikiapp/console.py`:

```diff
@@ -3,11 +3,12 @@ import requests
 import textwrap
 
 API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 @click.command()
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
-    with requests.get(API_URL) as response:
+    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
         response.raise_for_status()
         data = response.json()
         title = data["title"]
```

```bash
uv run wikiapp
```

A title in green, and a paragraph. Each run prints another page.

### step-01.4 --version

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c) shows what the move changes.

Now we let the command print its version. The package can read its own version from the installed package, which
has the version in `pyproject.toml`. `src/wikiapp/__init__.py` now sets `__version__` from the metadata of the
installed package. `src/wikiapp/console.py` imports `__version__`. The decorator `@click.version_option`, above
`def main`, gives the command the option `--version`.

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

The move changes these files:

- `src/wikiapp/__init__.py`: 2 lines added; `__version__`, from the installed package.
- `src/wikiapp/console.py`: 2 lines added; the option `--version`.

Files to read:
- [`src/wikiapp/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/48a829ee985a69171af7c66846bdb8e7345a199c/src/wikiapp/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c#diff-103f95a0e294ac54f1b7a73298af183996b7831d84a08729e5c6ddea7d80143a): the version, which Python reads when it imports the package.
  - look at: `__version__ = importlib.metadata.version(__name__ or __package__)`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/48a829ee985a69171af7c66846bdb8e7345a199c/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/commit/48a829ee985a69171af7c66846bdb8e7345a199c#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): click's version option.
  - look at: `@click.version_option(version=__version__)`

The change of `src/wikiapp/__init__.py`:

```diff
@@ -0,0 +1,2 @@
+import importlib.metadata
+__version__ = importlib.metadata.version(__name__ or __package__)
```

The change of `src/wikiapp/console.py`:

```diff
@@ -1,4 +1,5 @@
 import click
+from wikiapp import __version__
 import requests
 import textwrap
 
@@ -6,6 +7,7 @@ API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 @click.command()
+@click.version_option(version=__version__)
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
     with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```

```bash
uv run wikiapp --version
uv run wikiapp --help
```

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring. So the docstring of `main` is also help text, for a person who runs the command.

## step-02.1 to step-02.2 pytest and a first test

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/48a829ee985a69171af7c66846bdb8e7345a199c), the commit before step-02.1.

```bash
just setup
```

pytest comes in, with a first test, and `just test` runs the tests.

### step-02.1 pytest and the first test

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/645fc59b58e6f49dc92635e2562f949524a4629c) shows what the move changes.

Now we install pytest, the tool that runs the tests. The tests need pytest, but the package does not. A person who
installs wikiapp should not get pytest. So pytest goes in a dependency group of its own, `test`. uv installs the
group `dev` by default, so `dev` includes `test`.

In `pyproject.toml`, add the groups above `[build-system]`.

```toml
[dependency-groups]
test = []
dev = [{ include-group = "test" }]

```

```bash
uv add --group test pytest
```

Next we write the first test, in `tests/test_console.py`, which runs the command and checks that it ends with exit
code 0. click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code
of the command.

This first test is an end-to-end test. It runs the whole command, and the command asks the real Wikipedia. So a
failure can come from the code, from the network or from Wikipedia.

Make `tests/test_console.py`.

```python
import click.testing

from wikiapp import console

def test_main_succeeds():
    runner = click.testing.CliRunner()
    result = runner.invoke(console.main)
    assert result.exit_code == 0
```

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

Add the recipe at the end of the `justfile`.

```just

# Run the tests. Extra arguments go to pytest: just test -k title
[group('quality')]
[no-exit-message]
test *args:
    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

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

## step-02.3 to step-02.6 Fixtures and mocks

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/94970c50651566f11d5c9d017cb01004e240821a), the commit before step-02.3.

```bash
just setup
```

A fixture gives each test a runner, and a mock takes the place of Wikipedia. Tests check the title that the
command prints, and the request. A failed request ends the command with exit code 1.

### step-02.3 The runner as a fixture

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/cd31b8a082b8c3ecf168413a21e06b9888480534) shows what the move changes.

Now we move the `CliRunner` into a fixture, `runner`, which returns it. Each test of the command needs a
`CliRunner`. A fixture is a function that pytest calls for each test that names it as a parameter. So
`test_main_succeeds` takes the runner as its parameter.

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

A test that uses the mock is a unit test of the command. It checks the command alone, without the network, so a
failure points at the command. `test_main_succeeds` still asks the real Wikipedia.

```bash
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

Add the two tests to `tests/test_console.py`, after `test_main_prints_title`.

```python
def test_main_invokes_requests_get(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.called

def test_main_uses_correct_url(runner, mock_requests_get):
    result = runner.invoke(console.main)
    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
```

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

Add the test below to `tests/test_console.py`, before `test_main_succeeds`, with a blank line after it.

```python
def test_main_fails_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = Exception("Boom")
    result = runner.invoke(console.main)
    assert result.exit_code == 1
```

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

The command now has four tests that use the mock, and one that asks the real Wikipedia.

## step-02.7 Coverage

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/16b52dc4f9ec6e997b6954efde180ba6d7f521c7), the commit before step-02.7.

```bash
just setup
```

Every run of the tests now measures the lines of the code that they run.

### step-02.7 Coverage

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/bed3c6029878c71bef05322712c388dfb8c058ef) shows what the move changes.

Now we measure the coverage of the tests on every run. pytest-cov measures which lines of the code the tests run.
It goes in the group `test`, and pytest's settings, at the end of `pyproject.toml`, turn coverage on for every run.

```bash
uv add --group test pytest-cov
```

Add the settings at the end of `pyproject.toml`.

```toml

[tool.pytest.ini_options]
testpaths = ["tests"]
# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
addopts = "--cov=wikiapp --cov-report=term-missing"
```

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented out.
No test used them, so the project does not keep them.

The move changes these files:

- `pyproject.toml`: 6 lines added; pytest-cov in the group `test`, and pytest's settings.
- `uv.lock`: 102 lines added; pytest-cov and coverage.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/bed3c6029878c71bef05322712c388dfb8c058ef/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/16b52dc4f9ec6e997b6954efde180ba6d7f521c7...bed3c6029878c71bef05322712c388dfb8c058ef#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): coverage on every run.
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

## step-03.2 A shared mock in conftest.py

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/fec316ee50d27867f0dab60a755372ce1d1839d1), the commit before step-03.2.

```bash
just setup
```

Since the last stop, the walk leaves out the move
[step-03.1](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.1). The request moved out of the
command, into a function `random_page` in a new module, `src/wikiapp/wikipedia.py`. The notes call this module
the library, and the command uses it. This stop starts with that code.

The mock moves to `tests/conftest.py`, so that every test file can use it.

### step-03.2 The mock moves to conftest.py

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/dcb1e4c7102be3c1feec309ed88e1097ce28f32e) shows what the move changes.

Now we share the mock with every test file. pytest reads `tests/conftest.py` before the tests, and every test file
can use a fixture in it. The tests of wikipedia.py, in the next move, need the mock too. So the fixture
`mock_requests_get` moves from `tests/test_console.py` to a new file, `tests/conftest.py`.

`main` calls `random_page`, and only `requests.get` is a mock. So a test of the command that uses the mock runs
two parts of the code together, the command and the library. A test of parts together is an integration test.
Since step-03.1, the four tests of the command that use the mock are integration tests, and no longer unit tests.

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

The move changes these files:

- `tests/conftest.py`: 10 lines added; a new file with the mock.
- `tests/test_console.py`: 9 lines removed; the mock is gone.

Files to read:
- [`tests/conftest.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/conftest.py): the fixture, for every test file.
  - look at: `def mock_requests_get(mocker):`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/dcb1e4c7102be3c1feec309ed88e1097ce28f32e/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/fec316ee50d27867f0dab60a755372ce1d1839d1...dcb1e4c7102be3c1feec309ed88e1097ce28f32e#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the fixture is gone, but the tests still name it.

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

## step-03.3 A test of the language

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/dcb1e4c7102be3c1feec309ed88e1097ce28f32e), the commit before step-03.3.

```bash
just setup
```

`random_page` takes a language, and a test checks the address.

### step-03.3 A language

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3d9dfef45760f1ce2cfa78841f554e08f62d32f4) shows what the move changes.

Now we let `random_page` ask the Wikipedia of a language. Each language has its own Wikipedia, at
LANGUAGE.wikipedia.org. In `src/wikiapp/wikipedia.py`, the address has a placeholder for the language.
`random_page` fills it, with English as the default.

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

Then we write the first test of the library, in `tests/test_wikipedia.py`, which asks for a page in Spanish. It
checks that the address of the request contains `es.wikipedia.org`. It calls `random_page` alone, with the mock,
so it is a unit test of the library.

Make `tests/test_wikipedia.py`.

```python
from wikiapp import wikipedia

def test_random_page_uses_given_language(mock_requests_get):
    wikipedia.random_page(language="es")
    args, _ = mock_requests_get.call_args
    assert "es.wikipedia.org" in args[0]
```

The move changes these files:

- `src/wikiapp/wikipedia.py`: 3 lines added, 3 removed; `random_page` takes a language.
- `tests/test_wikipedia.py`: 6 lines added; a new file with a test that the language chooses the Wikipedia.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/3d9dfef45760f1ce2cfa78841f554e08f62d32f4/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/dcb1e4c7102be3c1feec309ed88e1097ce28f32e...3d9dfef45760f1ce2cfa78841f554e08f62d32f4#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the placeholder, and the code that fills it.
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

## step-03.6 A test of an error message

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/56214d31141adcc3dab1ecdd7545b94b03c7f0ea), the commit before step-03.6.

```bash
just setup
```

Since the last stop, the walk leaves out the moves
[step-03.4](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.4) and
[step-03.5](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html#step-03.5). The command got an option
`--language`. When a request fails, `random_page` raises an error of its own, `WikipediaError`. This stop starts
with that code.

The command prints `WikipediaError` as a message, and a test checks that a failed request prints `Error`.

### step-03.6 The command prints the error

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b090ad74622ee6109dd72ae66feec36377eef7d7) shows what the move changes.

Now we make `main` print a `WikipediaError` as a message. `src/wikiapp/console.py` imports the error with
`random_page`. `main` catches it, and raises the exception of click in its place. click prints that exception as a
message.

In the original wikiapp, the library raised the exception of click itself, with a note to move it to the
console one day. In this move, the exception of click moves to console.py. wikipedia.py knows Wikipedia and
requests, and console.py knows click.

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

Then we add a test, `test_main_prints_message_on_request_error`, which makes the mock raise a `RequestException`.
It checks that the output contains `Error`. `tests/test_console.py` now imports `requests`.

Add the test to `tests/test_console.py`, before `test_main_succeeds`, with a blank line after it. Put
`import requests` under `import pytest`.

```python
def test_main_prints_message_on_request_error(runner, mock_requests_get):
    mock_requests_get.side_effect = requests.RequestException
    result = runner.invoke(console.main)
    assert "Error" in result.output
```

The move changes these files:

- `src/wikiapp/console.py`: 5 lines added, 2 removed; `main` catches WikipediaError.
- `tests/test_console.py`: 6 lines added; a test of the message.

Files to read:
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/56214d31141adcc3dab1ecdd7545b94b03c7f0ea...b090ad74622ee6109dd72ae66feec36377eef7d7#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): the error becomes a message.
  - look at: `raise click.ClickException(str(error)) from error`
- [`tests/test_console.py`](https://github.com/rahuldave/smallwikiapp/blob/b090ad74622ee6109dd72ae66feec36377eef7d7/tests/test_console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/56214d31141adcc3dab1ecdd7545b94b03c7f0ea...b090ad74622ee6109dd72ae66feec36377eef7d7#diff-b4208c08b7028cf972b84e618100942bedd2eba3f8db6364f6e4bedf162a680f): the test.
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

## step-04.9 `just check`, with a coverage floor

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a45828b7972f3de77bd6a8d7a00a6b55833832cb), the commit before step-04.9.

```bash
just setup
```

Since the last stop, the walk leaves out the first eight moves of
[step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html). ruff formats the code and lints it, with
`just fmt` and `just lint`, and `just lint-config` checks the configuration. ruff formats the tests too.

In the tests, its linter finds an import below the code and unused variables, and a person fixes them. The request got
a timeout of 10 seconds, and the recipes refuse a lockfile that is out of date. This stop starts with that code.

A new recipe, `just check`, runs every check. One of them fails when the tests run less than 90% of the code.

### step-04.9 The recipe check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d) shows what the move changes.

Now we add a recipe `check`, which runs every check in order. It stops at the first check that fails. The order is
the format, the linter, the tests with a floor on the coverage, and the configuration.

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

The move changes one file:

- `justfile`: 12 lines added; the recipe `check`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/06ea9e2af2238f070b1e33f16aeb70002e25e44d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/a45828b7972f3de77bd6a8d7a00a6b55833832cb...06ea9e2af2238f070b1e33f16aeb70002e25e44d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its four checks.
  - look at: `just test -q --cov-fail-under=90`

The change of `justfile`:

```diff
@@ -50,3 +50,15 @@ lint-config *args:
     uv run validate-pyproject pyproject.toml
     uv lock --check
     just --fmt --check --unstable
+
+# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
+[group('quality')]
+[no-exit-message]
+check *args:
+    #!/usr/bin/env sh
+    set -e
+    if [ "$*" = help ]; then just help check; exit 0; fi
+    just fmt --check
+    just lint
+    just test -q --cov-fail-under=90
+    just lint-config
```

```bash
just --show check
just check
```

`just check` passes. The tests must run at least 90% of the statements, and the coverage is 96.77%.

## step-06.1 to step-06.2 End-to-end tests, on request

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/41990df7638f0964c66bf4e4433ffc4f5b6a026d), the commit before step-06.1.

```bash
just setup
```

Since the last stop, the walk leaves out the last move of
[step-04](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html) and the whole of
[step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). `just hook` installs a git hook. Before
each commit, pre-commit runs three small checks of the files, then `just check`.

ty checks the types, and the command reads its version by the name of its package. The code and the tests got their
types. `random_page` returns `dict[str, Any]`, and `just check` runs the type checker too. This stop starts with
that code.

The test that asks the real Wikipedia runs only when you ask for it. A second test of that kind checks the
library.

### step-06.1 The end-to-end test runs only on request

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4ccfe3566846e64d7383837ef3e936e151c6c9d5) shows what the move changes.

Now we mark the test that asks the real Wikipedia, so that it runs only on request.

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. In `tests/test_console.py`, it now has the marker `e2e`, which means end to end. Its new
name says so, `test_main_succeeds_in_production`. `pyproject.toml` declares the marker in `markers`. The option
`-m 'not e2e'` in `addopts` leaves the e2e tests out of every run that does not ask for them.

The other tests use the mock in place of Wikipedia. They run without the network, and give the same result on
every run.

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

This test is also a contract test. It checks that the real Wikipedia still returns the two keys that the mocks
return.

Add the test at the end of `tests/test_wikipedia.py`. Put `import pytest` in a block of its own between
`from unittest.mock import Mock` and `from wikiapp import wikipedia`, with a blank line on each side.

```python


@pytest.mark.e2e
def test_random_page_returns_dictionary_in_production() -> None:
    page = wikipedia.random_page()
    assert "title" in page
    assert "extract" in page
```

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

The project now has all four kinds of tests in the table of the intro. They are end to end, unit, integration and
contract.

## step-06.3 to step-06.4 The tests on GitHub

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/41e5681a18bc9975f383d1520b8781c4e836e90d), the commit before step-06.3.

```bash
just setup
```

The project accepts any Python from 3.11 on. GitHub runs the tests on three systems and four Pythons.

### step-06.3 Any Python from 3.11 on

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/15ba9fa843e3f055dac9c8f1a844b7382858b761) shows what the move changes.

Now we let the project accept every Python from 3.11 on. `uv init` wrote `requires-python = ">=3.13"`, because the
command asked for Python 3.13. Nothing here needs more than 3.11. Python 3.10 reached its end of life on 1 October
2026, so 3.11 is now the oldest Python that still gets security fixes. The line in `pyproject.toml` now says 3.11,
and uv solves the lockfile again.

In `pyproject.toml`, change the line.

```toml
requires-python = ">=3.11"
```

```bash
uv lock
```

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

Both jobs run pytest with the options in `pyproject.toml`, so they leave out the e2e tests. GitHub runs the unit
tests and the integration tests on every push to main and every pull request. GitHub never runs the e2e tests. A
person runs them, with `just test -m e2e`.

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

## step-07.2 to step-07.3 Tests of a model

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a86d7848100f28d4cd5bdca2bc3a8b5ab98bb4c8), the commit before step-07.2.

```bash
just setup
```

Since the last stop, the walk leaves out the move
[step-07.1](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html#step-07.1). pydantic came in, and
`wikipedia.py` got `Page`, a pydantic model with a title and an extract. This stop starts with that code.

`random_page` returns a `Page`. One test changes. An answer that is not a page is a `WikipediaError` too, and a
new test checks it.

### step-07.2 random_page returns a Page

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3b24928689614ab7cd0de47f722d95742cc7bb4a) shows what the move changes.

Now we make `random_page`, in `src/wikiapp/wikipedia.py`, return a Page made from the answer. The code no longer
uses `Any`, so its import and the blank line under it are gone.

In `src/wikiapp/wikipedia.py`, delete the import of `Any`, and the blank line under it. Then change the return
type of `random_page`, and its `return` line.

```python
def random_page(language: str = "en") -> Page:
```

```python
            return Page.model_validate(response.json())
```

Next we make `main`, in `src/wikiapp/console.py`, print the attributes of the page. ty and an editor know the names
of the attributes. A misspelled key of a dictionary shows up only when the program runs.

In `src/wikiapp/console.py`, replace the code under the docstring of `main` with the code below.

```python
    try:
        page = random_page(language=language)
    except WikipediaError as error:
        raise click.ClickException(str(error)) from error
    click.secho(page.title, fg="green")
    click.echo(textwrap.fill(page.extract))
```

Then we rename the e2e test in `tests/test_wikipedia.py` to `test_random_page_returns_page_in_production`, with the
same marker. Its new name says that it checks for a Page. Its two asserts on the keys become one,
`assert isinstance(page, wikipedia.Page)`.

In `tests/test_wikipedia.py`, replace the e2e test `test_random_page_returns_dictionary_in_production`, with its
marker, by the code below.

```python
@pytest.mark.e2e
def test_random_page_returns_page_in_production() -> None:
    page = wikipedia.random_page()
    assert isinstance(page, wikipedia.Page)
```

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

In `src/wikiapp/wikipedia.py`, import ValidationError, and catch it together with the exception of requests.

```python
from pydantic import BaseModel, ValidationError
```

```python
    except (requests.RequestException, ValidationError) as error:
```

Next we add a test from the original wikiapp, `test_random_page_handles_validation_error`, at the end of
`tests/test_wikipedia.py`. In the test, the mock answers with an empty dictionary.

Add the test at the end of `tests/test_wikipedia.py`.

```python


def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
    with pytest.raises(wikipedia.WikipediaError):
        wikipedia.random_page()
```

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

## step-07.4 A drop in coverage

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/8ef59a76a8988b6ef39a36c630e5785be2573703), the commit before step-07.4.

```bash
just setup
```

New code has no test, and the coverage drops.

### step-07.4 Only a language code goes into the address

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc) shows what the move changes.

Now we check, in `random_page`, that the language is a language code before it goes into the address.

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as
`example.com/x?` sends the request to example.com, with the User-Agent. The code of every Wikipedia has only
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. In `src/wikiapp/wikipedia.py`, a pattern
`LANGUAGE` under `API_URL` matches such a code. `random_page` checks the language first, before the `try`. Any
other language raises a WikipediaError.

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

The move changes one file:

- `src/wikiapp/wikipedia.py`: 5 lines added; the pattern, and the check.

Files to read:
- [`src/wikiapp/wikipedia.py`](https://github.com/rahuldave/smallwikiapp/blob/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc/src/wikiapp/wikipedia.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/8ef59a76a8988b6ef39a36c630e5785be2573703...fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc#diff-d76a864f1c0b09582ea64df8db4bcecf5956f42e4807d09aec98e45c893d73a2): the code checks a language before it uses it.
  - look at: `if not LANGUAGE.fullmatch(language):`

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,7 +1,10 @@
+import re
+
 import requests
 from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
+LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 
@@ -18,6 +21,8 @@ class Page(BaseModel):
 
 def random_page(language: str = "en") -> Page:
     """Get a random page from Wikipedia."""
+    if not LANGUAGE.fullmatch(language):
+        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
     try:
         with requests.get(
             API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
```

```bash
uv run wikiapp --language 'example.com/x?'
just test -q
```

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%. A drop in coverage is
something to know about. The tutorial adds no test to hide it.

The walk stops here. After it, the whole tutorial makes the steps
[08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html) to
[10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The tests get their docstrings. The library
becomes a package of its own, wikirandom. Its tests move to `tests/test_wikirandom.py`, and coverage measures both
packages. The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
