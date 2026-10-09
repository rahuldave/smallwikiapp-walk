## Format, lint, a hook

| Tool | Recipe | What it does |
|---|---|---|
| ruff format | `just fmt` | one way to lay out the code; nothing to argue about |
| ruff check | `just lint` | rules: unused names, import order, security |
| validate-pyproject, uv lock --check | `just lint-config` | the configuration |
| all of them, and the tests | `just check` | everything a commit must pass |
| pre-commit | git hook | runs `just check` before every commit |

---

## What the linter found

| Code | Where | Fix |
|---|---|---|
| I001 | imports out of order | `just lint --fix` |
| E402 | an import below code | by hand |
| F841 | a result never read, twice | by hand |
| **S113** | **a request with no timeout** | **by hand: the command could hang for ever** |
