<!-- Made by the walk skill's render.py from the facts of the walk. Do not edit it by hand: run just walk-update again. -->

# just, the interface of smallwikiapp

**Build it yourself.** Every command to run and every change to make by hand, to make the project yourself. [Read the tutorial](read.md) is the other way to read it.

Each part ends with a section called **What changed**. It lists every file that the part changes, with a link to the file, and then the whole diff of each file, folded. A lockfile and a binary file have a link alone. The text above it explains the change. What changed is what you check your files against.

In Build it yourself, a file that a command makes says which command. A diff that is open is a patch. Apply it with the command in the text, or make the same change in your editor.

We give `wikiapp` one interface for every task, a justfile. `wikiapp` is a small command that prints the title and
the summary of a random Wikipedia page. Its project has many tools, each with its own options. A person, a git hook
and GitHub must all run them the same way. This tutorial takes the parts about the justfile out of the whole
tutorial of smallwikiapp. It starts from the project that `uv init` made, for Python 3.13, and has a justfile
from the start.

The justfile is the interface of the project. Each task is a verb, such as `just test`, and the recipe behind the
verb names the tool that does the work. A person, a git hook and GitHub each run `just check`, and `check` runs
other verbs. A tool can change behind a verb, and the callers of the verb stay the same.

Most sections bring in a verb with three commands. First the tool's own command runs, then `just --show VERB` shows
the recipe, and then the verb runs. The sections of `test` and `check` skip the tool's command. Section 1 runs
`just setup` before it shows the recipe.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has seventeen sections:

1. **The project, and its justfile**
2. **`just test`**
3. **`just fmt`**
4. **`just lint`**
5. **`just lint-config`**
6. **A variable for every recipe**
7. **`just check`, everything a `git commit` must pass**
8. **The git hook runs `just check`**
9. **`just types`**
10. **The types join `just check`**
11. **GitHub runs `just check`**
12. **`just docs`**
13. **`just docs` alone builds a site**
14. **The docs check joins `just check`**
15. **The library, behind the same verbs**
16. **`just build`**
17. **`just lint-config` checks the library too**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**What `just check` runs**

`just check` runs every check that a `git commit` must pass, and ends at the first check that fails. The table gives each section that changes what it runs.

| Section | What changes | Where the change is |
|---|---|---|
| 7 | `check` comes in, with the format, the linter, the tests over a floor on the coverage, and the configuration | The justfile |
| 10 | The type checker | The justfile |
| 14 | The docs check | The justfile |
| 15 | The docs check counts the library | `docs/_smalldocs.yml` |
| 17 | The check of the configuration reads the library's `pyproject.toml` | The recipe `lint-config` |

Some changes that this tutorial leaves out change what `just check` runs too. They change `pyproject.toml`, not
the justfile. Before section 10, the rules `ANN` come into the linter. Before section 11, the end-to-end tests come in. They ask the
real Wikipedia, and pytest leaves them out of each run that does not ask for them, `just check` included. Before section 15, the floor on the coverage counts both
packages.

**Who runs `just check`**

Three callers run `just check`, and none of them changes when `check` changes.

| Caller | From | When it runs |
|---|---|---|
| A person, in the terminal | Section 7 | When the person remembers |
| The git hook | Section 8 | Before each `git commit`, in a clone where `just hook` ran |
| GitHub's job `check` | Section 11 | On every push to main and every pull request |

**The verbs, and what is behind each**

The table gives each verb of the last justfile, and the commands that its recipe runs.

| Verb | What its recipe runs | Section |
|---|---|---|
| `help` | `just --show VERB`, or `just --list --unsorted` | 1 |
| `setup` | `uv sync --locked` | 1 |
| `test` | `uv run pytest` | 2 |
| `fmt` | `uv run ruff format` | 3 |
| `lint` | `uv run ruff check` | 4 |
| `lint-config` | `uv run validate-pyproject`, `uv lock --check` and `just --fmt --check --unstable` | 5 and 17 |
| `check` | `just fmt --check`, `just lint`, `just types`, `just test -q --cov-fail-under=90`, `just docs check` and `just lint-config` | 7, 10 and 14 |
| `hook` | `uv run pre-commit install` | 8 |
| `types` | `uv run ty check` | 9 |
| `docs` | `uv run smalldocs render docs` alone, and `uv run smalldocs api` with words | 12 and 13 |
| `build` | `uv build --all-packages` | 16 |

## Get the project

You build the project in a clone of your own, on a branch `mine` that starts where this walk starts. Run the commands of these pages in its top folder.

```bash
git clone https://github.com/rahuldave/smallwikiapp
cd smallwikiapp
git switch -c mine ae86cb7d116c
```

Then add the command `git check`, which compares your files with the project's after each move. It compares `pyproject.toml` by the names of its packages, so another version of a package does not count as a difference. It does not compare the lines of `uv.lock`. It checks that you and the project both have a `uv.lock`, or both have none. It also checks that your `uv.lock` is up to date with your `pyproject.toml`.

```bash
echo '/pyproject.toml diff=names' >> .git/info/attributes
git config diff.names.textconv "sed -E 's/^([[:space:]]*\"[A-Za-z0-9_.-]+(\\[[^]]*\\])?)[^\";]*/\\1/'"
git config alias.check '!f() { i="$(git rev-parse --git-path check-index)" && { cp "$(git rev-parse --git-path index)" "$i" 2>/dev/null || rm -f "$i"; } && export GIT_INDEX_FILE="$i" && git add -A && git diff --cached "$1" -- ":/" ":(top,exclude,glob)uv.lock" && git diff --cached --name-status --diff-filter=AD "$1" -- ":(top,glob)uv.lock" && { [ "$2" = --stale-lock ] || [ ! -f uv.lock ] || uv lock --check -q; }; }; f'
```

<a id="step-00"></a>

## 0 The project, and its justfile

The project has a justfile from the start, so the first task already has a verb. This section shows what
`uv init` made, the command `wikiapp`, and the first justfile. The justfile has three recipes. `default` lists the
verbs, `help` explains one, and `setup` installs the project.

```bash
just setup
```

A project needs a name, a Python and a command before it has code to run. It also needs to install the same way
on every machine. `uv init --package --python 3.13 --name wikiapp` made `pyproject.toml`, a package in
`src/wikiapp/`, and `.python-version`.

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

The justfile is the interface of the project. Every task is a recipe in it. `just` lists the tasks, and
`just --show setup` shows the recipe behind one task. `just help setup` shows the same recipe. Later sections add
recipes to the justfile.

```bash
just
just --show setup
just --show help
just help setup
```

**The parts of a justfile**

A justfile has settings, variables and recipes. `set positional-arguments` is a setting. It gives the words after
a verb to the shell of the recipe, as `$1`, `$2` and `"$@"`. The first variable comes in section 6.

A recipe has up to four parts, from the top.

- **A comment.** `just --list` prints it beside the name of the recipe, and `just help VERB` prints it too.
- **Attributes,** in square brackets. `[group('setup')]` puts the recipe under the heading `[setup]` in the list.
  `[private]` leaves `default` out of the list.
- **The name and the parameters.** In `setup *args:`, the star lets `args` take any number of words, or none.
- **The body,** indented under the name. The body of `setup` is one line. The body of `help` is a script, which
  section 5 explains.

`just` with no verb runs the first recipe of the file. Here that is `default`, which lists the others.

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

<details><summary>The diff of <code>.python-version</code></summary>

```diff
@@ -0,0 +1 @@
+3.13
```

</details>

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

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -0,0 +1,4 @@
+
+def main() -> None:
+    """Print a line, until there is a page to print."""
+    print("Hello from wikiapp!")
```

</details>

[The code](https://github.com/rahuldave/smallwikiapp/tree/ae86cb7d116c4103832edf25ab3a7a9077583830).

<a id="step-02.4"></a>

## 2.4 `just test`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source ae86cb7d116c --staged -- :/ && git restore --source d92e2dec921d --staged --worktree -- :/
```

```bash
just setup
```

