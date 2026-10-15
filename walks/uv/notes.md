We manage the packages of `wikiapp` with uv. `wikiapp` is a small command that prints the title and the summary of
a random Wikipedia page. A project must install the same packages on every machine, and keep the tools of its
authors apart from what its users get. uv makes the project, installs its packages, runs its tools, and builds it.
This tutorial takes the parts about uv out of the whole tutorial of smallwikiapp.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has eleven sections:

1. **The project, and its `.venv`**
2. **Two dependencies, and the lockfile**
3. **A group for the tests, and when uv syncs**
4. **A lockfile that must be up to date**
5. **The oldest Python, and other environments**
6. **Versions of Python and groups on GitHub**
7. **Each job on GitHub with its own group**
8. **A workspace**
9. **The app uses the library**
10. **A build of both packages**
11. **A range of versions for the library**

Some sections run commands that the whole tutorial does not. They change `.venv`, and no file that git tracks. The
`$ just setup` at the top of the next section makes `.venv` match the lockfile again.

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**What uv does in this project**

| Idea | What it means here | Sections |
|---|---|---|
| `pyproject.toml` and `uv.lock` | `pyproject.toml` gives the range of versions of each package. `uv.lock` gives the exact version that uv chose | 1 and 2 |
| `uv sync` | Makes `.venv` match the lockfile and the groups it installs. It installs what is missing, and removes every other package | 1 and 3 |
| `uv run` | Syncs first, then runs a command in `.venv`. The sync installs what is missing, and removes nothing. `--no-sync` skips the sync | 3 |
| `--locked` and `UV_LOCKED` | Refuse a lockfile that is out of date with `pyproject.toml` | 1 and 4 |
| `--frozen` | Uses the lockfile as it is, and does not check it. The project never uses it | 4 |
| Dependency groups | `test`, `lint` and `docs`, for the people who work on the project. `default-groups = "all"` makes uv install every group | 3, 6 and 7 |
| `.python-version` and `requires-python` | The Python of `.venv`, and the oldest Python that the project accepts | 1 and 5 |
| Environments | `.venv`, a temporary one with `--isolated`, and the one of a tool that `uvx` runs | 1, 5 and 7 |
| A workspace | Several packages with one lockfile and one `.venv`. `--package` names one of them | 8 and 9 |
| `[tool.uv.sources]` | Where uv gets a package. Here the library comes from the workspace, not from PyPI | 9 and 11 |
| `uv build --all-packages` | Builds a wheel and a source archive of each package of the workspace | 10 and 11 |

## The project, and its `.venv`

A project needs a Python and its packages in one place, apart from the rest of the machine. `uv init` made the
project, and `uv lock` wrote its lockfile.

{{include step-00}}

`.venv` is the environment of the project. It has a Python, and every package that the lockfile names. `uv run`
runs a command with that Python. So `uv run wikiapp` works at once. Without uv, a person
first activates `.venv`, with a command that makes the shell use the Python of `.venv`.

## Two dependencies, and the lockfile

$ just setup

The command needs two packages that Python does not have. `uv add` writes a package into `pyproject.toml`, and
syncs `.venv`. It also chooses one version of each package that fits every range of versions, and writes the
versions in `uv.lock`. uv calls this choice resolving.

{{include step-01.1}}

`pyproject.toml` asks for a range, such as `click>=8.5.0`. `uv.lock` names the one version that uv chose, and the
versions of every package that click and requests need. Two people with the same lockfile get the same packages.

## A group for the tests, and when uv syncs

$ just setup

The command now asks Wikipedia for a random page, and prints its title and summary. It sends a User-Agent, a line
that tells Wikipedia the name of the program that asks. `wikiapp --version` prints the version.

The tests need pytest, and a user of the command does not. A dependency group is a list of packages for the
people who work on the project. By default uv installs only a group named `dev`. The project first sets
`default-groups = "all"`, so that uv installs every group. Then the test tools, the linters and the docs tools can
each have a group of their own.

{{include step-02.1..step-02.3}}

Now `.venv` has pytest, from the group `test`. The commands below show when uv syncs `.venv`, and when it does
not.

$ uv sync --no-default-groups

$ uv run --no-sync python -m pytest --version

$ uv run python -m pytest --version

`uv sync --no-default-groups` leaves out every group, and so it uninstalls pytest and the 4 packages that pytest
needs.
`--no-sync` runs Python in `.venv` as it is, and the last line says `No module named pytest`. A plain `uv run`
syncs first. It installs the 5 packages again, and prints the version of pytest.

$ uv pip install six

$ uv run python -c "import six; print(six.__version__)"

$ uv sync

`uv pip install` puts six into `.venv`, and the lockfile does not name it. `uv run` leaves six in place, and prints
its version. `uv sync` uninstalls it, because a sync removes every package that the lockfile and the groups do not
name.

## A lockfile that must be up to date

$ just setup

The code now also has pytest-mock and pytest-cov, in the group `test`. The project now has tests that use a
mock, a stand-in that answers in place of Wikipedia with no network. It also has recipes in the justfile that run each tool with `uv run`. The code that asks Wikipedia is now a library
of its own, `src/wikiapp/wikipedia.py`. ruff and
validate-pyproject are in a new group `lint`. `just lint-config` runs `uv lock --check`,
which fails if the lockfile is out of date with `pyproject.toml`.

A recipe should fail when `pyproject.toml` changes and nobody runs `uv lock`. But with no option, `uv run` resolves
the lockfile again and prints no warning. The justfile now exports `UV_LOCKED`, which makes every `uv run` refuse a
lockfile that is out of date.

