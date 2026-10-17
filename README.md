# smallwikiapp, one move at a time

This tutorial builds [smallwikiapp](https://github.com/rahuldave/smallwikiapp), a small command that prints
a random page of Wikipedia. It also builds the project around the command:

- packages and dependencies with uv, and one interface for every task with `just`
- tests and mocks, and a library with an app that uses it
- format, lint, types, a git hook and CI
- documentation made from the code, and published on GitHub Pages

smallwikiapp grew in **steps**. Each step is a tag, `step-00`, `step-01` and so on. The small commits between
two tags are the **moves**. Each move does one action, and ends with a command that shows what it did. The
tutorial has three forms, with the same text:

- **[The website](https://rahuldave.com/smallwikiapp-walk/)**, a page for each step in each mode, with a list
  of the steps beside it and a search box.
- **To read on GitHub**, [walks/show/read.md](walks/show/read.md) explains each move, and
  [walks/show/build.md](walks/show/build.md) gives every command to run. Both have the commands in code blocks,
  and a link to the code at every step and to the commit of every move.
- [walks/tutorial/notes.md](walks/tutorial/notes.md), **the notes that timewalk reads**. The teacher's
  `just walk-update` makes the website and the pages to read on GitHub from these notes.

The slides are in [smallwikiapp.pdf](smallwikiapp.pdf), one page each, and as Markdown in
[walks/tutorial/slides/](walks/tutorial/slides/). Every walk uses these slides.

## Five small walks

Each small walk has notes of its own, in `walks/ID/notes.md`. Each of its parts takes some steps or moves of the
whole tutorial, with their notes and their commits. A part starts from the code before its first move, and
starts with `just setup`. Where the walk leaves out moves, the next part says what they did.

| Walk | What it takes | Website | On GitHub |
|---|---|---|---|
| `testing` | the project and its command, then pytest, fixtures and mocks, coverage, end-to-end tests, the tests on GitHub, and their own group there: 14 parts, from step-00 to the move 08b.1 | [testing](https://rahuldave.com/smallwikiapp-walk/testing/) | [read](walks/testing/read.md), [build](walks/testing/build.md) |
| `linting` | the project and its command, then a formatter, a linter and its fixes, the check of the configuration, the gate and the hook, and the types the linter asks for: 10 parts, from step-00 to the move 10.3 | [linting](https://rahuldave.com/smallwikiapp-walk/linting/) | [read](walks/linting/read.md), [build](walks/linting/build.md) |
| `docs` | the project and its command, then smalldocs, docstrings and docments, a site, the README, the check of the docs, and the site on GitHub Pages: 11 parts, from step-00 to the move 09.10 | [docs](https://rahuldave.com/smallwikiapp-walk/docs/) | [read](walks/docs/read.md), [build](walks/docs/build.md) |
| `just` | the project and its first justfile, then each verb as it comes in, and `just check`, which a person, the git hook and GitHub run: 17 parts, from step-00 to the move 10.3 | [just](https://rahuldave.com/smallwikiapp-walk/just/) | [read](walks/just/read.md), [build](walks/just/build.md) |
| `uv` | the project and its `.venv`, then the lockfile, dependency groups, when uv syncs, Python versions, environments, a group for each job on GitHub, a workspace of two packages, and a build: 11 parts, from step-00 to the move 10.2 | [uv](https://rahuldave.com/smallwikiapp-walk/uv/) | [read](walks/uv/read.md), [build](walks/uv/build.md) |

`just present testing` opens a small walk in timewalk.

## The steps and moves

Each link opens its section of [walks/show/read.md](walks/show/read.md).

- [step-00](walks/show/read.md#step-00) **The project**
- [step-01](walks/show/read.md#step-01) **A random page**
  - [step-01.1](walks/show/read.md#step-01.1) click and requests
  - [step-01.2](walks/show/read.md#step-01.2) Ask Wikipedia for a page
  - [step-01.3](walks/show/read.md#step-01.3) A User-Agent
  - [step-01.4](walks/show/read.md#step-01.4) --version
- [step-02](walks/show/read.md#step-02) **Tests, with mocks**
  - [step-02.1](walks/show/read.md#step-02.1) uv installs every dependency group
  - [step-02.2](walks/show/read.md#step-02.2) The first test
  - [step-02.3](walks/show/read.md#step-02.3) pytest, in the group test
  - [step-02.4](walks/show/read.md#step-02.4) The recipe `just test`
  - [step-02.5](walks/show/read.md#step-02.5) The runner as a fixture
  - [step-02.6](walks/show/read.md#step-02.6) pytest-mock, in the group test
  - [step-02.7](walks/show/read.md#step-02.7) A mock in place of Wikipedia
  - [step-02.8](walks/show/read.md#step-02.8) Tests of the request
  - [step-02.9](walks/show/read.md#step-02.9) A test of a failed request
  - [step-02.10](walks/show/read.md#step-02.10) pytest-cov, in the group test
  - [step-02.11](walks/show/read.md#step-02.11) Coverage on every run
- [step-03](walks/show/read.md#step-03) **A library and an app**
  - [step-03.1](walks/show/read.md#step-03.1) random_page goes to wikipedia.py
  - [step-03.2](walks/show/read.md#step-03.2) The mock goes to conftest.py
  - [step-03.3](walks/show/read.md#step-03.3) A language
  - [step-03.4](walks/show/read.md#step-03.4) wikiapp --language
  - [step-03.5](walks/show/read.md#step-03.5) WikipediaError
  - [step-03.6](walks/show/read.md#step-03.6) The command prints the error
- [step-04](walks/show/read.md#step-04) **Format, lint, a hook**
  - [step-04.1](walks/show/read.md#step-04.1) ruff, in the group lint
  - [step-04.2](walks/show/read.md#step-04.2) The settings of ruff, and the recipe fmt
  - [step-04.3](walks/show/read.md#step-04.3) The code, formatted
  - [step-04.4](walks/show/read.md#step-04.4) The linter's rules, and the recipe lint
  - [step-04.5](walks/show/read.md#step-04.5) The tests' imports at the top, and no unused variables
  - [step-04.6](walks/show/read.md#step-04.6) A timeout
  - [step-04.7](walks/show/read.md#step-04.7) The linter sorts the imports
  - [step-04.8](walks/show/read.md#step-04.8) validate-pyproject, in the group lint
  - [step-04.9](walks/show/read.md#step-04.9) The recipe lint-config
  - [step-04.10](walks/show/read.md#step-04.10) Recipes refuse an old lockfile
  - [step-04.11](walks/show/read.md#step-04.11) The recipe check
  - [step-04.12](walks/show/read.md#step-04.12) `pre-commit`, in the group lint
  - [step-04.13](walks/show/read.md#step-04.13) A git hook
- [step-05](walks/show/read.md#step-05) **Types**
  - [step-05.1](walks/show/read.md#step-05.1) ty, in the group lint
  - [step-05.2](walks/show/read.md#step-05.2) The recipe types
  - [step-05.3](walks/show/read.md#step-05.3) The version of "wikiapp", by name
  - [step-05.4](walks/show/read.md#step-05.4) A type on every parameter and return
  - [step-05.5](walks/show/read.md#step-05.5) Types in the code
  - [step-05.6](walks/show/read.md#step-05.6) Types in the tests
  - [step-05.7](walks/show/read.md#step-05.7) The recipe check runs the type checker
- [step-06](walks/show/read.md#step-06) **End to end, and CI**
  - [step-06.1](walks/show/read.md#step-06.1) The end-to-end test runs only on request
  - [step-06.2](walks/show/read.md#step-06.2) An end-to-end test of the library
  - [step-06.3](walks/show/read.md#step-06.3) Any Python from 3.11 on
  - [step-06.4](walks/show/read.md#step-06.4) The lockfile, for every Python from 3.11 on
  - [step-06.5](walks/show/read.md#step-06.5) GitHub runs the tests
- [step-07](walks/show/read.md#step-07) **A page with a shape**
  - [step-07.1](walks/show/read.md#step-07.1) pydantic
  - [step-07.2](walks/show/read.md#step-07.2) The model Page
  - [step-07.3](walks/show/read.md#step-07.3) random_page returns a Page
  - [step-07.4](walks/show/read.md#step-07.4) An answer that is not a page
  - [step-07.5](walks/show/read.md#step-07.5) Only a language code goes into the address
- [step-08](walks/show/read.md#step-08) **Docs from the code**
  - [step-08.1](walks/show/read.md#step-08.1) smalldocs
  - [step-08.2](walks/show/read.md#step-08.2) What is not documented
  - [step-08.3](walks/show/read.md#step-08.3) The library documented
  - [step-08.4](walks/show/read.md#step-08.4) The command documented
  - [step-08.5](walks/show/read.md#step-08.5) The tests documented
  - [step-08.6](walks/show/read.md#step-08.6) A site
  - [step-08.7](walks/show/read.md#step-08.7) The README names the tests and the docs
  - [step-08.8](walks/show/read.md#step-08.8) The docs check in `just check`
- [step-08b](walks/show/read.md#step-08b) **The docs on GitHub Pages**
  - [step-08b.1](walks/show/read.md#step-08b.1) The tests install the group test alone
  - [step-08b.2](walks/show/read.md#step-08b.2) A workflow that publishes the docs
- [step-09](walks/show/read.md#step-09) **The library as a package**
  - [step-09.1](walks/show/read.md#step-09.1) An empty library, wikirandom
  - [step-09.2](walks/show/read.md#step-09.2) requests and pydantic, for the library
  - [step-09.3](walks/show/read.md#step-09.3) The library's README
  - [step-09.4](walks/show/read.md#step-09.4) The library gets a copy of wikipedia.py
  - [step-09.5](walks/show/read.md#step-09.5) The library's docstring and User-Agent
  - [step-09.6](walks/show/read.md#step-09.6) The app depends on wikirandom
  - [step-09.7](walks/show/read.md#step-09.7) The app uses wikirandom
  - [step-09.8](walks/show/read.md#step-09.8) The app no longer needs requests and pydantic
  - [step-09.9](walks/show/read.md#step-09.9) The tests of the library are named for it
  - [step-09.10](walks/show/read.md#step-09.10) The docs check counts the library
- [step-10](walks/show/read.md#step-10) **Build**
  - [step-10.1](walks/show/read.md#step-10.1) The recipe `build`
  - [step-10.2](walks/show/read.md#step-10.2) The app needs wikirandom 0.1
  - [step-10.3](walks/show/read.md#step-10.3) lint-config checks both pyproject.toml files
  - [step-10.4](walks/show/read.md#step-10.4) A licence for the library, and a repository link for both
  - [step-10.5](walks/show/read.md#step-10.5) The User-Agent says the installed version

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

In the move 04.13, `just hook` installs a git hook. Before each commit you make, it runs pre-commit's checks, and
`just check` among them. If you start at a later step, run `just hook` once.

**A move keeps your work.** Before a move, timewalk puts your edits and commits in `worktree/` on a branch
`timewalk/saved/<place>`, for example `timewalk/saved/step-03.2`, and does not ask. The page names the branch,
and gives the command that brings a file back.

## What you need

- [uv](https://docs.astral.sh/uv/), which also runs timewalk
- [git](https://git-scm.com/) and [just](https://just.systems/)
- Chrome, Edge or another recent browser
- A GitHub account, only to see CI and the docs site run in your own fork of smallwikiapp, from step-06 and
  step-08b. Those steps use GitHub's website. They need no `gh`, and timewalk has no part in them

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

`just check` checks the notes against the steps. `just pdf` makes `build/walk.pdf`, the slides. `just site` builds the
website and serves it on your machine.

## The folders

```
smallwikiapp-walk/
├── toc.toml                    the walks: show and do, and the small walks, over the same commits
├── walks/tutorial/notes.md     the notes of every step and move, for timewalk
├── walks/ID/read.md, build.md  the tutorial to read on GitHub: walks/show for the whole tutorial
├── walks/tutorial/slides/      the slides, and slides.toml, which step shows which
├── smallwikiapp.pdf            the slides, one page each
├── walks/testing/              a small walk's own notes, and its pages; linting, docs, just and uv too
├── site/                       the website of every walk, made from the notes; GitHub publishes it on every push
├── justfile                    present, setup, check, pdf, site
├── repo/                       ignored: your clone of smallwikiapp
└── worktree/                   ignored: the replay copy, at the step on show
```
