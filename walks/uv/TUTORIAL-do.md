<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

# uv in smallwikiapp, one move at a time

In do mode, you make each move yourself. The notes give every line to type, every command and every file. [The same tutorial in watch mode](TUTORIAL-watch.md).

This walk takes the moves about uv out of the whole tutorial of smallwikiapp. `wikiapp` is a small command that
prints the title and the summary of a random Wikipedia page. uv makes the project, installs its packages, runs its
tools, and builds it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has eleven stops. Each stop takes a whole step or one move:

1. **The project, and its `.venv`** (step-00)
2. **Two dependencies, and the lockfile** (step-01.1)
3. **A group for the tests, and when uv syncs** (step-02.1)
4. **A lockfile that must be up to date** (step-04.8)
5. **The oldest Python, and other environments** (step-06.3)
6. **Pythons and groups on GitHub** (step-06.4)
7. **A workspace** (step-09.1)
8. **A dependency of one member** (step-09.2)
9. **The app uses the library** (step-09.3)
10. **A build of both packages** (step-10.1)
11. **A range of versions for the library** (step-10.2)

Some stops run commands that the whole tutorial does not. They change `.venv`, and no file that git tracks. The
`$ just setup` at the top of the next stop makes `.venv` match the lockfile again.

Where the whole tutorial makes moves that this walk leaves out, the next stop says what they did. The stop
starts from their code.

**What uv does in this project**

| Idea | What it means here | Stops |
|---|---|---|
| `pyproject.toml` and `uv.lock` | `pyproject.toml` gives the range of versions of each package. `uv.lock` gives the exact version that uv chose | 1 and 2 |
| `uv sync` | Makes `.venv` match the lockfile and the groups it installs. It installs what is missing, and removes every other package | 1 and 3 |
| `uv run` | Syncs first, then runs a command in `.venv`. The sync installs what is missing, and removes nothing. `--no-sync` skips the sync | 3 |
| `--locked` and `UV_LOCKED` | Refuse a lockfile that is out of date with `pyproject.toml` | 1 and 4 |
| `--frozen` | Uses the lockfile as it is, and does not check it. The project never uses it | 4 |
| Dependency groups | `test`, `lint` and `docs`, for the people who work on the project. `dev` includes them, and uv installs `dev` by default | 3 and 6 |
| `.python-version` and `requires-python` | The Python of `.venv`, and the oldest Python that the project accepts | 1 and 5 |
| Environments | `.venv`, a temporary one with `--isolated`, and the one of a tool that `uvx` runs | 1 and 5 |
| A workspace | Several packages with one lockfile and one `.venv`. `--package` names one of them | 7 to 9 |
| `[tool.uv.sources]` | Where uv gets a package. Here the library comes from the workspace, not from PyPI | 9 and 11 |
| `uv build --all-packages` | Builds a wheel and a source archive of each package of the workspace | 10 and 11 |

## step-00 The project, and its `.venv`

[The code at step-00](https://github.com/rahuldave/smallwikiapp/tree/step-00)

This stop is all of step-00. `uv init` made the project, and `uv lock` wrote its lockfile.

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

`.venv` is the environment of the project. It has a Python, and every package that the lockfile names. `uv run`
runs a command with that Python. So `uv run wikiapp` needs no step to activate `.venv` first.

## step-01.1 Two dependencies, and the lockfile

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/ae86cb7d116c4103832edf25ab3a7a9077583830), the commit before step-01.1.

```bash
just setup
```

`uv add` writes a package into `pyproject.toml`, solves the lockfile again, and syncs `.venv`, all in one command.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/1efd5611b90ac42a697374b0ca0449d5a880773e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/ae86cb7d116c4103832edf25ab3a7a9077583830...1efd5611b90ac42a697374b0ca0449d5a880773e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the dependencies of the package, which anyone who installs it gets.
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

`pyproject.toml` asks for a range, such as `click>=8.5.0`. `uv.lock` names the one version that uv chose, and the
versions of every package that click and requests need. Two people with the same lockfile get the same packages.

## step-02.1 A group for the tests, and when uv syncs

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/48a829ee985a69171af7c66846bdb8e7345a199c), the commit before step-02.1.

```bash
just setup
```

