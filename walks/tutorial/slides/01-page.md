## A random page

```
https://en.wikipedia.org/api/rest_v1/page/random/summary
```

- **click** makes the command line
- **requests** asks Wikipedia
- the answer is JSON: `title`, `extract`, and many keys we do not use

---

## 403 Forbidden

The code of 2024 no longer works. Wikipedia refuses a request whose User-Agent is a library's default:
`python-requests/2.34.2`. Its policy asks for this instead:

```
User-Agent: wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)
```

The program, its version, and where to find whoever runs it.
