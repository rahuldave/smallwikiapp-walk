<!-- Made by the walk skill's render.py from the facts of the walk. Do not edit it by hand: run just walk-update again. -->

# The docs

**Read the tutorial.** Each change explained, with the code to look at. [Build it yourself](build.md) is the other way to read it.

Each part ends with a section called **What changed**. It lists every file that the part changes, with a link to the file, and then the whole diff of each file, folded. A lockfile and a binary file have a link alone. The text above it explains the change.

We document `wikiapp`, a small command that prints the title and the summary of a random Wikipedia page. A person
who calls the code needs to know what each part does. A person who reads the project on GitHub needs to know where
each part is. [smalldocs](https://docs.smallish.dev/) makes a reference from the docstrings of the code, and counts what has none.

This tutorial takes the parts about documentation out of the whole tutorial of smallwikiapp. It starts from the
project that `uv init` made, for Python 3.13. The command then gets its code. The documentation comes after,
when the code has tests, lint and types.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

The project uses [uv](https://docs.astral.sh/uv/) and [`just`](https://just.systems/). uv installs Python and the project's packages, which are
code that other people wrote. It also runs commands with them. `uv init` is the command of uv that made the project. `just` runs the tasks that the file
`justfile` lists. For example, `just setup` has uv install the packages that the project needs.

The code is on GitHub, at [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp). Its author kept
the history of the project with git, a tool that records each change. That history, each change of the whole
tutorial one after another, is on GitHub too. A tag is a name for
one point in that history. The tags `step-00` to `step-10`, with `step-08b`, name the code at the end of each part
of the whole tutorial.

At the end of the whole tutorial, the command is in `src/wikiapp/`. `wikirandom`, the library that asks Wikipedia for a
random page, has a folder of its own, `packages/wikirandom/`. The tests of both are in `tests/`. The project also has a website of
documentation, the docs site, and `docs/` has its front page and its settings.

GitHub can also run the tasks of the project on its own machines. Each file in `.github/workflows/` says which
tasks, and when. `main` is the main line of the history on GitHub. Each time the author adds
a change to it, GitHub runs the tests, and every check that `just check` runs. It does the same when someone proposes a change. It also builds the docs site and publishes it each time
a change reaches `main`.

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
| Help text | A person who runs the command. [click](https://click.palletsprojects.com/), the library that the command is built on, writes it from the docstring and the options | Sections 2 and 5 |
| Reference | A person who calls the code. smalldocs makes it from the code | Sections 3, 7 and 11 |
| Docstring | What a module, a class or a function does | Sections 1 to 6 |
| Docment | What each parameter, field and return is | Sections 3 to 6 |
| Tests as documentation | What the code must do, in a docstring above the asserts | Section 6 |
| A written page | What the project does, on the front page of the site | Section 7 |
| A published site | The site, on GitHub Pages, built again on every push to main | Section 10 |
| Docs check | Counts what is documented, and names each gap. From section 9, each `git commit` must pass it | Sections 3, 9 and 11 |

<a id="step-00"></a>

## 0 The project

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part is where the project starts, at `step-00`. [The code of this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

The first documentation of a project is its README. This section shows what `uv init` made, and the command
`wikiapp`. The justfile lists the tasks of the project, and the README says what the project is.

```bash
just setup
```

A project needs a name, a Python and a command before it has code to run. It also needs to install the same way
on every machine. `uv init --package --python 3.13 --name wikiapp` made `pyproject.toml`, a package in
`src/wikiapp/`, and `.python-version`.

[uv](https://docs.astral.sh/uv/) comes from Astral, and is written in Rust. It installs Python, makes the folder
`.venv` with the project's packages, and runs commands in `.venv`. It also writes the lockfile, a file that lists
the exact version of each package. One tool does the work of
pip, venv and pip-tools.

Then the author changed the project by hand. `main` went to `src/wikiapp/console.py`. `pyproject.toml` got a
description, an author and a licence, and names `wikiapp.console:main` as the command. `uv lock` wrote the
lockfile, `uv.lock`. The author also wrote the justfile, `LICENSE`, the README and `.gitignore`.

`just setup` runs `uv sync --locked`. It makes `.venv` with Python 3.13, from `.python-version`, and installs
exactly the packages that the lockfile names. Here, the only package is `wikiapp` itself.

```bash
cat pyproject.toml
```

The line under `[project.scripts]` makes `wikiapp` a command. The name is on the left. The function is on the
right, `main` in `src/wikiapp/console.py`. For now, `main` prints one line.

```bash
uv run wikiapp
cat src/wikiapp/console.py
```

The program [`just`](https://just.systems/) is a command runner. It runs the tasks of the project, and the justfile contains them.

A task is called a recipe. It has a name, and the commands that it runs. `just` alone lists the tasks, and
`just --show setup` shows the recipe behind one task. `just help setup` shows the same recipe. Later sections add
recipes to the justfile.

```bash
just
just --show setup
just --show help
just help setup
```

### What changed

- <a id="step-00-.gitignore-a5cc29"></a>`.gitignore`: what git does not track, such as `.venv`. New, 30 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/.gitignore).
- <a id="step-00-.python-version-7696e9"></a>`.python-version`: the version of Python that uv installs, 3.13. New, 1 line. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/.python-version).
- <a id="step-00-LICENSE-0398cc"></a>`LICENSE`: the Apache License 2.0. New, 202 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/LICENSE).
- <a id="step-00-README.md-8ec9a0"></a>`README.md`: what the project is, and what you need to build it. New, 57 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/README.md).
- <a id="step-00-justfile-424f0b"></a>`justfile`: the recipes `help` and `setup`. New, 21 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/justfile).
  - look at `@{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}`
- <a id="step-00-pyproject.toml-5d07e7"></a>`pyproject.toml`: the project, and the table `[project.scripts]` that makes the command `wikiapp`. New, 17 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/pyproject.toml).
  - look at `wikiapp = "wikiapp.console:main"`
- <a id="step-00-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: an empty file that makes `src/wikiapp` a package. New, 0 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/src/wikiapp/__init__.py).
- <a id="step-00-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: `main`, which prints one line. New, 4 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/src/wikiapp/console.py).
- <a id="step-00-uv.lock-8356d8"></a>`uv.lock`: the exact packages, the same on every machine. New, 8 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/ae86cb7d116c4103832edf25ab3a7a9077583830/uv.lock).

<a id="step-00-.gitignore-a5cc29-diff"></a>

<details><summary>The diff of <code>.gitignore</code></summary>

```diff
@@ -0,0 +1,30 @@
+# Nothing a run makes is tracked. This list is complete from the first commit, so a run's output never
+# shows up as a stray file, whichever step of the history is checked out.
+
+# Python, and the environment uv makes
+__pycache__/
+*.py[cod]
+.venv/
+*.egg-info/
+/build/
+/dist/
+
+# Tool caches and coverage
+.ruff_cache/
+.pytest_cache/
+.coverage
+.coverage.*
+htmlcov/
+
+# The built docs site and its generated reference pages
+/docs/_site/
+/docs/api/
+/docs/_symbols.json
+
+# Settings for one machine
+.env
+
+# Operating systems and editors
+.DS_Store
+.idea/
+.vscode/
```

</details>

<a id="step-00-.python-version-7696e9-diff"></a>

<details><summary>The diff of <code>.python-version</code></summary>

```diff
@@ -0,0 +1 @@
+3.13
```

</details>

<a id="step-00-LICENSE-0398cc-diff"></a>

<details><summary>The diff of <code>LICENSE</code></summary>