Since the last stop, the walk leaves out the rest of
[step-01](https://rahuldave.com/smallwikiapp-walk/watch/step-01.html). The command asks Wikipedia for a random
page, and prints its title and summary. It sends a User-Agent, and `wikiapp --version` prints the version. This
stop starts with that code.

A dependency group is a list of packages for the people who work on the project.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/645fc59b58e6f49dc92635e2562f949524a4629c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/48a829ee985a69171af7c66846bdb8e7345a199c...645fc59b58e6f49dc92635e2562f949524a4629c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the groups.
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

Now `.venv` has pytest, from the group `test`. The commands below show when uv syncs `.venv`, and when it does
not.

```bash
uv sync --no-dev
uv run --no-sync python -m pytest --version
uv run python -m pytest --version
```

`uv sync --no-dev` leaves out the group `dev`, and so it uninstalls pytest and the 4 packages that pytest needs.
`--no-sync` runs Python in `.venv` as it is, and the last line says `No module named pytest`. A plain `uv run`
syncs first. It installs the 5 packages again, and prints the version of pytest.

```bash
uv pip install six
uv run python -c "import six; print(six.__version__)"
uv sync
```

`uv pip install` puts six into `.venv`, and the lockfile does not name it. `uv run` leaves six in place, and prints
its version. `uv sync` uninstalls it, because a sync removes every package that the lockfile and the groups do not
name.

## step-04.8 A lockfile that must be up to date

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a), the commit before step-04.8.

```bash
just setup
```

Since the last stop, the walk leaves out the moves from
[step-02.2](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html#step-02.2) to
[step-04.7](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.7). pytest-mock and pytest-cov joined
the group `test`. The project got tests with a mock, a library, `src/wikiapp/wikipedia.py`, and recipes in the
justfile that run each tool with `uv run`. ruff and validate-pyproject came in, in a new group `lint`, which `dev`
includes. `just lint-config` runs `uv lock --check`, which fails if the lockfile is out of date with
`pyproject.toml`. This stop starts with that code.

The justfile exports `UV_LOCKED`.

### step-04.8 A locked lockfile

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a45828b7972f3de77bd6a8d7a00a6b55833832cb) shows what the move changes.

Now we export the variable `UV_LOCKED` from the `justfile`, under `set positional-arguments`. With it, every `uv
run` of a recipe refuses a lockfile that is out of date. Without it, `uv run` quietly updates the lockfile.

In the `justfile`, under `set positional-arguments`, add the line below.

```just

export UV_LOCKED := "1"
```

The move changes one file:

- `justfile`: 2 lines added; the variable `UV_LOCKED`, exported to every recipe.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/a45828b7972f3de77bd6a8d7a00a6b55833832cb/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a...a45828b7972f3de77bd6a8d7a00a6b55833832cb#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): one line.
  - look at: `export UV_LOCKED := "1"`

The change of `justfile`:

```diff
@@ -3,6 +3,8 @@
 # Each word after a recipe's name reaches its commands whole, as "$1", "$2" and so on; "$@" is all of them
 set positional-arguments
 
+export UV_LOCKED := "1"
+
 [private]
 default:
     @just --list --unsorted
```

```bash
just --evaluate UV_LOCKED
```

It prints `1`. `just` puts the variable in the environment of every command of every recipe, so each `uv run`
sees it.

uv has three ways to treat the lockfile. With no option, `uv run` and `uv sync` solve it again and write it, if it
is out of date with `pyproject.toml`. `--locked`, or `UV_LOCKED`, refuses a lockfile that is out of date. `--frozen`
uses the lockfile as it is, and does not compare it with `pyproject.toml`.

The project uses `--locked`. So a change to the dependencies, the version or `requires-python` without `uv lock`
fails in every recipe that runs `uv run` or `uv sync`. `uv build` does not read the lockfile, so `just build` still
works.

## step-06.3 The oldest Python, and other environments

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/41e5681a18bc9975f383d1520b8781c4e836e90d), the commit before step-06.3.

```bash
just setup
```

Since the last stop, the walk leaves out the moves from
[step-04.9](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.9) to
[step-06.2](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.2). `just check` runs every check,
and a git hook runs it before each commit. pre-commit and ty, a type checker, came in, in the group `lint`, and
`just check` runs ty. The tests that ask the real Wikipedia run only on request. This stop starts with that code.

`.python-version` says which Python `.venv` has. `requires-python` says which Pythons the project accepts.

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
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/15ba9fa843e3f055dac9c8f1a844b7382858b761/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/41e5681a18bc9975f383d1520b8781c4e836e90d...15ba9fa843e3f055dac9c8f1a844b7382858b761#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
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

