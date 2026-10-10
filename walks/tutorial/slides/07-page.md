## A page with a shape

```python
class Page(BaseModel):
    title: str
    extract: str
```

- `Page.model_validate(answer)` keeps the two keys, and checks they are strings
- `page.title` is an attribute that ty and an editor know, and a misspelled name is an error
- an answer without the two keys raises `ValidationError`, which becomes `WikipediaError`

---

## A language with a shape

```python
API_URL = "https://{language}.wikipedia.org/..."
```

`--language 'example.com/x?'` would send the request to example.com.

```python
LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")   # en, fr, simple, zh-yue
```

Check what comes in, before it goes into an address.
