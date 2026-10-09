## A page with a shape

```python
class Page(BaseModel):
    title: str
    extract: str
```

- `Page.model_validate(answer)` keeps the two keys, and checks they are strings
- `page.title`: an attribute that ty and an editor know, not a key that could be misspelled
- an answer without them: `ValidationError`, which becomes `WikipediaError`