`--isolated` made a second environment, which uv deletes after the command. `uvx` makes a third kind, an
environment of its own for one tool.

```bash
uv run python -c "import sys; print(sys.prefix)"
uvx --from ruff python -c "import sys; print(sys.prefix)"
```

The first path ends in `.venv`. The second is a folder in the cache of uv, with ruff installed. `uvx ruff` picks a
ruff of its own, which need not be the version that the lockfile names. So the recipes run ruff with `uv run`, and
get the version of the lockfile.

## step-06.4 Pythons and groups on GitHub

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/15ba9fa843e3f055dac9c8f1a844b7382858b761), the commit before step-06.4.

```bash
just setup
```

This stop shows which groups GitHub's jobs install.

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

The job `tests` runs `uv run --locked pytest`, and so it installs the group `dev`, with ruff, ty and pre-commit.
pytest needs none of them. A dry run shows what the job would leave out with the group `test` alone.

```bash
uv sync --locked --no-default-groups --group test --dry-run
```

uv would uninstall 14 packages, ruff, ty, pre-commit and validate-pyproject among them. The project does not make
this change, and each of the twelve jobs installs the whole group `dev`.

## step-09.1 A workspace

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/1ea19fb90f9341fd939f150ef44d2089986e07be), the commit before step-09.1.

```bash
just setup
```

Since the last stop, the walk leaves out [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html) and
[step-08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html). `uv add pydantic` added pydantic to the
dependencies. `random_page` returns a `Page`, a pydantic model. smalldocs came in, in a new group `docs`, which
`dev` includes. `just docs` builds a site from the code, and `just docs check` counts what has documentation. This
stop starts with that code.

The library becomes a second package of the project. The two packages form a workspace.

### step-09.1 An empty library, wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/474ca60c5ff642f9e6d80d47cccc18831fb38232) shows what the move changes.

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

```bash
uv init --lib --author-from none packages/wikirandom
```

Another version of uv writes another range for `uv_build` in the library's `pyproject.toml`, so that line differs
from the commit. timewalk still finds that your files match, since it compares the file without the versions.

Next we give the library's `pyproject.toml` Python 3.11, as the app has, and a description. Its `README.md` gets a
heading and one line of what it is.

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

Then we make the lockfile again with `uv lock`, for the workspace of two packages.

```bash
uv lock
```

The move changes these files:

- `packages/wikirandom/pyproject.toml`: 11 lines added; new. It has the package's name, version and description, and uv_build.
- `packages/wikirandom/README.md`: 3 lines added; new. It says what the library is.
- `packages/wikirandom/src/wikirandom/__init__.py`: 2 lines added; new. It has uv's example function, `hello`.
- `packages/wikirandom/src/wikirandom/py.typed`: new and empty. It tells ty and other checkers that the package has types.
- `pyproject.toml`: 5 lines added; the workspace, with one member.
- `uv.lock`: 11 lines added; the second package.

Files to read:
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/474ca60c5ff642f9e6d80d47cccc18831fb38232/packages/wikirandom/pyproject.toml): a package of its own.
  - look at: `name = "wikirandom"`
- [`packages/wikirandom/README.md`](https://github.com/rahuldave/smallwikiapp/blob/474ca60c5ff642f9e6d80d47cccc18831fb38232/packages/wikirandom/README.md): a heading, and what the library is.
  - look at: ``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/474ca60c5ff642f9e6d80d47cccc18831fb38232/packages/wikirandom/src/wikirandom/__init__.py): uv's example function.
  - look at: `def hello() -> str:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/474ca60c5ff642f9e6d80d47cccc18831fb38232/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/1ea19fb90f9341fd939f150ef44d2089986e07be...474ca60c5ff642f9e6d80d47cccc18831fb38232#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the workspace.
  - look at: `"packages/wikirandom",`

The change of `pyproject.toml`:

```diff
@@ -74,3 +74,8 @@ select = [
 [tool.ruff.lint.per-file-ignores]
 # A test is written with assert
 "tests/**" = ["S101"]
+
+[tool.uv.workspace]
+members = [
+    "packages/wikirandom",
+]
```

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.hello())"
```

The command prints `Hello from wikirandom!`. `--package wikirandom` installs the library into the shared `.venv`,
and runs the command there. The app does not depend on the library yet, so a plain `uv run` would not install it.

A workspace member is a package that the root `pyproject.toml` names under `[tool.uv.workspace]`. With no
workspace, the app could name the library by its folder. At stop 9, it would write the line below under
`[tool.uv.sources]`.

```toml
wikirandom = { path = "packages/wikirandom" }
```

uv would copy the library into `.venv`, so an edit to it would reach the app only after a new sync. uv links a
workspace member instead. The library would also be a project of its own. `uv lock` in its folder would write a
second lockfile, `uv run --package wikirandom` would fail, and `uv build --all-packages` would build only the app.

## step-09.2 A dependency of one member

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/474ca60c5ff642f9e6d80d47cccc18831fb38232), the commit before step-09.2.

