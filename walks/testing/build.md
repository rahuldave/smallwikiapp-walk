<!-- Made by the walk skill's render.py from the facts of the walk. Do not edit it by hand: run just walk-update again. -->

# The tests

**Build it yourself.** Every command to run and every change to make by hand, to make the project yourself. [Read the tutorial](read.md) is the other way to read it.

Each part ends with a section called **What changed**. It lists every file that the part changes, with a link to the file, and then the whole diff of each file, folded. A lockfile and a binary file have a link alone. The text above it explains the change. What changed is what you check your files against.

In Build it yourself, a file that a command makes says which command. A diff that is open is a patch. Apply it with the command in the text, or make the same change in your editor.

We build the tests of `wikiapp`, a small command that prints the title and the summary of a random Wikipedia
page. A test runs the code and checks what it gives back, so a later change cannot break the command without a
failure. This tutorial takes the parts about tests out of the whole tutorial of smallwikiapp. It starts from the
project that `uv init` made, for Python 3.13. Then the command gets its code, and the tests come after it.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote
in 2024 with pixi. Where the text says "the original wikiapp", it means that project.

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

This tutorial has fourteen sections:

1. **The project**
2. **The command under test**
3. **pytest and a first test**
4. **Fixtures and mocks**
5. **Coverage**
6. **A shared mock in conftest.py**
7. **A test of the language**
8. **A test of an error message**
9. **`just check`, with a coverage floor**
10. **End-to-end tests, on request**
11. **The tests on GitHub**
12. **Tests of a model**
13. **A drop in coverage**
14. **GitHub installs only the test tools**

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**Kinds of tests**

Each kind of test comes in at the section in the table. The tutorial adds no test for the sake of a kind.

| Kind | What it checks | Where |
|---|---|---|
| End-to-end | The code against the real Wikipedia, with no mock | Section 3. From section 10, it runs only when you ask for it |
| Unit | One part of the code alone, with a mock in place of the network | Section 4 for the command, until section 6 moves the request into a library. Section 7 for the library |
| Integration | The command and the library together, with only the network a mock | Section 6. The unit tests of the command become integration tests |
| Contract | That the real Wikipedia still answers as the mocks do | Section 10 |

## Get the project

You build the project in a clone of your own, on a branch `mine` that starts where this walk starts. Run the commands of these pages in its top folder.

```bash
git clone https://github.com/rahuldave/smallwikiapp
cd smallwikiapp
git switch -c mine ae86cb7d116c
```

Then add the command `git check`, which compares your files with the project's after each move, and leaves what `git add` has staged as it was. It compares `pyproject.toml` and `uv.lock` by the names of their packages, so another version of a package does not count as a difference. A small Python program, `package_names.py`, reads each of these files as data, and uv runs it. These commands write the program into the folder `.git`, and tell git to show each file as the program prints it.

```bash
cat > "$(git rev-parse --git-common-dir)/package_names.py" <<'PY'
"""Print a pyproject.toml or a uv.lock without the versions of its packages, so that git check compares their names.

    python package_names.py pyproject.toml FILE
    python package_names.py uv.lock FILE

A pyproject.toml keeps all it says, with each requirement cut to its name, its extras, its address and its marker. A
uv.lock keeps the names that the project's own packages ask for, and the members of the workspace. The rules are those
of timewalk's package_names. The result is JSON, one item a line. A file that is not TOML is printed as it is.
"""

import json
import re
import sys
import tomllib

# A requirement such as "pytest>=8.3.4", "Uvicorn[standard] ; python_version < '3.12'" or "x @ git+https://...": its name,
# its extras, what comes between (the versions, or "@" and an address), and its marker after the ";".
REQUIREMENT = re.compile(r"^\s*([A-Za-z0-9][A-Za-z0-9._-]*)\s*(\[[^\]]*\])?([^;]*)(?:;(.*))?$", re.S)


def package_names(
    path: str,  # The file's path in the project; its name says how to read it
    data: bytes,  # Its contents
) -> object | None:  # What it says without the versions of packages, to compare; None if it is not a file of packages
    """Read a pyproject.toml or a uv.lock with the versions left out, as timewalk's package_names does."""
    name = path.rsplit("/", 1)[-1]
    if name not in ("pyproject.toml", "uv.lock"):
        return None
    try:
        doc = tomllib.loads(data.decode("utf-8"))
    except (UnicodeDecodeError, tomllib.TOMLDecodeError):
        return None

    def cut(requirement: object) -> object:   # "pytest>=8.3.4" is pytest; a table, such as { include-group = "test" }, stays
        found = REQUIREMENT.match(requirement) if isinstance(requirement, str) else None
        if not found:
            return requirement
        extras = sorted(e.strip().lower() for e in (found.group(2) or "[]")[1:-1].split(",") if e.strip())
        between, marker = found.group(3).strip(), " ".join((found.group(4) or "").split())
        address = between[1:].strip() if between.startswith("@") else ""   # a package from an address: the address counts
        return (re.sub(r"[-_.]+", "-", found.group(1)).lower() + (f"[{','.join(extras)}]" if extras else "")
                + (f" @ {address}" if address else "") + (f"; {marker}" if marker else ""))

    def names(value: object) -> list:   # every name = "..." in a table, at any depth
        if isinstance(value, dict):
            return [*([value["name"]] if isinstance(value.get("name"), str) else []), *(n for v in value.values() for n in names(v))]
        return [n for v in value for n in names(v)] if isinstance(value, list) else []

    if name == "uv.lock":
        own = [p for p in doc.get("package", []) if isinstance(p, dict) and isinstance(p.get("source"), dict)
               and {"editable", "virtual"} & set(p["source"])]
        return {"requires-python": doc.get("requires-python"), "manifest": sorted(set(names(doc.get("manifest", {})))),
                "own": {p.get("name"): sorted(set(names({k: v for k, v in p.items() if k not in ("name", "version", "source")})))
                        for p in own}}
    lists = [("project", "dependencies"), ("build-system", "requires"), ("tool", "uv", "dev-dependencies")]
    groups = [("project", "optional-dependencies"), ("dependency-groups",)]

    def at(keys: tuple) -> object:   # the table or list at a path of keys, or None
        value = doc
        for key in keys:
            value = value.get(key) if isinstance(value, dict) else None
        return value

    for keys in lists:
        if isinstance(at(keys), list):
            at(keys[:-1])[keys[-1]] = sorted(map(cut, at(keys)), key=repr)
    for keys in groups:
        table = at(keys)
        for group, wanted in (table.items() if isinstance(table, dict) else []):
            if isinstance(wanted, list):
                table[group] = sorted(map(cut, wanted), key=repr)
    return doc


def main() -> int:  # The exit code
    """Print a file as package_names reads it, or as it is when it is not TOML."""
    kind, file = sys.argv[1], sys.argv[2]
    with open(file, "rb") as handle:
        data = handle.read()
    found = package_names(kind, data)
    if found is None:
        sys.stdout.buffer.write(data)
    else:
        print(json.dumps(found, indent=1, sort_keys=True, ensure_ascii=False, default=str))
    return 0


if __name__ == "__main__":
    sys.exit(main())
PY
echo '/pyproject.toml diff=pyproject' >> .git/info/attributes
echo '/uv.lock diff=uvlock' >> .git/info/attributes
git config diff.pyproject.textconv 'uv run --quiet --no-config --no-project --python ">=3.11" python "$(git rev-parse --git-common-dir)/package_names.py" pyproject.toml'
git config diff.uvlock.textconv 'uv run --quiet --no-config --no-project --python ">=3.11" python "$(git rev-parse --git-common-dir)/package_names.py" uv.lock'
git config alias.check '!f() { i="$(git rev-parse --git-path check-index)" && { cp -p "$(git rev-parse --git-path index)" "$i" 2>/dev/null || rm -f "$i"; } && export GIT_INDEX_FILE="$i" && git add -A && git diff --cached "$1" -- ":/"; }; f'
```

<a id="step-00"></a>

