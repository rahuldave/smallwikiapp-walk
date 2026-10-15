## smallwikiapp

A command that prints a random page of Wikipedia, in any language.

The tutorial builds the project around the command, one step at a time:

- packages, with **uv**
- one interface for every task, with `just`
- tests, and mocks
- a library, and an app that uses it
- format, lint, types, a git hook, CI
- documentation, made from the code

---

## Steps and moves

A **step** is a version of the project with a name, for example `step-00` or `step-01`.

A **move** is one small change on the way to the next step. It does one action, and a command at its end shows what it did.

| Mode | What you do |
|---|---|
| **Watch** | **Show** puts the files of each move in your folder, and the notes explain the change |
| **Do** | You make each move from the notes, run the command at its end, and press **Done** |

Every step starts from the code of the step before. Run `just setup` first, to install what that code needs.

---

## The project before the code

```
uv init --package --python 3.13 --name wikiapp
```

| File | What it says | Made by |
|---|---|---|
| `pyproject.toml` | the name, the versions of Python, the packages it needs, the command | `uv init`, then by hand |
| `.python-version` | which Python uv installs | `uv init` |
| `uv.lock` | the exact version of every package | `uv lock` |
| `justfile` | the tasks: `just` lists them | by hand |

`just setup` makes `.venv`, the folder with Python and the packages. It installs the exact versions in `uv.lock`, so every machine gets the same ones.
