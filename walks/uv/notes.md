This walk takes the moves about uv out of the whole tutorial of smallwikiapp. `wikiapp` is a small command that
prints the title and the summary of a random Wikipedia page. uv makes the project, installs its packages, runs its
tools, and builds it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has twelve stops. Each stop takes a whole step or one move:

1. **The project, and its `.venv`** (step-00)
2. **Two dependencies, and the lockfile** (step-01.1)
3. **A group for the tests, and when uv syncs** (step-02.1)
4. **A lockfile that must be up to date** (step-04.8)
5. **The oldest Python, and other environments** (step-06.3)
6. **Pythons and groups on GitHub** (step-06.4)
7. **Each job on GitHub with its own group** (step-08b)
8. **A workspace** (step-09.1)
9. **A dependency of one member** (step-09.2)
10. **The app uses the library** (step-09.3)
11. **A build of both packages** (step-10.1)
12. **A range of versions for the library** (step-10.2)

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
| Dependency groups | `test`, `lint` and `docs`, for the people who work on the project. `dev` includes them, and uv installs `dev` by default | 3, 6 and 7 |
| `.python-version` and `requires-python` | The Python of `.venv`, and the oldest Python that the project accepts | 1 and 5 |
| Environments | `.venv`, a temporary one with `--isolated`, and the one of a tool that `uvx` runs | 1, 5 and 7 |
| A workspace | Several packages with one lockfile and one `.venv`. `--package` names one of them | 8 to 10 |
| `[tool.uv.sources]` | Where uv gets a package. Here the library comes from the workspace, not from PyPI | 10 and 12 |
| `uv build --all-packages` | Builds a wheel and a source archive of each package of the workspace | 11 and 12 |

## The project, and its `.venv`

This stop is all of step-00. `uv init` made the project, and `uv lock` wrote its lockfile.

{{include step-00}}

`.venv` is the environment of the project. It has a Python, and every package that the lockfile names. `uv run`
runs a command with that Python. So `uv run wikiapp` needs no step to activate `.venv` first.

## Two dependencies, and the lockfile

$ just setup

`uv add` writes a package into `pyproject.toml`, solves the lockfile again, and syncs `.venv`, all in one command.

{{include step-01.1}}

`pyproject.toml` asks for a range, such as `click>=8.5.0`. `uv.lock` names the one version that uv chose, and the
versions of every package that click and requests need. Two people with the same lockfile get the same packages.

## A group for the tests, and when uv syncs

$ just setup

