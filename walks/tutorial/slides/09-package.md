## The library as a package

```
smallwikiapp/
├── pyproject.toml            wikiapp: click, wikirandom
├── src/wikiapp/              the app
└── packages/wikirandom/
    ├── pyproject.toml        wikirandom: requests, pydantic
    └── src/wikirandom/       the library
```

Each `pyproject.toml` names its package, and the packages it needs. The app now needs the library.

A uv **workspace**: two packages, one lockfile, one `.venv`.

```toml
[tool.uv.sources]
wikirandom = { workspace = true }   # from packages/wikirandom, not from PyPI
```

Before, a program that wanted the code that asks Wikipedia had to install all of wikiapp, and click with it. Now it can install
wikirandom alone, without click.
