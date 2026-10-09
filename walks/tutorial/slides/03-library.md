## A library and an app

| File | Knows | Does |
|---|---|---|
| `wikipedia.py` | Wikipedia, requests | `random_page(language)`, `WikipediaError` |
| `console.py` | click | reads `--language`, prints, turns the error into a message |

The library knows nothing of the command line. Another program could use it.

---

## One error, at the edge

```python
try:
    with requests.get(...) as response: ...
except requests.RequestException as error:
    raise WikipediaError(str(error)) from error
```

A user of the library catches one exception, not requests' many. The app turns it into `Error: ...` and exit
code 1.
