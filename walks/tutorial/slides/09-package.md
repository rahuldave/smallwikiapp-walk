## The library as a package

```
smallwikiapp/
├── pyproject.toml            wikiapp: click, wikirandom
├── src/wikiapp/              the app
└── packages/wikirandom/
    ├── pyproject.toml        wikirandom: requests, pydantic
    └── src/wikirandom/       the library
```

A uv **workspace**: two packages, one lockfile, one `.venv`.

```toml
[tool.uv.sources]
wikirandom = { workspace = true }   # from packages/wikirandom, not from PyPI
```

Another program can install wikirandom without click.
