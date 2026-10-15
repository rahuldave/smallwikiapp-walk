## A random page

```
https://en.wikipedia.org/api/rest_v1/page/random/summary
```

- **click** turns the function `main` into a command, with options such as `--help`. `pyproject.toml` names it `wikiapp`
- **requests** asks Wikipedia, at the address above, for the summary of a random page
- the answer is JSON, a text of names and values. wikiapp prints the values of two names, `title` and `extract`, the title of the page and its summary

---

## 403 Forbidden

The command of the original wikiapp, from 2024, now gets the error 403 Forbidden. Each request names its sender in a
header, the User-Agent. Wikipedia refuses the User-Agent that the package `requests` sends by default, for example
`python-requests/2.34.2`. The policy of Wikimedia, the group that runs Wikipedia, asks for a User-Agent like the one below.

```
User-Agent: wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)
```

It names the program, its version, and a page that leads to the person who runs it. The next move gives wikiapp
this User-Agent, and Wikipedia answers.
