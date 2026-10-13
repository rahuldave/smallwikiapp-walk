## The docs on GitHub Pages

Each job on GitHub installs the group it needs, and no more.

| Who | Installs | Runs |
|---|---|---|
| A person, `just setup` | `dev`: test, lint, docs | every recipe |
| GitHub, job `check` | `dev` | `just check` |
| GitHub, 12 jobs `tests` | the group `test` | `pytest` |
| GitHub, workflow `Docs` | the group `docs` | `smalldocs render docs`, then Pages |

`uv run --locked --no-default-groups --group test pytest`

The site: https://rahuldave.com/smallwikiapp/
