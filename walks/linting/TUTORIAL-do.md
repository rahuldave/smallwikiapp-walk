<!-- Made by timewalk-tutorial from the notes of the walk. Do not edit it by hand: run timewalk-tutorial again. -->

# Linting smallwikiapp, one move at a time

In do mode, you make each move yourself. The notes give every line to type, every command and every file. [The same tutorial in watch mode](TUTORIAL-watch.md).

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ca8685e532e9d372857667484e1c94c91ac9e986) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/ad0f0c3c814865fe7e54f5aaff74d55a831b2daf) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/3ba5d239ff4f171c58d4249a33caafc510883b46) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/80c33d4cfaf4b157cd44482712e520c77378cf9c) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a) shows what the move changes.

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

## step-04.9 to step-04.10

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a45828b7972f3de77bd6a8d7a00a6b55833832cb), the commit before step-04.9.

```bash
just setup
```

### step-04.9 The recipe check

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/06ea9e2af2238f070b1e33f16aeb70002e25e44d) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/eb43634c9c0a1fe39912ebdfb84f7994ef6a81a9) shows what the move changes.

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

## step-05.3 to step-05.6

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/9d95e1a48037b527b275be02d576cf464baf7df0), the commit before step-05.3.

```bash
just setup
```

### step-05.3 A type on every parameter and return

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c2da7ec65f0a74620c5e411d96dc516b8d63ad15) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/37ff4096c6af3750178af2e961cf2c61a6fa8d6a) shows what the move changes.

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

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fd2af757335e7569c44a38ef4d4f76a3e71f2989) shows what the move changes.

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

## step-10.3 lint-config checks both pyproject.toml files

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a3a4092ef4f32ba87b39a0273fe48b9f228e94cf), the commit before step-10.3.

```bash
just setup
```

### step-10.3 lint-config checks both pyproject.toml files

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1119ea644f945e053558c5309aa2961626006d3c) shows what the move changes.

Since step 09, the repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. In
the `justfile`, in `lint-config`, replace the line `uv run validate-pyproject pyproject.toml` with the line below.

```just
    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
```

The move changed this file:

- `justfile`: `lint-config` checks both files.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/1119ea644f945e053558c5309aa2961626006d3c/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/a3a4092ef4f32ba87b39a0273fe48b9f228e94cf...1119ea644f945e053558c5309aa2961626006d3c#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
  - look at: `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.