The command now asks Wikipedia for a random page, and prints its title and summary, with click and requests. It
sends a User-Agent, and has an option `--version`. `default-groups = "all"` in `pyproject.toml` makes uv install
every dependency group. pytest is in a dependency group `test`, with the first test.
`uv run pytest` printed `1 passed`.

A person who runs the tests must know the tool and its options. `just test` is the first verb after `setup`, and
the first that runs a check.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/d92e2dec921d6322e2a356af20dafef3837c1849). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/45807a0ddd9f97798c3f86a82b19782d4df45837).

<a id="step-02.4"></a>

### 2.4 The recipe `just test`

The command that runs the tests is `uv run pytest`, with any options for pytest after it. A recipe `test` in the
justfile gives it a short name, `just test`. The words after `just test` go to pytest. `"$@"` stands for those
words, and the recipe gives each word to pytest whole. `just test help` shows the recipe.

Apply the patch to [`justfile`](#step-02.4-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/45807a0ddd9f97798c3f86a82b19782d4df45837.diff | git apply --include=justfile
```

The patch adds the recipe `test` at the end of the `justfile`, under the recipe `setup`, with a comment above it.

`just` prints each line of a recipe before it runs the line, if the line does not start with `@`. So `just test`
prints `uv run pytest "$@"`, the command that it ran.

```bash
just --show test
just test
```

`just --show test` prints the comment and the recipe. `just test` prints `uv run pytest "$@"`, and then the same
result as before, `1 passed`.

The body of `test` is one line, `{{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}`.
`just` works out the part between `{{` and `}}` before a shell sees the line. If the only word after the verb is
`help`, the line is `just help test`. Otherwise it is `uv run pytest "$@"`.

Each later recipe of one line has this form. The longer recipes test the word in the shell, from section 5. So
`just VERB help` explains each verb.

`[no-exit-message]` changes what a failed test prints. Without it, `just` adds a line of its own, which begins
"error: Recipe `test` failed". With it, the report of pytest is the last thing that the recipe prints.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 45807a0ddd9f
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source d92e2dec921d --staged -- :/ && git restore --source 45807a0ddd9f --staged --worktree -- :/
```

#### What changed

- <a id="step-02.4-justfile-424f0b"></a>`justfile`: the recipe `test`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/45807a0ddd9f97798c3f86a82b19782d4df45837/justfile).
  - look at `test *args:`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -19,3 +19,9 @@ help *verb:
 [group('setup')]
 setup *args:
     @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
+
+# Run the tests. Extra arguments go to pytest: just test -k title
+[group('quality')]
+[no-exit-message]
+test *args:
+    {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/45807a0ddd9f97798c3f86a82b19782d4df45837). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/45807a0ddd9f97798c3f86a82b19782d4df45837).

<a id="step-04.1-to-step-04.2"></a>

## 4.1 to 4.2 `just fmt`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 45807a0ddd9f --staged -- :/ && git restore --source b6942869d5fc --staged --worktree -- :/
```

```bash
just setup
```

The code now also has tests with a mock in place of Wikipedia, and every run measures the coverage. The code is
split into a library, `src/wikiapp/wikipedia.py`, and the command. The command has an option `--language`. The
library raises its own error, `WikipediaError`, and the command turns it into a message.

The code mixes styles. ruff comes in, and `just fmt` formats the code and the tests.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/b6942869d5fcfffff81beb598630288fe3a67372). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/31445743379186b800fd4c035c8f04eed7ad7f3d).

<a id="step-04.1"></a>

### 4.1 ruff, in the group lint

The code has no one style, so a later change can mix a fix with a change of blank lines and quotes. A formatter
changes how the code looks, and never what it does. A linter finds problems in the code, such as a variable that
is never used, and changes nothing unless it is asked to. ruff is both, in one program. It goes in a second group
of dependencies, `lint`, next to the group `test`.

```bash
uv add --group lint ruff
```

```bash
uv run ruff --version
```

It prints `ruff 0.17.0`. uv installs every group, so ruff is in the environment of the project, and nothing has
used it yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 8f7b800001ee
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source b6942869d5fc --staged -- :/ && git restore --source 8f7b800001ee --staged --worktree -- :/
```

#### What changed

- <a id="step-04.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group `lint`, with ruff in it. 3 lines added. It comes from `uv add --group lint ruff`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8f7b800001ee35d8db80c47521b02777047c019d/pyproject.toml).
  - look at `"ruff>=0.17.0",`
- <a id="step-04.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of ruff. 29 lines added. It comes from `uv add --group lint ruff`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8f7b800001ee35d8db80c47521b02777047c019d/uv.lock).

<details><summary>The diff that <code>uv add --group lint ruff</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -24,6 +24,9 @@ build-backend = "uv_build"
 default-groups = "all"
 
 [dependency-groups]
+lint = [
+    "ruff>=0.17.0",
+]
 test = [
     "pytest>=9.1.1",
     "pytest-cov>=7.1.0",
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/8f7b800001ee35d8db80c47521b02777047c019d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/8f7b800001ee35d8db80c47521b02777047c019d).

<a id="step-04.2"></a>

### 4.2 The settings of ruff, and the recipe fmt

ruff needs its settings, at the end of `pyproject.toml`. They allow lines of up to 100 characters, and write out
the defaults of the formatter, so that a reader sees them. A recipe `fmt` runs the formatter. The words after
`just fmt` go to `ruff format`.

Apply the patch to [`pyproject.toml`](#step-04.2-pyproject.toml-5d07e7), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/31445743379186b800fd4c035c8f04eed7ad7f3d.diff | git apply --include=pyproject.toml
```

Apply the patch to [`justfile`](#step-04.2-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/31445743379186b800fd4c035c8f04eed7ad7f3d.diff | git apply --include=justfile
```

In `pyproject.toml`, the patch adds the tables `[tool.ruff]` and `[tool.ruff.format]` at the end. In the
`justfile`, it adds the recipe `fmt` at the end.

```bash
uv run ruff format --check
just --show fmt
just fmt --check
```

`--check` changes nothing. It shows what it would change in each file, and fails. It ends with `6 files would be
reformatted, 1 file already formatted`. The six files that it names are the Python files. The seventh is
`pyproject.toml`, which ruff also reads. The recipe
runs the same command, and passes on the words after `just fmt`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 314457433791
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 8f7b800001ee --staged -- :/ && git restore --source 314457433791 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.2-justfile-424f0b"></a>`justfile`: the recipe `fmt`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/31445743379186b800fd4c035c8f04eed7ad7f3d/justfile).
  - look at `fmt *args:`
- <a id="step-04.2-pyproject.toml-5d07e7"></a>`pyproject.toml`: the settings of ruff. 11 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/31445743379186b800fd4c035c8f04eed7ad7f3d/pyproject.toml).
  - look at `line-length = 100`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -25,3 +25,9 @@ setup *args:
 [no-exit-message]
 test *args:
     {{ if args == "help" { "just help test" } else { 'uv run pytest "$@"' } }}
+
+# Format the code, one way. Extra arguments go to ruff: just fmt --check, just fmt --diff
+[group('quality')]
+[no-exit-message]
+fmt *args:
+    {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
```

</details>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -37,3 +37,14 @@ test = [
 testpaths = ["tests"]
 # Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
 addopts = "--cov=wikiapp --cov-report=term-missing"
+
+[tool.ruff]
+# The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
+# better at 100.
+line-length = 100
+
+[tool.ruff.format]
+# The formatter has no style to argue about. These are ruff's defaults, written out so they are visible.
+quote-style = "double"            # "text", not 'text'
+indent-style = "space"            # four spaces, never tabs
+skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/31445743379186b800fd4c035c8f04eed7ad7f3d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/31445743379186b800fd4c035c8f04eed7ad7f3d).

<a id="step-04.4"></a>

## 4.4 `just lint`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 314457433791 --staged -- :/ && git restore --source 6690eee9f7e1 --staged --worktree -- :/
```

```bash
just setup
```

The code is now formatted, by `just fmt`.

A formatter changes how the code looks, and finds no mistakes. The rules of the linter go in `pyproject.toml`, and
`just lint` runs the linter.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/6690eee9f7e177a6df2ea5e1821b8f581948bc85). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/589f2f691557470eac084858d430a302c98390ce).

