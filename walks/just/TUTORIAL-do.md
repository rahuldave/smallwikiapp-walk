<!-- Made by timewalk-export from the notes of the walk. Do not edit it by hand: run timewalk-export again. -->

# just, the interface of smallwikiapp, one move at a time

In do mode, you make each move yourself. The notes give every line to type, every command and every file. [The same tutorial in watch mode](TUTORIAL-watch.md).

This walk takes the moves about the justfile out of the whole tutorial of smallwikiapp. `wikiapp` is a small
command that prints the title and the summary of a random Wikipedia page. The walk starts with the project, which
`uv init` began, for Python 3.13. The project has a justfile from the start.

The justfile is the interface of the project. Each task is a verb, such as `just test`, and the recipe behind the
verb names the tool that does the work. A person, a git hook and GitHub each run `just check`, and `check` runs
other verbs. A tool can change behind a verb, and the callers of the verb stay the same.

Each new verb comes in the same way. `just --show VERB` shows the recipe, then the verb runs. Most stops that bring
in a verb also run the tool's own command first. The stops of `test` and `check` do not.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the notes say "the original wikiapp", they mean that project.

The walk has seventeen stops. Each stop takes a whole step or one move:

1. **The project, and its justfile** (step-00)
2. **`just test`** (step-02.2)
3. **`just fmt`** (step-04.1)
4. **`just lint`** (step-04.3)
5. **`just lint-config`** (step-04.7)
6. **A variable for every recipe** (step-04.8)
7. **`just check`, everything a commit must pass** (step-04.9)
8. **The git hook runs `just check`** (step-04.10)
9. **`just types`** (step-05.1)
10. **The types join `just check`** (step-05.6)
11. **GitHub runs `just check`** (step-06.4)
12. **`just docs`** (step-08.1)
13. **`just docs` alone builds a site** (step-08.5)
14. **The docs check joins `just check`** (step-08.7)
15. **The library, behind the same verbs** (step-09.4)
16. **`just build`** (step-10.1)
17. **`just lint-config` checks the library too** (step-10.3)

Where the whole tutorial makes moves that this walk leaves out, the next stop says what they did. The stop
starts from their code.

**What `just check` runs**

`just check` is the gate of the project. It runs every check that a commit must pass, and stops at the first
that fails. The table gives each stop that changes what it runs.

| Stop | What changes | Where the change is |
|---|---|---|
| 7 | `check` comes in, with the format, the linter, the tests over a floor on the coverage, and the configuration | The justfile |
| 10 | The type checker | The justfile |
| 14 | The docs check | The justfile |
| 15 | The docs check counts the library | `docs/_smalldocs.yml` |
| 17 | The check of the configuration reads the library's `pyproject.toml` | The recipe `lint-config` |

Some moves that the walk leaves out change what `just check` runs too. They change `pyproject.toml`, not the
justfile. The move step-05.3 adds the rules `ANN` to the linter. The move step-06.1 leaves the e2e test out of each
run that does not ask for it, `just check` included. The move step-09.3 makes the floor on the coverage count both
packages.

**Who runs `just check`**

Three callers run `just check`, and none of them changes when `check` changes.

| Caller | From | When it runs |
|---|---|---|
| A person, in the terminal | Stop 7 | When the person remembers |
| The git hook | Stop 8 | Before each commit, in a clone where `just hook` ran |
| GitHub's job `check` | Stop 11 | On every push to main and every pull request |

## step-00 The project, and its justfile