```bash
just setup
```

`--package wikirandom` makes `uv add` change the library's `pyproject.toml`, and not the app's.

### step-09.2 The code goes into wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/0b62a6adc7bdea694923769184c3c0708d0d6774) shows what the move changes.

Now we give the library the code of `src/wikiapp/wikipedia.py`, and the packages that the code imports.
The library needs requests and pydantic. `packages/wikirandom/src/wikirandom/__init__.py` now contains the code of
`src/wikiapp/wikipedia.py`. Its docstring says what the package is. Its User-Agent names the program that makes
the request.

```bash
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

The move changes these files:

- `packages/wikirandom/src/wikirandom/__init__.py`: 41 lines added, 2 removed; the code of wikipedia.py.
- `packages/wikirandom/pyproject.toml`: 4 lines added, 1 removed; requests and pydantic, which are the library's dependencies.
- `uv.lock`: 10 lines added; the library's dependencies.

Files to read:
- [`packages/wikirandom/src/wikirandom/__init__.py`](https://github.com/rahuldave/smallwikiapp/blob/0b62a6adc7bdea694923769184c3c0708d0d6774/packages/wikirandom/src/wikirandom/__init__.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/474ca60c5ff642f9e6d80d47cccc18831fb38232...0b62a6adc7bdea694923769184c3c0708d0d6774#diff-872d7a197fe9f160d159d0b82650ce1c3a922c71cfb992ffe8c82113430501cc): the library.
  - look at: `def random_page(`
- [`packages/wikirandom/pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/0b62a6adc7bdea694923769184c3c0708d0d6774/packages/wikirandom/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/474ca60c5ff642f9e6d80d47cccc18831fb38232...0b62a6adc7bdea694923769184c3c0708d0d6774#diff-dba523fb4ea9a53f2d7b8fd6a67ba45f8fc7242e3da5c00681e0a9fbbe049f53): its dependencies.
  - look at: `"pydantic>=2.14.0",`

The change of `packages/wikirandom/src/wikirandom/__init__.py`:

```diff
@@ -1,2 +1,41 @@
-def hello() -> str:
-    return "Hello from wikirandom!"
+"""wikirandom: a random page of Wikipedia, in any language, from its REST API."""
+
+import re
+
+import requests
+from pydantic import BaseModel, ValidationError
+
+API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
+LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
+USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+
+
+class WikipediaError(Exception):
+    """Wikipedia could not give a page."""
+
+
+class Page(BaseModel):
+    """A page of Wikipedia: its title and the summary of its text."""
+
+    title: str  # The title of the page
+    extract: str  # The summary: the first paragraph of the page, as plain text
+
+
+def random_page(
+    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
+) -> Page:  # A page chosen at random
+    """Get a random page from Wikipedia.
+
+    Raises WikipediaError when the language is not a language code, when the request fails, or
+    when the answer is not a page.
+    """
+    if not LANGUAGE.fullmatch(language):
+        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
+    try:
+        with requests.get(
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
+        ) as response:
+            response.raise_for_status()
+            return Page.model_validate(response.json())
+    except (requests.RequestException, ValidationError) as error:
+        raise WikipediaError(str(error)) from error
```

The change of `packages/wikirandom/pyproject.toml`:

```diff
@@ -4,7 +4,10 @@ version = "0.1.0"
 description = "A random page of Wikipedia, in any language"
 readme = "README.md"
 requires-python = ">=3.11"
-dependencies = []
+dependencies = [
+    "pydantic>=2.14.0",
+    "requests>=2.34.2",
+]
 
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
```

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The command prints the title of a French page. The app still has its own `wikipedia.py`, and does not use the
library yet.

## step-09.3 The app uses the library

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/0b62a6adc7bdea694923769184c3c0708d0d6774), the commit before step-09.3.