<a id="step-04.4"></a>

### 4.4 The linter's rules, and the recipe lint

The linter checks the code against rules, and it needs to know which. A table at the end of `pyproject.toml`
chooses the families of rules. Each family is on a line of its own, with a comment that says why it is on. The
tests may use `assert`. The rest of the code may not, because Python skips every `assert` when it runs with `-O`.

A recipe `lint` runs the linter. The words after `just lint` go to `ruff check`.

Apply the patch to [`pyproject.toml`](#step-04.4-pyproject.toml-5d07e7), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/589f2f691557470eac084858d430a302c98390ce.diff | git apply --include=pyproject.toml
```

Apply the patch to [`justfile`](#step-04.4-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/589f2f691557470eac084858d430a302c98390ce.diff | git apply --include=justfile
```

In `pyproject.toml`, the patch adds the tables `[tool.ruff.lint]` and `[tool.ruff.lint.per-file-ignores]` at the
end. Read the comment beside each family of rules. In the `justfile`, it adds the recipe `lint` at the end.

```bash
uv run ruff check --statistics
just --show lint
just lint --statistics
```

The linter finds five problems, and fails. Each problem has its code.

- `I001`: the imports of `src/wikiapp/console.py` are out of order.
- `E402`: an import in `tests/test_console.py` comes below code.
- `F841`, twice: a variable is assigned and never used.
- `S113`: a request has no timeout.

Without `--statistics`, `just lint` prints each problem with its lines. `uv run ruff rule S113` explains a code.

A `[*]` marks the one problem that ruff can fix by itself, `I001`. ruff also has a fix for the two unused variables, and marks it unsafe,
because it may delete a comment on the line. It has no fix for the other two problems. So a person fixes those four
in the next two moves, and then ruff fixes the last one.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 589f2f691557
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 6690eee9f7e1 --staged -- :/ && git restore --source 589f2f691557 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.4-justfile-424f0b"></a>`justfile`: the recipe `lint`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/589f2f691557470eac084858d430a302c98390ce/justfile).
  - look at `lint *args:`
- <a id="step-04.4-pyproject.toml-5d07e7"></a>`pyproject.toml`: a family of rules on each line. 18 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/589f2f691557470eac084858d430a302c98390ce/pyproject.toml).
  - look at `"tests/**" = ["S101"]`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -31,3 +31,9 @@ test *args:
 [no-exit-message]
 fmt *args:
     {{ if args == "help" { "just help fmt" } else { 'uv run ruff format "$@"' } }}
+
+# Check the code against the rules in pyproject.toml. Extra arguments go to ruff: just lint --fix
+[group('quality')]
+[no-exit-message]
+lint *args:
+    {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
```

</details>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -48,3 +48,21 @@ line-length = 100
 quote-style = "double"            # "text", not 'text'
 indent-style = "space"            # four spaces, never tabs
 skip-magic-trailing-comma = false # a trailing comma means "keep this one item per line"
+
+[tool.ruff.lint]
+# What the linter checks: a family of rules on each line, and why it is on
+select = [
+    "E",   # pycodestyle errors: the basics, from indentation to line length
+    "W",   # pycodestyle warnings: stray whitespace and the like
+    "F",   # pyflakes: names that are unused, undefined or redefined
+    "I",   # isort: imports in one order, standard library first
+    "B",   # bugbear: constructs that are likely bugs, such as a mutable default argument
+    "UP",  # pyupgrade: older syntax that this Python has a newer form for
+    "SIM", # simplify: code that can be said in fewer words
+    "S",   # bandit: security, from `assert` in production code to a request with no timeout
+    "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
+]
+
+[tool.ruff.lint.per-file-ignores]
+# A test is written with assert
+"tests/**" = ["S101"]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/589f2f691557470eac084858d430a302c98390ce). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/589f2f691557470eac084858d430a302c98390ce).

<a id="step-04.8-to-step-04.9"></a>

## 4.8 to 4.9 `just lint-config`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 589f2f691557 --staged -- :/ && git restore --source a57134d1cef6 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has the fixes of the linter's five problems. `just lint --fix` sorted the imports, since the
words after `lint` go to ruff. A person fixed the other four problems.

Nothing checks the files that set up the project. `just lint-config` checks the configuration. Its recipe is a
small shell script, which runs three commands and ends at the first that fails.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/a57134d1cef6ff24803235ace966e5870046fbd9). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d8a9c8f71eb58893025360c20b32c9078e5b0c3c).

<a id="step-04.8"></a>

### 4.8 validate-pyproject, in the group lint

The tests and the linter check the code, and not the configuration. So an error in `pyproject.toml`, in the
lockfile or in the `justfile` passes them all. validate-pyproject checks `pyproject.toml` against the standard for
it. It goes in the group `lint`.

```bash
uv add --group lint validate-pyproject
```

```bash
uv run validate-pyproject --version
```

It prints `validate_pyproject 0.26`. Nothing runs it yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 4e710d50a229
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source a57134d1cef6 --staged -- :/ && git restore --source 4e710d50a229 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.8-pyproject.toml-5d07e7"></a>`pyproject.toml`: one package more in `lint`. 1 line added. It comes from `uv add --group lint validate-pyproject`. [The file](https://github.com/rahuldave/smallwikiapp/blob/4e710d50a22967ebff9502eacbdada54313ebe70/pyproject.toml).
  - look at `"validate-pyproject>=0.26",`
- <a id="step-04.8-uv.lock-8356d8"></a>`uv.lock`: the exact version of validate-pyproject, and of what it needs. 26 lines added, 1 removed. It comes from `uv add --group lint validate-pyproject`. [The file](https://github.com/rahuldave/smallwikiapp/blob/4e710d50a22967ebff9502eacbdada54313ebe70/uv.lock).

<details><summary>The diff that <code>uv add --group lint validate-pyproject</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -26,6 +26,7 @@ default-groups = "all"
 [dependency-groups]
 lint = [
     "ruff>=0.17.0",
+    "validate-pyproject>=0.26",
 ]
 test = [
     "pytest>=9.1.1",
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/4e710d50a22967ebff9502eacbdada54313ebe70). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/4e710d50a22967ebff9502eacbdada54313ebe70).

<a id="step-04.9"></a>

### 4.9 The recipe lint-config

A recipe `lint-config` checks the configuration, with three commands. validate-pyproject checks
`pyproject.toml`. `uv lock --check` checks that the lockfile matches `pyproject.toml`. `just --fmt --check
--unstable` checks the `justfile`. The recipe runs the three commands, one on each line, and `set -e` stops it at
the first that fails.

Apply the patch to [`justfile`](#step-04.9-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/d8a9c8f71eb58893025360c20b32c9078e5b0c3c.diff | git apply --include=justfile
```

The patch adds the recipe `lint-config` at the end of the `justfile`.

```bash
uv run validate-pyproject pyproject.toml
uv lock --check
just --fmt --check --unstable
just --show lint-config
just lint-config
```

The three checks pass. validate-pyproject prints `Valid file: pyproject.toml`. `uv lock --check` prints
`Resolved 19 packages` and exits with 0, because the lockfile matches `pyproject.toml`. `just --fmt` prints
nothing, because the `justfile` is in the format of `just`.

A recipe has one of two kinds of body. Each line of a plain body runs in a shell of its own, and the recipe ends
at the first line that fails. A body whose first line is `#!/usr/bin/env sh` is a script, and one shell runs all of
it. `help`, from section 1, is a script too. A script without `set -e` goes on after a command fails. In
`lint-config`, `set -e` is the line after `#!/usr/bin/env sh`.

In a script, the test of the word `help` is a line of shell, `[ "$*" = help ]`. It does the same as the `{{ if }}`
of section 2, since `"$*"` is the words after the verb, joined by spaces.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check d8a9c8f71eb5
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 4e710d50a229 --staged -- :/ && git restore --source d8a9c8f71eb5 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.9-justfile-424f0b"></a>`justfile`: the recipe, with its three checks. 11 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/d8a9c8f71eb58893025360c20b32c9078e5b0c3c/justfile).
  - look at `uv run validate-pyproject pyproject.toml`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -37,3 +37,14 @@ fmt *args:
 [no-exit-message]
 lint *args:
     {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
+
+# Check the configuration: pyproject.toml, the lockfile, and this justfile
+[group('quality')]
+[no-exit-message]
+lint-config *args:
+    #!/usr/bin/env sh
+    set -e
+    if [ "$*" = help ]; then just help lint-config; exit 0; fi
+    uv run validate-pyproject pyproject.toml
+    uv lock --check
+    just --fmt --check --unstable
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/d8a9c8f71eb58893025360c20b32c9078e5b0c3c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d8a9c8f71eb58893025360c20b32c9078e5b0c3c).

<a id="step-04.10"></a>

## 4.10 A variable for every recipe

```bash
just setup
```

A recipe that runs `uv` can change the lockfile, and prints no warning. This section changes no recipe. It
changes how each recipe that runs `uv` runs it.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/d8a9c8f71eb58893025360c20b32c9078e5b0c3c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/b7469ee81a824a46e6799d60957ea09d7cf2eade).

