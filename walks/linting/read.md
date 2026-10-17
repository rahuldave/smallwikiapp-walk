<!-- Made by the walk skill's render.py from the facts of the walk. Do not edit it by hand: run just walk-update again. -->

# The formatter and the linter of smallwikiapp

**Read the tutorial.** Each change explained, with the code to look at. [Build it yourself](build.md) is the other way to read it.

Each part ends with a section called **What changed**. It lists every file that the part changes, with a link to the file, and then the whole diff of each file, folded. A lockfile and a binary file have a link alone. The text above it explains the change.

We give `wikiapp` a formatter and a linter. `wikiapp` is a small command that prints the title and the summary of
a random Wikipedia page. A formatter writes every file in one style. Then, when someone changes the code, the list of
changed lines shows only what they meant to change, and no changes of style. A linter finds problems that the tests do not find.

This tutorial takes the parts about format and lint out of the
whole tutorial of smallwikiapp. It starts from the project that `uv init` made, for Python 3.13. The command
then gets its code, and the format and the lint check that code and its tests.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has ten sections:

1. **The project**
2. **The command**
3. **A formatter**
4. **The linter's rules**
5. **The linter's problems, fixed**
6. **A check of the configuration**
7. **`just check`, every check in one recipe**
8. **A git hook**
9. **The linter asks for types**
10. **The library's pyproject.toml too**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**Kinds of checks**

Each kind of check comes in at the section in the table.

| Kind | What it does | Where |
|---|---|---|
| Formatter | Changes how the code looks, never what it does | Section 3 |
| Linter | Finds problems in the code, against rules | Section 4 |
| A fix by the tool | A fix that ruff counts as safe, such as the order of imports | Section 5 |
| A fix by a person | The rest. ruff has no fix for some problems, and marks others unsafe | Section 5 |
| A check of the configuration | Finds errors in `pyproject.toml`, the lockfile and the justfile | Sections 6 and 10 |
| One recipe for every check | `just check` runs every check, one after the other | Section 7 |
| A hook | Runs `just check` by itself, before each `git commit` | Section 8 |
| A linter's rule about types | Checks that each type is written. The type checker checks that it is right | Section 9 |

<a id="step-00"></a>

