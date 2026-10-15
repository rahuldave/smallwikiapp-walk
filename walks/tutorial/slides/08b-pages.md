## The docs on GitHub Pages

Each job on GitHub installs the group it needs, and no more.

| Who | Installs | Runs |
|---|---|---|
| A person, `just setup` | every group: test, lint, docs | every recipe |
| GitHub, job `check` | every group | `just check` |
| GitHub, 12 jobs `tests` | the group `test` | `pytest` |
| GitHub, workflow `Docs` | the group `docs` | `smalldocs render docs`, and GitHub Pages publishes the site |

Each job `tests` runs the command below. `--no-default-groups` installs no group, and `--group test` adds `test`.

`uv run --locked --no-default-groups --group test pytest`

GitHub Pages publishes the docs at one of these addresses. OWNER is the account that owns the fork.

| Repository | Its site |
|---|---|
| a fork | `https://OWNER.github.io/smallwikiapp/` |
| rahuldave/smallwikiapp | https://rahuldave.com/smallwikiapp/ |
