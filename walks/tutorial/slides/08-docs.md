## Docs from the code

```python
def random_page(
    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
) -> Page:  # A page chosen at random
    """Get a random page from Wikipedia.

    Raises WikipediaError when the language is not a language code, when the request fails, or
    when the answer is not a page.
    """
```

| Part | From |
|---|---|
| signature, types | the code |
| what it does | the docstring |
| what each parameter or field is | its **docment**, the comment beside it |

The code contains its docs, once, and every page of the docs comes from them.

---

## `just docs`: one task, three uses

smalldocs makes the docs from the code, and `just docs` runs it.

| Command | Does |
|---|---|
| `just docs module wikipedia` | prints the reference of the module `wikipedia`, as Markdown |
| `just docs check` | lists each module without a docstring, and each function, class or field without its types and docs. It fails if it finds one |
| `just docs` | makes the reference pages from the code, then builds the site in `docs/_site` |

`just check` now also runs `just docs check`, and the git hook runs `just check` before git records a change. So git refuses a
change with an undocumented function.
