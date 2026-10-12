<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

# Linting smallwikiapp, one move at a time

In watch mode, you read each move. The notes explain what it changed, and its commit holds the code. [The same tutorial in do mode](TUTORIAL-do.md).

This walk takes the moves about format and lint out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts when the command and
its tests work, and no tool checks the code.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The moves add ruff, which formats the code and then finds problems in it. The next moves fix each problem. Then
a recipe checks the configuration, and another runs every check. A git hook runs them before each commit.

Later, the linter asks for a type on every parameter and return. The next moves add the types to the code and to
the tests, and `just check` runs the type checker too. The last move makes `just lint-config` check the
`pyproject.toml` of a second package.

Each step of the walk starts from the code before its first move, so each one starts with `just setup`.

## What the walk leaves out

Between its steps, the whole tutorial makes moves that this walk does not show:

- **Before step-04.9,** the move [step-04.8](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.8). The `justfile` exports `UV_LOCKED`, so that
  `uv run` refuses a lockfile that is out of date.
- **Before step-05.3,** the first two moves of [step-05](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html). ty, a type checker, comes in, and
  `just types` runs it. The command reads its version from the installed package, by its name.
- **Before step-10.3,** the steps [06](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html) to [09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html) and the first two moves of
  [step-10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The tests that ask the real Wikipedia run only on request, so the tests no longer
  need the network. GitHub runs the tests. `random_page` returns a pydantic model, `Page`. smalldocs
  documents the code, and `just check` runs the check of the docs too. The library becomes a package of its own, `packages/wikirandom`, with its own
  `pyproject.toml`, and its tests are in `tests/test_wikirandom.py`. `just build` builds both packages, and the app asks for wikirandom 0.1.

The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.

## step-04.1 to step-04.7

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/b090ad74622ee6109dd72ae66feec36377eef7d7), the commit before step-04.1.

```bash
just setup
```

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

The change of `pyproject.toml`:

```diff
@@ -21,7 +21,10 @@ test = [
     "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
-dev = [{ include-group = "test" }]
+dev = [{ include-group = "test" }, { include-group = "lint" }]
+lint = [
+    "ruff>=0.17.0",
+]
 
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
@@ -31,3 +34,14 @@ build-backend = "uv_build"
 testpaths = ["tests"]
 # Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
 addopts = "--cov=wikiapp --cov-report=term-missing"
+
+[tool.ruff]
+# The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
+# better at 100.
+line-length = 100
+
+[tool.ruff.format]
+# The formatter has no style to argue about. These are ruff's defaults, written out so they are visible.
+quote-style = "double"            # "text", not 'text'
+indent-style = "space"            # four spaces, never tabs
+skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
```

The change of `justfile`:

```diff
@@ -25,3 +25,9 @@ setup *args:
 [no-exit-message]
 test *args:
     {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
+
+# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
+[group('quality')]
+[no-exit-message]
+fmt *args:
+    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```

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

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -3,13 +3,17 @@ import requests
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
+
 class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
+
 def random_page(language="en"):
     """Get a random page from Wikipedia."""
     try:
-        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
+        with requests.get(
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}
+        ) as response:
             response.raise_for_status()
             return response.json()
     except requests.RequestException as error:
```

The change of `tests/test_console.py`:

```diff
@@ -2,34 +2,44 @@ import click.testing
 import pytest
 import requests
 
+
 @pytest.fixture
 def runner():
     return click.testing.CliRunner()
 
+
 from wikiapp import console
 
+
 def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
+
 def test_main_invokes_requests_get(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert mock_requests_get.called
 
+
 def test_main_uses_correct_url(runner, mock_requests_get):
     result = runner.invoke(console.main)
-    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
+    assert mock_requests_get.call_args[0] == (
+        "https://en.wikipedia.org/api/rest_v1/page/random/summary",
+    )
+
 
 def test_main_fails_on_request_error(runner, mock_requests_get):
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
+
 def test_main_prints_message_on_request_error(runner, mock_requests_get):
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

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

The change of `pyproject.toml`:

```diff
@@ -45,3 +45,21 @@ line-length = 100
 quote-style = "double"            # "text", not 'text'
 indent-style = "space"            # four spaces, never tabs
 skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
+
+[tool.ruff.lint]
+# What the linter checks: a family of rules on each line, and why it is on
+select = [
+    "E",   # pycodestyle errors: the basics, from indentation to line length
+    "W",   # pycodestyle warnings: stray whitespace and the like
+    "F",   # pyflakes: names that are unused, undefined or redefined
+    "I",   # isort: imports in one order, standard library first
+    "B",   # bugbear: constructs that are likely bugs, such as a mutable default argument
+    "UP",  # pyupgrade: older syntax that this Python has a newer form for
+    "SIM", # simplify: code that can be said in fewer words
+    "S",   # bandit: security, from `assert` in production code to a request with no timeout
+    "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
+]
+
+[tool.ruff.lint.per-file-ignores]
+# A test is written with assert
+"tests/**" = ["S101"]
```

The change of `justfile`:

```diff
@@ -31,3 +31,9 @@ test *args:
 [no-exit-message]
 fmt *args:
     {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
+
+# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
+[group('quality')]
+[no-exit-message]
+lint *args:
+    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```

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

The change of `src/wikiapp/console.py`:

```diff
@@ -1,7 +1,8 @@
-import click
-from wikiapp import __version__
 import textwrap
 
+import click
+
+from wikiapp import __version__
 from wikiapp.wikipedia import WikipediaError, random_page
 
 
```

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

The change of `tests/test_console.py`:

```diff
@@ -2,27 +2,26 @@ import click.testing
 import pytest
 import requests
 
+from wikiapp import console
+
 
 @pytest.fixture
 def runner():
     return click.testing.CliRunner()
 
 
-from wikiapp import console
-
-
 def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
 def test_main_invokes_requests_get(runner, mock_requests_get):
-    result = runner.invoke(console.main)
+    runner.invoke(console.main)
     assert mock_requests_get.called
 
 
 def test_main_uses_correct_url(runner, mock_requests_get):
-    result = runner.invoke(console.main)
+    runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
```

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

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -12,7 +12,7 @@ def random_page(language="en"):
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
-            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
         ) as response:
             response.raise_for_status()
             return response.json()
