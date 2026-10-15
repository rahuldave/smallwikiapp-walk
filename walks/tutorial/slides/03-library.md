## A library and an app

| File | Knows | Does |
|---|---|---|
| `wikipedia.py` | Wikipedia, requests | `random_page(language)` returns a random page, or raises `WikipediaError` |
| `console.py` | click | reads `--language`, prints, turns the error into a message |

`wikipedia.py` is the library, and `console.py` is the app. The library knows nothing of the command line, so
another program could use it.

---

## The library raises one error of its own

```python
try:
    with requests.get(...) as response: ...
except requests.RequestException as error:
    raise WikipediaError(str(error)) from error
```

The package requests fetches the page, and it can raise many kinds of error. `wikipedia.py` turns each of them into
`WikipediaError`, so a program that uses the library catches one error. The app turns that error into `Error: ...`
and exit code 1.