<a id="step-04.10"></a>

### 4.10 Recipes refuse an old lockfile

When `pyproject.toml` changes and the lockfile does not, `uv run` writes a new lockfile and prints no warning. So
any recipe can change the lockfile, and the person who runs it does not see the change. The variable `UV_LOCKED`
makes every `uv run` refuse a lockfile that is out of date. The `justfile` exports it to every recipe.

Apply the patch to [`justfile`](#step-04.10-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/b7469ee81a824a46e6799d60957ea09d7cf2eade.diff | git apply --include=justfile
```

In the `justfile`, the patch adds `export UV_LOCKED := "1"` under the line `set positional-arguments`, after a
blank line.

```bash
just --evaluate UV_LOCKED
```

It prints `1`. `just` puts the variable in the environment of every command of every recipe, so each `uv run`
sees it.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check b7469ee81a82
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source d8a9c8f71eb5 --staged -- :/ && git restore --source b7469ee81a82 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.10-justfile-424f0b"></a>`justfile`: one line, which exports `UV_LOCKED` to every recipe. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/b7469ee81a824a46e6799d60957ea09d7cf2eade/justfile).
  - look at `export UV_LOCKED := "1"`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -3,6 +3,8 @@
 # Each word after a recipe's name reaches its commands whole, as "$1", "$2" and so on; "$@" is all of them
 set positional-arguments
 
+export UV_LOCKED := "1"
+
 [private]
 default:
     @just --list --unsorted
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/b7469ee81a824a46e6799d60957ea09d7cf2eade). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/b7469ee81a824a46e6799d60957ea09d7cf2eade).

<a id="step-04.11"></a>

## 4.11 `just check`, everything a `git commit` must pass

```bash
just setup
```

A person must remember four verbs before each `git commit`. `just check` runs those four verbs, one after the
other. It names no tool of its own.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/b7469ee81a824a46e6799d60957ea09d7cf2eade). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543).

<a id="step-04.11"></a>

### 4.11 The recipe check

There are now four checks, and a person must remember to run each. A recipe `check` runs them all in order, and
stops at the first that fails. The order is the format, the linter, the tests with a floor on the coverage, and
the configuration.

Apply the patch to [`justfile`](#step-04.11-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543.diff | git apply --include=justfile
```

The patch adds the recipe `check` at the end of the `justfile`.

```bash
just --show check
just check
```

`just check` passes. The tests must run at least 90% of the statements, and the coverage is 96.77%.

```bash
just
```

`just` lists `help` first, then the other verbs in their groups, each with its comment. `check` is under
`[quality]`, after the four verbs that it runs.

From here on, "each `git commit` must pass `just check`" is the rule of the project. The next section and section
11 add two callers, which run it by themselves. Each later check joins `check`, so each caller runs it too.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 1f73d6af30cc
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source b7469ee81a82 --staged -- :/ && git restore --source 1f73d6af30cc --staged --worktree -- :/
```

#### What changed

- <a id="step-04.11-justfile-424f0b"></a>`justfile`: the recipe, with its four checks. 12 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543/justfile).
  - look at `just test -q --cov-fail-under=90`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -50,3 +50,15 @@ lint-config *args:
     uv run validate-pyproject pyproject.toml
     uv lock --check
     just --fmt --check --unstable
+
+# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
+[group('quality')]
+[no-exit-message]
+check *args:
+    #!/usr/bin/env sh
+    set -e
+    if [ "$*" = help ]; then just help check; exit 0; fi
+    just fmt --check
+    just lint
+    just test -q --cov-fail-under=90
+    just lint-config
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543).

<a id="step-04.12-to-step-04.13"></a>

## 4.12 to 4.13 The git hook runs `just check`

```bash
just setup
```

A person can forget to run `just check`. `pre-commit` installs a git hook, which is one more caller of
`just check`. The hook also checks YAML files, large files and leftover marks of a merge. But its only check of
the Python code is `just check`.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/6860da13f0fdf9595f32390f2fa70fe0976159b1).

<a id="step-04.12"></a>

### 4.12 `pre-commit`, in the group lint

`just check` runs every check, but a person must remember to run it. A `pre-commit` hook is a program that git runs
before it records a change. If the program fails, git does not record the change. `pre-commit` installs such a hook, and
runs the checks that the file `.pre-commit-config.yaml` names. It goes in the group `lint`.

```bash
uv add --group lint pre-commit
```

```bash
uv run pre-commit --version
```

It prints `pre-commit 4.7.0`. No hook is installed yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 29291b3575f2
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 1f73d6af30cc --staged -- :/ && git restore --source 29291b3575f2 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.12-pyproject.toml-5d07e7"></a>`pyproject.toml`: `pre-commit` in the group `lint`. 1 line added. It comes from `uv add --group lint pre-commit`. [The file](https://github.com/rahuldave/smallwikiapp/blob/29291b3575f2efd8f6062e3d04bbea648ae1fc11/pyproject.toml).
  - look at `"pre-commit>=4.7.0",`
- <a id="step-04.12-uv.lock-8356d8"></a>`uv.lock`: the exact version of `pre-commit`, and of what it needs. 136 lines added. It comes from `uv add --group lint pre-commit`. [The file](https://github.com/rahuldave/smallwikiapp/blob/29291b3575f2efd8f6062e3d04bbea648ae1fc11/uv.lock).

<details><summary>The diff that <code>uv add --group lint pre-commit</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -25,6 +25,7 @@ default-groups = "all"
 
 [dependency-groups]
 lint = [
+    "pre-commit>=4.7.0",
     "ruff>=0.17.0",
     "validate-pyproject>=0.26",
 ]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/29291b3575f2efd8f6062e3d04bbea648ae1fc11). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/29291b3575f2efd8f6062e3d04bbea648ae1fc11).

<a id="step-04.13"></a>

### 4.13 A git hook

`pre-commit` reads the hooks from a file, `.pre-commit-config.yaml`. Three come from `pre-commit`'s collection.
They check for valid YAML, large files and leftover merge-conflict markers. The last hook runs `just check`, so the
hook and the terminal run the same thing.

A recipe `hook` installs the hook, once in each clone. `hook` is a recipe of its own, because `just setup` runs
often and must not change files under `.git`. Once `just hook` installs the hook in a clone, it runs
`just check` before each `git commit` in that clone.

Apply the patch to [`.pre-commit-config.yaml`](#step-04.13-.pre-commit-config.yaml-e7d14d), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/6860da13f0fdf9595f32390f2fa70fe0976159b1.diff | git apply --include=.pre-commit-config.yaml
```

Apply the patch to [`justfile`](#step-04.13-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/6860da13f0fdf9595f32390f2fa70fe0976159b1.diff | git apply --include=justfile
```

The patch makes the file `.pre-commit-config.yaml`. Read the hook under `repo: local`, which runs `just check`. In
the `justfile`, the patch adds the recipe `hook` after the recipe `setup`.

```bash
uv run pre-commit install
just --show hook
just hook
uv run pre-commit run --files .pre-commit-config.yaml
```

`uv run pre-commit install` prints `pre-commit installed at .git/hooks/pre-commit`, and `just hook` prints the
same line. The hook is in `.git/hooks`, a folder that git does not track, so it stays installed for the rest of
the tutorial.

`pre-commit run` now runs every hook on the file named, as git does before it records a change. The first time on
a machine, it prints `[INFO]` lines while it downloads the hooks. Then it prints four lines, each `Passed`.

With `--all-files`, `pre-commit` would check every file that git tracks. It would skip a new file until git tracks
it.

The hook makes sure that `just check` runs on this machine before each `git commit`. It has limits.

- **It is in one clone only.** git does not copy `.git/hooks` with the repository. A clone has the hook only after
  `just hook` runs in it, and `git commit --no-verify` skips the hook.
- **It needs the clone's `.venv`.** `pre-commit install` writes the path of `.venv/bin/python3` into the
  hook, as an absolute path. If `.venv` is gone and no other `pre-commit` is on the PATH, every `git commit`
  fails. The hook prints that `pre-commit` was not found, and asks whether the virtualenv is active.
  `just setup` makes `.venv` again.
- **It runs tools of the machine.** The line `language: system` tells `pre-commit` to run `just check` as it is,
  with the `just` and the `uv` that the machine has.

So the hook runs `just check` on one machine only. In section 11, GitHub runs `just check` too, on
its own machines, for every push to main and every pull request.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 6860da13f0fd
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 29291b3575f2 --staged -- :/ && git restore --source 6860da13f0fd --staged --worktree -- :/
```

#### What changed

- <a id="step-04.13-.pre-commit-config.yaml-e7d14d"></a>`.pre-commit-config.yaml`: three hooks from `pre-commit`'s collection, then `just check`. New, 20 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/6860da13f0fdf9595f32390f2fa70fe0976159b1/.pre-commit-config.yaml).
  - look at `entry: just check`
- <a id="step-04.13-justfile-424f0b"></a>`justfile`: the recipe `hook`. 5 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/6860da13f0fdf9595f32390f2fa70fe0976159b1/justfile).
  - look at `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`

<details open><summary>The patch to <code>.pre-commit-config.yaml</code></summary>

```diff
@@ -0,0 +1,20 @@
+# What every commit must pass. `just hook` installs it as a git hook.
+#
+# The project's own checks are one hook that runs `just check`, so the hook and the terminal run the
+# same thing. The hooks before it guard against files that should never be committed.
+repos:
+  - repo: https://github.com/pre-commit/pre-commit-hooks
+    rev: v6.0.0
+    hooks:
+      - id: check-yaml
+      - id: check-added-large-files
+        args: [--maxkb=1000]
+      - id: check-merge-conflict
+  - repo: local
+    hooks:
+      - id: check
+        name: just check
+        entry: just check
+        language: system
+        pass_filenames: false
+        always_run: true
```

</details>

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -22,6 +22,11 @@ help *verb:
 setup *args:
     @{{ if args == "help" { "just help setup" } else { "uv sync --locked" } }}
 
+# Install the git hook: just check before every commit. Once per clone; just setup never touches git
+[group('setup')]
+hook *args:
+    @{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}
+
 # Run the tests. Extra arguments go to pytest: just test -k title
 [group('quality')]
 [no-exit-message]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6860da13f0fdf9595f32390f2fa70fe0976159b1). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/6860da13f0fdf9595f32390f2fa70fe0976159b1).