```diff
@@ -0,0 +1,202 @@
+
+                                 Apache License
+                           Version 2.0, January 2004
+                        http://www.apache.org/licenses/
+
+   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION
+
+   1. Definitions.
+
+      "License" shall mean the terms and conditions for use, reproduction,
+      and distribution as defined by Sections 1 through 9 of this document.
+
+      "Licensor" shall mean the copyright owner or entity authorized by
+      the copyright owner that is granting the License.
+
+      "Legal Entity" shall mean the union of the acting entity and all
+      other entities that control, are controlled by, or are under common
+      control with that entity. For the purposes of this definition,
+      "control" means (i) the power, direct or indirect, to cause the
+      direction or management of such entity, whether by contract or
+      otherwise, or (ii) ownership of fifty percent (50%) or more of the
+      outstanding shares, or (iii) beneficial ownership of such entity.
+
+      "You" (or "Your") shall mean an individual or Legal Entity
+      exercising permissions granted by this License.
+
+      "Source" form shall mean the preferred form for making modifications,
+      including but not limited to software source code, documentation
+      source, and configuration files.
+
+      "Object" form shall mean any form resulting from mechanical
+      transformation or translation of a Source form, including but
+      not limited to compiled object code, generated documentation,
+      and conversions to other media types.
+
+      "Work" shall mean the work of authorship, whether in Source or
+      Object form, made available under the License, as indicated by a
+      copyright notice that is included in or attached to the work
+      (an example is provided in the Appendix below).
+
+      "Derivative Works" shall mean any work, whether in Source or Object
+      form, that is based on (or derived from) the Work and for which the
+      editorial revisions, annotations, elaborations, or other modifications
+      represent, as a whole, an original work of authorship. For the purposes
+      of this License, Derivative Works shall not include works that remain
+      separable from, or merely link (or bind by name) to the interfaces of,
+      the Work and Derivative Works thereof.
+
+      "Contribution" shall mean any work of authorship, including
+      the original version of the Work and any modifications or additions
+      to that Work or Derivative Works thereof, that is intentionally
+      submitted to Licensor for inclusion in the Work by the copyright owner
+      or by an individual or Legal Entity authorized to submit on behalf of
+      the copyright owner. For the purposes of this definition, "submitted"
+      means any form of electronic, verbal, or written communication sent
+      to the Licensor or its representatives, including but not limited to
+      communication on electronic mailing lists, source code control systems,
+      and issue tracking systems that are managed by, or on behalf of, the
+      Licensor for the purpose of discussing and improving the Work, but
+      excluding communication that is conspicuously marked or otherwise
+      designated in writing by the copyright owner as "Not a Contribution."
+
+      "Contributor" shall mean Licensor and any individual or Legal Entity
+      on behalf of whom a Contribution has been received by Licensor and
+      subsequently incorporated within the Work.
+
+   2. Grant of Copyright License. Subject to the terms and conditions of
+      this License, each Contributor hereby grants to You a perpetual,
+      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
+      copyright license to reproduce, prepare Derivative Works of,
+      publicly display, publicly perform, sublicense, and distribute the
+      Work and such Derivative Works in Source or Object form.
+
+   3. Grant of Patent License. Subject to the terms and conditions of
+      this License, each Contributor hereby grants to You a perpetual,
+      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
+      (except as stated in this section) patent license to make, have made,
+      use, offer to sell, sell, import, and otherwise transfer the Work,
+      where such license applies only to those patent claims licensable
+      by such Contributor that are necessarily infringed by their
+      Contribution(s) alone or by combination of their Contribution(s)
+      with the Work to which such Contribution(s) was submitted. If You
+      institute patent litigation against any entity (including a
+      cross-claim or counterclaim in a lawsuit) alleging that the Work
+      or a Contribution incorporated within the Work constitutes direct
+      or contributory patent infringement, then any patent licenses
+      granted to You under this License for that Work shall terminate
+      as of the date such litigation is filed.
+
+   4. Redistribution. You may reproduce and distribute copies of the
+      Work or Derivative Works thereof in any medium, with or without
+      modifications, and in Source or Object form, provided that You
+      meet the following conditions:
+
+      (a) You must give any other recipients of the Work or
+          Derivative Works a copy of this License; and
+
+      (b) You must cause any modified files to carry prominent notices
+          stating that You changed the files; and
+
+      (c) You must retain, in the Source form of any Derivative Works
+          that You distribute, all copyright, patent, trademark, and
+          attribution notices from the Source form of the Work,
+          excluding those notices that do not pertain to any part of
+          the Derivative Works; and
+
+      (d) If the Work includes a "NOTICE" text file as part of its
+          distribution, then any Derivative Works that You distribute must
+          include a readable copy of the attribution notices contained
+          within such NOTICE file, excluding those notices that do not
+          pertain to any part of the Derivative Works, in at least one
+          of the following places: within a NOTICE text file distributed
+          as part of the Derivative Works; within the Source form or
+          documentation, if provided along with the Derivative Works; or,
+          within a display generated by the Derivative Works, if and
+          wherever such third-party notices normally appear. The contents
+          of the NOTICE file are for informational purposes only and
+          do not modify the License. You may add Your own attribution
+          notices within Derivative Works that You distribute, alongside
+          or as an addendum to the NOTICE text from the Work, provided
+          that such additional attribution notices cannot be construed
+          as modifying the License.
+
+      You may add Your own copyright statement to Your modifications and
+      may provide additional or different license terms and conditions
+      for use, reproduction, or distribution of Your modifications, or
+      for any such Derivative Works as a whole, provided Your use,
+      reproduction, and distribution of the Work otherwise complies with
+      the conditions stated in this License.
+
+   5. Submission of Contributions. Unless You explicitly state otherwise,
+      any Contribution intentionally submitted for inclusion in the Work
+      by You to the Licensor shall be under the terms and conditions of
+      this License, without any additional terms or conditions.
+      Notwithstanding the above, nothing herein shall supersede or modify
+      the terms of any separate license agreement you may have executed
+      with Licensor regarding such Contributions.
+
+   6. Trademarks. This License does not grant permission to use the trade
+      names, trademarks, service marks, or product names of the Licensor,
+      except as required for reasonable and customary use in describing the
+      origin of the Work and reproducing the content of the NOTICE file.
+
+   7. Disclaimer of Warranty. Unless required by applicable law or
+      agreed to in writing, Licensor provides the Work (and each
+      Contributor provides its Contributions) on an "AS IS" BASIS,
+      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
+      implied, including, without limitation, any warranties or conditions
+      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
+      PARTICULAR PURPOSE. You are solely responsible for determining the
+      appropriateness of using or redistributing the Work and assume any
+      risks associated with Your exercise of permissions under this License.
+
+   8. Limitation of Liability. In no event and under no legal theory,
+      whether in tort (including negligence), contract, or otherwise,
+      unless required by applicable law (such as deliberate and grossly
+      negligent acts) or agreed to in writing, shall any Contributor be
+      liable to You for damages, including any direct, indirect, special,
+      incidental, or consequential damages of any character arising as a
+      result of this License or out of the use or inability to use the
+      Work (including but not limited to damages for loss of goodwill,
+      work stoppage, computer failure or malfunction, or any and all
+      other commercial damages or losses), even if such Contributor
+      has been advised of the possibility of such damages.
+
+   9. Accepting Warranty or Additional Liability. While redistributing
+      the Work or Derivative Works thereof, You may choose to offer,
+      and charge a fee for, acceptance of support, warranty, indemnity,
+      or other liability obligations and/or rights consistent with this
+      License. However, in accepting such obligations, You may act only
+      on Your own behalf and on Your sole responsibility, not on behalf
+      of any other Contributor, and only if You agree to indemnify,
+      defend, and hold each Contributor harmless for any liability
+      incurred by, or claims asserted against, such Contributor by reason
+      of your accepting any such warranty or additional liability.
+
+   END OF TERMS AND CONDITIONS
+
+   APPENDIX: How to apply the Apache License to your work.
+
+      To apply the Apache License to your work, attach the following
+      boilerplate notice, with the fields enclosed by brackets "[]"
+      replaced with your own identifying information. (Don't include
+      the brackets!)  The text should be enclosed in the appropriate
+      comment syntax for the file format. We also recommend that a
+      file or class name and description of purpose be included on the
+      same "printed page" as the copyright notice for easier
+      identification within third-party archives.
+
+   Copyright [yyyy] [name of copyright owner]
+
+   Licensed under the Apache License, Version 2.0 (the "License");
+   you may not use this file except in compliance with the License.
+   You may obtain a copy of the License at
+
+       http://www.apache.org/licenses/LICENSE-2.0
+
+   Unless required by applicable law or agreed to in writing, software
+   distributed under the License is distributed on an "AS IS" BASIS,
+   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
+   See the License for the specific language governing permissions and
+   limitations under the License.
```

