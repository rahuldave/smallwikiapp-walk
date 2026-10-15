## A page with a shape

```python
class Page(BaseModel):
    title: str
    extract: str
```

- `Page` is a model of **pydantic**, a library that checks data against the types of a class
- `Page.model_validate(answer)` takes the JSON of Wikipedia, keeps `title` and `extract`, and checks they are strings
- ty and an editor know the attribute `page.title`, so they report a misspelled name before the program runs
- an answer without the two keys raises `ValidationError`, which becomes `WikipediaError`

---

## A language with a shape

```python
API_URL = "https://{language}.wikipedia.org/..."
```

The language goes before `.wikipedia.org`. With `--language 'example.com/x?'`, the address starts
`https://example.com/x?`. The `?` turns the rest, `.wikipedia.org/...`, into a question to that site, so the
request goes to example.com.

```python
LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")   # en, fr, simple, zh-yue
```

`LANGUAGE` matches lowercase letters, with a hyphen between groups of them. Before `random_page` builds the address,
it checks that the whole language matches, and raises `WikipediaError` if it does not.