## 0 The project

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part is where the project starts, at `step-00`. [The code of this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

Before there is code to check, there is a project. This section shows what `uv init` made, and the command
`wikiapp`. The justfile lists the tasks of the project.

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

<a id="step-01"></a>

## 1 The command

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-00`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

The checks need code to check. The command asks Wikipedia for a random page, and prints its title and summary. It
sends a User-Agent, and has an option `--version`.

```bash
just setup
```

The command prints a fixed line. It should ask Wikipedia for a random page and print it. We need two packages for
that, then the request, then a header that Wikipedia asks for, and last an option that prints the version.

<a id="step-01.1"></a>

### 1.1 click and requests

The command needs two packages that Python does not have. click makes command lines, with options and help.
requests gets pages over HTTP. `uv add` puts both in the dependencies of wikiapp, and installs them in `.venv`. It
also chooses one version of each package that fits every range of versions, and writes the versions in the
lockfile, `uv.lock`. uv calls this choice resolving.

[click](https://click.palletsprojects.com/) comes from Pallets, who also make Flask. In click, the line `@click.command()` above a
function makes the function a command. Such a line is a decorator. Each option of the command becomes a parameter of
the function. [requests](https://requests.readthedocs.io/)
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

[± See the change to `src/wikiapp/console.py`](#step-01.2-src-wikiapp-console.py-d9ae67)

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

[± See the change to `src/wikiapp/console.py`](#step-01.3-src-wikiapp-console.py-d9ae67)

In `src/wikiapp/console.py`, `USER_AGENT` is under `API_URL`. The request now passes it in
`headers={"User-Agent": USER_AGENT}`.

```bash
uv run wikiapp
```

It prints a title in green, and a paragraph. Each run prints another page.

#### What changed

- <a id="step-01.3-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the header. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/0ffd5df563acb876953855d86be30b6952ecfd44/src/wikiapp/console.py).
  - look at `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

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

[± See the change to `src/wikiapp/__init__.py`](#step-01.4-src-wikiapp-__init__.py-682a01)

[± See the change to `src/wikiapp/console.py`](#step-01.4-src-wikiapp-console.py-d9ae67)

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

<details><summary>The diff of <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -0,0 +1,2 @@
+import importlib.metadata
+__version__ = importlib.metadata.version(__name__ or __package__)
```

</details>

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

<a id="step-04.1-to-step-04.3"></a>

## 4.1 to 4.3 A formatter

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-03`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-03)

```bash
just setup
```

The code now also has tests, and pytest runs them. pytest is in a dependency group `test`, a named list of
packages in `pyproject.toml`, and uv installs every group. In the tests, a mock takes the place of Wikipedia, so
the tests never ask the real site. Each run of the tests also measures the coverage, the share of the lines of
code that the tests run.

The code is split into a library,
`src/wikiapp/wikipedia.py`, and the command. The command has an option `--language`. The library takes a language
and raises its own error, `WikipediaError`, and the command prints it as a message.

The code mixes styles, and nothing keeps one style. ruff comes in, in a new group `lint`, and `just fmt` formats
the code and the tests.

<a id="step-04.1"></a>

### 4.1 ruff, in the group lint

The code has no one style, so a later change can mix a fix with a change of blank lines and quotes. A formatter
changes how the code looks, and never what it does. A linter finds problems in the code, such as a variable that
is never used, and changes nothing unless it is asked to. ruff is both, in one program. It goes in a second group
of dependencies, `lint`, next to the group `test`.

[ruff](https://docs.astral.sh/ruff/) comes from Astral, as uv does, and is written in Rust. It does the work of
older tools, such as Black for the format, and flake8 and isort for the lint, much faster.

This change came from running `uv add --group lint ruff`.

In `pyproject.toml`, the new group `lint` starts at line 27, above `test`, with the line `"ruff>=0.17.0",`.
`uv.lock` has the exact version of ruff.

```bash
uv run ruff --version
```

It prints `ruff 0.17.0`, or a newer version. uv installs every group, so ruff is in the environment of the project, and nothing has
used it yet.

#### What changed

- <a id="step-04.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group `lint`, with ruff in it. 3 lines added. It comes from `uv add --group lint ruff`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8f7b800001ee35d8db80c47521b02777047c019d/pyproject.toml).
  - look at `"ruff>=0.17.0",`
- <a id="step-04.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of ruff. 29 lines added. It comes from `uv add --group lint ruff`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8f7b800001ee35d8db80c47521b02777047c019d/uv.lock).

<details><summary>The diff of <code>pyproject.toml</code></summary>

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

ruff needs its settings, in `pyproject.toml`. They allow lines of up to 100 characters, and write out
the defaults of the formatter, so that a reader sees them. A recipe `fmt` runs the formatter. The words after
`just fmt` go to `ruff format`.

[± See the change to `pyproject.toml`](#step-04.2-pyproject.toml-5d07e7)

[± See the change to `justfile`](#step-04.2-justfile-424f0b)

At the end of `pyproject.toml`, the table `[tool.ruff]` on line 41 sets `line-length = 100`. The table
`[tool.ruff.format]` on line 46 gives the three defaults of the formatter, each with a comment. At the end of the
`justfile`, the recipe `fmt *args:` on line 32 runs `uv run ruff format`, with the words after `just fmt`.

```bash
uv run ruff format --check
just --show fmt
just fmt --check
```

`--check` changes nothing. It shows what it would change in each file, and fails. It ends with `6 files would be
reformatted, 1 file already formatted`. It names the six files that it would
change. The recipe
runs the same command, and passes on the words after `just fmt`.

#### What changed

- <a id="step-04.2-justfile-424f0b"></a>`justfile`: the recipe `fmt`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/31445743379186b800fd4c035c8f04eed7ad7f3d/justfile).
  - look at `fmt *args:`
- <a id="step-04.2-pyproject.toml-5d07e7"></a>`pyproject.toml`: the settings of ruff. 11 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/31445743379186b800fd4c035c8f04eed7ad7f3d/pyproject.toml).
  - look at `line-length = 100`

<details><summary>The diff of <code>justfile</code></summary>

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

<details><summary>The diff of <code>pyproject.toml</code></summary>

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

<a id="step-04.3"></a>

### 4.3 The code, formatted

`just fmt --check` found six files that do not follow the style. The formatter rewrites them. It adds blank lines,
puts spaces around `==`, and splits the lines longer than 100 characters.

This change came from running `just fmt`.

In `src/wikiapp/console.py`, two blank lines now come before `@click.command()` on line 8, and before
`if __name__ == "__main__":` on line 30. In `src/wikiapp/wikipedia.py`, the request was one line of more than 100
characters, and is now lines 14 to 16. In `tests/test_console.py`, two blank lines come around each function. The
long address in the test of the address is on line 27, a line of its own.

```bash
just fmt --check
just test
```

The check prints `7 files already formatted`, and the tests pass as before, `7 passed`. One test asks the real Wikipedia, so the tests still need the network.

#### What changed

- <a id="step-04.3-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: a blank line after the import. 1 line added. It comes from `just fmt`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6690eee9f7e177a6df2ea5e1821b8f581948bc85/src/wikiapp/__init__.py).
- <a id="step-04.3-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: blank lines, and spaces around `==`. 3 lines added, 1 removed. It comes from `just fmt`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6690eee9f7e177a6df2ea5e1821b8f581948bc85/src/wikiapp/console.py).
  - look at `if __name__ == "__main__":`
- <a id="step-04.3-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: blank lines, and the long request split into three lines. 5 lines added, 1 removed. It comes from `just fmt`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6690eee9f7e177a6df2ea5e1821b8f581948bc85/src/wikiapp/wikipedia.py).
  - look at `API_URL.format(language=language), headers={"User-Agent": USER_AGENT}`
- <a id="step-04.3-tests-conftest.py-626af3"></a>`tests/conftest.py`: two blank lines before the fixture. 1 line added. It comes from `just fmt`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6690eee9f7e177a6df2ea5e1821b8f581948bc85/tests/conftest.py).
- <a id="step-04.3-tests-test_console.py-9442ee"></a>`tests/test_console.py`: blank lines, and the long address split. 11 lines added, 1 removed. It comes from `just fmt`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6690eee9f7e177a6df2ea5e1821b8f581948bc85/tests/test_console.py).
  - look at `"https://en.wikipedia.org/api/rest_v1/page/random/summary",`
- <a id="step-04.3-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: two blank lines before the test. 1 line added. It comes from `just fmt`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6690eee9f7e177a6df2ea5e1821b8f581948bc85/tests/test_wikipedia.py).

<details><summary>The diff of <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -1,2 +1,3 @@
 import importlib.metadata
+
 __version__ = importlib.metadata.version(__name__ or __package__)
```

</details>

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -4,6 +4,7 @@ import textwrap
 
 from wikiapp.wikipedia import WikipediaError, random_page
 
+
 @click.command()
 @click.option(
     "--language",
@@ -25,5 +26,6 @@ def main(language) -> None:
     click.secho(title, fg="green")
     click.echo(textwrap.fill(extract))
 
-if __name__=="__main__":
+
+if __name__ == "__main__":
     main()
```

</details>

<details><summary>The diff of <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -3,13 +3,17 @@ import requests
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
+
 class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
+
 def random_page(language="en"):
     """Get a random page from Wikipedia."""
     try:
-        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
+        with requests.get(
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}
+        ) as response:
             response.raise_for_status()
             return response.json()
     except requests.RequestException as error:
