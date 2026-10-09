## Types

| Tool | Asks |
|---|---|
| ruff, `ANN` | is a type written on every parameter and return? |
| ty, `just types` | can every call have the types the function asks for? |

ty's one finding:

```python
importlib.metadata.version(__name__ or __package__)
#                          ^^^^^^^^^^^^^^^^^^^^^^^ str | None
```

The name of the package, `"wikiapp"`, is always a string.