{{include step-04.10}}

uv has three ways to treat the lockfile. With no option, `uv run` and `uv sync` resolve it again and write it, if it
is out of date with `pyproject.toml`. `--locked`, or `UV_LOCKED`, refuses a lockfile that is out of date. `--frozen`
uses the lockfile as it is, and does not compare it with `pyproject.toml`.

The project uses `--locked`. So a change to the dependencies, the version or `requires-python` without `uv lock`
fails in every recipe that runs `uv run` or `uv sync`. `uv build` does not read the lockfile, so `just build`, from
section 10, still works.

## The oldest Python, and other environments

$ just setup

The code now also has `just check`, which runs every check, and a git hook runs it before each `git commit`.
`pre-commit` and ty, a type checker, are in the group `lint`, and `just check` runs ty. The tests that ask the real
Wikipedia run only on request.

The project runs on one Python, and its users may have an older one. `.python-version` says which Python `.venv`
has. `requires-python` says which versions of Python the project accepts.

{{include step-06.3..step-06.4}}

The first of these moves changes `requires-python` by hand, and the second runs `uv lock`. Between the two, the
lockfile is out of date with `pyproject.toml`, and every recipe that runs `uv run` refuses it.

The second of these moves runs the tests with `uv run --isolated --python 3.11`. `--isolated` makes a second
environment, and uv deletes it after the command. `uvx` makes a third kind, an
environment of its own for one tool.

$ uv run python -c "import sys; print(sys.prefix)"

$ uvx --from ruff python -c "import sys; print(sys.prefix)"

The first path ends in `.venv`. The second is a folder in the cache of uv, with ruff installed. `uvx ruff` picks a
ruff of its own, which need not be the version that the lockfile names. So the recipes run ruff with `uv run`, and
get the version of the lockfile.

## Versions of Python and groups on GitHub

$ just setup

GitHub runs the tests on several versions of Python, and each job installs groups. This section shows which groups GitHub's
jobs install.

{{include step-06.5}}

The job `tests` runs `uv run --locked pytest`, and so it installs every group, with ruff, ty and `pre-commit`.
pytest needs none of them. A dry run shows what the job would leave out with the group `test` alone.

$ uv sync --locked --no-default-groups --group test --dry-run

uv would uninstall 14 packages, ruff, ty, `pre-commit` and validate-pyproject among them. The project makes this
change in the next section.

## Each job on GitHub with its own group

The code now also has pydantic in the dependencies, from `uv add pydantic`. The function `random_page`, which asks
Wikipedia for a page, now returns a `Page`. A `Page` is a pydantic model, a class that checks the type of each of
its fields. smalldocs is in a new group `docs`. `just docs` builds a site from the code,
and `just docs check` counts what has documentation.

{{include step-08b}}

`--no-default-groups --group NAME` installs the package and one group. A person and the job `check` still install
every group, since they run every tool.

## A workspace

$ just setup

The library and the app are in one package. So a program that needs only the library must install the app too. The library becomes a
second package of the project. The two packages form a workspace. The library also needs packages of its own.
`--package wikirandom` makes `uv add` change the library's `pyproject.toml`, and not the app's.

{{include step-09.1..step-09.2}}

A workspace member is a package that the root `pyproject.toml` names under `[tool.uv.workspace]`. With no
workspace, the app could name the library by its folder. In section 9, it would write the line below under
`[tool.uv.sources]`.

```toml
wikirandom = { path = "packages/wikirandom" }
```

Without a workspace:

- uv would copy the library into `.venv`. A plain sync does not see an edit to the library, so the edit would
  reach the app only after `uv sync --reinstall-package wikirandom`.
- The library would be a project of its own. `uv lock` in its folder would write a second lockfile.
- `uv run --package wikirandom` would fail, and `uv build --all-packages` would build only the app.

In the next section, the app comes to depend on the library. Because the library is a member of the workspace, uv
then installs it editable. An editable install points `.venv` at the library's code, in `packages/wikirandom/src`, so an edit to the library
reaches the app at once.

## The app uses the library

$ just setup

The code now also has a README of the library, and a copy of `wikipedia.py` as the library's code. The library has
its own docstring, and its User-Agent names `wikirandom`.

The app must get the library from the workspace, not from PyPI. The app's `pyproject.toml` names the library as a
dependency, and `[tool.uv.sources]` says where uv gets it.

{{include step-09.6..step-09.8}}

$ ls -a packages/wikirandom

The library's folder has its `pyproject.toml`, and no `uv.lock` or `.venv`. The workspace has one lockfile and one
`.venv`, at its root.

## A build of both packages

$ just setup

The code now also has a docs check that counts the library. The tests of the library are now in
`tests/test_wikirandom.py`.

A user installs a package from a wheel, and not from a copy of the repository. A wheel is one file that contains
the package, ready to install. `uv build` makes the wheel, and also a source archive of the code, with the build
backend that its `pyproject.toml` names, here `uv_build`. A build backend is the tool that packs the code into that file.

{{include step-10.1}}

## A range of versions for the library

$ just setup

`uv build` copies each entry of `dependencies` into a line `Requires-Dist` in the wheel's metadata. `[tool.uv.sources]` does not
go into the wheel. The app names wikirandom with no range of versions, so a user who installs the app from PyPI
can get any version of wikirandom.

{{include step-10.2}}

This tutorial ends here. After it, the whole tutorial changes the justfile, and gives the library a licence and an
author. Both packages get a link to the repository. The User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.