```

</details>

<details><summary>The diff of <code>tests/conftest.py</code></summary>

```diff
@@ -1,5 +1,6 @@
 import pytest
 
+
 @pytest.fixture
 def mock_requests_get(mocker):
     mock = mocker.patch("requests.get")
```

</details>

<details><summary>The diff of <code>tests/test_console.py</code></summary>

```diff
@@ -2,34 +2,44 @@ import click.testing
 import pytest
 import requests
 
+
 @pytest.fixture
 def runner():
     return click.testing.CliRunner()
 
+
 from wikiapp import console
 
+
 def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
+
 def test_main_invokes_requests_get(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert mock_requests_get.called
 
+
 def test_main_uses_correct_url(runner, mock_requests_get):
     result = runner.invoke(console.main)
-    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
+    assert mock_requests_get.call_args[0] == (
+        "https://en.wikipedia.org/api/rest_v1/page/random/summary",
+    )
+
 
 def test_main_fails_on_request_error(runner, mock_requests_get):
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
+
 def test_main_prints_message_on_request_error(runner, mock_requests_get):
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

<details><summary>The diff of <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -1,5 +1,6 @@
 from wikiapp import wikipedia
 
+
 def test_random_page_uses_given_language(mock_requests_get):
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6690eee9f7e177a6df2ea5e1821b8f581948bc85).

This part ends at the code at `6690eee9f7e1`, partway through `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/6690eee9f7e177a6df2ea5e1821b8f581948bc85)

<a id="step-04.4"></a>

## 4.4 The linter's rules

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `6690eee9f7e1`, partway through `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/6690eee9f7e177a6df2ea5e1821b8f581948bc85)

```bash
just setup
```

A linter needs rules to check. The rules go in `pyproject.toml`, and `just lint` finds five problems.

### 4.4 The linter's rules, and the recipe lint

The linter checks the code against rules, and it needs to know which. A table in `pyproject.toml`
chooses the families of rules. Each family is on a line of its own, with a comment that says why it is on. The
tests may use `assert`. The rest of the code may not, because Python skips every `assert` when it runs with `-O`.

A recipe `lint` runs the linter. The words after `just lint` go to `ruff check`.

[± See the change to `pyproject.toml`](#step-04.4-pyproject.toml-5d07e7)

[± See the change to `justfile`](#step-04.4-justfile-424f0b)

At the end of `pyproject.toml`, `select = [` on line 54 lists nine families of rules. The last table lets the files
under `tests/` break the rule `S101`, which forbids `assert`, on line 68. At the end of the `justfile`, the recipe
`lint *args:` on line 38 runs `uv run ruff check`, with the words after `just lint`.

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

A `[*]` marks the one problem that ruff can fix by itself, `I001`. ruff also has a fix for the two unused variables, and marks it unsafe,
because it may delete a comment on the line. It has no fix for the other two problems. So a person fixes those four
in the next two moves, and then ruff fixes the last one.

#### What changed

- <a id="step-04.4-justfile-424f0b"></a>`justfile`: the recipe `lint`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/589f2f691557470eac084858d430a302c98390ce/justfile).
  - look at `lint *args:`
- <a id="step-04.4-pyproject.toml-5d07e7"></a>`pyproject.toml`: a family of rules on each line. 18 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/589f2f691557470eac084858d430a302c98390ce/pyproject.toml).
  - look at `"tests/**" = ["S101"]`