## 0 The project

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part is where the project starts, at `step-00`. [The code of this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

Before there is code to test, there is a project. This section shows what `uv init` made, and the command
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

Check your files against this part. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check ae86cb7d116c
```

If you are stuck, this command puts the files of this part in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git rm -rq --cached --ignore-unmatch -- :/ && git restore --source step-00 --staged --worktree -- :/
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

## 1 The command under test

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-00`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

The tests need a command to test. The command asks Wikipedia for a random page, and prints its title and summary.
It sends a User-Agent, and has an option `--version`. The next sections test this command.

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

```bash
uv add click requests
```

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

If your versions are newer, `uv add` writes them into `pyproject.toml` and `uv.lock`. Only those versions differ
from the ones here.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 36d49582843a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-00 --staged -- :/ && git restore --source 36d49582843a --staged --worktree -- :/
```

#### What changed

- <a id="step-01.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the dependencies of the package, which anyone who installs it gets. 4 lines added, 1 removed. It comes from `uv add click requests`. [The file](https://github.com/rahuldave/smallwikiapp/blob/36d49582843a575d84ed178ad66157913be4c59c/pyproject.toml).
  - look at `"click>=8.5.0",`
- <a id="step-01.1-uv.lock-8356d8"></a>`uv.lock`: the exact versions, for every platform. 176 lines added. It comes from `uv add click requests`. [The file](https://github.com/rahuldave/smallwikiapp/blob/36d49582843a575d84ed178ad66157913be4c59c/uv.lock).

<a id="step-01.1-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff that <code>uv add click requests</code> makes in <code>pyproject.toml</code></summary>

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

Apply the patch to [`src/wikiapp/console.py`](#step-01.2-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/571c82ebd31fee095e56a45cf2bf77eb7bfe0c8c.diff | git apply --include=src/wikiapp/console.py
```

Read the new `main` in the patch, from `@click.command()` down. The imports of click, requests and textwrap, and the
constant `API_URL`, are above it.

```bash
uv run wikiapp
```

The command fails. The last line of the traceback is `requests.exceptions.HTTPError: 403 Client Error:
Forbidden for url:` and the address. A request carries headers, which are named lines of text sent with the
address. The header User-Agent names the program that sends the request. Wikipedia refuses a request whose
User-Agent is the default of a library. requests sends `python-requests/` and its version.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 571c82ebd31f
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 36d49582843a --staged -- :/ && git restore --source 571c82ebd31f --staged --worktree -- :/
```

#### What changed

- <a id="step-01.2-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: a request, and two lines printed. 17 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/571c82ebd31fee095e56a45cf2bf77eb7bfe0c8c/src/wikiapp/console.py).
  - look at `with requests.get(API_URL) as response:`

<a id="step-01.2-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

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

Apply the patch to [`src/wikiapp/console.py`](#step-01.3-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/0ffd5df563acb876953855d86be30b6952ecfd44.diff | git apply --include=src/wikiapp/console.py
```

The patch adds `USER_AGENT` under the line `API_URL = ...`. It also changes the line of the request, so the request
sends the header.

```bash
uv run wikiapp
```

It prints a title in green, and a paragraph. Each run prints another page.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 0ffd5df563ac
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 571c82ebd31f --staged -- :/ && git restore --source 0ffd5df563ac --staged --worktree -- :/
```

#### What changed

- <a id="step-01.3-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the header. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/0ffd5df563acb876953855d86be30b6952ecfd44/src/wikiapp/console.py).
  - look at `with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:`

<a id="step-01.3-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

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

Apply the patch to [`src/wikiapp/__init__.py`](#step-01.4-src-wikiapp-__init__.py-682a01), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/f05d3c31be2cf640cc2aa4345658b8eebc394d60.diff | git apply --include=src/wikiapp/__init__.py
```

Apply the patch to [`src/wikiapp/console.py`](#step-01.4-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/f05d3c31be2cf640cc2aa4345658b8eebc394d60.diff | git apply --include=src/wikiapp/console.py
```

`src/wikiapp/__init__.py` was empty, and the patch gives it two lines. In `src/wikiapp/console.py`, the patch adds
`from wikiapp import __version__` under the line `import click`. It also adds `@click.version_option(...)` between
`@click.command()` and `def main`.

```bash
uv run wikiapp --version
uv run wikiapp --help
```

`--version` prints `wikiapp, version 0.1.0`. `--help` lists both options. click writes the help from the
decorators and the docstring. So the docstring of `main` is also help text, for a person who runs the command.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check f05d3c31be2c
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 0ffd5df563ac --staged -- :/ && git restore --source step-01 --staged --worktree -- :/
```

#### What changed

- <a id="step-01.4-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: the version, which Python reads when it imports the package. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/f05d3c31be2cf640cc2aa4345658b8eebc394d60/src/wikiapp/__init__.py).
  - look at `__version__ = importlib.metadata.version(__name__ or __package__)`
- <a id="step-01.4-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: click's version option. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/f05d3c31be2cf640cc2aa4345658b8eebc394d60/src/wikiapp/console.py).
  - look at `@click.version_option(version=__version__)`

<a id="step-01.4-src-wikiapp-__init__.py-682a01-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -0,0 +1,2 @@
+import importlib.metadata
+__version__ = importlib.metadata.version(__name__ or __package__)
```

</details>

<a id="step-01.4-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

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

<a id="step-02.1-to-step-02.4"></a>

## 2.1 to 2.4 pytest and a first test

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-01`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-01)

```bash
just setup
```

We can check the command only by running it and reading what it prints. [pytest](https://docs.pytest.org/) runs tests for us, and `just test`
runs them all.

<a id="step-02.1"></a>

### 2.1 uv installs every dependency group

The tests need pytest, but the package does not. A person who installs wikiapp should not get pytest. So the tools
of the project go in dependency groups. A dependency group is a list of packages in `pyproject.toml` that the
project needs while we work on it. A user of the package never gets them. The test tools go in a group `test`, and
later the linters and the docs tools get groups of their own.

uv installs only the group `dev` by default. The setting `default-groups = "all"` makes `uv sync` and `uv run`
install every group. So each later `uv add --group` needs no other change to `pyproject.toml`. A patch adds the
table `[tool.uv]` with this setting.

Set the values that this change sets in [`pyproject.toml`](#step-02.1-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '46dc20fb9092:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'uv'),
]

def body(table):   # the items of a table in their order, with its comment lines
    inner = table if isinstance(table, tomlkit.TOMLDocument) else getattr(table, 'value', None)
    return getattr(inner, 'body', [])

def above(table, key):   # the comment lines just above a key
    found = []
    for name, item in body(table):
        if name is not None and name.key == key:
            return found
        found = found + [item] if isinstance(item, Comment) else found if isinstance(item, Whitespace) else []
    return []

for keys in COPY:
    source, target = project, doc
    for key in keys[:-1]:   # make each table on the way
        source = source[key]
        if key not in target:
            target[key] = tomlkit.table(True)
        target = target[key]
    item = copy.deepcopy(source[keys[-1]])
    if isinstance(item, Table) and not item.as_string().endswith('\n\n'):
        item.add(tomlkit.nl())   # a blank line before the table after it
    if keys[-1] not in target:
        for comment in above(source, keys[-1]):
            target.add(copy.deepcopy(comment))
    target[keys[-1]] = item
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

The change adds the table `[tool.uv]` to `pyproject.toml`. It has a comment and one setting.

The setting changes which groups uv installs, not which versions. So `uv.lock` still matches `pyproject.toml`.

```bash
uv lock --check
```

uv prints `Resolved 7 packages`, and no error. The project has no groups yet, so the setting changes nothing until a later move adds one.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 46dc20fb9092
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-01 --staged -- :/ && git restore --source 46dc20fb9092 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the table `[tool.uv]`, so uv installs every dependency group. 4 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/46dc20fb9092170695699eaa052f4830563cb930/pyproject.toml).
  - look at `default-groups = "all"`

<a id="step-02.1-pyproject.toml-5d07e7-diff"></a>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -18,3 +18,7 @@ wikiapp = "wikiapp.console:main"
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
+
+[tool.uv]
+# uv sync and uv run install every dependency group, not only dev
+default-groups = "all"
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/46dc20fb9092170695699eaa052f4830563cb930). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/46dc20fb9092170695699eaa052f4830563cb930).

<a id="step-02.2"></a>

### 2.2 The first test

Nothing checks yet that the command works. The first test runs the command and checks that it ends with exit code
0. click's `CliRunner` runs a command in the same process as the test. It keeps the output and the exit code of
the command.

This test is an end-to-end test. It runs the whole command, and the command asks the real Wikipedia. So a failure
can come from the code, from the network or from Wikipedia.

The test comes in a new file, `tests/test_console.py`, as a patch. The patch also makes the folder `tests`.

Apply the patch to [`tests/test_console.py`](#step-02.2-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/6d7a6cfdae6008a9687f3525348ab24ea05930cc.diff | git apply --include=tests/test_console.py
```

Read the one test, `test_main_succeeds`, before you run it.

pytest is not installed yet, so the test cannot run. `python -m pytest` uses the pytest of the project's `.venv`,
and never one from elsewhere.

```bash
uv run python -m pytest
```

The command fails on purpose. Python prints `No module named pytest`, and the exit code is 1. The next move installs pytest.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 6d7a6cfdae60
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 46dc20fb9092 --staged -- :/ && git restore --source 6d7a6cfdae60 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.2-tests-test_console.py-9442ee"></a>`tests/test_console.py`: a test that runs the command and checks its exit code. New, 8 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/6d7a6cfdae6008a9687f3525348ab24ea05930cc/tests/test_console.py).
  - look at `assert result.exit_code == 0`

<a id="step-02.2-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -0,0 +1,8 @@
+import click.testing
+
+from wikiapp import console
+
+def test_main_succeeds():
+    runner = click.testing.CliRunner()
+    result = runner.invoke(console.main)
+    assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6d7a6cfdae6008a9687f3525348ab24ea05930cc). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/6d7a6cfdae6008a9687f3525348ab24ea05930cc).

<a id="step-02.3"></a>

### 2.3 pytest, in the group test

The test needs [pytest](https://docs.pytest.org/). `uv add --group test` writes pytest into a new group `test` of `pyproject.toml`, adds its
exact version to `uv.lock`, and installs it.

pytest is the test runner of most Python projects. It finds each function whose name
starts with `test_`, in the files whose names start with `test_`, and runs it. When an `assert` fails, it prints the
values on both sides.

```bash
uv add --group test pytest
```

```bash
uv run pytest
```

pytest finds `tests/test_console.py`, and prints `collected 1 item` and `1 passed`. The test asks the real
Wikipedia, so it needs the network.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check d92e2dec921d
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 6d7a6cfdae60 --staged -- :/ && git restore --source d92e2dec921d --staged --worktree -- :/
```

#### What changed

- <a id="step-02.3-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group `test`, with pytest. 5 lines added. It comes from `uv add --group test pytest`. [The file](https://github.com/rahuldave/smallwikiapp/blob/d92e2dec921d6322e2a356af20dafef3837c1849/pyproject.toml).
  - look at `"pytest>=9.1.1",`
- <a id="step-02.3-uv.lock-8356d8"></a>`uv.lock`: pytest, and the packages that it needs. 69 lines added. It comes from `uv add --group test pytest`. [The file](https://github.com/rahuldave/smallwikiapp/blob/d92e2dec921d6322e2a356af20dafef3837c1849/uv.lock).

<a id="step-02.3-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff that <code>uv add --group test pytest</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -22,3 +22,8 @@ build-backend = "uv_build"
 [tool.uv]
 # uv sync and uv run install every dependency group, not only dev
 default-groups = "all"
+
+[dependency-groups]
+test = [
+    "pytest>=9.1.1",
+]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/d92e2dec921d6322e2a356af20dafef3837c1849). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d92e2dec921d6322e2a356af20dafef3837c1849).

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

