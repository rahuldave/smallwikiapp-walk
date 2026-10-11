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

Written once, beside the code it describes.

---

## smalldocs: one recipe, three uses

| Command | Does |
|---|---|
| `just docs module wikipedia` | one module's reference, as Markdown |
| `just docs check` | each module without a docstring, and each function, class or field without its types and docs. It fails if any |
| `just docs` | the site, with the reference pages made from the code first |

The check runs in `just check`, so the git hook refuses an undocumented function.