<details><summary>The diff of <code>justfile</code></summary>

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

<details><summary>The diff of <code>pyproject.toml</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/589f2f691557470eac084858d430a302c98390ce).

This part ends at the code at `589f2f691557`, partway through `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/589f2f691557470eac084858d430a302c98390ce)

<a id="step-04.5-to-step-04.7"></a>

## 4.5 to 4.7 The linter's problems, fixed

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `589f2f691557`, partway through `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/589f2f691557470eac084858d430a302c98390ce)

```bash
just setup
```

The linter found five problems. A person fixes the tests, and gives the request a timeout. Then
`just lint --fix` fixes the last problem, the order of the imports.

<a id="step-04.5"></a>

### 4.5 The tests' imports at the top, and no unused variables

Three of the five problems are in `tests/test_console.py`. The import of `console` comes below the fixture, where a
reader does not look for it. Two tests assign `result` and never read it. ruff has no fix for the import below the
code, and its fix for the unused variables is unsafe. So a person makes these fixes.

The import goes up, under `import requests`. wikiapp's own imports are a block of their own, after the installed
packages, which is the order that the rule `I001` asks for. The tests `test_main_invokes_requests_get` and
`test_main_uses_correct_url` check the mock, and not the result, so they need no `result =`.

[± See the change to `tests/test_console.py`](#step-04.5-tests-test_console.py-9442ee)

In `tests/test_console.py`, `from wikiapp import console` is now on line 5, under `import requests`, after a blank
line. It is gone from below the fixture. The first line of each of the two tests, lines 19 and 24, is now
`runner.invoke(console.main)` alone.

```bash
just lint --statistics
just fmt --check
```

Two problems are left, `S113` and `I001`, and the linter still fails. The format is unchanged, and the check prints
`7 files already formatted`.

#### What changed

- <a id="step-04.5-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the import goes up, and two lines lose `result =`. 4 lines added, 5 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/2ec7932b37e21c1533f319c03e0533bc755f6da7/tests/test_console.py).
  - look at `from wikiapp import console`

<details><summary>The diff of <code>tests/test_console.py</code></summary>

```diff
@@ -2,27 +2,26 @@ import click.testing
 import pytest
 import requests
 
+from wikiapp import console
+
 
 @pytest.fixture
 def runner():
     return click.testing.CliRunner()
 
 
-from wikiapp import console
-
-
 def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
 def test_main_invokes_requests_get(runner, mock_requests_get):
-    result = runner.invoke(console.main)
+    runner.invoke(console.main)
     assert mock_requests_get.called
 
 
 def test_main_uses_correct_url(runner, mock_requests_get):
-    result = runner.invoke(console.main)
+    runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/2ec7932b37e21c1533f319c03e0533bc755f6da7). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/2ec7932b37e21c1533f319c03e0533bc755f6da7).

<a id="step-04.6"></a>

### 4.6 A timeout

Of the two problems left, `S113` comes from the family `S` of security rules. The request has no timeout, so
requests waits as long as the server keeps the connection open, and the command can wait for ever. No test had
found it. The request in `src/wikiapp/wikipedia.py` gets `timeout=10`, a number of seconds that the author of the project chose.

[± See the change to `src/wikiapp/wikipedia.py`](#step-04.6-src-wikiapp-wikipedia.py-258803)

In `src/wikiapp/wikipedia.py`, the arguments of `requests.get` on line 15 now end with `timeout=10`.

If the server does not answer within 10 seconds, the request now raises an exception. `random_page` turns it
into a WikipediaError, as it does with every other error of requests.

```bash
just lint --statistics
```

One problem is left, `I001`, so the linter still fails. Its `[*]` says that ruff can fix it.

#### What changed

- <a id="step-04.6-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: one more argument. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/0fb4985582732edf7372a4b90659d703db138446/src/wikiapp/wikipedia.py).
  - look at `timeout=10`

<details><summary>The diff of <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -12,7 +12,7 @@ def random_page(language="en"):
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
-            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
         ) as response:
             response.raise_for_status()
             return response.json()
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/0fb4985582732edf7372a4b90659d703db138446). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/0fb4985582732edf7372a4b90659d703db138446).

<a id="step-04.7"></a>

### 4.7 The linter sorts the imports

The last problem is the order of the imports of `src/wikiapp/console.py`. ruff can fix it safely, and `--fix`
makes only the fixes that ruff counts as safe. It puts the imports in three blocks. The standard library comes
first, then the packages installed, and then wikiapp's own.

This change came from running `just lint --fix`.

At the top of `src/wikiapp/console.py`, `import textwrap` is on line 1, `import click` on line 3, and
`from wikiapp import __version__` on line 5. A blank line comes between the blocks.

```bash
just lint
```

`just lint --fix` reported `Found 1 error (1 fixed, 0 remaining).`, and exited with 0. Now `just lint` prints `All checks passed!`.

The linter finds no problem now. Of its five problems, ruff fixed one, and a person fixed four.

#### What changed

- <a id="step-04.7-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the imports, sorted. 3 lines added, 2 removed. It comes from `just lint --fix`. [The file](https://github.com/rahuldave/smallwikiapp/blob/a57134d1cef6ff24803235ace966e5870046fbd9/src/wikiapp/console.py).
  - look at `from wikiapp import __version__`

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -1,7 +1,8 @@
-import click
-from wikiapp import __version__
 import textwrap
 
+import click
+
+from wikiapp import __version__
 from wikiapp.wikipedia import WikipediaError, random_page
 
 
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/a57134d1cef6ff24803235ace966e5870046fbd9).

This part ends at the code at `a57134d1cef6`, partway through `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/a57134d1cef6ff24803235ace966e5870046fbd9)

