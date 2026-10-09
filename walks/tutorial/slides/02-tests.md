## Tests, with mocks

A test that asks the real Wikipedia:

- fails on a train
- sees a different page each time

A **mock** replaces `requests.get` for the length of one test, and answers with the page we choose:
**Lorem Ipsum**.

| Fixture | What a test receives |
|---|---|
| `runner` | click's CliRunner: runs the command, keeps what it printed |
| `mock_requests_get` | the mock: what it returns, and how it was called |

---

## Dependency groups

```toml
[dependency-groups]
test = ["pytest", "pytest-mock", "pytest-cov"]
dev = [{ include-group = "test" }]
```

Someone who installs wikiapp gets click and requests, not pytest. `uv sync` installs `dev` by default.
