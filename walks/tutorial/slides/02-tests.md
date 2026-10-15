## Tests, with mocks

A test that asks the real Wikipedia:

- fails without a network
- gets a different page each time

wikiapp downloads the page with `requests.get`. A **mock** replaces it for the length of one test. It answers with a page that the test chooses,
**Lorem Ipsum**.

pytest runs the tests. A **fixture** is a function that pytest runs for each test that names it as an argument.

| Fixture | What a test receives |
|---|---|
| `runner` | a runner from click: it runs the command and keeps what it printed |
| `mock_requests_get` | the mock: what it returns, and how it was called |

---

## Dependency groups

```toml
[tool.uv]
default-groups = "all"

[dependency-groups]
test = [
    "pytest>=9.1.1",
    "pytest-cov>=7.1.0",
    "pytest-mock>=3.16.0",
]
```

A **group** is a named list of packages that only the people who work on wikiapp need. Someone who installs wikiapp
gets click and requests, but not the group `test`. `uv sync` sets up the project for that work, and installs every
group, because of `default-groups = "all"`.