<a id="step-02.4-justfile-424f0b-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/45807a0ddd9f97798c3f86a82b19782d4df45837).

This part ends at the code at `45807a0ddd9f`, partway through `step-02`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/45807a0ddd9f97798c3f86a82b19782d4df45837)

<a id="step-02.5-to-step-02.9"></a>

## 2.5 to 2.9 Fixtures and mocks

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `45807a0ddd9f`, partway through `step-02`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/45807a0ddd9f97798c3f86a82b19782d4df45837)

```bash
just setup
```

The first test asks the real Wikipedia, so it is slow and needs the network. A mock solves that. It takes the
place of Wikipedia in the tests, and gives back a made-up page, "Lorem Ipsum", with no network.

The tests get the mock from a fixture. A fixture is a function that pytest calls for each test that names it as a
parameter. A second fixture gives each test a runner, which runs the command and keeps what it prints. The tests
check the title that the command prints, that the command made a request, and the address of the request.

When a command ends, it gives back a number, its exit code. The number is 0 when the command works, and another number,
such as 1, when it fails. A last test makes the request fail, and checks that the command ends with exit code 1.

<a id="step-02.5"></a>

### 2.5 The runner as a fixture

Each test of the command needs a `CliRunner`, and each would make its own. A fixture puts the code that makes it in one place.
A fixture is a function that pytest calls for each test that names it as a parameter. So a fixture `runner`
returns a `CliRunner`, and `test_main_succeeds` takes the runner as its parameter.

Apply the patch to [`tests/test_console.py`](#step-02.5-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/8435ae56cf5630c401d83760b4dffe1fe5bde109.diff | git apply --include=tests/test_console.py
```

The patch adds `import pytest` and the fixture `runner` above the line `from wikiapp import console`. It gives
`test_main_succeeds` the parameter `runner`, in place of its own `CliRunner`.

```bash
just test
```

The test passes as before, with `1 passed`. It still asks the real Wikipedia.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 8435ae56cf56
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 45807a0ddd9f --staged -- :/ && git restore --source 8435ae56cf56 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.5-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the fixture, and the test that names it. 6 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/8435ae56cf5630c401d83760b4dffe1fe5bde109/tests/test_console.py).
  - look at `def test_main_succeeds(runner):`

<a id="step-02.5-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -1,8 +1,12 @@
 import click.testing
+import pytest
+
+@pytest.fixture
+def runner():
+    return click.testing.CliRunner()
 
 from wikiapp import console
 
-def test_main_succeeds():
-    runner = click.testing.CliRunner()
+def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/8435ae56cf5630c401d83760b4dffe1fe5bde109). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/8435ae56cf5630c401d83760b4dffe1fe5bde109).

<a id="step-02.6"></a>

### 2.6 pytest-mock, in the group test

A test that needs the network fails on a train. Also, a test cannot check the title of a random page. A mock
solves both. [pytest-mock](https://pytest-mock.readthedocs.io/) replaces a function with a mock for the length of one test. Its fixture `mocker` does
this, and puts the function back after the test. pytest-mock goes in the group `test`.

pytest-mock is a plugin of pytest. Python's standard library already has
mocks, in `unittest.mock`. pytest-mock gives them to a test through a fixture, so each mock ends with its test.

```bash
uv add --group test pytest-mock
```

```bash
just test
```

No test uses the mock yet, so the result is the same, `1 passed`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 55b7b55dffa3
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 8435ae56cf56 --staged -- :/ && git restore --source 55b7b55dffa3 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.6-pyproject.toml-5d07e7"></a>`pyproject.toml`: pytest-mock in the group `test`. 1 line added. It comes from `uv add --group test pytest-mock`. [The file](https://github.com/rahuldave/smallwikiapp/blob/55b7b55dffa30e6eb91a88c882201f955271e28d/pyproject.toml).
  - look at `"pytest-mock>=3.16.0",`
- <a id="step-02.6-uv.lock-8356d8"></a>`uv.lock`: the exact version of pytest-mock. 17 lines added, 1 removed. It comes from `uv add --group test pytest-mock`. [The file](https://github.com/rahuldave/smallwikiapp/blob/55b7b55dffa30e6eb91a88c882201f955271e28d/uv.lock).

<a id="step-02.6-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff that <code>uv add --group test pytest-mock</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -26,4 +26,5 @@ default-groups = "all"
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
+    "pytest-mock>=3.16.0",
 ]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/55b7b55dffa30e6eb91a88c882201f955271e28d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/55b7b55dffa30e6eb91a88c882201f955271e28d).

<a id="step-02.7"></a>

### 2.7 A mock in place of Wikipedia

The mock now takes the place of `requests.get`. A new fixture, `mock_requests_get`, calls
`mocker.patch("requests.get")`. The line `mock.return_value.__enter__.return_value.json.return_value = {` sets
what the mock returns when the code calls `response.json()` inside the `with` block. The mock returns a page with
the title Lorem Ipsum.

A new test, `test_main_prints_title`, checks that the command prints that title.

A test that uses the mock is a unit test of the command. It checks the command alone, without the network, so a
failure points at the command. `test_main_succeeds` still asks the real Wikipedia.

Apply the patch to [`tests/test_console.py`](#step-02.7-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/7c1911b9f0155df43da70d010b25fc1ec947fe7c.diff | git apply --include=tests/test_console.py
```

The patch adds the fixture `mock_requests_get` under the fixture `runner`. It adds `test_main_prints_title` above
`test_main_succeeds`.

```bash
just test -k title -v
```

pytest runs only the test whose name contains `title`. The output shows `test_main_prints_title PASSED` and
`1 passed, 1 deselected`, without the network.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 7c1911b9f015
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 55b7b55dffa3 --staged -- :/ && git restore --source 7c1911b9f015 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.7-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the fixture of the mock, and the new test. 13 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/7c1911b9f0155df43da70d010b25fc1ec947fe7c/tests/test_console.py).
  - look at `mock = mocker.patch("requests.get")`

<a id="step-02.7-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -5,8 +5,21 @@ import pytest
 def runner():
     return click.testing.CliRunner()
 
+@pytest.fixture
+def mock_requests_get(mocker):
+    mock = mocker.patch("requests.get")
+    mock.return_value.__enter__.return_value.json.return_value = {
+        "title": "Lorem Ipsum",
+        "extract": "Lorem ipsum dolor sit amet",
+    }
+    return mock
+
 from wikiapp import console
 
+def test_main_prints_title(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert "Lorem Ipsum" in result.output
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/7c1911b9f0155df43da70d010b25fc1ec947fe7c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/7c1911b9f0155df43da70d010b25fc1ec947fe7c).

<a id="step-02.8"></a>

### 2.8 Tests of the request

The test of the title shows what the command prints. It does not show that the command asks Wikipedia, or at
which address. A mock keeps a record of each call to it, and two tests read that record.
`test_main_invokes_requests_get` checks that the command calls `requests.get`, and `test_main_uses_correct_url`
checks the address.

`call_args[0]` contains the arguments that the last call gave in order, without a name. Here that is only the
address. The call gives the header by name, as `headers=...`, so the header is in `call_args[1]`.

Apply the patch to [`tests/test_console.py`](#step-02.8-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/9be013d11b88d0e40680024a8ea99d501c681252.diff | git apply --include=tests/test_console.py
```

The patch adds the two tests after `test_main_prints_title`.

```bash
just test
```

The result is `4 passed`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 9be013d11b88
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 7c1911b9f015 --staged -- :/ && git restore --source 9be013d11b88 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.8-tests-test_console.py-9442ee"></a>`tests/test_console.py`: two tests, that the command makes the request, and to the right address. 8 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/9be013d11b88d0e40680024a8ea99d501c681252/tests/test_console.py).
  - look at `assert mock_requests_get.called`

<a id="step-02.8-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -20,6 +20,14 @@ def test_main_prints_title(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert "Lorem Ipsum" in result.output
 
+def test_main_invokes_requests_get(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert mock_requests_get.called
+
+def test_main_uses_correct_url(runner, mock_requests_get):
+    result = runner.invoke(console.main)
+    assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/9be013d11b88d0e40680024a8ea99d501c681252). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/9be013d11b88d0e40680024a8ea99d501c681252).

<a id="step-02.9"></a>

### 2.9 A test of a failed request

A request can fail, and nothing checks what the command does then. A mock can raise an exception as well as return
a value. If `side_effect` is an exception, a call to the mock raises it. A test,
`test_main_fails_on_request_error`, makes the mock raise, and checks that the command ends with exit code 1.

Apply the patch to [`tests/test_console.py`](#step-02.9-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/bfc38e738984492a5dbf6a1a6a0b6691baad4c34.diff | git apply --include=tests/test_console.py
```

The patch adds the test above `test_main_succeeds`.

```bash
just test
```

The result is `5 passed`.

The command now has four tests that use the mock, and one that asks the real Wikipedia.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check bfc38e738984
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 9be013d11b88 --staged -- :/ && git restore --source bfc38e738984 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.9-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the mock raises. 5 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/bfc38e738984492a5dbf6a1a6a0b6691baad4c34/tests/test_console.py).
  - look at `mock_requests_get.side_effect = Exception("Boom")`

<a id="step-02.9-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -28,6 +28,11 @@ def test_main_uses_correct_url(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert mock_requests_get.call_args[0] == ("https://en.wikipedia.org/api/rest_v1/page/random/summary",)
 
+def test_main_fails_on_request_error(runner, mock_requests_get):
+    mock_requests_get.side_effect = Exception("Boom")
+    result = runner.invoke(console.main)
+    assert result.exit_code == 1
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/bfc38e738984492a5dbf6a1a6a0b6691baad4c34).