<a id="step-05.1-to-step-05.2"></a>

## 5.1 to 5.2 `just types`

```bash
just setup
```

The linter does not check types. The next verb runs a type checker, and `check` does not run it yet.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/6860da13f0fdf9595f32390f2fa70fe0976159b1). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/2a5904d01d950678e8364d7f6958dccaf5b69368).

<a id="step-05.1"></a>

### 5.1 ty, in the group lint

Nothing checks the types of the code yet. ty is a type checker. It reads the code without running it, and finds
calls whose arguments cannot have the types that the function asks for.
`uv add` puts ty in the group `lint`, with the other tools that check the code.

```bash
uv add --group lint ty
```

```bash
uv run ty --version
```

It prints `ty 0.0.87 (ea4c3d273 2026-10-13)`, or a newer version. Nothing runs it yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 56a11f0bb31a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 6860da13f0fd --staged -- :/ && git restore --source 56a11f0bb31a --staged --worktree -- :/
```

#### What changed

- <a id="step-05.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: ty in the group `lint`. 1 line added. It comes from `uv add --group lint ty`. [The file](https://github.com/rahuldave/smallwikiapp/blob/56a11f0bb31a607e6c5ff37454c7915f2eddd86d/pyproject.toml).
  - look at `"ty>=0.0.87",`
- <a id="step-05.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of ty. 27 lines added. It comes from `uv add --group lint ty`. [The file](https://github.com/rahuldave/smallwikiapp/blob/56a11f0bb31a607e6c5ff37454c7915f2eddd86d/uv.lock).

<details><summary>The diff that <code>uv add --group lint ty</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -27,6 +27,7 @@ default-groups = "all"
 lint = [
     "pre-commit>=4.7.0",
     "ruff>=0.17.0",
+    "ty>=0.0.87",
     "validate-pyproject>=0.26",
 ]
 test = [
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/56a11f0bb31a607e6c5ff37454c7915f2eddd86d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/56a11f0bb31a607e6c5ff37454c7915f2eddd86d).

<a id="step-05.2"></a>

### 5.2 The recipe types

A recipe `types` runs ty, as every other tool of the project runs through `just`. It goes after the recipe `lint`
in the `justfile`.

Apply the patch to [`justfile`](#step-05.2-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/2a5904d01d950678e8364d7f6958dccaf5b69368.diff | git apply --include=justfile
```

The patch puts the recipe `types` after the recipe `lint` and the blank line under it. Read its comment, which
`just` lists for the recipe.

```bash
uv run ty check
just --show types
just types
```

ty finds one problem, in `src/wikiapp/__init__.py`, and ends with `Found 1 diagnostic`. The message is
``Expected `str`, found `str | None` ``. As far as ty can tell, `__name__ or __package__` could be None. But
`importlib.metadata.version` needs a string.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 2a5904d01d95
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 56a11f0bb31a --staged -- :/ && git restore --source 2a5904d01d95 --staged --worktree -- :/
```

#### What changed

- <a id="step-05.2-justfile-424f0b"></a>`justfile`: the recipe. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/2a5904d01d950678e8364d7f6958dccaf5b69368/justfile).
  - look at `types *args:`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -45,6 +45,12 @@ fmt *args:
 lint *args:
     {{ if args == "help" { "just help lint" } else { 'uv run ruff check "$@"' } }}
 
+# Check the types of every function call, with ty. Extra arguments go to ty: just types --help
+[group('quality')]
+[no-exit-message]
+types *args:
+    {{ if args == "help" { "just help types" } else { 'uv run ty check "$@"' } }}
+
 # Check the configuration: pyproject.toml, the lockfile, and this justfile
 [group('quality')]
 [no-exit-message]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/2a5904d01d950678e8364d7f6958dccaf5b69368). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/2a5904d01d950678e8364d7f6958dccaf5b69368).

<a id="step-05.7"></a>

## 5.7 The types join `just check`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 2a5904d01d95 --staged -- :/ && git restore --source 5873353449ad --staged --worktree -- :/
```

```bash
just setup
```

In the code now, `__init__.py` asks for the version of `"wikiapp"` by name, which fixes the one problem that
ty found. A family of rules, `ANN`, asks for a type on every parameter and return. The code and the tests have
their types.

`just check` does not run the type checker yet. One line in `check` runs it.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/5873353449adaf1734a9cb14d13262486b1fb5d5). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/701783af434e19b17e38a10898a39adc1dc5dae9).

<a id="step-05.7"></a>

### 5.7 The recipe check runs the type checker

`just check` is what a person and the git hook run before git records a change, and it does not run ty yet. So a
change can break a type, and pass. The recipe `check` now runs `just types` after `just lint`, and its comment
names the types too.

