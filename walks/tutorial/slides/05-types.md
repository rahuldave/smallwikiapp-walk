## Types

Two tools check the types. `ANN` is a set of rules of ruff, and ty is a new tool.

| Tool | Asks |
|---|---|
| ruff, `ANN` | is a type written on every parameter and return? |
| ty, `just types` | does every call pass values of the types the function asks for? |

ty finds one problem. The function `version` returns the version of an installed package, and needs its name as a
string. The code gives it `__name__ or __package__`, two names that Python sets in each file. ty sees that
`__package__` could be None, so the whole expression could be None. None means no value.

```python
importlib.metadata.version(__name__ or __package__)
#                          ^^^^^^^^^^^^^^^^^^^^^^^ str | None
```

`str | None` means a string or None. The fix passes the name of the package, `"wikiapp"`, which is always a string.