This part ends at the code at `bfc38e738984`, partway through `step-02`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/bfc38e738984492a5dbf6a1a6a0b6691baad4c34)

<a id="step-02.10-to-step-02.11"></a>

## 2.10 to 2.11 Coverage

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `bfc38e738984`, partway through `step-02`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/bfc38e738984492a5dbf6a1a6a0b6691baad4c34)

```bash
just setup
```

The tests pass, but nothing says which lines of the code they run. From now on, each run of the tests measures
the coverage, the share of the lines that the tests run.

<a id="step-02.10"></a>

### 2.10 pytest-cov, in the group test

The tests pass, but we do not know which lines of the code they run. [pytest-cov](https://pytest-cov.readthedocs.io/) measures that, when pytest gets the
option `--cov`. It goes in the group `test`.

pytest-cov is a plugin of pytest. It runs the tests under coverage.py, which
records each line that runs, and it prints the report at the end.

```bash
uv add --group test pytest-cov
```

```bash
just test --cov=wikiapp
```

Under the tests, a table lists each file of `src/wikiapp`, with its statements and the share of them that ran.
`console.py` has 18 statements. One of them did not run, so its line reads `94%`. The total is `95%`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 8409e0f2e7f6
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source bfc38e738984 --staged -- :/ && git restore --source 8409e0f2e7f6 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.10-pyproject.toml-5d07e7"></a>`pyproject.toml`: pytest-cov in the group `test`. 1 line added. It comes from `uv add --group test pytest-cov`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8409e0f2e7f68a697de1e8bf32a745658364f17f/pyproject.toml).
  - look at `"pytest-cov>=7.1.0",`
- <a id="step-02.10-uv.lock-8356d8"></a>`uv.lock`: pytest-cov, and coverage, the package that it needs. 100 lines added. It comes from `uv add --group test pytest-cov`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8409e0f2e7f68a697de1e8bf32a745658364f17f/uv.lock).

<a id="step-02.10-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff that <code>uv add --group test pytest-cov</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -26,5 +26,6 @@ default-groups = "all"
 [dependency-groups]
 test = [
     "pytest>=9.1.1",
+    "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/8409e0f2e7f68a697de1e8bf32a745658364f17f). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/8409e0f2e7f68a697de1e8bf32a745658364f17f).

<a id="step-02.11"></a>

### 2.11 Coverage on every run

A person can forget to type `--cov=wikiapp`. The settings of pytest in `pyproject.toml` give it options for
every run. They tell pytest to look for tests in `tests`, to measure coverage, and to list the lines that no test
ran.

Set the values that this change sets in [`pyproject.toml`](#step-02.11-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '7508f1d424d5:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'pytest', 'ini_options'),
]

def body(table):   # the items of a table in their order, with its comment lines
    inner = table if isinstance(table, tomlkit.TOMLDocument) else getattr(table, 'value', None)
    return getattr(inner, 'body', [])

def above(table, key):   # the comment lines just above a key
    found = []
    for name, item in body(table):
        if name is not None and name.key == key:
            return found
        found = found + [item] if isinstance(item, Comment) else found if isinstance(item, Whitespace) else []
    return []

for keys in COPY:
    source, target = project, doc
    for key in keys[:-1]:   # make each table on the way
        source = source[key]
        if key not in target:
            target[key] = tomlkit.table(True)
        target = target[key]
    item = copy.deepcopy(source[keys[-1]])
    if isinstance(item, Table) and not item.as_string().endswith('\n\n'):
        item.add(tomlkit.nl())   # a blank line before the table after it
    if keys[-1] not in target:
        for comment in above(source, keys[-1]):
            target.add(copy.deepcopy(comment))
    target[keys[-1]] = item
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

The change adds the table `[tool.pytest.ini_options]` to `pyproject.toml`.

The tests of the original wikiapp had one more fixture, `mock_wikipedia_random_page`, and a test that was commented
out. No test used them, so the project does not keep them.

```bash
just test
```

The table under the tests now has a column `Missing`. `console.py` reads `94%`, and its missing line is 22. Line 22
is the call to `main` at the end, which runs only when you run the file as a script.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 7508f1d424d5
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 8409e0f2e7f6 --staged -- :/ && git restore --source step-02 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.11-pyproject.toml-5d07e7"></a>`pyproject.toml`: the settings of pytest. They name the folder of the tests, and turn coverage on for every run. 5 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/7508f1d424d5f906ee4630be09b2fddf3483e9c4/pyproject.toml).
  - look at `addopts = "--cov=wikiapp --cov-report=term-missing"`

<a id="step-02.11-pyproject.toml-5d07e7-diff"></a>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -29,3 +29,8 @@ test = [
     "pytest-cov>=7.1.0",
     "pytest-mock>=3.16.0",
 ]
+
+[tool.pytest.ini_options]
+testpaths = ["tests"]
+# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
+addopts = "--cov=wikiapp --cov-report=term-missing"
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/7508f1d424d5f906ee4630be09b2fddf3483e9c4).

This part ends at the code at `step-02`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-02)

<a id="step-03.2"></a>

## 3.2 A shared mock in conftest.py

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `3f6d8cf59ab3`, partway through `step-03`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205)

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git fetch --quiet --tags --force origin; git restore --source step-02 --staged -- :/ && git restore --source 3f6d8cf59ab3 --staged --worktree -- :/
```

```bash
just setup
```

The code now has a library, a new module `src/wikiapp/wikipedia.py`, with a function `random_page`. The request
moved out of the command into `random_page`, and the command calls it.

Tests of the library need the mock too, and it is in the tests of the command. The mock goes to
`tests/conftest.py`, so that every test file can use it.

### 3.2 The mock goes to conftest.py

The tests of the library, which come next, need the mock too. Only the tests of `tests/test_console.py` can use
a fixture in that file. pytest reads `tests/conftest.py` before the tests, and every test file can use a fixture in it. So the
fixture `mock_requests_get` goes from `tests/test_console.py` to a new file, `tests/conftest.py`.

`main` calls `random_page`, and only `requests.get` is a mock. So a test of the command that uses the mock runs two
parts of the code together, the command and the library. A test of parts together is an integration test. Since
the library came out of `main`, the four tests of the command that use the mock are integration tests, and no
longer unit tests.

Apply the patch to [`tests/conftest.py`](#step-03.2-tests-conftest.py-626af3), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/a65f7f11432be0a56de38e7d4babe10bda735c2c.diff | git apply --include=tests/conftest.py
```

Apply the patch to [`tests/test_console.py`](#step-03.2-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/a65f7f11432be0a56de38e7d4babe10bda735c2c.diff | git apply --include=tests/test_console.py
```

The first patch makes the file `tests/conftest.py`, with the fixture. The second deletes the fixture from
`tests/test_console.py`, from `@pytest.fixture` to `return mock`.

```bash
just test
```

The result is `5 passed`. pytest finds the fixture in `conftest.py`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check a65f7f11432b
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 3f6d8cf59ab3 --staged -- :/ && git restore --source a65f7f11432b --staged --worktree -- :/
```

#### What changed

- <a id="step-03.2-tests-conftest.py-626af3"></a>`tests/conftest.py`: the fixture, for every test file. New, 10 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/a65f7f11432be0a56de38e7d4babe10bda735c2c/tests/conftest.py).
  - look at `def mock_requests_get(mocker):`
