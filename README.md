# smallwikiapp, one move at a time

A tutorial that builds [smallwikiapp](https://github.com/rahuldave/smallwikiapp), a small command that prints a
random page of Wikipedia, and the project around it: packaging with uv, one interface for every task with just,
tests and mocks, a library and an app that uses it, format, lint, types, a git hook, CI, and documentation
made from the code.

smallwikiapp grew in **steps**. Each step is a tag, `step-00`, `step-01` and so on. Between two tags are the
**moves**: small commits, one action each, and each ends with a command that shows what it did. The tutorial
is in three forms, with the same text:

- **[The website](https://rahuldave.com/smallwikiapp-walk/)**, a page for each step, with a list of the
  steps beside it and a search box.
- [walks/tutorial/TUTORIAL.md](walks/tutorial/TUTORIAL.md), **to read on GitHub**: the commands in code blocks,
  and a link to the code at every step and to the commit of every move.
- [walks/tutorial/notes.md](walks/tutorial/notes.md), **the notes that timewalk reads**, below. TUTORIAL.md is
  made from them.

The slides are in [walks/tutorial/slides/](walks/tutorial/slides/).

## The steps and moves

Each link opens its section of TUTORIAL.md.

- [step-00](walks/tutorial/TUTORIAL.md#step-00-the-project) **The project**
- [step-01](walks/tutorial/TUTORIAL.md#step-01-a-random-page) **A random page**
  - [step-01.1](walks/tutorial/TUTORIAL.md#step-011-click-and-requests) click and requests
  - [step-01.2](walks/tutorial/TUTORIAL.md#step-012-ask-wikipedia-for-a-page) Ask Wikipedia for a page
  - [step-01.3](walks/tutorial/TUTORIAL.md#step-013-a-user-agent) A User-Agent
  - [step-01.4](walks/tutorial/TUTORIAL.md#step-014---version) --version
- [step-02](walks/tutorial/TUTORIAL.md#step-02-tests-with-mocks) **Tests, with mocks**
  - [step-02.1](walks/tutorial/TUTORIAL.md#step-021-pytest-and-the-first-test) pytest, and the first test
  - [step-02.2](walks/tutorial/TUTORIAL.md#step-022-just-test) just test
  - [step-02.3](walks/tutorial/TUTORIAL.md#step-023-a-mock-in-place-of-wikipedia) A mock in place of Wikipedia
  - [step-02.4](walks/tutorial/TUTORIAL.md#step-024-tests-of-the-request) Tests of the request
  - [step-02.5](walks/tutorial/TUTORIAL.md#step-025-a-test-of-a-failed-request) A test of a failed request
  - [step-02.6](walks/tutorial/TUTORIAL.md#step-026-coverage) Coverage
- [step-03](walks/tutorial/TUTORIAL.md#step-03-a-library-and-an-app) **A library and an app**
  - [step-03.1](walks/tutorial/TUTORIAL.md#step-031-random_page-moves-to-wikipediapy) random_page moves to wikipedia.py
  - [step-03.2](walks/tutorial/TUTORIAL.md#step-032-the-mock-moves-to-conftestpy) The mock moves to conftest.py
  - [step-03.3](walks/tutorial/TUTORIAL.md#step-033-a-language) A language
  - [step-03.4](walks/tutorial/TUTORIAL.md#step-034-wikiapp---language) wikiapp --language
  - [step-03.5](walks/tutorial/TUTORIAL.md#step-035-wikipediaerror) WikipediaError
  - [step-03.6](walks/tutorial/TUTORIAL.md#step-036-the-command-prints-the-error) The command prints the error
- [step-04](walks/tutorial/TUTORIAL.md#step-04-format-lint-a-hook) **Format, lint, a hook**
  - [step-04.1](walks/tutorial/TUTORIAL.md#step-041-ruff-and-just-fmt) ruff, and just fmt
  - [step-04.2](walks/tutorial/TUTORIAL.md#step-042-the-code-formatted) The code, formatted
  - [step-04.3](walks/tutorial/TUTORIAL.md#step-043-the-linters-rules-and-just-lint) The linter's rules, and just lint
  - [step-04.4](walks/tutorial/TUTORIAL.md#step-044-just-lint---fix-sorts-the-imports) just lint --fix sorts the imports
  - [step-04.5](walks/tutorial/TUTORIAL.md#step-045-the-tests-imports-at-the-top-and-no-unused-variables) The tests' imports at the top, and no unused variables
  - [step-04.6](walks/tutorial/TUTORIAL.md#step-046-a-timeout) A timeout
  - [step-04.7](walks/tutorial/TUTORIAL.md#step-047-just-lint-config-and-just-check) just lint-config, and just check
  - [step-04.8](walks/tutorial/TUTORIAL.md#step-048-a-git-hook) A git hook
- [step-05](walks/tutorial/TUTORIAL.md#step-05-types) **Types**
  - [step-05.1](walks/tutorial/TUTORIAL.md#step-051-ty-and-just-types) ty, and just types
  - [step-05.2](walks/tutorial/TUTORIAL.md#step-052-the-version-of-wikiapp-by-name) The version of "wikiapp", by name
  - [step-05.3](walks/tutorial/TUTORIAL.md#step-053-a-type-on-every-parameter-and-return) A type on every parameter and return
  - [step-05.4](walks/tutorial/TUTORIAL.md#step-054-types-in-the-code) Types in the code
  - [step-05.5](walks/tutorial/TUTORIAL.md#step-055-types-in-the-tests) Types in the tests
  - [step-05.6](walks/tutorial/TUTORIAL.md#step-056-types-join-just-check) Types join just check
- [step-06](walks/tutorial/TUTORIAL.md#step-06-end-to-end-and-ci) **End to end, and CI**
  - [step-06.1](walks/tutorial/TUTORIAL.md#step-061-the-end-to-end-test-runs-only-when-asked-for) The end-to-end test runs only when asked for
  - [step-06.2](walks/tutorial/TUTORIAL.md#step-062-an-end-to-end-test-of-the-library) An end-to-end test of the library
  - [step-06.3](walks/tutorial/TUTORIAL.md#step-063-any-python-from-311-on) Any Python from 3.11 on
  - [step-06.4](walks/tutorial/TUTORIAL.md#step-064-github-runs-the-tests) GitHub runs the tests
- [step-07](walks/tutorial/TUTORIAL.md#step-07-a-page-with-a-shape) **A page with a shape**
  - [step-07.1](walks/tutorial/TUTORIAL.md#step-071-page) Page
  - [step-07.2](walks/tutorial/TUTORIAL.md#step-072-random_page-returns-a-page) random_page returns a Page
  - [step-07.3](walks/tutorial/TUTORIAL.md#step-073-an-answer-that-is-not-a-page) An answer that is not a page
  - [step-07.4](walks/tutorial/TUTORIAL.md#step-074-only-a-language-code-goes-into-the-address) Only a language code goes into the address
- [step-08](walks/tutorial/TUTORIAL.md#step-08-docs-from-the-code) **Docs from the code**
  - [step-08.1](walks/tutorial/TUTORIAL.md#step-081-docsapidocspy) docs/apidocs.py
  - [step-08.2](walks/tutorial/TUTORIAL.md#step-082-the-library-documented) The library documented
  - [step-08.3](walks/tutorial/TUTORIAL.md#step-083-the-command-documented) The command documented
  - [step-08.4](walks/tutorial/TUTORIAL.md#step-084-the-tests-documented) The tests documented
  - [step-08.5](walks/tutorial/TUTORIAL.md#step-085-a-site) A site
  - [step-08.6](walks/tutorial/TUTORIAL.md#step-086-the-docs-check-joins-just-check) The docs check joins just check
- [step-09](walks/tutorial/TUTORIAL.md#step-09-the-library-as-a-package) **The library as a package**
  - [step-09.1](walks/tutorial/TUTORIAL.md#step-091-an-empty-library-wikirandom) An empty library, wikirandom
  - [step-09.2](walks/tutorial/TUTORIAL.md#step-092-wikirandom-gets-the-code) wikirandom gets the code
  - [step-09.3](walks/tutorial/TUTORIAL.md#step-093-the-app-uses-wikirandom) The app uses wikirandom
  - [step-09.4](walks/tutorial/TUTORIAL.md#step-094-the-docs-name-both-packages) The docs name both packages
- [step-10](walks/tutorial/TUTORIAL.md#step-10-build) **Build**
  - [step-10.1](walks/tutorial/TUTORIAL.md#step-101-just-build) just build
  - [step-10.2](walks/tutorial/TUTORIAL.md#step-102-the-app-needs-wikirandom-01) The app needs wikirandom 0.1
  - [step-10.3](walks/tutorial/TUTORIAL.md#step-103-a-licence-and-a-home-for-both) A licence and a home for both
  - [step-10.4](walks/tutorial/TUTORIAL.md#step-104-the-user-agent-says-the-installed-version) The User-Agent says the installed version

## Two ways to take it

The tutorial runs in [timewalk](https://rahuldave.com/timewalk/), a page in the browser with the files, the
notes, the slides, and terminals in the project at each step.

| Mode | What you do |
|---|---|
| **Do** | You make each move yourself, from its notes: type the code, run the command in the grey block, run the command at the end of the move, and press **Done**. **Your files match** says when your files are the same as the move's commit. **Apply** and **Catch me up** are there when you are stuck |
| **Watch** | **Show** checks out each move's commit, and the notes explain what changed. This is how the class is shown |

The switch **Do / Watch** beside the walk's name changes the mode at any time. Every step starts from the code
of the step before, so every step starts with `just setup`.

## What you need

- [uv](https://docs.astral.sh/uv/), which also runs timewalk
- [git](https://git-scm.com/) and [just](https://just.systems/)
- [Quarto](https://quarto.org/), from step 08, for the docs site
- Chrome, Edge or another recent browser

## Start

Fork this repository on GitHub first, so that you can keep your own notes; or clone `rahuldave/smallwikiapp-walk`
itself in place of your fork.

```
git clone https://github.com/<you>/smallwikiapp-walk
cd smallwikiapp-walk
just present do         # do mode: you make the moves
just present            # watch mode: the moves are shown
```

`just present` runs `just setup`, which clones
smallwikiapp into `repo/` (your fork of it, if you have one) and fetches the tags of the steps. timewalk then
keeps its own copy in `worktree/`, which it moves from step to step and move to move. Git ignores both
folders. `just check` checks the notes against the steps, and `just pdf` makes `build/walk.pdf`, the slides.

## The folders

```
smallwikiapp-walk/
├── toc.toml                    the walks: do and show, over the same notes
├── walks/tutorial/TUTORIAL.md  the tutorial, to read on GitHub, made from notes.md
├── walks/tutorial/notes.md     the notes of every step and move, for timewalk
├── walks/tutorial/slides/      the slides, and slides.toml, which step shows which
├── site/                       the website, made from TUTORIAL.md; GitHub publishes it on every push
├── justfile                    present, setup, check, pdf, site
├── repo/                       ignored: your clone of smallwikiapp
└── worktree/                   ignored: timewalk's copy, at the step on show
```
