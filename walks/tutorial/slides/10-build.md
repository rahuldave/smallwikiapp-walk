## Build

```
just build        # uv build --all-packages
```

| File | What it is |
|---|---|
| `wikiapp-0.1.0.tar.gz` | the source archive |
| `wikiapp-0.1.0-py3-none-any.whl` | the wheel: what pip and uv install |
| `wikirandom-0.1.0...` | the same, for the library |

- the wheel's metadata names its dependencies and their ranges: `click>=8.5.0`, `wikirandom>=0.1.0,<0.2`
- a licence, and a link to the repository, for each
- one place for a version: `pyproject.toml`. The code reads it from what is installed