Apply the patch to [`justfile`](#step-05.7-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/701783af434e19b17e38a10898a39adc1dc5dae9.diff | git apply --include=justfile
```

The patch changes the comment above the recipe `check`, and puts `just types` under `just lint` in it.

```bash
just check
```

Every check passes, the type check among them. The coverage is 96.88%.

`.pre-commit-config.yaml` still says `entry: just check`, and the hook now
checks the types too.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 701783af434e
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 5873353449ad --staged -- :/ && git restore --source 701783af434e --staged --worktree -- :/
```

#### What changed

- <a id="step-05.7-justfile-424f0b"></a>`justfile`: the comment, and one line in check. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/701783af434e19b17e38a10898a39adc1dc5dae9/justfile).
  - look at `just types`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -62,7 +62,7 @@ lint-config *args:
     uv lock --check
     just --fmt --check --unstable
 
-# Everything a commit must pass: format, lint, the tests over the coverage floor, the configuration
+# Everything a commit must pass: format, lint, types, the tests over the coverage floor, the configuration
 [group('quality')]
 [no-exit-message]
 check *args:
@@ -71,5 +71,6 @@ check *args:
     if [ "$*" = help ]; then just help check; exit 0; fi
     just fmt --check
     just lint
+    just types
     just test -q --cov-fail-under=90
     just lint-config
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/701783af434e19b17e38a10898a39adc1dc5dae9). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/701783af434e19b17e38a10898a39adc1dc5dae9).

<a id="step-06.5"></a>

## 6.5 GitHub runs `just check`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 701783af434e --staged -- :/ && git restore --source d8af75e8fd57 --staged --worktree -- :/
```

```bash
just setup
```

In the code now, the tests that ask the real Wikipedia run only on request, with `just test -m e2e`. The project
accepts any Python from 3.11 on.

The hook runs only in a clone where `just hook` ran. GitHub's job `check` runs `just setup`, then `just check`, on
a fresh machine.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/d8af75e8fd576ae8d09cb76ed960b1c4892e0a84). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/20cf458261edc55b725da39a99c9b37ef5d24657).

<a id="step-06.5"></a>

### 6.5 GitHub runs the tests

The tests run only on the machine of the person who runs them, on one system and one version of Python. GitHub can run them
on its own machines after each push.

A GitHub Actions workflow is a file in `.github/workflows/`. GitHub runs its jobs on the events that its `on:`
names. The workflow `.github/workflows/test.yaml` names every push to main and every pull request, and has two
jobs. The job `tests` runs the tests on three systems and four versions of Python. The job `check` runs `just check` once.

Both jobs run pytest with the options in `pyproject.toml`, so they leave out the e2e tests. GitHub never runs the
e2e tests. A person runs them, with `just test -m e2e`.

Apply the patch to [`.github/workflows/test.yaml`](#step-06.5-.github-workflows-test.yaml-a60e23), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/20cf458261edc55b725da39a99c9b37ef5d24657.diff | git apply --include=.github/workflows/test.yaml
```

The patch makes the folder `.github/workflows`, and the whole file in it. Read the comment at its top, and the
matrix of the job `tests`.

The original wikiapp used pixi for the same work, with one environment for each version of Python. Here, `setup-uv` tells
uv which Python to use. If that Python is missing, `uv run` installs it.

```bash
uv run pre-commit run check-yaml --files .github/workflows/test.yaml
```

The file is valid YAML. GitHub runs the workflow after a push. The **Actions** tab of the repository shows the
thirteen jobs. In a fork, GitHub runs no workflow until the owner turns the workflows on, on that tab. A later
part of the tutorial publishes the docs with GitHub Pages, and lists each setting that a fork needs.

The job `check` is the third caller of `just check`, after a person and the git hook. It runs from a fresh clone.
No person has to install it or remember it, and `--no-verify` does not skip it. The job `tests` runs
`uv run --locked pytest`, not a verb, so a change behind `just test` would not reach it.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 20cf458261ed
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source d8af75e8fd57 --staged -- :/ && git restore --source 20cf458261ed --staged --worktree -- :/
```

#### What changed

- <a id="step-06.5-.github-workflows-test.yaml-a60e23"></a>`.github/workflows/test.yaml`: the matrix of systems and versions of Python. New, 37 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/20cf458261edc55b725da39a99c9b37ef5d24657/.github/workflows/test.yaml).
  - look at `python: ["3.11", "3.12", "3.13", "3.14"]`

<details open><summary>The patch to <code>.github/workflows/test.yaml</code></summary>

```diff
@@ -0,0 +1,37 @@
+# What GitHub runs on every push to main and every pull request.
+#
+# tests: the tests, on three systems and four Pythons, twelve jobs at once.
+# check: everything `just check` runs, once, as the git hook does.
+name: CI
+
+on:
+  pull_request:
+  push:
+    branches: [main]
+
+permissions:
+  contents: read  # the jobs read the code, and change nothing on GitHub
+
+jobs:
+  tests:
+    strategy:
+      fail-fast: false  # one failing job does not stop the others
+      matrix:
+        os: [ubuntu-latest, macos-latest, windows-latest]
+        python: ["3.11", "3.12", "3.13", "3.14"]
+    runs-on: ${{ matrix.os }}
+    steps:
+      - uses: actions/checkout@v7
+      - uses: astral-sh/setup-uv@v10.2.0
+        with:
+          python-version: ${{ matrix.python }}
+      - run: uv run --locked pytest
+
+  check:
+    runs-on: ubuntu-latest
+    steps:
+      - uses: actions/checkout@v7
+      - uses: astral-sh/setup-uv@v10.2.0
+      - uses: extractions/setup-just@v4
+      - run: just setup
+      - run: just check
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/20cf458261edc55b725da39a99c9b37ef5d24657). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/20cf458261edc55b725da39a99c9b37ef5d24657).

<a id="step-08.1-to-step-08.2"></a>

