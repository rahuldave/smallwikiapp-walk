## Docs from the code

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
    """Get a random page from Wikipedia."""
```

| Part | From |
|---|---|
| signature, types | the code |
| what it does | the docstring |
| what each parameter is | its **docment**, the comment beside it |

Written once, beside the code it describes.

---

## One recipe, three uses

| Command | Does |
|---|---|
| `just docs module wikipedia` | one module's reference, as Markdown |
| `just docs check` | every function, class and field without its docs; fails if any |
| `just docs` | the site: Quarto, which runs `apidocs.py build` first |

The check runs in `just check`, so the git hook refuses an undocumented function.
