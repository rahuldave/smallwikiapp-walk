We document `wikiapp`, a small command that prints the title and the summary of a random Wikipedia page. A person
who calls the code needs to know what each part does. A person who reads the project on GitHub needs to know where
each part is. smalldocs makes a reference from the docstrings of the code, and counts what has none.

This tutorial takes the parts about documentation out of the whole tutorial of smallwikiapp. It starts from the
project that `uv init` made, for Python 3.13. The command then gets its code. The documentation comes after,
when the code has tests, lint and types.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has eleven sections:

1. **The project**
2. **The command**
3. **smalldocs, and what is not documented**
4. **The library documented**
5. **The command documented**
6. **The tests documented**
7. **A site**
8. **The README's folders**
9. **The docs check in `just check`**
10. **The docs on GitHub Pages**
11. **The docs check counts the library**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**Kinds of documentation**

The table gives each kind of documentation, and the sections where it appears.

| Kind | Who reads it, and what it says | Where |
|---|---|---|
| README | A reader on GitHub. What the project is, and where each part is | Sections 1 and 8 |
| Help text | A person who runs the command. click, the library that the command is built on, writes it from the docstring and the options | Sections 2 and 5 |
| Reference | A person who calls the code. smalldocs makes it from the code | Sections 3, 7 and 11 |
| Docstring | What a module, a class or a function does | Sections 1 to 6 |
| Docment | What each parameter, field and return is | Sections 3 to 6 |
| Tests as documentation | What the code must do, in a docstring above the asserts | Section 6 |
| A written page | What the project does, on the front page of the site | Section 7 |
| A published site | The site, on GitHub Pages, built again on every push to main | Section 10 |
| Docs check | Counts what is documented, and names each gap. From section 9, each `git commit` must pass it | Sections 3, 9 and 11 |

## The project

The first documentation of a project is its README. This section shows what `uv init` made, and the command
`wikiapp`. The justfile lists the tasks of the project, and the README says what the project is.

{{include step-00}}

## The command

The command asks Wikipedia for a random page, and prints its title and summary. Its docstring and its options make
the text of `--help`, the first documentation that a person who runs it reads.

{{include step-01}}

## smalldocs, and what is not documented

$ just setup

A dependency group is a named list of packages in `pyproject.toml`. The project uses them to test, check or
document the code, but the code does not need them to run. The code now also has pytest, in a group `test`, and
uv installs every group.

The code has tests. In the tests, a stand-in called a mock answers in place of Wikipedia, so the tests need no
network. Each run also measures coverage, which is the share of the lines of the code that the tests run. The code is split into a library,
`src/wikiapp/wikipedia.py`, and the command. The command has an option `--language`.

The code now also has ruff and ty, in a group `lint`. ruff formats the code, and lints it, which means that it
checks the code against a list of rules. ty checks the types, the kind of value, such as a string or a number,
that each name has. `just check` runs every check. `just hook` installs a git hook, a script that git runs by
itself before each `git commit`, and the hook runs `just check`.

The tests that ask the real Wikipedia run only on request, and GitHub runs the tests and `just check`.
`random_page` returns a `Page`. A `Page` is a pydantic model, a class that checks the type of each of its fields.
Its fields are a title and an extract. An answer that is not a page, or a
language that is not a language code, raises `WikipediaError`.

Nothing yet says which parts of the code have documentation. smalldocs, in a new group `docs`, makes the reference
from the code.
`just docs check` counts what has documentation, and lists each gap.

{{include step-08.1..step-08.2}}

## The library documented

$ just setup

The check lists gaps in the library. The module gets a docstring, and `random_page` a longer one. A docment is a
short comment at the end of the line of a name, which says what it is. Each field of `Page`, the parameter of
`random_page`, and the value it returns get a docment.

{{include step-08.3}}

## The command documented

$ just setup

The check lists gaps in the command, `console.py`. It and `src/wikiapp/__init__.py` get a docstring each. `main` gets
a longer docstring and a docment, and the option `--language` a clearer help.

{{include step-08.4}}

## The tests documented

$ just setup

The tests say what the code must do, and the check lists them as gaps too. Each test now says what it checks, and
the docs check finds no gap.

{{include step-08.5}}

## A site

$ just setup

The reference is text in a terminal. smalldocs builds a site, with a front page and a reference page for
`console.py` and one for `wikipedia.py`.

{{include step-08.6}}

## The README's folders

$ just setup

The README does not name the tests and the docs among the folders. Now it names them.

{{include step-08.7}}

## The docs check in `just check`

$ just setup

A person must remember to run the docs check. Now `just check` runs it, so each `git commit` must pass it.

{{include step-08.8}}

## The docs on GitHub Pages

$ just setup

The site that `just docs` builds is only on your own machine. In this section it goes on the web, and GitHub
builds it again after each push. But first, this section starts from a change that the whole tutorial makes and
this tutorial leaves out.

A job is a list of commands that GitHub runs on one of its own machines. GitHub runs the tests in twelve jobs, and
each job is called `tests`. There is one job for each pair of an operating system and a version of Python. The
systems are Linux, macOS and Windows, and the versions are Python 3.11 to 3.14. GitHub runs the jobs each time
someone pushes to the branch `main`. GitHub also runs them for each pull request, which is a request to add
changes to a branch.

At first, each job ran `uv run --locked pytest`. `uv.lock` lists the exact version of each package that uv installs. With
`--locked`, uv stops with an error if `uv.lock` does not match `pyproject.toml`.

`pyproject.toml` has three groups, `docs`, `lint`
and `test`. It sets `default-groups = "all"`, so `uv run` installs all three. But the tests need only the group
`test`. So each job also installed smalldocs, ruff, ty and other tools, and never used them.

A move of the [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) stops the extra installs. This tutorial
leaves that move out. Your code for this section already contains the
change from that move, so you do not make it yourself.

That move changed the command of each job to `uv run --locked --no-default-groups --group test pytest`. With
`--no-default-groups`, uv installs none of the groups that `default-groups` names. With `--group test`, uv adds the
group `test` back. So uv installs the package `wikiapp`, the packages that `wikiapp` needs to run, and the group `test`. It installs
no other group.

But `pyproject.toml` still sets `default-groups = "all"`, so `uv run` on your machine still installs every group.

{{include step-08b.2}}

## The docs check counts the library

$ just setup

The code now also has the library as a package of its own, `wikirandom`, in `packages/wikirandom`, with a README of
its own. Its code went there with its docstrings and docments. The app uses it, and `src/wikiapp/wikipedia.py` is
gone. The README and the front page of the docs name both packages. The tests of the library are now
`tests/test_wikirandom.py`.

The settings of smalldocs are in `docs/_smalldocs.yml`. Besides the tests, the check counts only the packages that
this file names, and it names only `wikiapp`. So when
the library's code moved to `wikirandom`, `just docs check` stopped counting it. Before this section, the check
counts only the functions, methods and classes of the app and the tests. After it, the check counts the library's
too. The line for `wikirandom` prints `3 of 3`, and the total is `15 of 15` again.

{{include step-09.10}}

This tutorial ends here. Later, `just build` builds both packages, and the app needs a 0.1 version of
wikirandom. `just lint-config` checks the library's `pyproject.toml` too, and the library gets a licence and an
author. Both packages get a link to the repository. Each request to Wikipedia carries a name for the program, called
its User-Agent, and that name also gets the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.