```bash
just setup
```

The app's `pyproject.toml` names the library as a dependency, and `[tool.uv.sources]` says where uv gets it.

### step-09.3 The app uses wikirandom

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/024ec7d71c51f7d8d6ef351641f301df94ada4be) shows what the move changes.

Now we make the library a dependency of the app, in place of requests and pydantic. In the app's code, only
`src/wikiapp/wikipedia.py` imports those two, and it goes later in the move. `tests/test_console.py` still imports
requests, which now comes with wikirandom.

Because wikirandom is a member of the workspace, `uv add` writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`. So uv installs the library from `packages/wikirandom`, and not from PyPI. A change to the
library's code then takes effect in the app with no new install. `src/wikiapp/console.py` imports from the
library. The import goes with the installed packages, under `import click`, so the lines are already in ruff's
order.

```bash
uv add wikirandom
```

```bash
uv remove requests pydantic
```

In `src/wikiapp/console.py`, import from the library, in place of the import from `wikiapp.wikipedia`.

```python
import click
from wikirandom import WikipediaError, random_page

from wikiapp import __version__
```

Next we delete `src/wikiapp/wikipedia.py`, and rename `tests/test_wikipedia.py` to `tests/test_wikirandom.py`.

```bash
git rm src/wikiapp/wikipedia.py
```

```bash
git mv tests/test_wikipedia.py tests/test_wikirandom.py
```

Next we make the renamed file, `tests/test_wikirandom.py`, test the library.
Its docstring is `Tests of the library, wikirandom.`, and it imports
`wikirandom` under `import pytest`. Its tests call `wikirandom.random_page`, `wikirandom.Page` and
`wikirandom.WikipediaError`. The host `es.wikipedia.org` in the first test stays as it was.

Make `tests/test_wikirandom.py` test the library.

- Change its docstring to `Tests of the library, wikirandom.`
- Put `import wikirandom` under `import pytest`, in place of `from wikiapp import wikipedia` and the blank line
  before it.
- Change `wikipedia.random_page`, `wikipedia.Page` and `wikipedia.WikipediaError` to `wikirandom.random_page`,
  `wikirandom.Page` and `wikirandom.WikipediaError`.

Keep the host `es.wikipedia.org` in the first test as it is.

Then we make coverage, in `pyproject.toml`, measure both packages.

In `pyproject.toml`, make coverage measure both packages. Replace the first line of the comment above
`addopts`, and the line `addopts`, with the lines below.

```toml
# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
```

```toml
addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
```

Last, we add a row for the library to `README.md`, and make the front page, `docs/index.qmd`, name two
packages.
The library's README now says that the app uses the library, and no longer that it will.

In `README.md`, replace the `src/wikiapp/` row of the table of folders with the two rows below.

```markdown
| `src/wikiapp/` | The app. `console.py` is the `wikiapp` command |
| `packages/wikirandom/` | The library the app uses: a random page of Wikipedia. A package of its own |
```

The front page is long to type, so take `docs/index.qmd` from [the move's commit](https://github.com/rahuldave/smallwikiapp/compare/0b62a6adc7bdea694923769184c3c0708d0d6774...024ec7d71c51f7d8d6ef351641f301df94ada4be).

In `packages/wikirandom/README.md`, replace the line under the heading with the line below.

```markdown
A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```

The move changes these files:

- `pyproject.toml`: 6 lines added, 4 removed; wikirandom in, requests and pydantic out. The source of wikirandom is the workspace, and coverage measures both packages.
- `uv.lock`: 2 lines added, 4 removed; the app's dependencies are now click and wikirandom.
- `src/wikiapp/console.py`: 1 line added, 1 removed; imports from wikirandom.
- `src/wikiapp/wikipedia.py`: deleted, 41 lines.
- `tests/test_wikirandom.py`: 7 lines added, 8 removed; renamed from `tests/test_wikipedia.py`, and it tests wikirandom.
- `README.md`: 2 lines added, 1 removed; a row for the library, and the `src/wikiapp/` row says the app.
- `docs/index.qmd`: 8 lines added, 7 removed; two packages, the library and the app.
- `packages/wikirandom/README.md`: 1 line added, 1 removed; says that wikiapp uses the library now.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/024ec7d71c51f7d8d6ef351641f301df94ada4be/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/0b62a6adc7bdea694923769184c3c0708d0d6774...024ec7d71c51f7d8d6ef351641f301df94ada4be#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the app depends on the library.
  - look at: `wikirandom = { workspace = true }`
- [`src/wikiapp/console.py`](https://github.com/rahuldave/smallwikiapp/blob/024ec7d71c51f7d8d6ef351641f301df94ada4be/src/wikiapp/console.py), [its change](https://github.com/rahuldave/smallwikiapp/compare/0b62a6adc7bdea694923769184c3c0708d0d6774...024ec7d71c51f7d8d6ef351641f301df94ada4be#diff-3695191d893fa6126fe5f92917b13d177600823c014ec46569d1d08d7ca43353): one import.
  - look at: `from wikirandom import WikipediaError, random_page`
- [`tests/test_wikirandom.py`](https://github.com/rahuldave/smallwikiapp/blob/024ec7d71c51f7d8d6ef351641f301df94ada4be/tests/test_wikirandom.py): the same three tests.
  - look at: `wikirandom.random_page(language="es")`
- [`README.md`](https://github.com/rahuldave/smallwikiapp/blob/024ec7d71c51f7d8d6ef351641f301df94ada4be/README.md), [its change](https://github.com/rahuldave/smallwikiapp/compare/0b62a6adc7bdea694923769184c3c0708d0d6774...024ec7d71c51f7d8d6ef351641f301df94ada4be#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5): one row more, and the `src/wikiapp/` row says the app.
  - look at: `| The library the app uses: a random page of Wikipedia. A package of its own |`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/024ec7d71c51f7d8d6ef351641f301df94ada4be/docs/index.qmd), [its change](https://github.com/rahuldave/smallwikiapp/compare/0b62a6adc7bdea694923769184c3c0708d0d6774...024ec7d71c51f7d8d6ef351641f301df94ada4be#diff-bfcaadbc044f4848960f04c96f4ac5930e20671e52514c04dd8347ff6f79ca7b): two packages.
  - look at: `The code has two packages, in one repository:`
- [`packages/wikirandom/README.md`](https://github.com/rahuldave/smallwikiapp/blob/024ec7d71c51f7d8d6ef351641f301df94ada4be/packages/wikirandom/README.md), [its change](https://github.com/rahuldave/smallwikiapp/compare/0b62a6adc7bdea694923769184c3c0708d0d6774...024ec7d71c51f7d8d6ef351641f301df94ada4be#diff-67c60576149738029c3a79bb8233bfb2720f590c0a16b6e4a7dab774bf98d1f9): the library's README says that the app uses it.
  - look at: ``A random page of Wikipedia, in any language. The command `wikiapp` uses this library.``

The change of `pyproject.toml`:

```diff
@@ -9,8 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
-    "pydantic>=2.14.0",
-    "requests>=2.34.2",
+    "wikirandom",
 ]
 
 [project.scripts]