<a id="step-04.8-to-step-04.9"></a>

## 4.8 to 4.9 A check of the configuration

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `a57134d1cef6`, partway through `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/a57134d1cef6ff24803235ace966e5870046fbd9)

```bash
just setup
```

The linter reads the Python code, and nothing checks the files that set up the project. `just lint-config` checks
`pyproject.toml`, the lockfile and the justfile.

<a id="step-04.8"></a>

### 4.8 validate-pyproject, in the group lint

The tests and the linter check the code, and not the configuration. So an error in `pyproject.toml`, in the
lockfile or in the `justfile` passes them all. validate-pyproject checks `pyproject.toml` against the standard for
it. It goes in the group `lint`.

[validate-pyproject](https://validate-pyproject.readthedocs.io/) checks `pyproject.toml` against JSON schemas of
the standards that define the file.

This change came from running `uv add --group lint validate-pyproject`.

In `pyproject.toml`, the group `lint` now has `"validate-pyproject>=0.26",` on line 29, under ruff. `uv.lock` has
its exact version, and that of `fastjsonschema`, which it needs.

```bash
uv run validate-pyproject --version
```

It prints `validate_pyproject 0.26`. Nothing runs it yet.

#### What changed

- <a id="step-04.8-pyproject.toml-5d07e7"></a>`pyproject.toml`: one package more in `lint`. 1 line added. It comes from `uv add --group lint validate-pyproject`. [The file](https://github.com/rahuldave/smallwikiapp/blob/4e710d50a22967ebff9502eacbdada54313ebe70/pyproject.toml).
  - look at `"validate-pyproject>=0.26",`
- <a id="step-04.8-uv.lock-8356d8"></a>`uv.lock`: the exact version of validate-pyproject, and of what it needs. 26 lines added, 1 removed. It comes from `uv add --group lint validate-pyproject`. [The file](https://github.com/rahuldave/smallwikiapp/blob/4e710d50a22967ebff9502eacbdada54313ebe70/uv.lock).

<details><summary>The diff of <code>pyproject.toml</code></summary>

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

[± See the change to `justfile`](#step-04.9-justfile-424f0b)

At the end of the `justfile`, the recipe `lint-config *args:` on line 44 runs the three commands, one on each line.
`set -e`, on line 46, stops it at the first that fails.

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

#### What changed

- <a id="step-04.9-justfile-424f0b"></a>`justfile`: the recipe, with its three checks. 11 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/d8a9c8f71eb58893025360c20b32c9078e5b0c3c/justfile).
  - look at `uv run validate-pyproject pyproject.toml`

<details><summary>The diff of <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/d8a9c8f71eb58893025360c20b32c9078e5b0c3c).

This part ends at the code at `d8a9c8f71eb5`, partway through `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/d8a9c8f71eb58893025360c20b32c9078e5b0c3c)

<a id="step-04.11"></a>

## 4.11 `just check`, every check in one recipe

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `b7469ee81a82`, partway through `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/b7469ee81a824a46e6799d60957ea09d7cf2eade)

```bash
just setup
```

The lockfile, `uv.lock`, lists the exact version of each package. Until now, `uv run` updated it without a
word. The justfile now sets `UV_LOCKED`, so each recipe that runs `uv` refuses a lockfile that is out of date.

Each check is a recipe of its own, and a person must remember to run them all. `just check` runs the format, the
linter, the tests and the configuration, in order.

### 4.11 The recipe check

There are now four checks, and a person must remember to run each. A recipe `check` runs them all in order, and
stops at the first that fails. The order is the format, the linter, the tests with a floor on the coverage, and
the configuration.

[± See the change to `justfile`](#step-04.11-justfile-424f0b)

At the end of the `justfile`, the recipe `check *args:` on line 57 runs four recipes. The tests run with
`--cov-fail-under=90`, on line 63, so they fail if they run less than 90% of the statements.

```bash
just --show check
just check
```

`just check` passes. The tests must run at least 90% of the statements, and the coverage is 96.77%.

Later in the whole tutorial, GitHub runs `just check` too, on every push to main and every pull request.

#### What changed

- <a id="step-04.11-justfile-424f0b"></a>`justfile`: the recipe, with its four checks. 12 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543/justfile).
  - look at `just test -q --cov-fail-under=90`

<details><summary>The diff of <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543).

This part ends at the code at `1f73d6af30cc`, partway through `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543)

<a id="step-04.12-to-step-04.13"></a>

