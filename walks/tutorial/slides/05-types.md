## Types

| Tool | Asks |
|---|---|
| ruff, `ANN` | is a type written on every parameter and return? |
| ty, `just types` | does every call pass values of the types the function asks for? |

ty finds one problem. The function `version` returns the version of an installed package, and needs its name as a
string. But `__name__ or __package__` could be None, which means no value:

```python
importlib.metadata.version(__name__ or __package__)
#                          ^^^^^^^^^^^^^^^^^^^^^^^ str | None
```

The fix passes the name of the package, `"wikiapp"`, which is always a string.