@@ -39,10 +38,10 @@ build-backend = "uv_build"
 
 [tool.pytest.ini_options]
 testpaths = ["tests"]
-# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
+# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
 # marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
 # just test -m e2e
-addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
+addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
 markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
 
 [tool.ruff]
@@ -79,3 +78,6 @@ select = [
 members = [
     "packages/wikirandom",
 ]
+
+[tool.uv.sources]
+wikirandom = { workspace = true }
```

The change of `src/wikiapp/console.py`:

```diff
@@ -3,9 +3,9 @@
 import textwrap
 
 import click
+from wikirandom import WikipediaError, random_page
 
 from wikiapp import __version__
-from wikiapp.wikipedia import WikipediaError, random_page
 
 
 @click.command()
```

The change of `README.md`:

```diff
@@ -30,7 +30,8 @@ Then `just setup`, and `uv run wikiapp`.
 | Path | What it is |
 |---|---|
 | `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
-| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
+| `src/wikiapp/` | The app. `console.py` is the `wikiapp` command |
+| `packages/wikirandom/` | The library the app uses: a random page of Wikipedia. A package of its own |
 | `tests/` | The tests. `just test` runs them |
 | `docs/` | The docs site. smalldocs makes its reference from the code |
 | `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
```

The change of `docs/index.qmd`:

````diff
@@ -16,13 +16,14 @@ Le Changement démocratique est un parti politique salvadorien fondé en
 2005.
 ```
 
-The code has two modules:
-
-- `wikiapp.wikipedia`, the library. `random_page` asks Wikipedia for a random page and returns a
-  `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a language
-  code, if the request fails, or if the answer is not a page. The library knows nothing of the command line.
-- `wikiapp.console`, the app. `main` is the command. It reads `--language`, calls `random_page`, and
-  prints the page, or the error.
+The code has two packages, in one repository:
+
+- `wikirandom`, the library, in `packages/wikirandom`. `random_page` asks Wikipedia for a random page
+  and returns a `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a
+  language code, if the request fails, or if the answer is not a page. The library knows nothing of the
+  command line.
+- `wikiapp`, the app. `main`, in `wikiapp.console`, is the command. It reads `--language`, calls
+  `random_page`, and prints the page, or the error.
 
 Each build of the site makes the pages under Reference from the code. A page takes these parts from
 each function:
````

The change of `packages/wikirandom/README.md`:

```diff
@@ -1,3 +1,3 @@
 # wikirandom
 
-A random page of Wikipedia, in any language. The command `wikiapp` will use this library.
+A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```

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

```bash
ls -a packages/wikirandom
```

The library's folder has its `pyproject.toml`, and no `uv.lock` or `.venv`. The workspace has one lockfile and one
`.venv`, at its root.

## step-10.1 A build of both packages

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea), the commit before step-10.1.

