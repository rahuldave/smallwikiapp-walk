## smallwikiapp

A command that prints a random page of Wikipedia, in any language.

The point is not the command. It is the project around it, built one step at a time:

- packaging, with **uv**
- one interface for every task, with **just**
- tests, and mocks
- a library, and an app that uses it
- format, lint, types, a git hook, CI
- documentation, made from the code

---

## Steps and moves

A **step** is a tag: `step-00`, `step-01`, ...

A **move** is one small commit between two tags: one action, and a command at its end that shows what it did.

| Mode | What you do |
|---|---|
| **Watch** | Show checks out each move; the notes explain the change |
| **Do** | You make each move from the notes, run the command at its end, and press Done |

Every step starts from the code of the step before: `just setup` first.

---

## The project before the code

```
uv init --package --python 3.13 --name wikiapp
```

| File | What it says | Made by |
|---|---|---|
| `pyproject.toml` | the name, the Python, the dependencies, the command | `uv init`, then by hand |
| `.python-version` | which Python uv installs | `uv init` |
| `uv.lock` | the exact version of every package | `uv lock` |
| `justfile` | the tasks: `just` lists them | by hand |

`just setup` makes `.venv` from the lockfile, on any machine.
