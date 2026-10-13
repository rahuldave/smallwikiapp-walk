# smallwikiapp, one move at a time

This tutorial builds [smallwikiapp](https://github.com/rahuldave/smallwikiapp), a small command that prints
a random page of Wikipedia. It also builds the project around the command:

- packages and dependencies with uv, and one interface for every task with `just`
- tests and mocks, and a library with an app that uses it
- format, lint, types, a git hook and CI
- documentation made from the code

smallwikiapp grew in **steps**. Each step is a tag, `step-00`, `step-01` and so on. The small commits between
two tags are the **moves**. Each move does one action, and ends with a command that shows what it did. The
tutorial has three forms, with the same text:

- **[The website](https://rahuldave.com/smallwikiapp-walk/)**, a page for each step in each mode, with a list
  of the steps beside it and a search box.
- **To read on GitHub**, [walks/tutorial/TUTORIAL-watch.md](walks/tutorial/TUTORIAL-watch.md) explains each move,
  and [walks/tutorial/TUTORIAL-do.md](walks/tutorial/TUTORIAL-do.md) gives every line to type. Both have the
  commands in code blocks, and a link to the code at every step and to the commit of every move.
- [walks/tutorial/notes.md](walks/tutorial/notes.md), **the notes that timewalk reads**. timewalk-tutorial makes
  the website and the two Markdown files from these notes, in `just walk-update` of the class material.

The slides are in [walks/tutorial/slides/](walks/tutorial/slides/).

## Three small walks

Each small walk takes some steps and moves of the whole tutorial, with the same notes and the same commits. A
small step starts from the code before its first move, and starts with `just setup`.

| Walk | What it takes | Website | On GitHub |
|---|---|---|---|
| `testing` | the project and its command, then pytest, fixtures and mocks, coverage, end-to-end tests, and the tests on GitHub: 13 stops with titles, from step-00 to the move 07.4 | [testing](https://rahuldave.com/smallwikiapp-walk/testing/) | [watch](walks/testing/TUTORIAL-watch.md), [do](walks/testing/TUTORIAL-do.md) |
| `linting` | the project and its command, then a formatter, a linter and its fixes, the check of the configuration, the gate and the hook, and the types the linter asks for: 10 stops with titles, from step-00 to the move 10.3 | [linting](https://rahuldave.com/smallwikiapp-walk/linting/) | [watch](walks/linting/TUTORIAL-watch.md), [do](walks/linting/TUTORIAL-do.md) |
| `docs` | the project and its command, then smalldocs, docstrings and docments, a site, the README, and the check of the docs: 10 stops with titles, from step-00 to the move 09.4 | [docs](https://rahuldave.com/smallwikiapp-walk/docs/) | [watch](walks/docs/TUTORIAL-watch.md), [do](walks/docs/TUTORIAL-do.md) |

`just present testing` opens a small walk in timewalk.

## The steps and moves

Each link opens its section of TUTORIAL-watch.md.

- [step-00](walks/tutorial/TUTORIAL-watch.md#step-00-the-project) **The project**
- [step-01](walks/tutorial/TUTORIAL-watch.md#step-01-a-random-page) **A random page**
  - [step-01.1](walks/tutorial/TUTORIAL-watch.md#step-011-click-and-requests) click and requests
  - [step-01.2](walks/tutorial/TUTORIAL-watch.md#step-012-ask-wikipedia-for-a-page) Ask Wikipedia for a page
  - [step-01.3](walks/tutorial/TUTORIAL-watch.md#step-013-a-user-agent) A User-Agent
  - [step-01.4](walks/tutorial/TUTORIAL-watch.md#step-014---version) --version
- [step-02](walks/tutorial/TUTORIAL-watch.md#step-02-tests-with-mocks) **Tests, with mocks**
  - [step-02.1](walks/tutorial/TUTORIAL-watch.md#step-021-pytest-and-the-first-test) pytest and the first test
  - [step-02.2](walks/tutorial/TUTORIAL-watch.md#step-022-the-recipe-just-test) The recipe `just test`
  - [step-02.3](walks/tutorial/TUTORIAL-watch.md#step-023-the-runner-as-a-fixture) The runner as a fixture
  - [step-02.4](walks/tutorial/TUTORIAL-watch.md#step-024-a-mock-in-place-of-wikipedia) A mock in place of Wikipedia
  - [step-02.5](walks/tutorial/TUTORIAL-watch.md#step-025-tests-of-the-request) Tests of the request
  - [step-02.6](walks/tutorial/TUTORIAL-watch.md#step-026-a-test-of-a-failed-request) A test of a failed request
  - [step-02.7](walks/tutorial/TUTORIAL-watch.md#step-027-coverage) Coverage
- [step-03](walks/tutorial/TUTORIAL-watch.md#step-03-a-library-and-an-app) **A library and an app**
  - [step-03.1](walks/tutorial/TUTORIAL-watch.md#step-031-random_page-moves-to-wikipediapy) random_page moves to wikipedia.py
  - [step-03.2](walks/tutorial/TUTORIAL-watch.md#step-032-the-mock-moves-to-conftestpy) The mock moves to conftest.py
  - [step-03.3](walks/tutorial/TUTORIAL-watch.md#step-033-a-language) A language
  - [step-03.4](walks/tutorial/TUTORIAL-watch.md#step-034-wikiapp---language) wikiapp --language
  - [step-03.5](walks/tutorial/TUTORIAL-watch.md#step-035-wikipediaerror) WikipediaError
  - [step-03.6](walks/tutorial/TUTORIAL-watch.md#step-036-the-command-prints-the-error) The command prints the error
- [step-04](walks/tutorial/TUTORIAL-watch.md#step-04-format-lint-a-hook) **Format, lint, a hook**
  - [step-04.1](walks/tutorial/TUTORIAL-watch.md#step-041-ruff-and-the-recipe-fmt) ruff, and the recipe fmt
  - [step-04.2](walks/tutorial/TUTORIAL-watch.md#step-042-the-code-formatted) The code, formatted
  - [step-04.3](walks/tutorial/TUTORIAL-watch.md#step-043-the-linters-rules-and-the-recipe-lint) The linter's rules, and the recipe lint
  - [step-04.4](walks/tutorial/TUTORIAL-watch.md#step-044-the-linter-sorts-the-imports) The linter sorts the imports
  - [step-04.5](walks/tutorial/TUTORIAL-watch.md#step-045-the-tests-imports-at-the-top-and-no-unused-variables) The tests' imports at the top, and no unused variables
  - [step-04.6](walks/tutorial/TUTORIAL-watch.md#step-046-a-timeout) A timeout
  - [step-04.7](walks/tutorial/TUTORIAL-watch.md#step-047-the-recipe-lint-config) The recipe lint-config
  - [step-04.8](walks/tutorial/TUTORIAL-watch.md#step-048-a-locked-lockfile) A locked lockfile
  - [step-04.9](walks/tutorial/TUTORIAL-watch.md#step-049-the-recipe-check) The recipe check
  - [step-04.10](walks/tutorial/TUTORIAL-watch.md#step-0410-a-git-hook) A git hook
- [step-05](walks/tutorial/TUTORIAL-watch.md#step-05-types) **Types**
  - [step-05.1](walks/tutorial/TUTORIAL-watch.md#step-051-ty-and-the-recipe-types) ty, and the recipe types
  - [step-05.2](walks/tutorial/TUTORIAL-watch.md#step-052-the-version-of-wikiapp-by-name) The version of "wikiapp", by name
  - [step-05.3](walks/tutorial/TUTORIAL-watch.md#step-053-a-type-on-every-parameter-and-return) A type on every parameter and return
  - [step-05.4](walks/tutorial/TUTORIAL-watch.md#step-054-types-in-the-code) Types in the code
  - [step-05.5](walks/tutorial/TUTORIAL-watch.md#step-055-types-in-the-tests) Types in the tests
  - [step-05.6](walks/tutorial/TUTORIAL-watch.md#step-056-the-recipe-check-runs-the-type-checker) The recipe check runs the type checker
- [step-06](walks/tutorial/TUTORIAL-watch.md#step-06-end-to-end-and-ci) **End to end, and CI**
  - [step-06.1](walks/tutorial/TUTORIAL-watch.md#step-061-the-end-to-end-test-runs-only-on-request) The end-to-end test runs only on request
  - [step-06.2](walks/tutorial/TUTORIAL-watch.md#step-062-an-end-to-end-test-of-the-library) An end-to-end test of the library
  - [step-06.3](walks/tutorial/TUTORIAL-watch.md#step-063-any-python-from-311-on) Any Python from 3.11 on
  - [step-06.4](walks/tutorial/TUTORIAL-watch.md#step-064-github-runs-the-tests) GitHub runs the tests
- [step-07](walks/tutorial/TUTORIAL-watch.md#step-07-a-page-with-a-shape) **A page with a shape**
  - [step-07.1](walks/tutorial/TUTORIAL-watch.md#step-071-the-model-page) The model Page
  - [step-07.2](walks/tutorial/TUTORIAL-watch.md#step-072-random_page-returns-a-page) random_page returns a Page
  - [step-07.3](walks/tutorial/TUTORIAL-watch.md#step-073-an-answer-that-is-not-a-page) An answer that is not a page
  - [step-07.4](walks/tutorial/TUTORIAL-watch.md#step-074-only-a-language-code-goes-into-the-address) Only a language code goes into the address
- [step-08](walks/tutorial/TUTORIAL-watch.md#step-08-docs-from-the-code) **Docs from the code**
  - [step-08.1](walks/tutorial/TUTORIAL-watch.md#step-081-smalldocs) smalldocs
  - [step-08.2](walks/tutorial/TUTORIAL-watch.md#step-082-the-library-documented) The library documented
  - [step-08.3](walks/tutorial/TUTORIAL-watch.md#step-083-the-command-documented) The command documented
  - [step-08.4](walks/tutorial/TUTORIAL-watch.md#step-084-the-tests-documented) The tests documented
  - [step-08.5](walks/tutorial/TUTORIAL-watch.md#step-085-a-site) A site
  - [step-08.6](walks/tutorial/TUTORIAL-watch.md#step-086-the-readme-names-the-tests-and-the-docs) The README names the tests and the docs
  - [step-08.7](walks/tutorial/TUTORIAL-watch.md#step-087-the-docs-check-in-just-check) The docs check in `just check`
- [step-09](walks/tutorial/TUTORIAL-watch.md#step-09-the-library-as-a-package) **The library as a package**
  - [step-09.1](walks/tutorial/TUTORIAL-watch.md#step-091-an-empty-library-wikirandom) An empty library, wikirandom
  - [step-09.2](walks/tutorial/TUTORIAL-watch.md#step-092-the-code-goes-into-wikirandom) The code goes into wikirandom
  - [step-09.3](walks/tutorial/TUTORIAL-watch.md#step-093-the-app-uses-wikirandom) The app uses wikirandom
  - [step-09.4](walks/tutorial/TUTORIAL-watch.md#step-094-the-docs-check-counts-the-library) The docs check counts the library
- [step-10](walks/tutorial/TUTORIAL-watch.md#step-10-build) **Build**
  - [step-10.1](walks/tutorial/TUTORIAL-watch.md#step-101-the-recipe-build) The recipe `build`
  - [step-10.2](walks/tutorial/TUTORIAL-watch.md#step-102-the-app-needs-wikirandom-01) The app needs wikirandom 0.1
  - [step-10.3](walks/tutorial/TUTORIAL-watch.md#step-103-lint-config-checks-both-pyprojecttoml-files) lint-config checks both pyproject.toml files
  - [step-10.4](walks/tutorial/TUTORIAL-watch.md#step-104-a-licence-and-a-repository-link-for-both) A licence and a repository link for both
  - [step-10.5](walks/tutorial/TUTORIAL-watch.md#step-105-the-user-agent-says-the-installed-version) The User-Agent says the installed version

## Two ways to take it

The tutorial runs in [timewalk](https://rahuldave.com/timewalk/), a page in the browser with the files, the
notes, the slides, and terminals in the project at each step.

| Mode | What you do |
|---|---|
| **Do** | You make each move yourself, from its notes. Type the code, run the command in the grey block, run the command at the end of the move, and press **Done**. **Your files match** says when your files are the same as the move's commit. Use **Apply** or **Catch me up** if you are stuck |
| **Watch** | **Show** checks out each move's commit, and the notes explain what changed. The teacher shows the class in this mode |

The switch **Do / Watch** beside the name of the walk changes the mode at any time. Every step starts from the code
of the step before, so every step starts with `just setup`. The moves of a step go in order. To go back, press
**Restart step**, and then run `just setup`.

In the move 04.10, `just hook` installs a git hook. Before each commit you make, it runs pre-commit's checks, and
`just check` among them. If you start at a later step, run `just hook` once.

**A move keeps your work.** Before a move, timewalk puts your edits and commits in `worktree/` on a branch
`timewalk/saved/<place>`, for example `timewalk/saved/step-03.2`, and does not ask. The page names the branch,
and gives the command that brings a file back.

## What you need

- [uv](https://docs.astral.sh/uv/), which also runs timewalk
- [git](https://git-scm.com/) and [just](https://just.systems/)
- Chrome, Edge or another recent browser

## Start

Fork this repository on GitHub first, so that you can keep your own notes. You can also clone
`rahuldave/smallwikiapp-walk` itself in place of a fork.

```
git clone https://github.com/<you>/smallwikiapp-walk
cd smallwikiapp-walk
just present do         # do mode: you make the moves
just present            # watch mode: the moves are shown
```

`just present` opens the first walk, `show`, and `just present do` opens the walk `do`. It runs `just setup` first.
`just setup` clones smallwikiapp into `repo/`, or your fork of smallwikiapp if you have one, and fetches the
tags of the steps. To clone from another address, run `just setup <address>` before the first `just present`.

timewalk then puts its replay copy in `worktree/`. The replay copy is a clone of `repo/` on the branch
`timewalk/replay`, and timewalk moves it from step to step and from move to move. timewalk never writes to
`repo/`. Git ignores both folders.

`just check` checks the notes against the steps. `just pdf` makes `build/walk.pdf`, the slides.

## The folders

```
smallwikiapp-walk/
├── toc.toml                    the walks: show and do, and the small walks, over the same notes
├── walks/tutorial/notes.md     the notes of every step and move, for timewalk
├── walks/tutorial/TUTORIAL-*.md  the tutorial to read on GitHub, in watch mode and in do mode
├── walks/tutorial/slides/      the slides, and slides.toml, which step shows which
├── walks/testing/              a small walk's intro, and its TUTORIAL-*.md; linting and docs too
├── site/                       the website, made from notes.md; GitHub publishes it on every push
├── sites/                      the website of each small walk, published under the website's address
├── justfile                    present, setup, check, pdf, site
├── repo/                       ignored: your clone of smallwikiapp
└── worktree/                   ignored: the replay copy, at the step on show
```
