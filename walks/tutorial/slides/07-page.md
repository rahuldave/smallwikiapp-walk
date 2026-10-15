## A page with a shape

```python
class Page(BaseModel):
    title: str
    extract: str
```

- `Page.model_validate(answer)` takes the JSON of Wikipedia, keeps `title` and `extract`, and checks they are strings
- `page.title` is an attribute that ty and an editor know, and a misspelled name is an error
- an answer without the two keys raises `ValidationError`, which becomes `WikipediaError`

---

## A language with a shape

```python
API_URL = "https://{language}.wikipedia.org/..."
```

The language goes before `.wikipedia.org`. With `--language 'example.com/x?'`, the address starts
`https://example.com/x?`, so the request goes to example.com.

```python
LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")   # en, fr, simple, zh-yue
```

`random_page` checks the language against `LANGUAGE` before it builds the address, and raises `WikipediaError`
if it does not match.