- <a id="step-03.2-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the fixture is gone, but the tests still name it. 0 lines added, 9 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/a65f7f11432be0a56de38e7d4babe10bda735c2c/tests/test_console.py).

<a id="step-03.2-tests-conftest.py-626af3-diff"></a>

<details open><summary>The patch to <code>tests/conftest.py</code></summary>

```diff
@@ -0,0 +1,10 @@
+import pytest
+
+@pytest.fixture
+def mock_requests_get(mocker):
+    mock = mocker.patch("requests.get")
+    mock.return_value.__enter__.return_value.json.return_value = {
+        "title": "Lorem Ipsum",
+        "extract": "Lorem ipsum dolor sit amet",
+    }
+    return mock
```

</details>

<a id="step-03.2-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -5,15 +5,6 @@ import pytest
 def runner():
     return click.testing.CliRunner()
 
-@pytest.fixture
-def mock_requests_get(mocker):
-    mock = mocker.patch("requests.get")
-    mock.return_value.__enter__.return_value.json.return_value = {
-        "title": "Lorem Ipsum",
-        "extract": "Lorem ipsum dolor sit amet",
-    }
-    return mock
-
 from wikiapp import console
 
 def test_main_prints_title(runner, mock_requests_get):
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/a65f7f11432be0a56de38e7d4babe10bda735c2c).

This part ends at the code at `a65f7f11432b`, partway through `step-03`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/a65f7f11432be0a56de38e7d4babe10bda735c2c)

<a id="step-03.3"></a>

## 3.3 A test of the language

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `a65f7f11432b`, partway through `step-03`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/a65f7f11432be0a56de38e7d4babe10bda735c2c)

```bash
just setup
```

`random_page` asks only the English Wikipedia. It takes a language now, and a test checks the address.

### 3.3 A language

`random_page` asks only the English Wikipedia. Each language has its own Wikipedia, at LANGUAGE.wikipedia.org. So
the address gets a placeholder for the language, and `random_page` fills it, with English as the default.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-03.3-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520.diff | git apply --include=src/wikiapp/wikipedia.py
```

In `src/wikiapp/wikipedia.py`, the patch changes the line `API_URL = ...` and the first three lines of
`random_page`, from `def random_page():` to the line `with requests.get`.

The first test of the library asks for a page in Spanish, and checks that the address of the request contains
`es.wikipedia.org`. It calls `random_page` alone, with the mock, so it is a unit test of the library.

Apply the patch to [`tests/test_wikipedia.py`](#step-03.3-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520.diff | git apply --include=tests/test_wikipedia.py
```

The patch makes the file `tests/test_wikipedia.py`, with one test.

```bash
just test
```

The result is `6 passed`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check d9d02ca26fd3
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source a65f7f11432b --staged -- :/ && git restore --source d9d02ca26fd3 --staged --worktree -- :/
```

#### What changed

- <a id="step-03.3-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the placeholder, and the code that fills it. 3 lines added, 3 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520/src/wikiapp/wikipedia.py).
  - look at `def random_page(language="en"):`
- <a id="step-03.3-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the test uses the mock from `conftest.py`. New, 6 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520/tests/test_wikipedia.py).
  - look at `assert "es.wikipedia.org" in args[0]`

<a id="step-03.3-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,10 +1,10 @@
 import requests
 
-API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
-def random_page():
+def random_page(language="en"):
     """Get a random page from Wikipedia."""
-    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
+    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
         response.raise_for_status()
         return response.json()
```

</details>

<a id="step-03.3-tests-test_wikipedia.py-2f4413-diff"></a>

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -0,0 +1,6 @@
+from wikiapp import wikipedia
+
+def test_random_page_uses_given_language(mock_requests_get):
+    wikipedia.random_page(language="es")
+    args, _ = mock_requests_get.call_args
+    assert "es.wikipedia.org" in args[0]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520).

This part ends at the code at `d9d02ca26fd3`, partway through `step-03`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520)

<a id="step-03.6"></a>

## 3.6 A test of an error message

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `a6f5ae9a475d`, partway through `step-03`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/a6f5ae9a475d916d4053315c9e6699f16951193f)

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source d9d02ca26fd3 --staged -- :/ && git restore --source a6f5ae9a475d --staged --worktree -- :/
```

```bash
just setup
```

The code now also has an option `--language` on the command. When a request fails, `random_page` raises an error
of its own, `WikipediaError`. To raise an error is to stop and report what went wrong.

The command should print that error as a short message. It should not print a traceback, the long list of lines
of code that Python prints when a program stops on an error. The command is built with click, a package for
command-line programs. The command now passes the error to click, and click prints the word `Error` and then the
message. A test checks that a failed request prints `Error`.

### 3.6 The command prints the error

A bad language ends the command in a traceback, which a person who runs it cannot use. `main` must print the error
as a message instead. `src/wikiapp/console.py` imports `WikipediaError` with `random_page`. `main` catches it, and
raises the exception of click, `click.ClickException`, in its place. click prints that exception as a message, and
ends with exit code 1.

In the original wikiapp, the library raised the exception of click itself, with a note to put it in the console
one day. Here the exception of click is in `console.py`. `wikipedia.py` imports requests, and only
`console.py` imports click.

Apply the patch to [`src/wikiapp/console.py`](#step-03.6-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/b6942869d5fcfffff81beb598630288fe3a67372.diff | git apply --include=src/wikiapp/console.py
```

In `src/wikiapp/console.py`, the patch adds `WikipediaError` to the line `from wikiapp.wikipedia import
random_page`. In `main`, it puts the line `data = random_page(language=language)` inside a `try` block.

A test makes the mock raise a `RequestException`, and checks that the output contains `Error`. The test needs the
module `requests`, to name the exception.

Apply the patch to [`tests/test_console.py`](#step-03.6-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/b6942869d5fcfffff81beb598630288fe3a67372.diff | git apply --include=tests/test_console.py
```

In `tests/test_console.py`, the patch adds `import requests` under the line `import pytest`. It adds the new test
before `test_main_succeeds`.

```bash
uv run wikiapp --language xx; echo "exit code $?"
just test
```

The first command prints `Error:` and the message in place of a traceback, then `exit code 1`. The tests give
`7 passed`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check b6942869d5fc
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source a6f5ae9a475d --staged -- :/ && git restore --source step-03 --staged --worktree -- :/
```

#### What changed

- <a id="step-03.6-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the error becomes a message. 5 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/b6942869d5fcfffff81beb598630288fe3a67372/src/wikiapp/console.py).
  - look at `raise click.ClickException(str(error)) from error`
- <a id="step-03.6-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the test of the message. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/b6942869d5fcfffff81beb598630288fe3a67372/tests/test_console.py).
  - look at `assert "Error" in result.output`

<a id="step-03.6-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

```diff
@@ -2,7 +2,7 @@ import click
 from wikiapp import __version__
 import textwrap
 
-from wikiapp.wikipedia import random_page
+from wikiapp.wikipedia import WikipediaError, random_page
 
 @click.command()
 @click.option(
@@ -16,7 +16,10 @@ from wikiapp.wikipedia import random_page
 @click.version_option(version=__version__)
 def main(language) -> None:
     """Print the title and summary of a random Wikipedia page."""
-    data = random_page(language=language)
+    try:
+        data = random_page(language=language)
+    except WikipediaError as error:
+        raise click.ClickException(str(error)) from error
     title = data["title"]
     extract = data["extract"]
     click.secho(title, fg="green")
```

</details>

<a id="step-03.6-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -1,5 +1,6 @@
 import click.testing
 import pytest
+import requests
 
 @pytest.fixture
 def runner():
@@ -24,6 +25,11 @@ def test_main_fails_on_request_error(runner, mock_requests_get):
     result = runner.invoke(console.main)
     assert result.exit_code == 1
 
+def test_main_prints_message_on_request_error(runner, mock_requests_get):
+    mock_requests_get.side_effect = requests.RequestException
+    result = runner.invoke(console.main)
+    assert "Error" in result.output
+
 def test_main_succeeds(runner):
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/b6942869d5fcfffff81beb598630288fe3a67372).

This part ends at the code at `step-03`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-03)

<a id="step-04.11"></a>

## 4.11 `just check`, with a coverage floor

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `b7469ee81a82`, partway through `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/b7469ee81a824a46e6799d60957ea09d7cf2eade)

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git fetch --quiet --tags --force origin; git restore --source step-03 --staged -- :/ && git restore --source b7469ee81a82 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has [ruff](https://docs.astral.sh/ruff/), a tool that checks Python code. A recipe is a named task of the justfile, such as `fmt`
or `lint`. `just fmt` makes ruff lay out the code and the tests
in one fixed way. `just lint` makes ruff check them against a list of rules. `just lint-config` checks the
settings in `pyproject.toml`, the lockfile and the justfile.

In the tests, ruff found an import below the code, and unused variables. A person fixed them. `just lint --fix`
put the imports of the command in order. The request now stops after 10 seconds with no answer. The lockfile,
`uv.lock`, lists the exact version of each package, and the recipes now refuse to run when it is out of date.

Each check is a recipe of its own, and a person must remember to run them all. A new recipe, `just check`, runs every check. One of them fails when the tests run less than 90% of the code.

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

<a id="step-04.11-justfile-424f0b-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543).

This part ends at the code at `1f73d6af30cc`, partway through `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543)