## 8.1 to 8.2 `just docs`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 20cf458261ed --staged -- :/ && git restore --source be473b80441f --staged --worktree -- :/
```

```bash
just setup
```

In the code now, `random_page` returns a `Page`, a pydantic model with a title and an extract. An answer that
is not a page, or a language that is not a language code, raises `WikipediaError`.

Nothing says which parts of the code have documentation. smalldocs comes in, and `just docs check` counts what has
documentation. The words after `docs` go to `smalldocs api`.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/be473b80441f82ce87bf800deeb432fd4212dea4). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/40d4293f5902e4a5ee51c9240e0eab4b59de797f).

<a id="step-08.1"></a>

### 8.1 smalldocs

The reference of a function gives its signature, what it does, and what each parameter is. The signature and the
types are in the code. The docstring says what the function does. A docment is the comment beside a parameter, a field
or a return type, and says what that thing is. Later moves put each parameter on a line of its own, so that its
docment can follow it on that line.

A reference that a tool writes from the code changes when the code changes. smalldocs is that tool. It also lists
what has no documentation.

smalldocs reads the signature, the docstring and the docments, and writes Markdown. It is a Python package, so uv
installs it like any other. It goes in a third dependency group, `docs`. uv sorts the groups by name, so `docs` comes before
`lint` and `test` in the file.

```bash
uv add --group docs smalldocs
```

`uv add` installs smalldocs and the packages that it needs, among them fastcore, markdown-it-py and mdurl.

`default-groups = "all"`, at line 25 of `pyproject.toml`, makes uv install every dependency group. So
`just setup` installs smalldocs, with no other change.

```bash
uv run smalldocs --version
uv tree --only-group docs
```

The first command prints `smalldocs 0.1.5`. `uv tree` prints smalldocs `(group: docs)`, and under it fastcore,
markdown-it-py, mdit-py-plugins, pygments and pyyaml.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 71726f393670
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source be473b80441f --staged -- :/ && git restore --source 71726f393670 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group. 3 lines added. It comes from `uv add --group docs smalldocs`. [The file](https://github.com/rahuldave/smallwikiapp/blob/71726f393670206ea480aaa2edc03ddeeeebc1fe/pyproject.toml).
  - look at `docs = [`
- <a id="step-08.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of smalldocs, and of the packages that it needs. 62 lines added. It comes from `uv add --group docs smalldocs`. [The file](https://github.com/rahuldave/smallwikiapp/blob/71726f393670206ea480aaa2edc03ddeeeebc1fe/uv.lock).

<details><summary>The diff that <code>uv add --group docs smalldocs</code> makes in <code>pyproject.toml</code></summary>

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

Apply the patch to [`docs/_smalldocs.yml`](#step-08.2-docs-_smalldocs.yml-4b0b48), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/40d4293f5902e4a5ee51c9240e0eab4b59de797f.diff | git apply --include=docs/_smalldocs.yml
```

Read the three keys under `api`, which are `packages`, `source` and `check`.

A recipe `docs` runs `smalldocs api`, and gives it the words after `just docs`. `smalldocs api` has two commands
that we use here:

- `module NAME` prints the reference of one module as Markdown.
- `check` lists each function and class without a docstring, a type or a docment, and each module without a
  docstring. It looks in the package and in the files of `check`, here the tests.

Apply the patch to [`justfile`](#step-08.2-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/40d4293f5902e4a5ee51c9240e0eab4b59de797f.diff | git apply --include=justfile
```

The patch adds the recipe `docs` at the end of the `justfile`, with its comment and its two attributes.

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

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 40d4293f5902
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 71726f393670 --staged -- :/ && git restore --source 40d4293f5902 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.2-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the package to document, and the tests to check. New, 5 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/40d4293f5902e4a5ee51c9240e0eab4b59de797f/docs/_smalldocs.yml).
  - look at `packages: [wikiapp]`
- <a id="step-08.2-justfile-424f0b"></a>`justfile`: the recipe. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/40d4293f5902e4a5ee51c9240e0eab4b59de797f/justfile).
  - look at `docs *args:`

<details open><summary>The patch to <code>docs/_smalldocs.yml</code></summary>

```diff
@@ -0,0 +1,5 @@
+# The settings of smalldocs. `api` is the reference, made from the code of the packages
+api:
+  packages: [wikiapp]
+  source: https://github.com/rahuldave/smallwikiapp/blob/main  # each entry links to its line here
+  check: ["tests/**/*.py"]  # the tests are held to the same rule as the package
```

</details>

<details open><summary>The patch to <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/40d4293f5902e4a5ee51c9240e0eab4b59de797f). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/40d4293f5902e4a5ee51c9240e0eab4b59de797f).

<a id="step-08.6"></a>

## 8.6 `just docs` alone builds a site

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 40d4293f5902 --staged -- :/ && git restore --source 7a0e50948873 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has the documentation of the library, the command and the tests, and the docs check finds no
gap.

The reference is text in a terminal. The recipe `docs` changes. With no words, it builds a site. With words, it
works as before, so `just docs check` is the same command.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/7a0e5094887304538655b706752de99408df2d97). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/e99ed4f3ab32aec60ae0e2329f4779673a5955d0).

<a id="step-08.6"></a>

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

Apply the patch to [`docs/_smalldocs.yml`](#step-08.6-docs-_smalldocs.yml-4b0b48), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/e99ed4f3ab32aec60ae0e2329f4779673a5955d0.diff | git apply --include=docs/_smalldocs.yml
```

The patch writes the first line, a comment, again, to say what `just docs` builds. Under it come the sections
`project` and `website`, and the keys `theme` and `toc`. A new comment above `api:` says what the reference is, and
the section `api` stays as it is.

The front page, `docs/index.qmd`, is new. A `.qmd` file is Markdown, with a header between two `---` lines that
gives the title of the page.

The page says what the command prints, what each module does, and what the reference pages contain. The file is
new, and comes whole, as a patch.

Apply the patch to [`docs/index.qmd`](#step-08.6-docs-index.qmd-d6d880), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/e99ed4f3ab32aec60ae0e2329f4779673a5955d0.diff | git apply --include=docs/index.qmd
```

`just docs` with no words now builds the site, with `smalldocs render docs`. With words, it runs `smalldocs api`
as before. So the recipe is now a script of several lines.

Apply the patch to [`justfile`](#step-08.6-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/e99ed4f3ab32aec60ae0e2329f4779673a5955d0.diff | git apply --include=justfile
```

The patch writes the recipe `docs` again, from its comment to its last line. Its body is now a script of `sh`, with
one line for `help`, one for no words, and one for words.

```bash
uv run smalldocs render docs
just --show docs
just docs
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. On the front page, `random_page` is a link to its entry. Each build makes the site and the reference
pages, and git ignores them.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check e99ed4f3ab32
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 7a0e50948873 --staged -- :/ && git restore --source e99ed4f3ab32 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.6-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the site. The sidebar lists the front page, then the reference pages. 17 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/e99ed4f3ab32aec60ae0e2329f4779673a5955d0/docs/_smalldocs.yml).
  - look at `contents: api/*  # the reference pages, which each build makes from the code`
- <a id="step-08.6-docs-index.qmd-d6d880"></a>`docs/index.qmd`: the front page, written by hand. New, 35 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/e99ed4f3ab32aec60ae0e2329f4779673a5955d0/docs/index.qmd).
  - look at `Each build of the site makes the pages under Reference from the code.`
- <a id="step-08.6-justfile-424f0b"></a>`justfile`: with no words, `docs` builds the site. 5 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/e99ed4f3ab32aec60ae0e2329f4779673a5955d0/justfile).
  - look at `if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi`

<details open><summary>The patch to <code>docs/_smalldocs.yml</code></summary>

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

<details open><summary>The patch to <code>docs/index.qmd</code></summary>

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

<details open><summary>The patch to <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/e99ed4f3ab32aec60ae0e2329f4779673a5955d0). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/e99ed4f3ab32aec60ae0e2329f4779673a5955d0).

<a id="step-08.8"></a>

## 8.8 The docs check joins `just check`

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source e99ed4f3ab32 --staged -- :/ && git restore --source 79c80120fc8f --staged --worktree -- :/
```

```bash
just setup
```

The code now also has a README that names the tests and the docs.

`just check` does not run the docs check yet. One line in `check` runs it.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/79c80120fc8fc12ec7b38474294b422e86619362). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/ce0734f1272cf16f4aadeaa6712e589010ccd69f).

<a id="step-08.8"></a>

### 8.8 The docs check in `just check`

Every function, parameter and field has documentation now, but no check fails when a new function has none. `just check` runs before
each `git commit`, through the git hook, so `just docs check` goes in it, after the tests. The comment above
`check` names the docs too.

Apply the patch to [`justfile`](#step-08.8-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/ce0734f1272cf16f4aadeaa6712e589010ccd69f.diff | git apply --include=justfile
```

The patch writes the comment above `check` again, with "docs" in it. In `check`, it adds the line `just docs check` under
the line `just test -q --cov-fail-under=90`.

```bash
just check
```

The docs check prints `15 of 15`. Now, when a function, a parameter or a field has no documentation, the git hook
fails, and git records no change. GitHub's job `check`, at lines 30 to 37 of `.github/workflows/test.yaml`, runs `just check`, so
it runs the docs check too.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check ce0734f1272c
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 79c80120fc8f --staged -- :/ && git restore --source ce0734f1272c --staged --worktree -- :/
```

#### What changed

- <a id="step-08.8-justfile-424f0b"></a>`justfile`: the comment, and one line in `check`. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/ce0734f1272cf16f4aadeaa6712e589010ccd69f/justfile).
  - look at `just docs check`

<details open><summary>The patch to <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/ce0734f1272cf16f4aadeaa6712e589010ccd69f). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/ce0734f1272cf16f4aadeaa6712e589010ccd69f).

<a id="step-09.10"></a>

## 9.10 The library, behind the same verbs

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source ce0734f1272c --staged -- :/ && git restore --source 008e616610b0 --staged --worktree -- :/
```

```bash
just setup
```

In the code now, the library is a package of its own, `wikirandom`, in `packages/wikirandom`, in a uv workspace.
The app uses it, and `src/wikiapp/wikipedia.py` is gone. The tests of the library are in `tests/test_wikirandom.py`.
The project on GitHub also changed, and the next paragraphs say what it does now.

A dependency group is a named list of packages in `pyproject.toml`. This project has three groups. Their names are
`docs`, `lint` and `test`. The line `default-groups = "all"` in `pyproject.toml` makes `uv sync` and `uv run` install
all three.

GitHub reads the jobs of the project from files in `.github/workflows`. Each of these files is a workflow. The jobs
`tests` and `check` are in one workflow, `.github/workflows/test.yaml`. A second workflow,
`.github/workflows/docs.yaml`, has two jobs. The job `build` builds the docs site. Then the job `deploy` puts the site
on GitHub Pages, the part of GitHub that serves websites.

The job `tests` runs only the tests, and needs only the group `test`. It runs `uv run --locked
--no-default-groups --group test pytest`. `--no-default-groups` tells uv to install none of the groups that
`default-groups = "all"` names. `--group test` then adds the group `test` alone. So uv installs the app, the
packages that the app needs, and the group `test`, and no other group.

`uv.lock` lists the exact version of each package that uv installs. `--locked` makes uv stop with an error if
`uv.lock` does not match `pyproject.toml`.

The docs workflow runs `uv run --locked --no-default-groups --group docs smalldocs render docs`. The options work as
they do in the job `tests`. uv installs the app, the packages that the app needs, and the group `docs`, and no other
group.

The docs workflow does not run `just docs`. With no words, the recipe `docs` runs `uv run smalldocs render docs`,
with no option for dependency groups. So `just docs` makes uv install all three groups, but the workflow needs only
the group `docs`. Line 26 of `.github/workflows/docs.yaml` runs `uv run` directly, so the docs workflow is
not a caller of `just docs`. If someone changes the command in the recipe `docs`, the change does not reach the
workflow.

Those changes did not change the justfile. One justfile, one `.pre-commit-config.yaml` and one hook work for both
packages. `just fmt`, `just lint` and `just types` read every Python file of the repository, so they checked the
library's code from the first. `just test` measures the coverage of both packages, since `pyproject.toml` has
`--cov=wikirandom`. Here, `just docs check` still counts only the functions, methods and classes of the app and
the tests. This section
changes `docs/_smalldocs.yml`, behind the verb.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/008e616610b0829196a2f61182e45255015b95c1). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/259e6364a52f83993c797f66148281b04eb92060).

<a id="step-09.10"></a>

### 9.10 The docs check counts the library

The front page names `random_page`, but it is not a link, and the docs check counts only the app. The settings of
the site, `docs/_smalldocs.yml`, name only `wikiapp`. The line `packages:` in the section `api` must name both.

Apply the patch to [`docs/_smalldocs.yml`](#step-09.10-docs-_smalldocs.yml-4b0b48), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/259e6364a52f83993c797f66148281b04eb92060.diff | git apply --include=docs/_smalldocs.yml
```

The patch changes one line, `packages:` in the section `api`, in line 19.

```bash
just docs check
just docs
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and on the front page, `random_page` is now a link to its entry in `api/wikirandom.html`. `just check`
passes.

The justfile did not change, and `just docs check` checks more. The hook and GitHub's job `check` run the new
docs check without a change.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 259e6364a52f
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 008e616610b0 --staged -- :/ && git restore --source 259e6364a52f --staged --worktree -- :/
```

#### What changed

- <a id="step-09.10-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the list of packages. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/259e6364a52f83993c797f66148281b04eb92060/docs/_smalldocs.yml).
  - look at `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

<details open><summary>The patch to <code>docs/_smalldocs.yml</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/259e6364a52f83993c797f66148281b04eb92060). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/259e6364a52f83993c797f66148281b04eb92060).

<a id="step-10.1"></a>

## 10.1 `just build`

```bash
just setup
```

The packages must be built before anyone can install them. The last verb is about the packages, not about checks,
so `check` does not run it.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/259e6364a52f83993c797f66148281b04eb92060). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/7744a84a4715e6edb876e1c4f3255daf524dd07d).

<a id="step-10.1"></a>

### 10.1 The recipe `build`

A package goes to PyPI as two files, a wheel and a source archive. pip and uv install the wheel. `uv build
--all-packages` builds both for every package of the workspace, into `dist/`. `.gitignore` already lists `dist/`.
A recipe `build`, at the end of the `justfile`, runs it.

Apply the patch to [`justfile`](#step-10.1-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/7744a84a4715e6edb876e1c4f3255daf524dd07d.diff | git apply --include=justfile
```

The patch adds the recipe `build`, with its comment, at the end of the `justfile`.

```bash
uv build --all-packages
just --show build
just build
unzip -l dist/wikiapp-0.1.0-py3-none-any.whl
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

`dist/` now has a source archive, `.tar.gz`, and a wheel, `.whl`, for each package. The app's wheel contains
`wikiapp/` and its metadata, which says that the app needs click and wikirandom. The metadata does not say which
version of wikirandom, because `uv add wikirandom` in a workspace writes no version. An install from PyPI would
get any package that PyPI has under that name. Today PyPI has none, so wikirandom would have to be published
first.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 7744a84a4715
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 259e6364a52f --staged -- :/ && git restore --source 7744a84a4715 --staged --worktree -- :/
```

#### What changed

- <a id="step-10.1-justfile-424f0b"></a>`justfile`: the recipe `build`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/7744a84a4715e6edb876e1c4f3255daf524dd07d/justfile).
  - look at `build *args:`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -84,3 +84,9 @@ docs *args:
     if [ "$*" = help ]; then just help docs; exit 0; fi
     if [ "$#" -eq 0 ]; then exec uv run smalldocs render docs; fi
     exec uv run smalldocs api "$@" --dir docs
+
+# Build the wheel and the source archive of both packages into dist/, as they would go to PyPI
+[group('setup')]
+[no-exit-message]
+build *args:
+    {{ if args == "help" { "just help build" } else { 'uv build --all-packages "$@"' } }}
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/7744a84a4715e6edb876e1c4f3255daf524dd07d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/7744a84a4715e6edb876e1c4f3255daf524dd07d).

<a id="step-10.3"></a>

## 10.3 `just lint-config` checks the library too

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 7744a84a4715 --staged -- :/ && git restore --source 6e6d2844bc7a --staged --worktree -- :/
```

```bash
just setup
```

In the code now, the app asks for wikirandom 0.1.

Since the library became a package, validate-pyproject, in `just lint-config`, has read only the app's
`pyproject.toml`. The hook and `just check` let every `git commit` through with no check of the library's
`pyproject.toml` against the standard.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/6e6d2844bc7a5b34605ad76b9e03e6631fa236be). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/522bcb94133654c1e72a9592c852681e0b5e2055).

<a id="step-10.3"></a>

### 10.3 lint-config checks both pyproject.toml files

The repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. A mistake in the
library's file would reach a build unseen. The recipe `lint-config` now gives validate-pyproject both files.

Apply the patch to [`justfile`](#step-10.3-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/522bcb94133654c1e72a9592c852681e0b5e2055.diff | git apply --include=justfile
```

The patch changes one line of the recipe `lint-config`, the line that runs `validate-pyproject`.

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.

The verb has the same name, and its callers did not change. A file that a recipe leaves out is a file that no
caller checks. The fix goes in one place, the recipe, and all three callers have it.

This tutorial ends here. After it, the library gets a licence and an author, both packages get a link to the
repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 522bcb941336
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 6e6d2844bc7a --staged -- :/ && git restore --source 522bcb941336 --staged --worktree -- :/
```

#### What changed

- <a id="step-10.3-justfile-424f0b"></a>`justfile`: two files. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/522bcb94133654c1e72a9592c852681e0b5e2055/justfile).
  - look at `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

<details open><summary>The patch to <code>justfile</code></summary>

```diff
@@ -58,7 +58,7 @@ lint-config *args:
     #!/usr/bin/env sh
     set -e
     if [ "$*" = help ]; then just help lint-config; exit 0; fi
-    uv run validate-pyproject pyproject.toml
+    uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml
     uv lock --check
     just --fmt --check --unstable
 
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/522bcb94133654c1e72a9592c852681e0b5e2055). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/522bcb94133654c1e72a9592c852681e0b5e2055).