```

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

The change of `justfile`:

```diff
@@ -37,3 +37,14 @@ fmt *args:
 [no-exit-message]
 lint *args:
     {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
+
+# Check the configuration: pyproject.toml, the lockfile, and this justfile
+[group('quality')]
+[no-exit-message]
+lint-config *args:
+    #!/usr/bin/env sh
+    set -e
+    if [ "$*" = help ]; then just help lint-config; exit 0; fi
+    uv run validate-pyproject pyproject.toml
+    uv lock --check
+    just --fmt --check --unstable
```

The change of `pyproject.toml`:

```diff
@@ -24,6 +24,7 @@ test = [
 dev = [{ include-group = "test" }, { include-group = "lint" }]
 lint = [
     "ruff>=0.17.0",
+    "validate-pyproject>=0.26",
 ]
 
 [build-system]
```

```bash
uv run validate-pyproject pyproject.toml
uv lock --check
just --fmt --check --unstable
just --show lint-config
just lint-config
```

The three checks pass. validate-pyproject prints `Valid file: pyproject.toml`. `uv lock --check` prints
`Resolved 19 packages` and exits with 0, because the lockfile matches `pyproject.toml`.

## step-04.9 to step-04.10

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a45828b7972f3de77bd6a8d7a00a6b55833832cb), the commit before step-04.9.

```bash
just setup
```

### step-04.9 The recipe check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d) shows what the move changes.

A recipe `check` runs every check in order, and stops at the first check that fails. The order is the format,
the linter, the tests with a floor on the coverage, and the configuration.

The move changed this file:

- `justfile`: the recipe `check`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/06ea9e2af2238f070b1e33f16aeb70002e25e44d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its four checks.
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

The change of `justfile`:

```diff
@@ -22,6 +22,11 @@ help *verb:
 setup *args:
     @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
 
+# Install the git hook: just check before every commit. Once per clone; just setup never touches git
+[group('setup')]
+hook *args:
+    @{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}
+
 # Run the tests. Extra arguments go to pytest: just test -k title
 [group('quality')]
 [no-exit-message]
```

The change of `pyproject.toml`:

```diff
@@ -23,6 +23,7 @@ test = [
 ]
 dev = [{ include-group = "test" }, { include-group = "lint" }]
 lint = [
+    "pre-commit>=4.6.2",
     "ruff>=0.17.0",
     "validate-pyproject>=0.26",
 ]
```

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

## step-05.3 to step-05.6

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/2c744eaef504d1adcc7fba0938360d140ef49978), the commit before step-05.3.

```bash
just setup
```

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

The change of `pyproject.toml`:

```diff
@@ -61,6 +61,7 @@ select = [
     "SIM", # simplify: code that can be said in fewer words
     "S",   # bandit: security, from `assert` in production code to a request with no timeout
     "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
+    "ANN", # annotations: every parameter and every return value has a type
 ]
 
 [tool.ruff.lint.per-file-ignores]
```

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

The change of `src/wikiapp/wikipedia.py`:

```diff
@@ -1,3 +1,5 @@
+from typing import Any
+
 import requests
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
@@ -8,7 +10,7 @@ class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
 
-def random_page(language="en"):
+def random_page(language: str = "en") -> dict[str, Any]:
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
```

The change of `src/wikiapp/console.py`:

```diff
@@ -16,7 +16,7 @@ from wikiapp.wikipedia import WikipediaError, random_page
     show_default=True,
 )
 @click.version_option(version=__version__)
-def main(language) -> None:
+def main(language: str) -> None:
     """Print the title and summary of a random Wikipedia page."""
     try:
         data = random_page(language=language)
```

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

### step-05.6 The recipe check runs the type checker

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d) shows what the move changes.

The recipe `check` in the `justfile` now runs `just types` after `just lint`. Its comment names the types too.

The move changed this file:

- `justfile`: `check` runs the type checker.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/41990df7638f0964c66bf4e4433ffc4f5b6a026d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
  - look at: `just types`

The change of `justfile`:

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -71,5 +71,6 @@ check *args:
     if [ "$*" = help ]; then just help check; exit 0; fi
     just fmt --check
     just lint
+    just types
     just test -q --cov-fail-under=90
     just lint-config
```

```bash
just check
```

Every check passes, the type check among them. The coverage is 96.88%.

## step-10.3 lint-config checks both pyproject.toml files

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29), the commit before step-10.3.

```bash
just setup
```

### step-10.3 lint-config checks both pyproject.toml files

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5680a827b9d6a412d145df259dd161119c4cd776) shows what the move changes.

Since step 09, the repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. The
recipe `lint-config` now gives validate-pyproject both files.

The move changed this file:

- `justfile`: `lint-config` checks both files.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5680a827b9d6a412d145df259dd161119c4cd776/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/b3d6fbbeca8cbdd86523b9e767092d8b4fe06b29...5680a827b9d6a412d145df259dd161119c4cd776#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

The change of `justfile`:

```diff
@@ -58,7 +58,7 @@ lint-config *args:
     #!/usr/bin/env sh
     set -e
     if [ "$*" = help ]; then just help lint-config; exit 0; fi
-    uv run validate-pyproject pyproject.toml
+    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
     uv lock --check
     just --fmt --check --unstable
 
```

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.