<a id="step-06.1-to-step-06.2"></a>

## 6.1 to 6.2 End-to-end tests, on request

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-05`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-05)

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git fetch --quiet --tags --force origin; git restore --source 1f73d6af30cc --staged -- :/ && git restore --source step-05 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has a git hook, which `just hook` installs. Before each `git commit`, [`pre-commit`](https://pre-commit.com/) runs three
small checks of the files, then `just check`.

The code also has [ty](https://docs.astral.sh/ty/), a type checker. A type says what kind of value a name has, for example a string or a
number. Each function of the code and the tests now names the types of its arguments and of the value it returns.
`random_page` returns `dict[str, Any]`, a dictionary whose keys are strings, and `just check` runs ty too. The
command also looks up its version by the fixed name of its package, `wikiapp`.

The test that asks the real Wikipedia fails without the network, and so every check fails with it. It now runs
only when you ask for it. A second test of that kind checks the library.

<a id="step-06.1"></a>

### 6.1 The end-to-end test runs only on request

`test_main_succeeds` is the one test that goes over the network. It fails without a network, and its result
depends on Wikipedia. The other tests use the mock in place of Wikipedia, so they run without the network, and give
the same result on every run. A marker, `e2e`, which means end to end, sets the one test apart. Its new name says
so, `test_main_succeeds_in_production`.

Apply the patch to [`tests/test_console.py`](#step-06.1-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/35f4ffc8c67a55ff91a9e7ec02c6de3b90179735.diff | git apply --include=tests/test_console.py
```

The patch puts the marker `@pytest.mark.e2e` above the last test of `tests/test_console.py`, and gives the test its
new name.

pytest must know the marker, and leave the e2e tests out of every run that does not ask for them.
`pyproject.toml` declares the marker in `markers`. The option `-m 'not e2e'` in `addopts` leaves the e2e tests out.

Set the values that this change sets in [`pyproject.toml`](#step-06.1-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '35f4ffc8c67a:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'pytest', 'ini_options', 'addopts'),
    ('tool', 'pytest', 'ini_options', 'markers'),
]

def body(table):   # the items of a table in their order, with its comment lines
    inner = table if isinstance(table, tomlkit.TOMLDocument) else getattr(table, 'value', None)
    return getattr(inner, 'body', [])

def above(table, key):   # the comment lines just above a key
    found = []
    for name, item in body(table):
        if name is not None and name.key == key:
            return found
        found = found + [item] if isinstance(item, Comment) else found if isinstance(item, Whitespace) else []
    return []

for keys in COPY:
    source, target = project, doc
    for key in keys[:-1]:   # make each table on the way
        source = source[key]
        if key not in target:
            target[key] = tomlkit.table(True)
        target = target[key]
    item = copy.deepcopy(source[keys[-1]])
    if isinstance(item, Table) and not item.as_string().endswith('\n\n'):
        item.add(tomlkit.nl())   # a blank line before the table after it
    if keys[-1] not in target:
        for comment in above(source, keys[-1]):
            target.add(copy.deepcopy(comment))
    target[keys[-1]] = item
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

The change is in `[tool.pytest.ini_options]`. It replaces the comment and the line `addopts`,
and adds the line `markers`.

```bash
just test -q
just test -q -m e2e
```

The first command prints `6 passed, 1 deselected`. The second command runs the e2e test alone.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 35f4ffc8c67a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-05 --staged -- :/ && git restore --source 35f4ffc8c67a --staged --worktree -- :/
```

#### What changed

- <a id="step-06.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the option `-m 'not e2e'`, and the marker `e2e` in `markers`, with a comment. 5 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/35f4ffc8c67a55ff91a9e7ec02c6de3b90179735/pyproject.toml).
  - look at `markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]`
- <a id="step-06.1-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the test, marked. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/35f4ffc8c67a55ff91a9e7ec02c6de3b90179735/tests/test_console.py).
  - look at `@pytest.mark.e2e`

<a id="step-06.1-pyproject.toml-5d07e7-diff"></a>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -38,8 +38,11 @@ test = [
 
 [tool.pytest.ini_options]
 testpaths = ["tests"]
-# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not
-addopts = "--cov=wikiapp --cov-report=term-missing"
+# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
+# marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
+# just test -m e2e
+addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
+markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
 
 [tool.ruff]
 # The one setting the formatter and the linter share. Ruff's own default is 88; this project reads
```

</details>

<a id="step-06.1-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

```diff
@@ -41,6 +41,7 @@ def test_main_prints_message_on_request_error(runner: CliRunner, mock_requests_g
     assert "Error" in result.output
 
 
-def test_main_succeeds(runner: CliRunner) -> None:
+@pytest.mark.e2e
+def test_main_succeeds_in_production(runner: CliRunner) -> None:
     result = runner.invoke(console.main)
     assert result.exit_code == 0
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/35f4ffc8c67a55ff91a9e7ec02c6de3b90179735). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/35f4ffc8c67a55ff91a9e7ec02c6de3b90179735).

<a id="step-06.2"></a>

### 6.2 An end-to-end test of the library

The mocks return a dictionary with a title and an extract. If the real Wikipedia stops sending those two keys,
every test with a mock still passes, and the command fails. A second e2e test, from the original wikiapp, asks the
real Wikipedia for a page and checks the two keys. It is also a contract test. It checks that the real Wikipedia
still returns what the mocks return.

Apply the patch to [`tests/test_wikipedia.py`](#step-06.2-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/307d4d7b36bb9dc7bc8ad601c8275d5241283e35.diff | git apply --include=tests/test_wikipedia.py
```

The patch puts `import pytest` in a block of its own, between the import of `Mock` and the import of `wikipedia`.
It adds the new test at the end of the file.

```bash
just test -q -m e2e
```

The output is `2 passed, 6 deselected`.

The project now has all four kinds of tests in the table of the intro. They are end-to-end, unit, integration and
contract.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 307d4d7b36bb
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 35f4ffc8c67a --staged -- :/ && git restore --source 307d4d7b36bb --staged --worktree -- :/
```

#### What changed

- <a id="step-06.2-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the test. 9 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/307d4d7b36bb9dc7bc8ad601c8275d5241283e35/tests/test_wikipedia.py).
  - look at `assert "extract" in page`

<a id="step-06.2-tests-test_wikipedia.py-2f4413-diff"></a>

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -1,5 +1,7 @@
 from unittest.mock import Mock
 
+import pytest
+
 from wikiapp import wikipedia
 
 
@@ -7,3 +9,10 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
+
+
+@pytest.mark.e2e
+def test_random_page_returns_dictionary_in_production() -> None:
+    page = wikipedia.random_page()
+    assert "title" in page
+    assert "extract" in page
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/307d4d7b36bb9dc7bc8ad601c8275d5241283e35).

This part ends at the code at `307d4d7b36bb`, partway through `step-06`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/307d4d7b36bb9dc7bc8ad601c8275d5241283e35)

<a id="step-06.3-to-step-06.5"></a>

## 6.3 to 6.5 The tests on GitHub

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `307d4d7b36bb`, partway through `step-06`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/307d4d7b36bb9dc7bc8ad601c8275d5241283e35)

```bash
just setup
```

The tests run on one machine, with one version of Python. The project asks for Python 3.13 or newer. In this
section it starts to accept any version of Python from 3.11 on. Then GitHub runs the tests on three
systems and four versions of Python.

<a id="step-06.3"></a>

### 6.3 Any Python from 3.11 on

The project asks for Python 3.13, and nothing in it needs more than 3.11. `uv init` wrote
`requires-python = ">=3.13"`, because the command that made the project asked for Python 3.13. Python 3.10 reached
its end of life on 1 October 2026, so 3.11 is now the oldest Python that still gets security fixes. The line in
`pyproject.toml` now says 3.11.

Set the values that this change sets in [`pyproject.toml`](#step-06.3-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', 'b97ee4cfc591:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('project', 'requires-python'),
]

def body(table):   # the items of a table in their order, with its comment lines
    inner = table if isinstance(table, tomlkit.TOMLDocument) else getattr(table, 'value', None)
    return getattr(inner, 'body', [])

def above(table, key):   # the comment lines just above a key
    found = []
    for name, item in body(table):
        if name is not None and name.key == key:
            return found
        found = found + [item] if isinstance(item, Comment) else found if isinstance(item, Whitespace) else []
    return []

for keys in COPY:
    source, target = project, doc
    for key in keys[:-1]:   # make each table on the way
        source = source[key]
        if key not in target:
            target[key] = tomlkit.table(True)
        target = target[key]
    item = copy.deepcopy(source[keys[-1]])
    if isinstance(item, Table) and not item.as_string().endswith('\n\n'):
        item.add(tomlkit.nl())   # a blank line before the table after it
    if keys[-1] not in target:
        for comment in above(source, keys[-1]):
            target.add(copy.deepcopy(comment))
    target[keys[-1]] = item
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

The patch changes one line of `pyproject.toml`, line 9, `requires-python`.

The lockfile, `uv.lock`, was resolved for Python 3.13 and newer. It no longer matches `pyproject.toml`, and this
move leaves it so on purpose. Line 6 of the `justfile` sets `UV_LOCKED` to 1 for every recipe. So uv refuses a
lockfile that does not match, until the next move resolves it again.

```bash
uv lock --check
just test -q
```

`uv lock --check` prints `Resolved 31 packages`, and then an error. The lockfile `uv.lock` "needs to be
updated". Its hint is to run `uv lock`, and it exits with 1. `just test -q` stops with the same error, and runs
no test. Its error names `UV_LOCKED=1` where the first error named `--check`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check b97ee4cfc591
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 307d4d7b36bb --staged -- :/ && git restore --source b97ee4cfc591 --staged --worktree -- :/
```

