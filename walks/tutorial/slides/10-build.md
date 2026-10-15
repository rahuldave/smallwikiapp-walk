## Build

```
just build        # uv build --all-packages
```

`just build` writes these files into `dist/`:

| File | What it is |
|---|---|
| `wikiapp-0.1.0.tar.gz` | the source archive: the code and its files, packed into one file |
| `wikiapp-0.1.0-py3-none-any.whl` | the wheel: what pip and uv install |
| `wikirandom-0.1.0...` | both files again, for the library |

- the wheel of wikiapp lists the packages it needs, and the versions that work. For example, `wikirandom>=0.1.0,<0.2`
  means 0.1.0 or later, but below 0.2
- each wheel names its own licence, and links to the repository
- each package writes its version once, in its own `pyproject.toml`, and the code reads it from the installed package