[The code at step-00](https://github.com/rahuldave/smallwikiapp/tree/step-00)

This stop is all of step-00. It shows what `uv init` made, the command `wikiapp`, and the first justfile. The
justfile has three recipes. `default` lists the verbs, `help` explains one, and `setup` installs the project.

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

## step-02.2 `just test`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/645fc59b58e6f49dc92635e2562f949524a4629c), the commit before step-02.2.

```bash
just setup
```

Since the last stop, the walk leaves out [step-01](https://rahuldave.com/smallwikiapp-walk/watch/step-01.html) and
the move [step-02.1](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html#step-02.1). The command asks
Wikipedia for a random page, and prints its title and summary, with click and requests. It sends a User-Agent, and
has an option `--version`. pytest came in, in a dependency group `test`, with the first test. `uv run pytest`
printed `1 passed`. This stop starts with that code.

`just test` is the first verb after `setup`, and the first that runs a check.

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
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/94970c50651566f11d5c9d017cb01004e240821a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/645fc59b58e6f49dc92635e2562f949524a4629c...94970c50651566f11d5c9d017cb01004e240821a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

## step-04.1 `just fmt`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/b090ad74622ee6109dd72ae66feec36377eef7d7), the commit before step-04.1.

```bash
just setup
```

Since the last stop, the walk leaves out the rest of
[step-02](https://rahuldave.com/smallwikiapp-walk/watch/step-02.html) and all of
[step-03](https://rahuldave.com/smallwikiapp-walk/watch/step-03.html). The tests got a mock in place of
Wikipedia, and every run measures the coverage. The code split into a library, `src/wikiapp/wikipedia.py`, and
the command. The command got an option `--language`. The library raises its own error, `WikipediaError`, and
the command turns it into a message. This stop starts with that code.

ruff comes in, and `just fmt` formats the code and the tests.

### step-04.1 ruff, and the recipe fmt

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/693240e344546dda08ad8fee3951675a0302dbc9) shows what the move changes.

Now we add ruff, a formatter and a linter in one program, to a third dependency group, `lint`, which `dev`
includes.

A formatter changes how the code looks, and never what it does. A linter finds problems in the code, such as a
variable that is never used. It changes nothing unless it is asked to.

In `pyproject.toml`, change the line `dev = ...`, and add the group.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }]
lint = []
```

```bash
uv add --group lint ruff
```

Next we give ruff its settings, at the end of `pyproject.toml`. They set lines of up to 100 characters, and
write out the defaults of the formatter.

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

Then we add a recipe `fmt`, which runs the formatter. The words after `just fmt` go to `ruff format`.

Add a recipe at the end of the `justfile`.

```just

# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
[group('quality')]
[no-exit-message]
fmt *args:
    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```

The move changes these files:

- `pyproject.toml`: 15 lines added, 1 removed; the group `lint`, and ruff's settings.
- `justfile`: 6 lines added; the recipe `fmt`.
- `uv.lock`: 31 lines added; ruff.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/693240e344546dda08ad8fee3951675a0302dbc9/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/b090ad74622ee6109dd72ae66feec36377eef7d7...693240e344546dda08ad8fee3951675a0302dbc9#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group and the settings.
  - look at: `line-length = 100`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/693240e344546dda08ad8fee3951675a0302dbc9/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/b090ad74622ee6109dd72ae66feec36377eef7d7...693240e344546dda08ad8fee3951675a0302dbc9#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

## step-04.3 `just lint`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/ca8685e532e9d372857667484e1c94c91ac9e986), the commit before step-04.3.

```bash
just setup
```

Since the last stop, the walk leaves out the move
[step-04.2](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.2), in which `just fmt` formatted
the code. This stop starts with that code.

The rules of the linter go in `pyproject.toml`, and `just lint` runs the linter.

### step-04.3 The linter's rules, and the recipe lint

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/c97fdb1e8e820db24fac697b01283c581924537e) shows what the move changes.

Now we choose the linter's rules, in a table at the end of `pyproject.toml`. The linter checks the code against
rules, and the table chooses the families of rules, one family on each line. The tests may use `assert`. The rest
of the code may not use it, because Python skips every `assert` when it runs with `-O`.

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

Next we add a recipe `lint`, which runs the linter. The words after `just lint` go to `ruff check`.

Add a recipe at the end of the `justfile`.

```just

# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
[group('quality')]
[no-exit-message]
lint *args:
    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```

The move changes these files:

- `pyproject.toml`: 18 lines added; the rules.
- `justfile`: 6 lines added; the recipe `lint`.

Files to read:
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/c97fdb1e8e820db24fac697b01283c581924537e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/ca8685e532e9d372857667484e1c94c91ac9e986...c97fdb1e8e820db24fac697b01283c581924537e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): a family of rules on each line.
  - look at: `"tests/**" = ["S101"]`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/c97fdb1e8e820db24fac697b01283c581924537e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/ca8685e532e9d372857667484e1c94c91ac9e986...c97fdb1e8e820db24fac697b01283c581924537e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
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

## step-04.7 `just lint-config`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/80c33d4cfaf4b157cd44482712e520c77378cf9c), the commit before step-04.7.

```bash
just setup
```

Since the last stop, the walk leaves out the moves
[step-04.4](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.4) to
[step-04.6](https://rahuldave.com/smallwikiapp-walk/watch/step-04.html#step-04.6). `just lint --fix` sorted the
imports, since the words after `lint` go to ruff. A person fixed the other four problems. This stop starts with
that code.

`just lint-config` checks the configuration. Its recipe is a small shell script, which runs three commands and
stops at the first that fails.

### step-04.7 The recipe lint-config

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a) shows what the move changes.

Now we add validate-pyproject to the group `lint`, and a recipe `lint-config` that checks the configuration.
The recipe runs three commands. validate-pyproject checks `pyproject.toml` against the standard for it,
`uv lock --check` checks the lockfile, and `just --fmt --check --unstable` checks the `justfile`.

These commands check the configuration, not the code. An error in `pyproject.toml`, in the lockfile or in the
`justfile` can pass every test and the linter.

```bash
uv add --group lint validate-pyproject
```

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

The move changes these files:

- `justfile`: 11 lines added; the recipe `lint-config`.
- `pyproject.toml`: 1 line added; validate-pyproject in the group `lint`.
- `uv.lock`: 28 lines added, 1 removed; the exact version of validate-pyproject, and of what it needs.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/80c33d4cfaf4b157cd44482712e520c77378cf9c...4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe, with its three checks.
  - look at: `uv run validate-pyproject pyproject.toml`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/80c33d4cfaf4b157cd44482712e520c77378cf9c...4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): one package more in `lint`.
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

## step-04.8 A variable for every recipe

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/4d3556f88a6f2241bd4b64b2e6e613d3d4d2534a), the commit before step-04.8.

```bash
just setup
```

This move changes no recipe. It changes how each recipe that runs `uv` runs it.

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

## step-04.9 `just check`, everything a commit must pass

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a45828b7972f3de77bd6a8d7a00a6b55833832cb), the commit before step-04.9.

```bash
just setup
```

`just check` runs four of the other verbs, one after the other. It names no tool of its own.

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

From this stop on, "a commit must pass `just check`" is the rule of the project. The next stop and stop 11 add
two callers, which run it with no one typing it. Each later check joins `check`, so each caller runs it too.

## step-04.10 The git hook runs `just check`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/06ea9e2af2238f070b1e33f16aeb70002e25e44d), the commit before step-04.10.

```bash
just setup
```

pre-commit installs a git hook. The hook is one more caller of `just check`, and its only check of the code is
`just check`.

### step-04.10 A git hook

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/4834655a3e50dcf56c557463c29bfce592d6d3db) shows what the move changes.

Now we add pre-commit, which installs a git hook, to the group `lint`. A git hook is a program that git runs
before every commit. If the program fails, git refuses the commit.

`just check` is a gate that a person must remember to run. Once `just hook` installs the hook in a clone, the
hook runs it by itself, before each commit in that clone.

```bash
uv add --group lint pre-commit
```

Next we make `.pre-commit-config.yaml`, a new file that names the hooks. Three come from pre-commit's collection.
They check for valid YAML, large files and leftover merge-conflict markers. The last hook runs `just check`, so the
hook and the terminal run the same thing.

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

Then we add a recipe `hook`, after `setup` in the `justfile`, which installs the hook. It is a recipe of its own,
run once in each clone, because `just setup` runs at every step and never touches git.

In the `justfile`, after `setup` and the blank line under it, add the recipe `hook`, with a blank line after it.

```just
# Install the git hook: just check before every commit. Once per clone; just setup never touches git
[group('setup')]
hook *args:
    @{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}
```

The move changes these files:

- `.pre-commit-config.yaml`: 20 lines added; a new file, with the hooks.
- `justfile`: 5 lines added; the recipe `hook`, which installs the hook.
- `pyproject.toml`: 1 line added; pre-commit in the group `lint`.
- `uv.lock`: 138 lines added; the exact version of pre-commit, and of what it needs.

Files to read:
- [`.pre-commit-config.yaml`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/.pre-commit-config.yaml): three hooks from pre-commit's collection, then `just check`.
  - look at: `entry: just check`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/06ea9e2af2238f070b1e33f16aeb70002e25e44d...4834655a3e50dcf56c557463c29bfce592d6d3db#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe `hook`.
  - look at: `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/4834655a3e50dcf56c557463c29bfce592d6d3db/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/06ea9e2af2238f070b1e33f16aeb70002e25e44d...4834655a3e50dcf56c557463c29bfce592d6d3db#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): pre-commit in the group `lint`.
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
same line. The hook is in `.git/hooks`, and no step or move changes that folder. The hook stays installed for the
rest of the tutorial.

`pre-commit run` now runs every hook on the file named, as git will before a commit. The first time on a machine, it
prints `[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

With `--all-files`, pre-commit would check every file that git tracks. It would skip a new file until git tracks
it.

The hook makes sure that `just check` runs on this machine before each commit. It has limits.

- **It is in one clone only.** git does not copy `.git/hooks` with the repository. A clone has the hook only after
  `just hook` runs in it, and `git commit --no-verify` skips the hook.
- **It needs the clone's `.venv`.** `pre-commit install` writes the path of `.venv/bin/python` into the
  hook, as an absolute path. If `.venv` is gone and no other pre-commit is on the PATH, git refuses every commit.
  The hook prints that `pre-commit` was not found, and asks whether the virtualenv is active. `just setup` makes
  `.venv` again.
- **It runs tools of the machine.** The line `language: system` tells pre-commit to run `just check` as it is,
  with the `just` and the `uv` that the machine has.

So the hook helps on one machine, and `just check` is the gate. At stop 11, GitHub runs the same gate, on
its own machines, for every push to main and every pull request.

## step-05.1 `just types`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/4834655a3e50dcf56c557463c29bfce592d6d3db), the commit before step-05.1.

```bash
just setup
```

The next verb runs a new tool, and `check` does not run it yet.

### step-05.1 ty, and the recipe types

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/68033d47be7dc34e8355c6812eede65f0eedcc7e) shows what the move changes.

Now we add ty, a type checker, to the group `lint`. ty reads the code without running it. It finds code whose
types cannot fit, for example a call whose arguments cannot have the types that the function asks for.

```bash
uv add --group lint ty
```

Next we add a recipe `types`, which runs ty, after the recipe `lint` in the `justfile`.

In the `justfile`, after the recipe `lint` and the blank line under it, add the recipe `types`, with a blank line
after it.

```just
# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
[group('quality')]
[no-exit-message]
types *args:
    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}
```

The move changes these files:

- `justfile`: 6 lines added; the recipe `types`.
- `pyproject.toml`: 1 line added; ty in the group `lint`.
- `uv.lock`: 29 lines added; the exact version of ty.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/68033d47be7dc34e8355c6812eede65f0eedcc7e/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/4834655a3e50dcf56c557463c29bfce592d6d3db...68033d47be7dc34e8355c6812eede65f0eedcc7e#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `types *args:`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/68033d47be7dc34e8355c6812eede65f0eedcc7e/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/4834655a3e50dcf56c557463c29bfce592d6d3db...68033d47be7dc34e8355c6812eede65f0eedcc7e#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): ty in the group `lint`.
  - look at: `"ty>=0.0.86",`

The change of `justfile`:

```diff
@@ -45,6 +45,12 @@ fmt *args:
 lint *args:
     {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
 
+# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
+[group('quality')]
+[no-exit-message]
+types *args:
+    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}
+
 # Check the configuration: pyproject.toml, the lockfile, and this justfile
 [group('quality')]
 [no-exit-message]
```

The change of `pyproject.toml`:

```diff
@@ -25,6 +25,7 @@ dev = [{ include-group = "test" }, { include-group = "lint" }]
 lint = [
     "pre-commit>=4.6.2",
     "ruff>=0.17.0",
+    "ty>=0.0.86",
     "validate-pyproject>=0.26",
 ]
 
```

```bash
uv run ty check
just --show types
just types
```

ty finds one problem, in `src/wikiapp/__init__.py`. The message is `Expected str, found str | None`. As far as
ty can tell, `__name__ or __package__` could be None. But `importlib.metadata.version` needs a string.

## step-05.6 The types join `just check`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/8f6e8938925501f9c1bc198818fbd8fab7b647ff), the commit before step-05.6.

```bash
just setup
```

Since the last stop, the walk leaves out the moves
[step-05.2](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html#step-05.2) to
[step-05.5](https://rahuldave.com/smallwikiapp-walk/watch/step-05.html#step-05.5). `__init__.py` now asks for the
version of `"wikiapp"` by name, which fixes the one problem that ty found. A family of rules, `ANN`, asks for a type
on every parameter and return. The code and the tests got their types. This stop starts with
that code.

One line in `check` runs the type checker.

### step-05.6 The recipe check runs the type checker

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/41990df7638f0964c66bf4e4433ffc4f5b6a026d) shows what the move changes.

Now we put the type checker in the recipe `check` of the `justfile`, after `just lint`. The comment of `check`
names the types too.

In the `justfile`, in `check`, run `just types` after `just lint`. Also add the types to the comment of `check`.

```just
# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
```

```just
    just lint
    just types
```

The move changes one file:

- `justfile`: 2 lines added, 1 removed; `check` runs the type checker.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/41990df7638f0964c66bf4e4433ffc4f5b6a026d/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/8f6e8938925501f9c1bc198818fbd8fab7b647ff...41990df7638f0964c66bf4e4433ffc4f5b6a026d#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in check.
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

`.pre-commit-config.yaml` still says `entry: just check`, and the hook now
checks the types too.

## step-06.4 GitHub runs `just check`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/15ba9fa843e3f055dac9c8f1a844b7382858b761), the commit before step-06.4.

```bash
just setup
```

Since the last stop, the walk leaves out the moves
[step-06.1](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.1) to
[step-06.3](https://rahuldave.com/smallwikiapp-walk/watch/step-06.html#step-06.3). The tests that ask the real
Wikipedia run only on request, with `just test -m e2e`. The project accepts any Python from 3.11 on. This stop
starts with that code.

GitHub's job `check` runs `just setup`, then `just check`, on a fresh machine.

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

The job `check` is the third caller of `just check`, after a person and the git hook. It runs from a fresh clone.
No person has to install it or remember it, and `--no-verify` does not skip it. The job `tests` runs
`uv run --locked pytest`, not a verb, so a change behind `just test` would not reach it.

## step-08.1 `just docs`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc), the commit before step-08.1.

```bash
just setup
```

Since the last stop, the walk leaves out [step-07](https://rahuldave.com/smallwikiapp-walk/watch/step-07.html).
`random_page` returns a `Page`, a pydantic model with a title and an extract. An answer that is not a page, or a
language that is not a language code, raises `WikipediaError`. This stop starts with that code.

smalldocs comes in, and `just docs check` counts what has documentation. The words after `docs` go to `smalldocs
api`.

### step-08.1 smalldocs

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/5aa8fa5b13364731bdd41caf1ecd8af505c7346c) shows what the move changes.

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

The block above is only to read.

smalldocs reads all three, and writes Markdown. It is a Python package, so uv installs it like
any other. smalldocs goes in a fourth dependency group, `docs`, and `dev` includes that group.

In `pyproject.toml`, change the line `dev = ...`, and add the group on the line after it.

```toml
dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
docs = []
```

```bash
uv add --group docs smalldocs
```

Next we write `docs/_smalldocs.yml`, the file of settings that smalldocs reads. For now the file has one section,
`api`, the reference. It names the package to document, the address of its source, and the files of the tests to
check.

Make `docs/_smalldocs.yml` with the lines below.

```yaml
# The settings of smalldocs. `api` is the reference, made from the code of the packages
api:
  packages: [wikiapp]
  source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
  check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

Then we add a recipe `docs`, at the end of the `justfile`. `just docs` runs `smalldocs api`, and gives it the words
after `just docs`. `smalldocs api` has two commands that this step uses:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

Add the recipe at the end of the `justfile`.

```just

# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
[group('docs')]
[no-exit-message]
docs *args:
    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

The move changes these files:

- `docs/_smalldocs.yml`: 5 lines added; a new file, with the settings of the reference.
- `justfile`: 6 lines added; the recipe `docs`.
- `pyproject.toml`: 4 lines added, 1 removed; the group `docs`, with smalldocs.
- `uv.lock`: 64 lines added; the exact version of smalldocs and of the packages it needs.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/5aa8fa5b13364731bdd41caf1ecd8af505c7346c/docs/_smalldocs.yml): the package to document, and the tests to check.
  - look at: `packages: [wikiapp]`
- [`pyproject.toml`](https://github.com/rahuldave/smallwikiapp/blob/5aa8fa5b13364731bdd41caf1ecd8af505c7346c/pyproject.toml), [its change](https://github.com/rahuldave/smallwikiapp/compare/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc...5aa8fa5b13364731bdd41caf1ecd8af505c7346c#diff-50c86b7ed8ac2cf95bd48334961bf0530cdc77b5a56f852c5c61b89d735fd711): the group.
  - look at: `docs = [`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/5aa8fa5b13364731bdd41caf1ecd8af505c7346c/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/fb06bcf74edc67eb57ef29fee4ad9cab3525f8fc...5aa8fa5b13364731bdd41caf1ecd8af505c7346c#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the recipe.
  - look at: `docs *args:`

The change of `pyproject.toml`:

```diff
@@ -22,7 +22,10 @@ test = [
     "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
-dev = [{ include-group = "test" }, { include-group = "lint" }]
+dev = [{ include-group = "test" }, { include-group = "lint" }, { include-group = "docs" }]
+docs = [
+    "smalldocs>=0.1.5",
+]
 lint = [
     "pre-commit>=4.6.2",
     "ruff>=0.17.0",
```

The change of `justfile`:

```diff
@@ -74,3 +74,9 @@ check *args:
     just types
     just test -q --cov-fail-under=90
     just lint-config
+
+# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+[group('docs')]
+[no-exit-message]
+docs *args:
+    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

```bash
uv run smalldocs api module wikipedia --dir docs
uv run smalldocs api check --dir docs
just --show docs
just docs check
```

`module` prints the reference of `wikipedia.py`, with empty descriptions. For each module and each test file,
`check` counts the functions and classes that are complete. Then it lists every gap, and fails with `1 of 15
functions, methods and classes are typed and documented`. The one is `WikipediaError`, which needs only its
docstring. Above the total, `check` names every gap, and the five modules without a docstring are among them. Like
coverage, which counts the lines that the tests run, `check` counts what has documentation.

## step-08.5 `just docs` alone builds a site

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/12f8bd1e97e91900d04e9676ee1a6ddfedf78084), the commit before step-08.5.

```bash
just setup
```

Since the last stop, the walk leaves out the moves
[step-08.2](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html#step-08.2) to
[step-08.4](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html#step-08.4). The library, the command and
the tests got their documentation, and the docs check finds no gap. This stop starts with that code.

The recipe `docs` changes. With no words, it builds a site. With words, it works as before, so `just docs check`
is the same command.

### step-08.5 A site

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/b2c6edfda40338f49e0d625b4eec7137d19da3c4) shows what the move changes.

Now we make a docs site, because smalldocs also makes a website from Markdown. The site is in `docs/`. It has a
front page, `index.qmd`, and a reference page for `console.py` and one for `wikipedia.py`. Each build writes the reference pages from the code,
before it builds the site. A name in backticks, such as `random_page`, becomes a link to its entry.

The front page is a written page, for a person who wants to know what the project does. The reference pages say
what each name does. The site has both kinds.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site. The front page, `docs/index.qmd`, is
new. A `.qmd` file is Markdown, with a header between two `---` lines that gives the title of the page.

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

The front page is long to type, so take `docs/index.qmd` from [the move's commit](https://github.com/rahuldave/smallwikiapp/compare/12f8bd1e97e91900d04e9676ee1a6ddfedf78084...b2c6edfda40338f49e0d625b4eec7137d19da3c4).

Next we change the recipe `docs`, so that `just docs` with no words builds the site, with `smalldocs render docs`.
With words, it runs `smalldocs api` as before. The recipe is now a script of several lines.

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

The move changes these files:

- `docs/_smalldocs.yml`: 17 lines added, 1 removed; the settings of the site above the section `api`, and a comment above `api`. The
  comment at the top now says that `just docs` builds the site.
- `docs/index.qmd`: 35 lines added; a new file, the front page.
- `justfile`: 5 lines added, 2 removed; with no words, `docs` builds the site, and its comment says so. The recipe is now a script of
  several lines.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/b2c6edfda40338f49e0d625b4eec7137d19da3c4/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/compare/12f8bd1e97e91900d04e9676ee1a6ddfedf78084...b2c6edfda40338f49e0d625b4eec7137d19da3c4#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the site. The sidebar lists the front page, then the reference pages.
  - look at: `contents: api/*  # the reference pages, which each build makes from the code`
- [`docs/index.qmd`](https://github.com/rahuldave/smallwikiapp/blob/b2c6edfda40338f49e0d625b4eec7137d19da3c4/docs/index.qmd): the front page, written by hand.
  - look at: `Each build of the site makes the pages under Reference from the code.`
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/b2c6edfda40338f49e0d625b4eec7137d19da3c4/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/12f8bd1e97e91900d04e9676ee1a6ddfedf78084...b2c6edfda40338f49e0d625b4eec7137d19da3c4#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): with no words, `docs` builds the site.
  - look at: `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

The change of `docs/_smalldocs.yml`:

```diff
@@ -1,4 +1,20 @@
-# The settings of smalldocs. `api` is the reference, made from the code of the packages
+# The settings of smalldocs. `just docs` builds the site into docs/_site
+project:
+  type: website
+  output-dir: _site
+
+website:
+  title: "wikiapp"
+  sidebar:
+    contents:
+      - index.qmd
+      - section: Reference
+        contents: api/*  # the reference pages, which each build makes from the code
+
+theme: cosmo
+toc: true
+
+# `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
   packages: [wikiapp]
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
```

The change of `justfile`:

```diff
@@ -75,8 +75,11 @@ check *args:
     just test -q --cov-fail-under=90
     just lint-config
 
-# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+# The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
 [group('docs')]
 [no-exit-message]
 docs *args:
-    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
+    #!/usr/bin/env sh
+    if [ "$*" = help ]; then just help docs; exit 0; fi
+    if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
+    exec uv run smalldocs api "$@" --dir docs
```

```bash
uv run smalldocs render docs
just --show docs
just docs
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. On the front page, `random_page` is a link to its entry. Each build makes the site and the reference
pages, and git ignores them.

## step-08.7 The docs check joins `just check`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/200e1c28a172ef898f93486832a601a8eac48379), the commit before step-08.7.

```bash
just setup
```

Since the last stop, the walk leaves out the move
[step-08.6](https://rahuldave.com/smallwikiapp-walk/watch/step-08.html#step-08.6), in which the README names the
tests and the docs. This stop starts with that code.

One line in `check` runs the docs check.

### step-08.7 The docs check in `just check`

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/1ea19fb90f9341fd939f150ef44d2089986e07be) shows what the move changes.

Now we add `just docs check` to the recipe `check`, after the tests, and name the docs in the comment above it.

In the `justfile`, replace the comment above `check` with the line below.

```just
# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
```

Then, in `check`, add `just docs check` after the line of the tests.

```just
    just test -q --cov-fail-under=90
    just docs check
```

The move changes one file:

- `justfile`: 2 lines added, 1 removed; the docs check in `check`, and the comment.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/1ea19fb90f9341fd939f150ef44d2089986e07be/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/200e1c28a172ef898f93486832a601a8eac48379...1ea19fb90f9341fd939f150ef44d2089986e07be#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): the comment, and one line in `check`.
  - look at: `just docs check`

The change of `justfile`:

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -73,6 +73,7 @@ check *args:
     just lint
     just types
     just test -q --cov-fail-under=90
+    just docs check
     just lint-config
 
 # The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
```

```bash
just check
```

The docs check prints `15 of 15`. Now the git hook refuses a commit that leaves a function, a parameter or a
field without documentation. GitHub's job `check`, at lines 30 to 37 of `.github/workflows/test.yaml`, runs
`just check`, so it runs the docs check too.

## step-09.4 The library, behind the same verbs

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/024ec7d71c51f7d8d6ef351641f301df94ada4be), the commit before step-09.4.

```bash
just setup
```

Since the last stop, the walk leaves out the first three moves of
[step-09](https://rahuldave.com/smallwikiapp-walk/watch/step-09.html). The library became a package of its own,
`wikirandom`, in `packages/wikirandom`, in a uv workspace. The app uses it, and `src/wikiapp/wikipedia.py` is gone.
This stop starts with that code.

Those moves did not change the justfile. One justfile, one `.pre-commit-config.yaml` and one hook serve both
packages. `just fmt`, `just lint` and `just types` read every Python file of the repository, so they checked the
library's code from the first move. `just test` measures the coverage of both packages, since the move step-09.3
added `--cov=wikirandom` to `pyproject.toml`. At the start of this stop, `just docs check` still counts only the
app and the tests, 12 of 12. This stop changes `docs/_smalldocs.yml`, behind the verb.

### step-09.4 The docs check counts the library

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea) shows what the move changes.

Now we make the docs check count the library, in `docs/_smalldocs.yml`.
The app uses the library `wikirandom`, in `packages/wikirandom`, but `docs/_smalldocs.yml` names only
`wikiapp`. The line `packages:` in the section `api` now names both.

In `docs/_smalldocs.yml`, change the line `packages:` in the section `api`, so that it names both.

```yaml
  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
```

The move changes one file:

- `docs/_smalldocs.yml`: 1 line added, 1 removed; two packages.

Files to read:
- [`docs/_smalldocs.yml`](https://github.com/rahuldave/smallwikiapp/blob/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea/docs/_smalldocs.yml), [its change](https://github.com/rahuldave/smallwikiapp/compare/024ec7d71c51f7d8d6ef351641f301df94ada4be...51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea#diff-7e4b31fde37815c769b2e393a4a3ae0e2800b876407688e90b2582fb72f71ed4): the list.
  - look at: `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

The change of `docs/_smalldocs.yml`:

```diff
@@ -16,6 +16,6 @@ toc: true
 
 # `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
-  packages: [wikiapp]
+  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
   check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

```bash
just docs check
just docs
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and on the front page, `random_page` is now a link to its entry. `just check` passes.

The justfile did not change, and `just docs check` checks more. The hook and GitHub's job `check` run the new
docs check without a change.

## step-10.1 `just build`

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/51254ef0fae3c0d4b44cf00d14c0b3b9aa1041ea), the commit before step-10.1.

```bash
just setup
```

The last verb is about the packages, not about checks, so `check` does not run it.

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

## step-10.3 `just lint-config` checks the library too

[The code at its Start](https://github.com/rahuldave/smallwikiapp/tree/a1be2b1d309a8b37ef50a9b28fd0aed0cc4cd79e), the commit before step-10.3.

```bash
just setup
```

Since the last stop, the walk leaves out the move
[step-10.2](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html#step-10.2). The app asks for wikirandom
0.1. This stop starts with that code.

From step-09.1 to here, validate-pyproject, in `just lint-config`, read only the app's `pyproject.toml`. The hook
and `just check` let every commit through with no check of the library's `pyproject.toml` against the standard.

### step-10.3 lint-config checks both pyproject.toml files

[The commit of this move](https://github.com/rahuldave/smallwikiapp/commit/6bcee949820224c622cb47680d467acacef15ae9) shows what the move changes.

Now we make `just lint-config` check the library's `pyproject.toml` too.
The repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. The
recipe `lint-config` now gives validate-pyproject both files.

In the `justfile`, in `lint-config`, replace the line `uv run validate-pyproject pyproject.toml` with the line
below.

```just
    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
```

The move changes one file:

- `justfile`: 1 line added, 1 removed; `lint-config` checks both files.

Files to read:
- [`justfile`](https://github.com/rahuldave/smallwikiapp/blob/6bcee949820224c622cb47680d467acacef15ae9/justfile), [its change](https://github.com/rahuldave/smallwikiapp/compare/a1be2b1d309a8b37ef50a9b28fd0aed0cc4cd79e...6bcee949820224c622cb47680d467acacef15ae9#diff-deb9bb56fb122db0b605aa5b63f95a4665c905b18dd670e1fa6c877576a94ff1): two files.
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

The verb has the same name, and its callers did not change. A file that a recipe leaves out is a file that no
caller checks. The fix goes in one place, the recipe, and all three callers have it.

The walk stops here. After it, the whole tutorial makes the last two moves of
[step-10](https://rahuldave.com/smallwikiapp-walk/watch/step-10.html). The library gets a licence and an author, both packages
get a link to the repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every step and every move.