## 4.12 to 4.13 A git hook

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `1f73d6af30cc`, partway through `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543)

```bash
just setup
```

A person can forget to run `just check`. `pre-commit` runs three small checks of the files, then `just check`,
before each `git commit`.

<a id="step-04.12"></a>

### 4.12 `pre-commit`, in the group lint

`just check` runs every check, but a person must remember to run it. A `pre-commit` hook is a program that git runs
before it records a change. If the program fails, git does not record the change. `pre-commit` installs such a hook, and
runs the checks that the file `.pre-commit-config.yaml` names. It goes in the group `lint`.

[pre-commit](https://pre-commit.com/) manages git hooks. A file lists the hooks, and `pre-commit` installs each in
an environment of its own, and runs them on the files of a change.

This change came from running `uv add --group lint pre-commit`.

In `pyproject.toml`, the group `lint` now starts with `"pre-commit>=4.7.0",`, on line 28. `uv.lock` has its exact
version, and those of the nine packages that it needs, such as `pyyaml` and `virtualenv`.

```bash
uv run pre-commit --version
```

It prints `pre-commit 4.7.0`, or a newer version. No hook is installed yet.

#### What changed

- <a id="step-04.12-pyproject.toml-5d07e7"></a>`pyproject.toml`: `pre-commit` in the group `lint`. 1 line added. It comes from `uv add --group lint pre-commit`. [The file](https://github.com/rahuldave/smallwikiapp/blob/29291b3575f2efd8f6062e3d04bbea648ae1fc11/pyproject.toml).
  - look at `"pre-commit>=4.7.0",`
- <a id="step-04.12-uv.lock-8356d8"></a>`uv.lock`: the exact version of `pre-commit`, and of what it needs. 136 lines added. It comes from `uv add --group lint pre-commit`. [The file](https://github.com/rahuldave/smallwikiapp/blob/29291b3575f2efd8f6062e3d04bbea648ae1fc11/uv.lock).

<details><summary>The diff of <code>pyproject.toml</code></summary>

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

[± See the new file `.pre-commit-config.yaml`](#step-04.13-.pre-commit-config.yaml-e7d14d)

[± See the change to `justfile`](#step-04.13-justfile-424f0b)

In `.pre-commit-config.yaml`, the three hooks under `repo: https://github.com/pre-commit/pre-commit-hooks`, on
line 6, come from `pre-commit`'s collection. The hook under `repo: local` has the line `entry: just check`, on
line 17. In the `justfile`, the recipe `hook *args:` on line 27 comes after `setup`, in the group `setup`. It runs
`uv run pre-commit install`.

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

#### What changed

- <a id="step-04.13-.pre-commit-config.yaml-e7d14d"></a>`.pre-commit-config.yaml`: three hooks from `pre-commit`'s collection, then `just check`. New, 20 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/6860da13f0fdf9595f32390f2fa70fe0976159b1/.pre-commit-config.yaml).
  - look at `entry: just check`
- <a id="step-04.13-justfile-424f0b"></a>`justfile`: the recipe `hook`. 5 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/6860da13f0fdf9595f32390f2fa70fe0976159b1/justfile).
  - look at `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`

<details><summary>The diff of <code>.pre-commit-config.yaml</code></summary>

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

<details><summary>The diff of <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6860da13f0fdf9595f32390f2fa70fe0976159b1).

This part ends at the code at `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-04)

<a id="step-05.4-to-step-05.6"></a>

## 5.4 to 5.6 The linter asks for types

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `b7a3e6d212b4`, partway through `step-05`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/b7a3e6d212b439920f62f0a023554b86d14ebd4e)

```bash
just setup
```

The code now also has ty, a type checker, which `just types` runs. A type says what kind of value a name has, for
example a string or a number. The code found the name of its package with
`__name__ or __package__`. It gave that name to `importlib.metadata.version`, which looks up the version of a
package. ty found that the name could be None, the value Python uses for no value at all, but
`importlib.metadata.version` needs a string. So the code now gives it the string `"wikiapp"`, the name of its
package.

ty checks only the types that are written in the code, and the code has almost none. ruff's rules `ANN` report
each parameter and each return value that has no type. Then the code and the tests get their types.

<a id="step-05.4"></a>

### 5.4 A type on every parameter and return

ty checks the types that the code states, and the code states almost none. ruff's rules `ANN` report each
parameter and each return without a type. So the linter checks that a type is written, and the type checker
checks that the type is right. The rules go in the list `select` in `pyproject.toml`.

[± See the change to `pyproject.toml`](#step-05.4-pyproject.toml-5d07e7)

In `pyproject.toml`, the list `select` now has `"ANN"` on line 67, after `"N"`.

```bash
just lint --statistics
```

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). The next two moves add them, in the code and then in the tests.

#### What changed

- <a id="step-05.4-pyproject.toml-5d07e7"></a>`pyproject.toml`: one line. 1 line added. [The file](https://github.com/rahuldave/smallwikiapp/blob/06613b9b25a8f16c7e60cf52803b2e471161d854/pyproject.toml).
  - look at `"ANN", # annotations: every parameter and every return value has a type`

