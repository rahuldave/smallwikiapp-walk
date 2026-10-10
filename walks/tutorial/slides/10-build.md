## Build

```
just build        # uv build --all-packages
```

| File | What it is |
|---|---|
| `wikiapp-0.1.0.tar.gz` | the source archive |
| `wikiapp-0.1.0-py3-none-any.whl` | the wheel: what pip and uv install |
| `wikirandom-0.1.0...` | the same, for the library |

- the metadata of the wheel names its dependencies and their ranges, for example `wikirandom>=0.1.0,<0.2`
- a licence, and a link to the repository, for each
- the version is in one place, `pyproject.toml`, and the code reads it from the installed package