#### What changed

- <a id="step-06.3-pyproject.toml-5d07e7"></a>`pyproject.toml`: one line. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/b97ee4cfc59182c79e4a09ca19a7790b25f25264/pyproject.toml).
  - look at `requires-python = ">=3.11"`

<a id="step-06.3-pyproject.toml-5d07e7-diff"></a>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -6,7 +6,7 @@ readme = "README.md"
 license = "Apache-2.0"
 license-files = ["LICENSE"]
 authors = [{ name = "Rahul Dave" }]
-requires-python = ">=3.13"
+requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
     "requests>=2.34.2",
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/b97ee4cfc59182c79e4a09ca19a7790b25f25264). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/b97ee4cfc59182c79e4a09ca19a7790b25f25264).

<a id="step-06.4"></a>

### 6.4 The lockfile, for every Python from 3.11 on

The lockfile must match `pyproject.toml` again. `uv lock` resolves it for every version of Python from 3.11 on. It writes only
`uv.lock`.

```bash
uv lock
```

`uv lock` prints `Resolved 31 packages` and `Added tomli v2.5.0`.

The project still runs on 3.13, from `.python-version`. uv can also run the tests on 3.11.

```bash
uv lock --check
just test -q
uv run --isolated --python 3.11 python --version
uv run --isolated --python 3.11 pytest -q
```

`uv lock --check` prints only `Resolved 31 packages`, and `just test -q` prints `6 passed, 2 deselected` again.
`--python 3.11` chooses the version of Python. `--isolated` makes the environment temporary, so `.venv` does not
change. The third command prints
`Python 3.11.12`, and the tests print `6 passed, 2 deselected` on 3.11 too.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check d8af75e8fd57
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source b97ee4cfc591 --staged -- :/ && git restore --source d8af75e8fd57 --staged --worktree -- :/
```

#### What changed

- <a id="step-06.4-uv.lock-8356d8"></a>`uv.lock`: resolved for every version of Python from 3.11 on. 160 lines added, 2 removed. It comes from `uv lock`. [The file](https://github.com/rahuldave/smallwikiapp/blob/d8af75e8fd576ae8d09cb76ed960b1c4892e0a84/uv.lock).

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/d8af75e8fd576ae8d09cb76ed960b1c4892e0a84). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d8af75e8fd576ae8d09cb76ed960b1c4892e0a84).

<a id="step-06.5"></a>

### 6.5 GitHub runs the tests

The tests run only on the machine of the person who runs them, on one system and one version of Python. GitHub can run them
on its own machines after each push.

[GitHub Actions](https://docs.github.com/en/actions) is GitHub's service that runs jobs, such as tests, on GitHub's
machines. It is free for a public repository.

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
part of the tutorial publishes the docs with [GitHub Pages](https://docs.github.com/en/pages), and lists each setting that a fork needs.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 20cf458261ed
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source d8af75e8fd57 --staged -- :/ && git restore --source step-06 --staged --worktree -- :/
```

#### What changed

- <a id="step-06.5-.github-workflows-test.yaml-a60e23"></a>`.github/workflows/test.yaml`: the matrix of systems and versions of Python. New, 37 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/20cf458261edc55b725da39a99c9b37ef5d24657/.github/workflows/test.yaml).
  - look at `python: ["3.11", "3.12", "3.13", "3.14"]`

<a id="step-06.5-.github-workflows-test.yaml-a60e23-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/20cf458261edc55b725da39a99c9b37ef5d24657).

This part ends at the code at `step-06`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-06)

<a id="step-07.3-to-step-07.4"></a>