<details><summary>The diff of <code>pyproject.toml</code></summary>

```diff
@@ -64,6 +64,7 @@ select = [
     "SIM", # simplify: code that can be said in fewer words
     "S",   # bandit: security, from `assert` in production code to a request with no timeout
     "N",   # pep8-naming: classes CamelCase, functions and variables lower_case
+    "ANN", # annotations: every parameter and every return value has a type
 ]
 
 [tool.ruff.lint.per-file-ignores]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/06613b9b25a8f16c7e60cf52803b2e471161d854). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/06613b9b25a8f16c7e60cf52803b2e471161d854).

<a id="step-05.5"></a>

### 5.5 Types in the code

The linter asks for types in `src/wikiapp/wikipedia.py` and `src/wikiapp/console.py`. `random_page` takes a
string. It returns the JSON that Wikipedia sends, which is a dictionary from strings to values of any kind. `Any`
says that ty cannot check the values. `Any` comes from the standard library, so its import is a block of its own,
above `import requests`.

[± See the change to `src/wikiapp/wikipedia.py`](#step-05.5-src-wikiapp-wikipedia.py-258803)

`main` takes the language as a string. Its return type, None, was already there.

[± See the change to `src/wikiapp/console.py`](#step-05.5-src-wikiapp-console.py-d9ae67)

In `src/wikiapp/wikipedia.py`, line 1 imports `Any`. On line 13, `random_page` now takes a `str`, and returns a
`dict[str, Any]`. In `src/wikiapp/console.py`, on line 19, the parameter `language` of `main` is a `str`.

```bash
just lint --statistics
```

22 problems are left, 13 parameters and 9 returns. The next move gives the tests their types.

#### What changed

- <a id="step-05.5-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the parameter. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/643f65323fd11c5c6f518c59431b13867e155952/src/wikiapp/console.py).
  - look at `def main(language: str) -> None:`
- <a id="step-05.5-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the parameter and the return. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/643f65323fd11c5c6f518c59431b13867e155952/src/wikiapp/wikipedia.py).
  - look at `def random_page(language: str = "en") -> dict[str, Any]:`

<details><summary>The diff of <code>src/wikiapp/console.py</code></summary>

```diff
@@ -16,7 +16,7 @@ from wikiapp.wikipedia import WikipediaError, random_page
     show_default=True,
 )
 @click.version_option(version=__version__)
-def main(language) -> None:
+def main(language: str) -> None:
     """Print the title and summary of a random Wikipedia page."""
     try:
         data = random_page(language=language)
```

</details>

<details><summary>The diff of <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+from typing import Any
+
 import requests
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
@@ -8,7 +10,7 @@ class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
 
-def random_page(language="en"):
+def random_page(language: str = "en") -> dict[str, Any]:
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/643f65323fd11c5c6f518c59431b13867e155952). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/643f65323fd11c5c6f518c59431b13867e155952).

<a id="step-05.6"></a>

### 5.6 Types in the tests

The code has its types, and `just lint` still finds 22 missing in the tests. A test returns None. The return type
of a fixture is the type of what a test receives.

The mock of `requests.get` is a `Mock`. `mocker` is
pytest-mock's `MockerFixture`. The original wikiapp used its older name, `MockFixture`. So
`tests/conftest.py` imports `Mock` and `MockerFixture`, and its fixture states both types.

[± See the change to `tests/conftest.py`](#step-05.6-tests-conftest.py-626af3)

In `tests/conftest.py`, the fixture on line 8 now reads `def mock_requests_get(mocker: MockerFixture) -> Mock:`.
`Mock` comes from `unittest.mock`, and `MockerFixture` from `pytest_mock`, in the imports above it.

The tests of the command need the same types. `tests/test_console.py` imports `Mock` and `CliRunner` by name,
in place of `import click.testing`. The fixture `runner` returns `CliRunner()`, so its return type is
`CliRunner`. In every test, `runner` is a `CliRunner`, `mock_requests_get` is a `Mock`, and the test returns
`None`.

[± See the change to `tests/test_console.py`](#step-05.6-tests-test_console.py-9442ee)

In `tests/test_console.py`, `from click.testing import CliRunner` on line 5 replaces `import click.testing`. The
fixture on line 11 reads `def runner() -> CliRunner:`, and each test names the types of its parameters and
returns `None`.

The test of the library gets its types the same way.

[± See the change to `tests/test_wikipedia.py`](#step-05.6-tests-test_wikipedia.py-2f4413)

In `tests/test_wikipedia.py`, `Mock` comes in on line 1, and the test on line 6 states its types.

```bash
just lint
just types
```

Both commands print `All checks passed!`.

```bash
just check
```

`just check` passes. pytest prints `7 passed`, and a coverage of 96.88%, above the floor of 90%.

#### What changed

- <a id="step-05.6-tests-conftest.py-626af3"></a>`tests/conftest.py`: the fixture returns a Mock. 4 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5873353449adaf1734a9cb14d13262486b1fb5d5/tests/conftest.py).
  - look at `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- <a id="step-05.6-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the runner is a CliRunner, and every test has its types. 11 lines added, 9 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5873353449adaf1734a9cb14d13262486b1fb5d5/tests/test_console.py).
  - look at `def runner() -> CliRunner:`