Since the last stop, the walk leaves out the rest of
[step-01](https://rahuldave.com/smallwikiapp-walk/watch/step-01.html). The command asks Wikipedia for a random
page, and prints its title and summary. It sends a User-Agent, and `wikiapp --version` prints the version. This
stop starts with that code.

A dependency group is a list of packages for the people who work on the project.

{{include step-02.1}}

Now `.venv` has pytest, from the group `test`. The commands below show when uv syncs `.venv`, and when it does
not.

$ uv sync --no-dev

$ uv run --no-sync python -m pytest --version

$ uv run python -m pytest --version

`uv sync --no-dev` leaves out the group `dev`, and so it uninstalls pytest and the 4 packages that pytest needs.
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

Since the last stop, the walk leaves out the moves from
[step-02.2](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html#step-02.2) to
[step-04.7](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.7). pytest-mock and pytest-cov joined
the group `test`. The project got tests with a mock, a library, `src/wikiapp/wikipedia.py`, and recipes in the
justfile that run each tool with `uv run`. ruff and validate-pyproject came in, in a new group `lint`, which `dev`
includes. `just lint-config` runs `uv lock --check`, which fails if the lockfile is out of date with
`pyproject.toml`. This stop starts with that code.

The justfile exports `UV_LOCKED`.

{{include step-04.8}}

uv has three ways to treat the lockfile. With no option, `uv run` and `uv sync` solve it again and write it, if it
is out of date with `pyproject.toml`. `--locked`, or `UV_LOCKED`, refuses a lockfile that is out of date. `--frozen`
uses the lockfile as it is, and does not compare it with `pyproject.toml`.

The project uses `--locked`. So a change to the dependencies, the version or `requires-python` without `uv lock`
fails in every recipe that runs `uv run` or `uv sync`. `uv build` does not read the lockfile, so `just build`, from
stop 11, still works.

## The oldest Python, and other environments

$ just setup

Since the last stop, the walk leaves out the moves from
[step-04.9](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.9) to
[step-06.2](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.2). `just check` runs every check,
and a git hook runs it before each commit. pre-commit and ty, a type checker, came in, in the group `lint`, and
`just check` runs ty. The tests that ask the real Wikipedia run only on request. This stop starts with that code.

`.python-version` says which Python `.venv` has. `requires-python` says which Pythons the project accepts.

{{include step-06.3}}

`--isolated` made a second environment, which uv deletes after the command. `uvx` makes a third kind, an
environment of its own for one tool.

$ uv run python -c "import sys; print(sys.prefix)"

$ uvx --from ruff python -c "import sys; print(sys.prefix)"

The first path ends in `.venv`. The second is a folder in the cache of uv, with ruff installed. `uvx ruff` picks a
ruff of its own, which need not be the version that the lockfile names. So the recipes run ruff with `uv run`, and
get the version of the lockfile.

## Pythons and groups on GitHub

$ just setup

This stop shows which groups GitHub's jobs install.

{{include step-06.4}}

The job `tests` runs `uv run --locked pytest`, and so it installs the group `dev`, with ruff, ty and pre-commit.
pytest needs none of them. A dry run shows what the job would leave out with the group `test` alone.

$ uv sync --locked --no-default-groups --group test --dry-run

uv would uninstall 14 packages, ruff, ty, pre-commit and validate-pyproject among them. The project makes this
change at the next stop.

## Each job on GitHub with its own group

Since the last stop, the walk leaves out [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html) and
[step-08](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html). `uv add pydantic` added pydantic to the
dependencies. `random_page` returns a `Page`, a pydantic model. smalldocs came in, in a new group `docs`, which
`dev` includes. `just docs` builds a site from the code, and `just docs check` counts what has documentation. This
stop starts with that code.

This stop is all of step-08b. The jobs `tests` install the group `test` alone, and a new workflow builds the
docs with the group `docs` alone.

{{include step-08b}}

`--no-default-groups --group NAME` installs the package and one group. Now a person and the job `check` install
`dev`, since they run every tool.

## A workspace

$ just setup

The library becomes a second package of the project. The two packages form a workspace.

{{include step-09.1}}

A workspace member is a package that the root `pyproject.toml` names under `[tool.uv.workspace]`. With no
workspace, the app could name the library by its folder. At stop 10, it would write the line below under
`[tool.uv.sources]`.

```toml
wikirandom = { path = "packages/wikirandom" }
```

uv would copy the library into `.venv`. A plain sync does not see an edit to the library, so the edit would reach
the app only after `uv sync --reinstall-package wikirandom`. uv links a workspace member instead. The library would
also be a project of its own. `uv lock` in its folder would write a second lockfile, `uv run --package wikirandom`
would fail, and `uv build --all-packages` would build only the app.

## A dependency of one member

$ just setup

`--package wikirandom` makes `uv add` change the library's `pyproject.toml`, and not the app's.

{{include step-09.2}}

## The app uses the library

$ just setup

The app's `pyproject.toml` names the library as a dependency, and `[tool.uv.sources]` says where uv gets it.

{{include step-09.3}}

$ ls -a packages/wikirandom

The library's folder has its `pyproject.toml`, and no `uv.lock` or `.venv`. The workspace has one lockfile and one
`.venv`, at its root.

## A build of both packages

$ just setup

Since the last stop, the walk leaves out the move
[step-09.4](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html#step-09.4), in which the docs check counts
the library. This stop starts with that code.

`uv build` builds a package with the build backend that its `pyproject.toml` names, here `uv_build`.

{{include step-10.1}}

## A range of versions for the library

$ just setup

The metadata of the app's wheel lists the dependencies as `dependencies` gives them, in lines `Requires-Dist`. It
has nothing of `[tool.uv.sources]`.

{{include step-10.2}}

The walk stops here. After it, the whole tutorial changes the justfile and gives the library a licence and an author.
Both packages get a link to the repository. The User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