```bash
just setup
```

Since the last stop, the walk leaves out the move
[step-09.4](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html#step-09.4), in which the docs check counts
the library. This stop starts with that code.

`uv build` builds a package with the build backend that its `pyproject.toml` names, here `uv_build`.

### step-10.1 The recipe `build`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/fc6091aa4bb985af8c55e5ed8f55a8df94078587) shows what the move changes.

Now we add a recipe, `build`, at the end of the `justfile`, that builds both packages. It runs
`uv build --all-packages`, which builds every package of the workspace into `dist/`. `.gitignore` lists `dist/`.

Add the recipe at the end of the `justfile`.

```just

# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
[group('setup')]
[no-exit-message]
build *args:
    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```

The move changes one file:

- `justfile`: 6 lines added; the recipe `build`.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/fc6091aa4bb985af8c55e5ed8f55a8df94078587/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea...fc6091aa4bb985af8c55e5ed8f55a8df94078587#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `build *args:`

The change of `justfile`:

```diff
@@ -84,3 +84,9 @@ docs *args:
     if [ "$*" = help ]; then just help docs; exit 0; fi
     if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
     exec uv run smalldocs api "$@" --dir docs
+
+# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
+[group('setup')]
+[no-exit-message]
+build *args:
+    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```

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

## step-10.2 A range of versions for the library

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/fc6091aa4bb985af8c55e5ed8f55a8df94078587), the commit before step-10.2.

```bash
just setup
```

The metadata of the app's wheel lists the dependencies as `dependencies` gives them, in lines `Requires-Dist`. It
has nothing of `[tool.uv.sources]`.

### step-10.2 The app needs wikirandom 0.1

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/a1be2b1d309a8b37ef50a9b28fd0aed0cc4cd79e) shows what the move changes.

Now we give the app's dependency on wikirandom a range of versions, `>=0.1.0,<0.2`. Until now, the app's wheel
says that the app needs `wikirandom`, of any version. An install from PyPI would take any package that anyone
publishes under that name. The app works with wikirandom 0.1.0, and `<0.2` keeps out a later release that may
change the library.

```bash
uv add "wikirandom>=0.1.0,<0.2"
```

Nothing else changes in the workspace. uv still installs the library from `packages/wikirandom`, as
`[tool.uv.sources]` says.

The move changes one file:

- `pyproject.toml`: 1 line added, 1 removed; a version range on wikirandom.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/a1be2b1d309a8b37ef50a9b28fd0aed0cc4cd79e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/fc6091aa4bb985af8c55e5ed8f55a8df94078587...a1be2b1d309a8b37ef50a9b28fd0aed0cc4cd79e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one line.
  - look at: `"wikirandom>=0.1.0,<0.2",`

The change of `pyproject.toml`:

```diff
@@ -9,7 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
-    "wikirandom",
+    "wikirandom>=0.1.0,<0.2",
 ]
 
 [project.scripts]
```

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

The walk stops here. After it, the whole tutorial changes the justfile and gives the library a licence and an author.
Both packages get a link to the repository. The User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