- <a id="step-05.6-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the import of `Mock`, and the types of one test. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5873353449adaf1734a9cb14d13262486b1fb5d5/tests/test_wikipedia.py).
  - look at `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

<details><summary>The diff of <code>tests/conftest.py</code></summary>

```diff
@@ -1,8 +1,11 @@
+from unittest.mock import Mock
+
 import pytest
+from pytest_mock import MockerFixture
 
 
 @pytest.fixture
-def mock_requests_get(mocker):
+def mock_requests_get(mocker: MockerFixture) -> Mock:
     mock = mocker.patch("requests.get")
     mock.return_value.__enter__.return_value.json.return_value = {
         "title": "Lorem Ipsum",
```

</details>

<details><summary>The diff of <code>tests/test_console.py</code></summary>

```diff
@@ -1,44 +1,46 @@
-import click.testing
+from unittest.mock import Mock
+
 import pytest
 import requests
+from click.testing import CliRunner
 
 from wikiapp import console
 
 
 @pytest.fixture
-def runner():
-    return click.testing.CliRunner()
+def runner() -> CliRunner:
+    return CliRunner()
 
 
-def test_main_prints_title(runner, mock_requests_get):
+def test_main_prints_title(runner: CliRunner, mock_requests_get: Mock) -> None:
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
 
-def test_main_invokes_requests_get(runner, mock_requests_get):
+def test_main_invokes_requests_get(runner: CliRunner, mock_requests_get: Mock) -> None:
     runner.invoke(console.main)
     assert mock_requests_get.called
 
 
-def test_main_uses_correct_url(runner, mock_requests_get):
+def test_main_uses_correct_url(runner: CliRunner, mock_requests_get: Mock) -> None:
     runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == (
         "https://en.wikipedia.org/api/rest_v1/page/random/summary",
     )
 
 
-def test_main_fails_on_request_error(runner, mock_requests_get):
+def test_main_fails_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
     mock_requests_get.side_effect = Exception("Boom")
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
 
-def test_main_prints_message_on_request_error(runner, mock_requests_get):
+def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_get: Mock) -> None:
     mock_requests_get.side_effect = requests.RequestException
     result = runner.invoke(console.main)
     assert "Error" in result.output
 
 
-def test_main_succeeds(runner):
+def test_main_succeeds(runner: CliRunner) -> None:
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

<details><summary>The diff of <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -1,7 +1,9 @@
+from unittest.mock import Mock
+
 from wikiapp import wikipedia
 
 
-def test_random_page_uses_given_language(mock_requests_get):
+def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/5873353449adaf1734a9cb14d13262486b1fb5d5).

This part ends at the code at `5873353449ad`, partway through `step-05`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/5873353449adaf1734a9cb14d13262486b1fb5d5)

<a id="step-10.3"></a>

## 10.3 The library's pyproject.toml too

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `6e6d2844bc7a`, partway through `step-10`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/6e6d2844bc7a5b34605ad76b9e03e6631fa236be)

```bash
just setup
```

The code now also has the type checker in `just check`. The project accepts any Python from 3.11 on. On every push
to main, GitHub runs the tests and `just check`, and it publishes a site with the docs.

`random_page`, the function of the library that asks Wikipedia for a random page, returns a `Page`. A `Page`
has a title and a summary, and pydantic, a library that checks data, checks that the answer of Wikipedia has
both. smalldocs documents the code, and `just check` runs the check of
the docs. The library is a package of its own, `packages/wikirandom`, with its own `pyproject.toml`. `just build`
builds both packages. The app is the package `wikiapp`, and it needs a 0.1 version of wikirandom.

Until this section, `just lint-config` checks only the app's `pyproject.toml`. After it, `just lint-config` also
checks the library's `pyproject.toml`.

### 10.3 lint-config checks both pyproject.toml files

The repository has two `pyproject.toml` files, and `just lint-config` checks only the app's. A mistake in the
library's file would reach a build unseen. The recipe `lint-config` now gives validate-pyproject both files.

[± See the change to `justfile`](#step-10.3-justfile-424f0b)

```bash
just lint-config
```

`just lint-config` prints `Valid file` twice, once for each file.

This tutorial ends here. After it, the whole tutorial gives the library a licence. Both packages get a link to the
repository, and the User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.

#### What changed

- <a id="step-10.3-justfile-424f0b"></a>`justfile`: two files. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/522bcb94133654c1e72a9592c852681e0b5e2055/justfile).
  - look at `uv run validate-pyproject pyproject.toml packages/wikirandom/pyproject.toml`

<details><summary>The diff of <code>justfile</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/522bcb94133654c1e72a9592c852681e0b5e2055).

This part ends at the code at `522bcb941336`, partway through `step-10`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/522bcb94133654c1e72a9592c852681e0b5e2055)