## 7.3 to 7.4 Tests of a model

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `1baf0602c1d1`, partway through `step-07`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/1baf0602c1d1cec79277c2faec438b76a9a8c768)

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git fetch --quiet --tags --force origin; git restore --source step-06 --staged -- :/ && git restore --source 1baf0602c1d1 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has [pydantic](https://docs.pydantic.dev/), a library that checks data. In `wikipedia.py`, `Page` is a pydantic model, a
class with two fields, `title` and `extract`, the summary. pydantic checks that the answer of Wikipedia has both,
as strings.

`random_page` returns a `Page` in place of a dictionary, so one test changes. An answer that is not a page is a
`WikipediaError` too, and a new test checks it.

<a id="step-07.3"></a>

### 7.3 random_page returns a Page

The model exists, but `random_page` still returns the dictionary, and `main` still reads its keys. A misspelled key
of a dictionary shows up only when the program runs. The attributes of a `Page` have names that ty and an editor
know. So `random_page` returns a `Page` made from the answer, and `main` prints its attributes.

`random_page` passes the answer to `Page.model_validate`, which checks it against the model and makes the page.
The code no longer uses `Any`, so its import goes.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-07.3-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch deletes `from typing import Any` and the blank line under it. It changes the return type of
`random_page`, and its line `return response.json()`.

`main`, in `src/wikiapp/console.py`, prints `page.title` and `page.extract` in place of the two keys.

Apply the patch to [`src/wikiapp/console.py`](#step-07.3-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d.diff | git apply --include=src/wikiapp/console.py
```

The patch changes the code under the docstring of `main`. It names the answer `page`, and prints its two attributes.

The test that asks the real Wikipedia, in `tests/test_wikipedia.py`, checked two keys of the dictionary. It now
checks that the answer is a `Page`, and its new name, `test_random_page_returns_page_in_production`, says so. It
keeps its marker `e2e`.

Apply the patch to [`tests/test_wikipedia.py`](#step-07.3-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d.diff | git apply --include=tests/test_wikipedia.py
```

The patch replaces the last test of `tests/test_wikipedia.py`, and keeps its marker.

```bash
just check
uv run wikiapp
```

`just check` passes, and the command prints a page as before.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 88fe0e20d645
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 1baf0602c1d1 --staged -- :/ && git restore --source 88fe0e20d645 --staged --worktree -- :/
```

#### What changed

- <a id="step-07.3-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: attributes, not keys. 3 lines added, 5 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d/src/wikiapp/console.py).
  - look at `click.secho(page.title, fg="green")`
- <a id="step-07.3-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the return. 2 lines added, 4 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d/src/wikiapp/wikipedia.py).
  - look at `return Page.model_validate(response.json())`
- <a id="step-07.3-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the e2e test checks for a Page. 2 lines added, 3 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d/tests/test_wikipedia.py).
  - look at `assert isinstance(page, wikipedia.Page)`

<a id="step-07.3-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

```diff
@@ -19,13 +19,11 @@ from wikiapp.wikipedia import WikipediaError, random_page
 def main(language: str) -> None:
     """Print the title and summary of a random Wikipedia page."""
     try:
-        data = random_page(language=language)
+        page = random_page(language=language)
     except WikipediaError as error:
         raise click.ClickException(str(error)) from error
-    title = data["title"]
-    extract = data["extract"]
-    click.secho(title, fg="green")
-    click.echo(textwrap.fill(extract))
+    click.secho(page.title, fg="green")
+    click.echo(textwrap.fill(page.extract))
 
 
 if __name__ == "__main__":
```

</details>

<a id="step-07.3-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,5 +1,3 @@
-from typing import Any
-
 import requests
 from pydantic import BaseModel
 
@@ -18,13 +16,13 @@ class Page(BaseModel):
     extract: str
 
 
-def random_page(language: str = "en") -> dict[str, Any]:
+def random_page(language: str = "en") -> Page:
     """Get a random page from Wikipedia."""
     try:
         with requests.get(
             API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
         ) as response:
             response.raise_for_status()
-            return response.json()
+            return Page.model_validate(response.json())
     except requests.RequestException as error:
         raise WikipediaError(str(error)) from error
```

</details>

<a id="step-07.3-tests-test_wikipedia.py-2f4413-diff"></a>

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -12,7 +12,6 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 
 
 @pytest.mark.e2e
-def test_random_page_returns_dictionary_in_production() -> None:
+def test_random_page_returns_page_in_production() -> None:
     page = wikipedia.random_page()
-    assert "title" in page
-    assert "extract" in page
+    assert isinstance(page, wikipedia.Page)
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/88fe0e20d645b581ff1e3ab4bb9679978bc3d38d).

<a id="step-07.4"></a>

### 7.4 An answer that is not a page

An answer with no title is not a page. `model_validate` then raises the ValidationError of pydantic, and the command
would end with a traceback. `random_page` turns a failed request into a WikipediaError, and it should do the same
with an answer that is not a page. So its `except` catches ValidationError together with the exception of requests.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-07.4-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/06ff2caa1958318b960fa9b9c84b32b3a23ae18d.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch adds `ValidationError` to the import from pydantic. It changes the line `except requests.RequestException as error:`
to catch both exceptions.

A test from the original wikiapp, `test_random_page_handles_validation_error`, checks it, at the end of
`tests/test_wikipedia.py`. The mock answers with an empty dictionary, `{}`, and `pytest.raises` expects a
WikipediaError.

Apply the patch to [`tests/test_wikipedia.py`](#step-07.4-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/06ff2caa1958318b960fa9b9c84b32b3a23ae18d.diff | git apply --include=tests/test_wikipedia.py
```

The patch adds the test at the end of `tests/test_wikipedia.py`, with two blank lines before it.

```bash
just test -k validation
```

The output is `1 passed, 8 deselected`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 06ff2caa1958
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 88fe0e20d645 --staged -- :/ && git restore --source 06ff2caa1958 --staged --worktree -- :/
```

#### What changed

- <a id="step-07.4-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: two exceptions caught. 2 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/06ff2caa1958318b960fa9b9c84b32b3a23ae18d/src/wikiapp/wikipedia.py).
  - look at `except (requests.RequestException, ValidationError) as error:`
- <a id="step-07.4-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the test. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/06ff2caa1958318b960fa9b9c84b32b3a23ae18d/tests/test_wikipedia.py).
  - look at `with pytest.raises(wikipedia.WikipediaError):`

<a id="step-07.4-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,5 +1,5 @@
 import requests
-from pydantic import BaseModel
+from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
@@ -24,5 +24,5 @@ def random_page(language: str = "en") -> Page:
         ) as response:
             response.raise_for_status()
             return Page.model_validate(response.json())
-    except requests.RequestException as error:
+    except (requests.RequestException, ValidationError) as error:
         raise WikipediaError(str(error)) from error
```

</details>

<a id="step-07.4-tests-test_wikipedia.py-2f4413-diff"></a>

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -15,3 +15,9 @@ def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:
 def test_random_page_returns_page_in_production() -> None:
     page = wikipedia.random_page()
     assert isinstance(page, wikipedia.Page)
+
+
+def test_random_page_handles_validation_error(mock_requests_get: Mock) -> None:
+    mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
+    with pytest.raises(wikipedia.WikipediaError):
+        wikipedia.random_page()
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/06ff2caa1958318b960fa9b9c84b32b3a23ae18d).

This part ends at the code at `06ff2caa1958`, partway through `step-07`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/06ff2caa1958318b960fa9b9c84b32b3a23ae18d)

<a id="step-07.5"></a>

## 7.5 A drop in coverage

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `06ff2caa1958`, partway through `step-07`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/06ff2caa1958318b960fa9b9c84b32b3a23ae18d)

```bash
just setup
```

The language goes into the address of the request, as `en` does in `en.wikipedia.org`. So a language such as
`example.com/x?` sends the request to the site `example.com`. New code now accepts only lowercase letters,
joined by hyphens, as in `en` or `zh-yue`. No test reaches the new code, so the coverage drops.

### 7.5 Only a language code goes into the address

The code puts the language into the host name, `{language}.wikipedia.org`. A language such as `example.com/x?`
sends the request to example.com, with the User-Agent. The language code of every Wikipedia has only lower-case
letters and hyphens, for example `en`, `fr`, `simple` and `zh-yue`. So `random_page` checks the language against a pattern of such a
code first, before the `try`, and any other language raises a WikipediaError.

The pattern is a constant, `LANGUAGE`, made with the module `re`. No request goes out for a language that does
not match it.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-07.5-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/be473b80441f82ce87bf800deeb432fd4212dea4.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch makes three changes to `src/wikiapp/wikipedia.py`. It puts `import re` and a blank line at the top, above
`import requests`. It adds `LANGUAGE` under the line `API_URL = ...`. It adds the check at the top of the body of
`random_page`, under its docstring and before the `try`.

```bash
uv run wikiapp --language 'example.com/x?'
just test -q
```

The command prints `Error: 'example.com/x?' is not a language code, such as en, fr or zh-yue`, and sends no
request. The tests print `7 passed, 2 deselected`. No test reaches the new `raise`, so the coverage table lists
its line as missing. The coverage is 95% in all, which is still over the floor of 90%.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check be473b80441f
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 06ff2caa1958 --staged -- :/ && git restore --source step-07 --staged --worktree -- :/
```

#### What changed

- <a id="step-07.5-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the code checks a language before it uses it. 5 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/be473b80441f82ce87bf800deeb432fd4212dea4/src/wikiapp/wikipedia.py).
  - look at `if not LANGUAGE.fullmatch(language):`

<a id="step-07.5-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,7 +1,10 @@
+import re
+
 import requests
 from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
+LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 
@@ -18,6 +21,8 @@ class Page(BaseModel):
 
 def random_page(language: str = "en") -> Page:
     """Get a random page from Wikipedia."""
+    if not LANGUAGE.fullmatch(language):
+        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
     try:
         with requests.get(
             API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/be473b80441f82ce87bf800deeb432fd4212dea4).

This part ends at the code at `step-07`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-07)

<a id="step-08b.1"></a>

## 8b.1 GitHub installs only the test tools

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-08)

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git fetch --quiet --tags --force origin; git restore --source step-07 --staged -- :/ && git restore --source step-08 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has [smalldocs](https://docs.smallish.dev/), which makes documentation from the code. It is in a
dependency group `docs`, a named list of packages in `pyproject.toml`. The code and the tests have docstrings, and `just check` runs
a check of the docs. `just docs` builds a site, and the README names the tests and the docs.

GitHub installs every tool of the project to run the tests, and the tests need only pytest and its plugins. This
section changes what GitHub installs to run the tests.

### 8b.1 The tests install the group test alone

The job `tests` runs twelve times on GitHub, and each run installs every group. So each run installs the linter, the type
checker, the git hook tools and smalldocs. pytest needs only the package and the group `test`, so this move makes
each run install only those.

The line `default-groups = "all"` in `pyproject.toml` makes uv install every group. `--no-default-groups` tells uv
to install none of them, and `--group test` then names the one group to install. The job `check`, at lines 30 to 37
of `.github/workflows/test.yaml`, still runs `just setup`, which installs every group. It needs every tool, since
`just check` runs them all.

Apply the patch to [`.github/workflows/test.yaml`](#step-08b.1-.github-workflows-test.yaml-a60e23), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/971e9d780fd539d13f49af3fbb00c1145fd22aa0.diff | git apply --include=.github/workflows/test.yaml
```

The patch changes the comment line that starts with `# tests:`, and the last line of the job `tests`, which was
`- run: uv run --locked pytest`.

```bash
uv run --isolated --locked --no-default-groups --group test pytest -q
uv run pre-commit run check-yaml --files .github/workflows/test.yaml
```

`--isolated` runs the command as the job does, in a temporary environment with the group `test` alone, and leaves
`.venv` as it is. The tests print `7 passed, 2 deselected`. The file is valid YAML.

This tutorial ends here. After it, the whole tutorial adds a workflow that publishes the docs. The library becomes
a package of its own, wikirandom. Its tests go to `tests/test_wikirandom.py`, and coverage measures both packages.
The [whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 971e9d780fd5
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-08 --staged -- :/ && git restore --source 971e9d780fd5 --staged --worktree -- :/
```

#### What changed

- <a id="step-08b.1-.github-workflows-test.yaml-a60e23"></a>`.github/workflows/test.yaml`: the comment, and the command of the job `tests`. 2 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/971e9d780fd539d13f49af3fbb00c1145fd22aa0/.github/workflows/test.yaml).
  - look at `- run: uv run --locked --no-default-groups --group test pytest  # the package and its tests, no more`

<a id="step-08b.1-.github-workflows-test.yaml-a60e23-diff"></a>

<details open><summary>The patch to <code>.github/workflows/test.yaml</code></summary>

```diff
@@ -1,6 +1,6 @@
 # What GitHub runs on every push to main and every pull request.
 #
-# tests: the tests, on three systems and four Pythons, twelve jobs at once.
+# tests: the tests, on three systems and four Pythons, twelve jobs at once, each with the group test alone.
 # check: everything `just check` runs, once, as the git hook does.
 name: CI
 
@@ -25,7 +25,7 @@ jobs:
       - uses: astral-sh/setup-uv@v10.2.0
         with:
           python-version: ${{ matrix.python }}
-      - run: uv run --locked pytest
+      - run: uv run --locked --no-default-groups --group test pytest  # the package and its tests, no more
 
   check:
     runs-on: ubuntu-latest
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/971e9d780fd539d13f49af3fbb00c1145fd22aa0).

This part ends at the code at `971e9d780fd5`, partway through `step-08b`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/971e9d780fd539d13f49af3fbb00c1145fd22aa0)