</details>

<a id="step-00-README.md-8ec9a0-diff"></a>

<details><summary>The diff of <code>README.md</code></summary>

````diff
@@ -0,0 +1,57 @@
+# smallwikiapp
+
+`wikiapp` is the command this project builds, step by step. By the last step it prints the title and the summary
+of a random Wikipedia page, in a language you choose.
+
+The command is small on purpose. The history of this repository shows how to build the project around it,
+one step at a time:
+
+- packages and dependencies, with uv
+- tests
+- a library split from the app
+- format, lint and types
+- CI, and documentation made from the code
+
+It is a rebuild of [wikiapp](https://github.com/rahuldave/wikiapp), which follows Claudio Jolowicz's
+[Hypermodern Python](https://cjolowicz.github.io/posts/hypermodern-python-01-setup/) series, with
+[uv](https://docs.astral.sh/uv/) and [just](https://just.systems/) in place of pixi.
+
+## What you need
+
+| Tool | What it is for |
+|---|---|
+| [uv](https://docs.astral.sh/uv/) | Python itself, the dependencies, and running the command |
+| [just](https://just.systems/) | The project's tasks. `just` lists them |
+
+Then `just setup`, and `uv run wikiapp`.
+
+## What is here
+
+| Path | What it is |
+|---|---|
+| `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
+| `src/wikiapp/` | The code. `console.py` is the `wikiapp` command |
+| `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
+| `.python-version` | The Python version the project uses |
+| `.gitignore` | Everything a run makes, ignored from the first commit on |
+| `LICENSE` | The licence, Apache-2.0 |
+
+## How the history is organised
+
+The history has steps. Each step is a tag, `step-00`, `step-01` and so on, and the message of the tag
+says what the step adds. The commits between two tags are the *moves*. A move is a small commit that does
+one action, and its subject starts `step-NN.k:`. The last move of a step is the tagged commit, and its
+subject starts `step-NN:`. The message of each commit says what the commit does and why.
+
+```
+git tag -n3 --list 'step-*'           # the steps, and what each adds
+git log --oneline --reverse           # every move, in order
+git switch --detach step-01           # the project as it was at a step
+```
+
+The walk through these steps, with its notes and slides, is in
+[smallwikiapp-walk](https://github.com/rahuldave/smallwikiapp-walk).
+
+## Licence
+
+Apache-2.0: see [`LICENSE`](LICENSE).
````

</details>

<a id="step-00-justfile-424f0b-diff"></a>

<details><summary>The diff of <code>justfile</code></summary>

```diff
@@ -0,0 +1,21 @@
+# wikiapp: every task is a recipe here. `just` lists them; `just help VERB` explains one.
+
+# Each word after a recipe's name reaches its commands whole, as "$1", "$2" and so on; "$@" is all of them
+set positional-arguments
+
+[private]
+default:
+    @just --list --unsorted
+
+# Explain a verb: the comment above its recipe, then the recipe. Alone, the list
+[no-exit-message]
+help *verb:
+    #!/usr/bin/env sh
+    if [ "$#" -eq 0 ]; then just --list --unsorted; exit 0; fi
+    shown=$(just --show "$1") || exit 1
+    printf '%s\n' "$shown"
+
+# Install Python and every dependency into .venv, exactly as the lockfile says
+[group('setup')]
+setup *args:
+    @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
```

</details>

<a id="step-00-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff of <code>pyproject.toml</code></summary>

```diff
@@ -0,0 +1,17 @@
+[project]
+name = "wikiapp"
+version = "0.1.0"
+description = "Print the title and summary of a random Wikipedia page"
+readme = "README.md"
+license = "Apache-2.0"
+license-files = ["LICENSE"]
+authors = [{ name = "Rahul Dave" }]
+requires-python = ">=3.13"
+dependencies = []
+
+[project.scripts]
+wikiapp = "wikiapp.console:main"
+
+[build-system]
+requires = ["uv_build>=0.12.13,<0.13.0"]
+build-backend = "uv_build"
```

</details>

<a id="step-00-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -0,0 +1,4 @@
+
+def main() -> None:
+    """Print a line, until there is a page to print."""
+    print("Hello from wikiapp!")
```

</details>

<a id="step-01"></a>

## 1 The command

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-00`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

The command asks Wikipedia for a random page, and prints its title and summary. Its docstring and its options make
the text of `--help`, the first documentation that a person who runs it reads.

```bash
just setup
```

The command prints a fixed line. It should ask Wikipedia for a random page and print it. We need two packages for
that, then the request, then a header that Wikipedia asks for, and last an option that prints the version.

<a id="step-01.1"></a>

### 1.1 click and requests

The command needs two packages that Python does not have. [click](https://click.palletsprojects.com/) makes command lines, with options and help.
[requests](https://requests.readthedocs.io/) gets pages over HTTP. `uv add` puts both in the dependencies of wikiapp, and installs them in `.venv`. It
also chooses one version of each package that fits every range of versions, and writes the versions in the
lockfile, `uv.lock`. uv calls this choice resolving.

click comes from Pallets, who also make Flask. In click, the line `@click.command()` above a
function makes the function a command. Such a line is a decorator. Each option of the command becomes a parameter of
the function. requests
is a widely used library for HTTP. One call, `requests.get`, fetches a page.

This change came from running `uv add click requests`.

In `pyproject.toml`, the list `dependencies` was empty. Now it has `"click>=8.5.0",` and `"requests>=2.34.2",`,
each with the newest version as its lower bound. `uv.lock` has the exact version of each, and of every package
that they need.

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

#### What changed

- <a id="step-01.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the dependencies of the package, which anyone who installs it gets. 4 lines added, 1 removed. It comes from `uv add click requests`. [The file](https://github.com/rahuldave/smallwikiapp/blob/36d49582843a575d84ed178ad66157913be4c59c/pyproject.toml).
  - look at `"click>=8.5.0",`
- <a id="step-01.1-uv.lock-8356d8"></a>`uv.lock`: the exact versions, for every platform. 176 lines added. It comes from `uv add click requests`. [The file](https://github.com/rahuldave/smallwikiapp/blob/36d49582843a575d84ed178ad66157913be4c59c/uv.lock).

<a id="step-01.1-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff of <code>pyproject.toml</code></summary>

```diff
@@ -7,7 +7,10 @@ license = "Apache-2.0"
 license-files = ["LICENSE"]
 authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.13"
-dependencies = []
+dependencies = [
+    "click>=8.5.0",
+    "requests>=2.34.2",
+]
 
 [project.scripts]
 wikiapp = "wikiapp.console:main"
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/36d49582843a575d84ed178ad66157913be4c59c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/36d49582843a575d84ed178ad66157913be4c59c).

<a id="step-01.2"></a>

### 1.2 Ask Wikipedia for a page

`main` prints a fixed line. It must ask Wikipedia for a random page instead, and print the title and the summary.
The new `main` is the command of the first version of the original wikiapp, from 2024.

Its docstring, the text in triple quotes under `def main`, is new, and says what the command does. The `-> None`
after `main()` says that `main` returns no value. `uv init` wrote it, and this `main` keeps it. The `main` of the
original wikiapp did not have it.

- `@click.command()` makes `main` a command.
- `requests.get` asks the REST API of Wikipedia for the summary of a random page.
- `raise_for_status` raises an exception if the answer is an error.
- `response.json()` reads the answer as a dictionary.
- `click.secho` prints the title in green, and `textwrap.fill` wraps the summary to 70 columns.
- The last two lines call `main` when Python runs the file as a script. `uv run wikiapp` does not need them.

The patch writes `src/wikiapp/console.py` again.

[± See the change to `src/wikiapp/console.py`](#step-01.2-src-wikiapp-console.py-d9ae67-diff)

In `src/wikiapp/console.py`, the `print` is gone. The block `with requests.get(API_URL) as response:` asks
Wikipedia for the page, and the last two lines of the block print it.

```bash
uv run wikiapp
```

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. A request carries headers, which are named lines of text sent with the
address. The header User-Agent names the program that sends the request. Wikipedia refuses a request whose
User-Agent is the default of a library. requests sends `python-requests/` and its version.

#### What changed

- <a id="step-01.2-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: a request, and two lines printed. 17 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/571c82ebd31fee095e56a45cf2bf77eb7bfe0c8c/src/wikiapp/console.py).
  - look at `with requests.get(API_URL) as response:`

<a id="step-01.2-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -1,4 +1,19 @@
+import click
+import requests
+import textwrap
 
+API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+
+@click.command()
 def main() -> None:
-    """Print a line, until there is a page to print."""
-    print("Hello from wikiapp!")
+    """Print the title and summary of a random Wikipedia page."""
+    with requests.get(API_URL) as response:
+        response.raise_for_status()
+        data = response.json()
+        title = data["title"]
+        extract = data["extract"]
+        click.secho(title, fg="green")
+        click.echo(textwrap.fill(extract))
+
+if __name__=="__main__":
+    main()
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/571c82ebd31fee095e56a45cf2bf77eb7bfe0c8c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/571c82ebd31fee095e56a45cf2bf77eb7bfe0c8c).

<a id="step-01.3"></a>

### 1.3 A User-Agent

Wikipedia refused the request, because its User-Agent named only the library requests, and not the program that
sent it. The policy of
Wikimedia asks for the name of the program, its version, and a way to reach the person who runs it. A constant
`USER_AGENT` gives these three things, and the request sends it as a header.

[± See the change to `src/wikiapp/console.py`](#step-01.3-src-wikiapp-console.py-d9ae67-diff)

In `src/wikiapp/console.py`, `USER_AGENT` is under `API_URL`. The request now passes it in
`headers={"User-Agent": USER_AGENT}`.

```bash
uv run wikiapp
```

It prints a title in green, and a paragraph. Each run prints another page.

#### What changed

- <a id="step-01.3-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the header. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/0ffd5df563acb876953855d86be30b6952ecfd44/src/wikiapp/console.py).
  - look at `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

<a id="step-01.3-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -3,11 +3,12 @@ import requests
 import textwrap
 
 API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 @click.command()
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
-    with requests.get(API_URL) as response:
+    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
         response.raise_for_status()
         data = response.json()
         title = data["title"]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/0ffd5df563acb876953855d86be30b6952ecfd44). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/0ffd5df563acb876953855d86be30b6952ecfd44).

<a id="step-01.4"></a>

### 1.4 --version

A person who reports a bug must say which version they run, and the command cannot tell them. The package can read
its own version from the installed package, which has the version from `pyproject.toml`. So
`src/wikiapp/__init__.py` sets `__version__` from the metadata of the installed package. The decorator
`@click.version_option` gives the command the option `--version`, which prints it.

[± See the change to `src/wikiapp/__init__.py`](#step-01.4-src-wikiapp-__init__.py-682a01-diff)

[± See the change to `src/wikiapp/console.py`](#step-01.4-src-wikiapp-console.py-d9ae67-diff)

In `src/wikiapp/__init__.py`, `__version__` comes from `importlib.metadata`. In `src/wikiapp/console.py`,
`@click.version_option(version=__version__)` is under `@click.command()`.

```bash
uv run wikiapp --version
uv run wikiapp --help
```

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring. So the docstring of `main` is also help text, for a person who runs the command.

#### What changed

- <a id="step-01.4-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: the version, which Python reads when it imports the package. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/f05d3c31be2cf640cc2aa4345658b8eebc394d60/src/wikiapp/__init__.py).
  - look at `__version__ = importlib.metadata.version(__name__ or __package__)`
- <a id="step-01.4-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: click's version option. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/f05d3c31be2cf640cc2aa4345658b8eebc394d60/src/wikiapp/console.py).
  - look at `@click.version_option(version=__version__)`

<a id="step-01.4-src-wikiapp-__init__.py-682a01-diff"></a>

<details><summary>The diff of <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -0,0 +1,2 @@
+import importlib.metadata
+__version__ = importlib.metadata.version(__name__ or __package__)
```

</details>

<a id="step-01.4-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -1,4 +1,5 @@
 import click
+from wikiapp import __version__
 import requests
 import textwrap
 
@@ -6,6 +7,7 @@ API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 @click.command()
+@click.version_option(version=__version__)
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
     with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/f05d3c31be2cf640cc2aa4345658b8eebc394d60).

This part ends at the code at `step-01`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-01)

<a id="step-08.1-to-step-08.2"></a>

## 8.1 to 8.2 smalldocs, and what is not documented

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-07`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-07)

```bash
just setup
```

A dependency group is a named list of packages in `pyproject.toml`. The project uses them to test, check or
document the code, but the code does not need them to run. The code now also has [pytest](https://docs.pytest.org/), in a group `test`, and
uv installs every group.

The code has tests. In the tests, a stand-in called a mock answers in place of Wikipedia, so the tests need no
network. Each run also measures coverage, which is the share of the lines of the code that the tests run. The code is split into a library,
`src/wikiapp/wikipedia.py`, and the command. The command has an option `--language`.

The code now also has [ruff](https://docs.astral.sh/ruff/) and [ty](https://docs.astral.sh/ty/), in a group `lint`. ruff formats the code, and lints it, which means that it
checks the code against a list of rules. ty checks the types, the kind of value, such as a string or a number,
that each name has. `just check` runs every check. `just hook` installs a git hook, a script that git runs by
itself before each `git commit`, and the hook runs `just check`.

The tests that ask the real Wikipedia run only on request, and GitHub runs the tests and `just check`.
`random_page` returns a `Page`. A `Page` is a [pydantic](https://docs.pydantic.dev/) model, a class that checks the type of each of its fields.
Its fields are a title and an extract. An answer that is not a page, or a
language that is not a language code, raises `WikipediaError`.

Nothing yet says which parts of the code have documentation. smalldocs, in a new group `docs`, makes the reference
from the code.
`just docs check` counts what has documentation, and lists each gap.

<a id="step-08.1"></a>

### 8.1 smalldocs

The reference of a function gives its signature, what it does, and what each parameter is. The signature and the
types are in the code. The docstring says what the function does. A docment is the comment beside a parameter, a field
or a return type, and says what that thing is. Later moves put each parameter on a line of its own, so that its
docment can follow it on that line.

A reference that a tool writes from the code changes when the code changes. [smalldocs](https://docs.smallish.dev/) is that tool. It is a Python program that writes the reference, and builds a
website from it. It also lists what has no documentation.

smalldocs reads the signature, the docstring and the docments, and writes Markdown. It is a Python package, so uv
installs it like any other. It goes in a third dependency group, `docs`. uv sorts the groups by name, so `docs` comes before
`lint` and `test` in the file.

This change came from running `uv add --group docs smalldocs`.

In `pyproject.toml`, the new group `docs` is lines 28 to 30, with the line `"smalldocs>=0.1.5",`. `uv.lock` has
the exact version of smalldocs, and of the packages that it needs.

`default-groups = "all"`, at line 25 of `pyproject.toml`, makes uv install every dependency group. So
`just setup` installs smalldocs, with no other change.

```bash
uv run smalldocs --version
uv tree --only-group docs
```

The first command prints `smalldocs 0.1.5`, or a newer version. `uv tree` prints smalldocs `(group: docs)`, and under it fastcore,
markdown-it-py, mdit-py-plugins, pygments and pyyaml.

#### What changed

- <a id="step-08.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group. 3 lines added. It comes from `uv add --group docs smalldocs`. [The file](https://github.com/rahuldave/smallwikiapp/blob/71726f393670206ea480aaa2edc03ddeeeebc1fe/pyproject.toml).
  - look at `docs = [`
- <a id="step-08.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of smalldocs, and of the packages that it needs. 62 lines added. It comes from `uv add --group docs smalldocs`. [The file](https://github.com/rahuldave/smallwikiapp/blob/71726f393670206ea480aaa2edc03ddeeeebc1fe/uv.lock).

<a id="step-08.1-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff of <code>pyproject.toml</code></summary>

```diff
@@ -25,6 +25,9 @@ build-backend = "uv_build"
 default-groups = "all"
 
 [dependency-groups]
+docs = [
+    "smalldocs>=0.1.5",
+]
 lint = [
     "pre-commit>=4.7.0",
     "ruff>=0.17.0",
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/71726f393670206ea480aaa2edc03ddeeeebc1fe). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/71726f393670206ea480aaa2edc03ddeeeebc1fe).

<a id="step-08.2"></a>

### 8.2 What is not documented

smalldocs is installed, but nothing tells it which package to document, and no recipe runs it. It needs a file of settings,
and the `justfile` a recipe `docs`. Then `just docs check` lists what has no documentation.

smalldocs reads its settings from `docs/_smalldocs.yml`. For now the file has one section, `api`, the reference.
It names the package to document, the address of its source, and the files of the tests to check. The file is new,
and comes whole, as a patch.

[± See the new file `docs/_smalldocs.yml`](#step-08.2-docs-_smalldocs.yml-4b0b48-diff)

The new file `docs/_smalldocs.yml` has five lines. Line 3 names the package, `wikiapp`. Line 5 names the tests,
`tests/**/*.py`, which `check` also checks.

A recipe `docs` runs `smalldocs api`, and gives it the words after `just docs`. `smalldocs api` has two commands
that we use here:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

[± See the change to `justfile`](#step-08.2-justfile-424f0b-diff)

The recipe `docs *args:` is at line 81, the end of the `justfile`. It also passes `--dir docs`, the folder of the
settings.

```bash
uv run smalldocs api module wikipedia --dir docs
uv run smalldocs api check --dir docs
just --show docs
just docs check
```

`module` prints the reference of `wikipedia.py`, with empty descriptions. For each module and each test file,
`check` counts the functions and classes that are complete. It names every gap, and the five modules without a
docstring are among them. Then it fails with `1 of 15 functions, methods and classes are typed and documented`.
The one is `WikipediaError`, which needs only its docstring. Like
coverage, which counts the lines that the tests run, `check` counts what has documentation.

#### What changed

- <a id="step-08.2-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the package to document, and the tests to check. New, 5 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/40d4293f5902e4a5ee51c9240e0eab4b59de797f/docs/_smalldocs.yml).
  - look at `packages: [wikiapp]`
- <a id="step-08.2-justfile-424f0b"></a>`justfile`: the recipe. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/40d4293f5902e4a5ee51c9240e0eab4b59de797f/justfile).
  - look at `docs *args:`

<a id="step-08.2-docs-_smalldocs.yml-4b0b48-diff"></a>

<details><summary>The diff of <code>docs/_smalldocs.yml</code></summary>

```diff
@@ -0,0 +1,5 @@
+# The settings of smalldocs. `api` is the reference, made from the code of the packages
+api:
+  packages: [wikiapp]
+  source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
+  check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

</details>

<a id="step-08.2-justfile-424f0b-diff"></a>

<details><summary>The diff of <code>justfile</code></summary>

```diff
@@ -74,3 +74,9 @@ check *args:
     just types
     just test -q --cov-fail-under=90
     just lint-config
+
+# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+[group('docs')]
+[no-exit-message]
+docs *args:
+    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/40d4293f5902e4a5ee51c9240e0eab4b59de797f).

This part ends at the code at `40d4293f5902`, partway through `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/40d4293f5902e4a5ee51c9240e0eab4b59de797f)

<a id="step-08.3"></a>

## 8.3 The library documented

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `40d4293f5902`, partway through `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/40d4293f5902e4a5ee51c9240e0eab4b59de797f)

```bash
just setup
```

The check lists gaps in the library. The module gets a docstring, and `random_page` a longer one. A docment is a
short comment at the end of the line of a name, which says what it is. Each field of `Page`, the parameter of
`random_page`, and the value it returns get a docment.

### 8.3 The library documented

The reference of `wikipedia.py` has empty descriptions, because the library has no docments and short
docstrings. We document it in four places:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

[± See the change to `src/wikiapp/wikipedia.py`](#step-08.3-src-wikiapp-wikipedia.py-258803-diff)

In `src/wikiapp/wikipedia.py`, see the docstring at the top, the comments beside the fields of `Page`, and the
line `) -> Page:  # A page chosen at random`, the docment of the return.

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

```bash
just docs module wikipedia
```

The tables now have their descriptions.

#### What changed

- <a id="step-08.3-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the comments are the documentation. 12 lines added, 4 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/66a702fe4a01d424177085b9ef056dd8d8d11cc8/src/wikiapp/wikipedia.py).
  - look at `) -> Page:  # A page chosen at random`

<a id="step-08.3-src-wikiapp-wikipedia.py-258803-diff"></a>

<details><summary>The diff of <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""Wikipedia's REST API: a random page."""
+
 import re
 
 import requests
@@ -15,12 +17,18 @@ class WikipediaError(Exception):
 class Page(BaseModel):
     """A page of Wikipedia: its title and the summary of its text."""
 
-    title: str
-    extract: str
+    title: str  # The title of the page
+    extract: str  # The summary: the first paragraph of the page, as plain text
+
 
+def random_page(
+    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
+) -> Page:  # A page chosen at random
+    """Get a random page from Wikipedia.
 
-def random_page(language: str = "en") -> Page:
-    """Get a random page from Wikipedia."""
+    Raises WikipediaError when the language is not a language code, when the request fails, or
+    when the answer is not a page.
+    """
     if not LANGUAGE.fullmatch(language):
         raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
     try:
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/66a702fe4a01d424177085b9ef056dd8d8d11cc8).

This part ends at the code at `66a702fe4a01`, partway through `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/66a702fe4a01d424177085b9ef056dd8d8d11cc8)

<a id="step-08.4"></a>

## 8.4 The command documented

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `66a702fe4a01`, partway through `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/66a702fe4a01d424177085b9ef056dd8d8d11cc8)

```bash
just setup
```

The check lists gaps in the command, `console.py`. It and `src/wikiapp/__init__.py` get a docstring each. `main` gets
a longer docstring and a docment, and the option `--language` a clearer help.

### 8.4 The command documented

The two other modules, `src/wikiapp/__init__.py` and `src/wikiapp/console.py`, have no docstring, and `main` has
no docment. `wikiapp --help` prints the docstring of `main` and the help of each option, so those are
documentation too.

Each of the two modules gets a docstring at the top, which says what the module is.

[± See the change to `src/wikiapp/__init__.py`](#step-08.4-src-wikiapp-__init__.py-682a01-diff)

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

The help of `--language` now says what a language is. It replaces the help of the original wikiapp, "Gets random
page from Wikipedia in given language". `main` has one parameter to a line, with its docment, and a docstring that
says what `main` prints. A function that returns None needs no docment for its return.

[± See the change to `src/wikiapp/console.py`](#step-08.4-src-wikiapp-console.py-d9ae67-diff)

In `src/wikiapp/console.py`, the docment of `language` is
`# The language of the Wikipedia to ask, from --language`. The second paragraph of the docstring of `main` gives the colour of the title and the width of the
summary.

```bash
just docs module console
uv run wikiapp --help
```

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

#### What changed

- <a id="step-08.4-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: a docstring, which `help(wikiapp)` shows. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/bb648b91f4aba037eac04caa5cd7b41095e7c388/src/wikiapp/__init__.py).
  - look at `"""wikiapp: the title and summary of a random Wikipedia page."""`
- <a id="step-08.4-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the docment, the docstring and the help. 10 lines added, 3 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/bb648b91f4aba037eac04caa5cd7b41095e7c388/src/wikiapp/console.py).
  - look at `language: str,  # The language of the Wikipedia to ask, from --language`

<a id="step-08.4-src-wikiapp-__init__.py-682a01-diff"></a>

<details><summary>The diff of <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""wikiapp: the title and summary of a random Wikipedia page."""
+
 import importlib.metadata
 
 __version__ = importlib.metadata.version("wikiapp")
```

</details>

<a id="step-08.4-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""The wikiapp command."""
+
 import textwrap
 
 import click
@@ -11,13 +13,18 @@ from wikiapp.wikipedia import WikipediaError, random_page
     "--language",
     "-l",
     default="en",
-    help="Gets random page from Wikipedia in given language",
+    help="The language of the Wikipedia to ask, as its code: en, fr, es",
     metavar="LANG",
     show_default=True,
 )
 @click.version_option(version=__version__)
-def main(language: str) -> None:
-    """Print the title and summary of a random Wikipedia page."""
+def main(
+    language: str,  # The language of the Wikipedia to ask, from --language
+) -> None:
+    """Print the title and summary of a random Wikipedia page, in the language asked for.
+
+    The title is in green, and the summary is wrapped to 70 columns.
+    """
     try:
         page = random_page(language=language)
     except WikipediaError as error:
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/bb648b91f4aba037eac04caa5cd7b41095e7c388).

This part ends at the code at `bb648b91f4ab`, partway through `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/bb648b91f4aba037eac04caa5cd7b41095e7c388)

<a id="step-08.5"></a>

## 8.5 The tests documented

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `bb648b91f4ab`, partway through `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/bb648b91f4aba037eac04caa5cd7b41095e7c388)

```bash
just setup
```

The tests say what the code must do, and the check lists them as gaps too. Each test now says what it checks, and
the docs check finds no gap.

### 8.5 The tests documented

`just docs check` still finds gaps in the tests. Each test file must say what it tests, and each fixture what it
returns. Each test says in one line what it checks. The docstring says in words what the asserts say in code. Each
parameter of a test has a docment, one parameter to a line.

Tests documented this way are documentation too. A reader learns from them what the code must do.

The fixture in `tests/conftest.py` gets a docstring for the file, a docment for its parameter and its return, and a
docstring of its own.

[± See the change to `tests/conftest.py`](#step-08.5-tests-conftest.py-626af3-diff)

In `tests/conftest.py`, see the docment of `mocker`, and the docment of the return after `-> Mock:`.

`tests/test_console.py` has a fixture and six tests, and each gets the same pattern.

[± See the change to `tests/test_console.py`](#step-08.5-tests-test_console.py-9442ee-diff)

In `tests/test_console.py`, the fixture `runner` also documents its return.

The three tests of `tests/test_wikipedia.py` get the same pattern.

[± See the change to `tests/test_wikipedia.py`](#step-08.5-tests-test_wikipedia.py-2f4413-diff)

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

#### What changed

- <a id="step-08.5-tests-conftest.py-626af3"></a>`tests/conftest.py`: the fixture, documented. 6 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/7a0e5094887304538655b706752de99408df2d97/tests/conftest.py).
  - look at `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- <a id="step-08.5-tests-test_console.py-9442ee"></a>`tests/test_console.py`: seven functions. 33 lines added, 7 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/7a0e5094887304538655b706752de99408df2d97/tests/test_console.py).
  - look at `"""The command prints the title of the page."""`
- <a id="step-08.5-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: three tests. 11 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/7a0e5094887304538655b706752de99408df2d97/tests/test_wikipedia.py).
  - look at `"""The language chooses the Wikipedia that is asked."""`

<a id="step-08.5-tests-conftest.py-626af3-diff"></a>

<details><summary>The diff of <code>tests/conftest.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""What every test file can use: a mock in place of `requests.get`."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -5,7 +7,10 @@ from pytest_mock import MockerFixture
 
 
 @pytest.fixture
-def mock_requests_get(mocker: MockerFixture) -> Mock:
+def mock_requests_get(
+    mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test
+) -> Mock:  # The mock that replaces `requests.get` for the length of one test
+    """Replace `requests.get` with a mock that answers with one page, Lorem Ipsum."""
     mock = mocker.patch("requests.get")
     mock.return_value.__enter__.return_value.json.return_value = {
         "title": "Lorem Ipsum",
```

</details>

<a id="step-08.5-tests-test_console.py-9442ee-diff"></a>

<details><summary>The diff of <code>tests/test_console.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""Tests of the command, `main`, run in the same process by click's CliRunner."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -8,40 +10,64 @@ from wikiapp import console
 
 
 @pytest.fixture
-def runner() -> CliRunner:
+def runner() -> CliRunner:  # A runner that calls a command and keeps what it prints
+    """Give each test a runner for the command."""
     return CliRunner()
 
 
-def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_prints_title(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The command prints the title of the page."""
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
-def test_main_invokes_requests_get(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_invokes_requests_get(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The command makes a request."""
     runner.invoke(console.main)
     assert mock_requests_get.called
 
 
-def test_main_uses_correct_url(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_uses_correct_url(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The request goes to the random page of the English Wikipedia."""
     runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
 
 
-def test_main_fails_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_fails_on_request_error(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """An exception in the request ends the command with exit code 1."""
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
 
-def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
+def test_main_prints_message_on_request_error(
+    runner: CliRunner,  # The runner from the fixture
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """A failed request is printed as an error message, not a traceback."""
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
 
 @pytest.mark.e2e
-def test_main_succeeds_in_production(runner: CliRunner) -> None:
+def test_main_succeeds_in_production(
+    runner: CliRunner,  # The runner from the fixture
+) -> None:
+    """The command works against the real Wikipedia."""
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

<a id="step-08.5-tests-test_wikipedia.py-2f4413-diff"></a>

<details><summary>The diff of <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""Tests of the library, wikipedia.py."""
+
 from unittest.mock import Mock
 
 import pytest
@@ -5,7 +7,10 @@ import pytest
 from wikiapp import wikipedia
 
 
-def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
+def test_random_page_uses_given_language(
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """The language chooses the Wikipedia that is asked."""
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
@@ -13,11 +18,15 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 
 @pytest.mark.e2e
 def test_random_page_returns_page_in_production() -> None:
+    """The real Wikipedia's answer makes a Page."""
     page = wikipedia.random_page()
     assert isinstance(page, wikipedia.Page)
 
 
-def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
+def test_random_page_handles_validation_error(
+    mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
+) -> None:
+    """An answer that is not a page raises WikipediaError."""
     mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
     with pytest.raises(wikipedia.WikipediaError):
         wikipedia.random_page()
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/7a0e5094887304538655b706752de99408df2d97).

This part ends at the code at `7a0e50948873`, partway through `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/7a0e5094887304538655b706752de99408df2d97)

<a id="step-08.6"></a>

## 8.6 A site

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `7a0e50948873`, partway through `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/7a0e5094887304538655b706752de99408df2d97)

```bash
just setup
```

The reference is text in a terminal. smalldocs builds a site, with a front page and a reference page for
`console.py` and one for `wikipedia.py`.

### 8.6 A site

The reference exists only as Markdown that `just docs module` prints. A reader wants a site, with a front page
that says what the project does, and a page of reference for each module. smalldocs also builds a site from
Markdown.

The site is in `docs/`. It has a front page, `index.qmd`, and a reference page for `console.py` and one
for `wikipedia.py`. Each build writes the reference pages from the code, before it builds the site. A name in
backticks, such as `random_page`, becomes a link to its entry.

The settings of the site go in `docs/_smalldocs.yml`, above the section `api`, which stays as it is. They are
the type of the project, its output folder, the title, the sidebar, the theme and a table of contents on each
page. The comment at the top now says that `just docs` builds the site.

[± See the change to `docs/_smalldocs.yml`](#step-08.6-docs-_smalldocs.yml-4b0b48-diff)

In `docs/_smalldocs.yml`, the sidebar lists the front page, then the reference pages, in the line
`contents: api/*  # the reference pages, which each build makes from the code`.

The front page, `docs/index.qmd`, is new. A `.qmd` file is Markdown, with a header between two `---` lines that
gives the title of the page.

The page says what the command prints, what each module does, and what the reference pages contain. The file is
new, and comes whole, as a patch.

[± See the new file `docs/index.qmd`](#step-08.6-docs-index.qmd-d6d880-diff)

`just docs` with no words now builds the site, with `smalldocs render docs`. With words, it runs `smalldocs api`
as before. So the recipe is now a script of several lines.

[± See the change to `justfile`](#step-08.6-justfile-424f0b-diff)

In the `justfile`, the recipe `docs` starts with `#!/usr/bin/env sh`. The line
`if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi` is the case with no words.

```bash
uv run smalldocs render docs
just --show docs
just docs
grep -o 'href="api/wikipedia.html#random_page"' docs/_site/index.html | head -n 1
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. grep searches a file for a piece of text, and `-o` prints only the text that it finds. Here it finds the
link from `random_page` on the front page to its entry in `api/wikipedia.html`. The `|` passes what grep prints to
`head -n 1`, which keeps the first line, so the link prints once. Each build makes the site and the reference pages, and git ignores them.

#### What changed

- <a id="step-08.6-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the site. The sidebar lists the front page, then the reference pages. 17 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/e99ed4f3ab32aec60ae0e2329f4779673a5955d0/docs/_smalldocs.yml).
  - look at `contents: api/*  # the reference pages, which each build makes from the code`
- <a id="step-08.6-docs-index.qmd-d6d880"></a>`docs/index.qmd`: the front page, written by hand. New, 35 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/e99ed4f3ab32aec60ae0e2329f4779673a5955d0/docs/index.qmd).
  - look at `Each build of the site makes the pages under Reference from the code.`
- <a id="step-08.6-justfile-424f0b"></a>`justfile`: with no words, `docs` builds the site. 5 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/e99ed4f3ab32aec60ae0e2329f4779673a5955d0/justfile).
  - look at `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

<a id="step-08.6-docs-_smalldocs.yml-4b0b48-diff"></a>

<details><summary>The diff of <code>docs/_smalldocs.yml</code></summary>

```diff
@@ -1,4 +1,20 @@
-# The settings of smalldocs. `api` is the reference, made from the code of the packages
+# The settings of smalldocs. `just docs` builds the site into docs/_site
+project:
+  type: website
+  output-dir: _site
+
+website:
+  title: "wikiapp"
+  sidebar:
+    contents:
+      - index.qmd
+      - section: Reference
+        contents: api/*  # the reference pages, which each build makes from the code
+
+theme: cosmo
+toc: true
+
+# `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
   packages: [wikiapp]
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
```

</details>

<a id="step-08.6-docs-index.qmd-d6d880-diff"></a>

<details><summary>The diff of <code>docs/index.qmd</code></summary>

````diff
@@ -0,0 +1,35 @@
+---
+title: wikiapp
+---
+
+wikiapp prints the title and the summary of a random Wikipedia page, in any language Wikipedia has.
+
+```
+$ uv run wikiapp
+Waimārama
+Waimārama is a seaside village in Hastings District, Hawke's Bay, New
+Zealand.
+
+$ uv run wikiapp --language fr
+Changement démocratique (Salvador)
+Le Changement démocratique est un parti politique salvadorien fondé en
+2005.
+```
+
+The code has two modules:
+
+- `wikiapp.wikipedia`, the library. `random_page` asks Wikipedia for a random page and returns a
+  `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a language
+  code, if the request fails, or if the answer is not a page. The library knows nothing of the command line.
+- `wikiapp.console`, the app. `main` is the command. It reads `--language`, calls `random_page`, and
+  prints the page, or the error.
+
+Each build of the site makes the pages under Reference from the code. A page takes these parts from
+each function:
+
+- the signature and the types
+- the description, from the docstring
+- the description of each parameter and each field, from its docment, the comment beside it
+- the options of a command, with their help
+
+A name in backticks, such as `random_page`, links to its entry.
````

</details>

<a id="step-08.6-justfile-424f0b-diff"></a>

<details><summary>The diff of <code>justfile</code></summary>

```diff
@@ -75,8 +75,11 @@ check *args:
     just test -q --cov-fail-under=90
     just lint-config
 
-# The reference, from the code: just docs check, just docs module wikipedia. Words go to smalldocs api
+# The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
 [group('docs')]
 [no-exit-message]
 docs *args:
-    {{ if args == "help" { "just help docs" } else { 'uv run smalldocs api "$@" --dir docs' } }}
+    #!/usr/bin/env sh
+    if [ "$*" = help ]; then just help docs; exit 0; fi
+    if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
+    exec uv run smalldocs api "$@" --dir docs
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/e99ed4f3ab32aec60ae0e2329f4779673a5955d0).

This part ends at the code at `e99ed4f3ab32`, partway through `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/e99ed4f3ab32aec60ae0e2329f4779673a5955d0)

<a id="step-08.7"></a>

## 8.7 The README's folders

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `e99ed4f3ab32`, partway through `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/e99ed4f3ab32aec60ae0e2329f4779673a5955d0)

```bash
just setup
```

The README does not name the tests and the docs among the folders. Now it names them.

### 8.7 The README names the tests and the docs

The README is the first page that a reader sees on GitHub. Its table of folders says where each part of the
project is, and it lists neither the tests nor the docs. The table gets rows for `tests/` and `docs/`. The row of
`src/wikiapp/` also says that `wikipedia.py` is the library and `console.py` the command.

[± See the change to `README.md`](#step-08.7-README.md-8ec9a0-diff)

```bash
grep -n -E 'tests/|docs/' README.md
```

`grep` prints the two new rows of the table.

#### What changed

- <a id="step-08.7-README.md-8ec9a0"></a>`README.md`: the folders. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/79c80120fc8fc12ec7b38474294b422e86619362/README.md).
  - look at `| The docs site. smalldocs makes its reference from the code |`

<a id="step-08.7-README.md-8ec9a0-diff"></a>

<details><summary>The diff of <code>README.md</code></summary>

```diff
@@ -30,7 +30,9 @@ Then `just setup`, and `uv run wikiapp`.
 | Path | What it is |
 |---|---|
 | `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
-| `src/wikiapp/` | The code. `console.py` is the `wikiapp` command |
+| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
+| `tests/` | The tests. `just test` runs them |
+| `docs/` | The docs site. smalldocs makes its reference from the code |
 | `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
 | `.python-version` | The Python version the project uses |
 | `.gitignore` | Everything a run makes, ignored from the first commit on |
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/79c80120fc8fc12ec7b38474294b422e86619362).

This part ends at the code at `79c80120fc8f`, partway through `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/79c80120fc8fc12ec7b38474294b422e86619362)

<a id="step-08.8"></a>

## 8.8 The docs check in `just check`

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `79c80120fc8f`, partway through `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/79c80120fc8fc12ec7b38474294b422e86619362)

```bash
just setup
```

A person must remember to run the docs check. Now `just check` runs it, so each `git commit` must pass it.

### 8.8 The docs check in `just check`

Every function, parameter and field has documentation now, but no check fails when a new function has none. `just check` runs before
each `git commit`, through the git hook, so `just docs check` goes in it, after the tests. The comment above
`check` names the docs too.

[± See the change to `justfile`](#step-08.8-justfile-424f0b-diff)

In the `justfile`, `just docs check` is the line under `just test -q --cov-fail-under=90`, in `check`.

```bash
just check
```

The docs check prints `15 of 15`. Now, when a function, a parameter or a field has no documentation, the git hook
fails, and git records no change. GitHub's job `check`, at lines 30 to 37 of `.github/workflows/test.yaml`, runs `just check`, so
it runs the docs check too.

#### What changed

- <a id="step-08.8-justfile-424f0b"></a>`justfile`: the comment, and one line in `check`. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/ce0734f1272cf16f4aadeaa6712e589010ccd69f/justfile).
  - look at `just docs check`

<a id="step-08.8-justfile-424f0b-diff"></a>

<details><summary>The diff of <code>justfile</code></summary>

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, tests over the coverage floor, docs, configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -73,6 +73,7 @@ check *args:
     just lint
     just types
     just test -q --cov-fail-under=90
+    just docs check
     just lint-config
 
 # The docs. Alone, the site in docs/_site; with words, smalldocs api: just docs check
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/ce0734f1272cf16f4aadeaa6712e589010ccd69f).

This part ends at the code at `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-08)

<a id="step-08b.2"></a>

## 8b.2 The docs on GitHub Pages

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `971e9d780fd5`, partway through `step-08b`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/971e9d780fd539d13f49af3fbb00c1145fd22aa0)

```bash
just setup
```

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

### 8b.2 A workflow that publishes the docs

`just docs` builds the docs site on one machine, and nobody else can read it. A second workflow,
`.github/workflows/docs.yaml`, builds the site on GitHub on every push to main, and [GitHub Pages](https://docs.github.com/en/pages) publishes it.

GitHub Pages publishes a website from a repository, free for a public one. A
workflow of [GitHub Actions](https://docs.github.com/en/actions) can build the site and give it to Pages.

The workflow has two jobs. The job `build`, from line 21, installs the package and the group `docs`, and runs
`smalldocs render docs`, the command behind `just docs`. It does not run `just docs`, because that recipe, at
line 85, runs `uv run` with no option, which installs every group. The job then gives the folder
`docs/_site` to Pages. The job `deploy`, from line 32, publishes it.

Lines 11 to 14, under `permissions`, let the workflow publish to Pages. Lines 16 to 18, under `concurrency`, stop
an older publish when a newer push starts one.

The file is new, and comes whole, as a patch.

[± See the new file `.github/workflows/docs.yaml`](#step-08b.2-.github-workflows-docs.yaml-ce7835-diff)

In the new file `.github/workflows/docs.yaml`, the line
`- run: uv run --locked --no-default-groups --group docs smalldocs render docs` is the build of the site.

The workflow runs only where two settings on GitHub allow it. The settings are not in any file of the project. Both
are on GitHub's website, and need no tool on your machine.

- **Actions.** GitHub turns off the workflows of a fork, until its owner turns them on, on the tab **Actions**.
- **Pages.** Under **Settings**, then **Pages**, the source of the site must be **GitHub Actions**.

GitHub then publishes the site at `https://OWNER.github.io/smallwikiapp/`, where OWNER is the name of the account
that owns the fork. The account rahuldave has a domain of its own. So the site of rahuldave/smallwikiapp is at
[rahuldave.com/smallwikiapp](https://rahuldave.com/smallwikiapp/).

In every fork, the links from the reference to the code go to rahuldave/smallwikiapp. Line 20 of
`docs/_smalldocs.yml` names that repository.

```bash
uv run pre-commit run check-yaml --files .github/workflows/docs.yaml
uv run --isolated --locked --no-default-groups --group docs smalldocs render docs
```

The first command runs one check of [`pre-commit`](https://pre-commit.com/), `check-yaml`, on the new file. The file
is valid YAML. The second command builds the site as the job does, with the group `docs` alone, and
prints `wrote 3 page(s) to docs/_site`. git ignores `docs/_site`.

#### What changed

- <a id="step-08b.2-.github-workflows-docs.yaml-ce7835"></a>`.github/workflows/docs.yaml`: the site, built with the group `docs` alone, then published. New, 40 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/39a4b09f85638bbe8424b243c4ba4477070f2740/.github/workflows/docs.yaml).
  - look at `- run: uv run --locked --no-default-groups --group docs smalldocs render docs`

<a id="step-08b.2-.github-workflows-docs.yaml-ce7835-diff"></a>

<details><summary>The diff of <code>.github/workflows/docs.yaml</code></summary>

```diff
@@ -0,0 +1,40 @@
+# The docs site. On every push to main, smalldocs builds the site from the code, and GitHub Pages
+# publishes it at https://OWNER.github.io/smallwikiapp/, with the name of the repository's owner. For
+# rahuldave/smallwikiapp, that is https://rahuldave.com/smallwikiapp/. The job installs the group docs alone.
+name: Docs
+
+on:
+  push:
+    branches: [main]
+  workflow_dispatch:  # a person can also run it from the Actions tab
+
+permissions:
+  contents: read
+  pages: write     # to publish the site
+  id-token: write  # to prove to Pages that this workflow is the one publishing
+
+concurrency:
+  group: pages
+  cancel-in-progress: true  # a newer push replaces a publish that has not finished
+
+jobs:
+  build:
+    runs-on: ubuntu-latest
+    steps:
+      - uses: actions/checkout@v7
+      - uses: astral-sh/setup-uv@v10.2.0
+      - run: uv run --locked --no-default-groups --group docs smalldocs render docs
+      - uses: actions/configure-pages@v6
+      - uses: actions/upload-pages-artifact@v5
+        with:
+          path: docs/_site
+
+  deploy:
+    needs: build
+    runs-on: ubuntu-latest
+    environment:
+      name: github-pages
+      url: ${{ steps.deployment.outputs.page_url }}
+    steps:
+      - id: deployment
+        uses: actions/deploy-pages@v5
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/39a4b09f85638bbe8424b243c4ba4477070f2740).

This part ends at the code at `step-08b`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-08b)

<a id="step-09.10"></a>

## 9.10 The docs check counts the library

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `008e616610b0`, partway through `step-09`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/008e616610b0829196a2f61182e45255015b95c1)

```bash
just setup
```

The code now also has the library as a package of its own, `wikirandom`, in `packages/wikirandom`, with a README of
its own. Its code went there with its docstrings and docments. The app uses it, and `src/wikiapp/wikipedia.py` is
gone. The README and the front page of the docs name both packages. The tests of the library are now
`tests/test_wikirandom.py`.

The settings of smalldocs are in `docs/_smalldocs.yml`. Besides the tests, the check counts only the packages that
this file names, and it names only `wikiapp`. So when
the library's code moved to `wikirandom`, `just docs check` stopped counting it. Before this section, the check
counts only the functions, methods and classes of the app and the tests. After it, the check counts the library's
too. The line for `wikirandom` prints `3 of 3`, and the total is `15 of 15` again.

### 9.10 The docs check counts the library

The settings of the site, `docs/_smalldocs.yml`, name only `wikiapp`, so the docs and their check leave out the
library. The line `packages:` in the section `api` must name both.

[± See the change to `docs/_smalldocs.yml`](#step-09.10-docs-_smalldocs.yml-4b0b48-diff)

In `docs/_smalldocs.yml`, line 19, `packages:` lists `wikiapp` and `wikirandom`.

```bash
just docs check
just docs
grep -o 'href="api/wikirandom.html#random_page"' docs/_site/index.html | head -n 1
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and grep finds the link from `random_page` on the front page to its entry in `api/wikirandom.html`.
`just check` passes.

This tutorial ends here. Later, `just build` builds both packages, and the app needs a 0.1 version of
wikirandom. `just lint-config` checks the library's `pyproject.toml` too, and the library gets a licence and an
author. Both packages get a link to the repository. Each request to Wikipedia carries a name for the program, called
its User-Agent, and that name also gets the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.

#### What changed

- <a id="step-09.10-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the list of packages. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/259e6364a52f83993c797f66148281b04eb92060/docs/_smalldocs.yml).
  - look at `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

<a id="step-09.10-docs-_smalldocs.yml-4b0b48-diff"></a>

<details><summary>The diff of <code>docs/_smalldocs.yml</code></summary>

```diff
@@ -16,6 +16,6 @@ toc: true
 
 # `api` is the reference, made from the code of the packages. A name in backticks links to its entry
 api:
-  packages: [wikiapp]
+  packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom
   source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
   check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/259e6364a52f83993c797f66148281b04eb92060).

This part ends at the code at `step-09`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-09)
