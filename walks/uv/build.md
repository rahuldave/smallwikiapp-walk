<!-- Made by the walk skill's render.py from the facts of the walk. Do not edit it by hand: run just walk-update again. -->

# uv in smallwikiapp

**Build it yourself.** Every command to run and every change to make by hand, to make the project yourself. [Read the tutorial](read.md) is the other way to read it.

Each part ends with a section called **What changed**. It lists every file that the part changes, with a link to the file, and then the whole diff of each file, folded. A lockfile and a binary file have a link alone. The text above it explains the change. What changed is what you check your files against.

In Build it yourself, a file that a command makes says which command. A diff that is open is a patch. Apply it with the command in the text, or make the same change in your editor.

We manage the packages of `wikiapp` with uv. `wikiapp` is a small command that prints the title and the summary of
a random Wikipedia page. A project must install the same packages on every machine, and keep the tools of its
authors apart from what its users get. uv makes the project, installs its packages, runs its tools, and builds it.
This tutorial takes the parts about uv out of the whole tutorial of smallwikiapp.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi. Where the text says "the original wikiapp", it means that project.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch changes a
file, and a command such as `uv add` writes the files it needs. You make each move, and then check your files
against it.

This tutorial has eleven sections:

1. **The project, and its `.venv`**
2. **Two dependencies, and the lockfile**
3. **A group for the tests, and when uv syncs**
4. **A lockfile that must be up to date**
5. **The oldest Python, and other environments**
6. **Versions of Python and groups on GitHub**
7. **Each job on GitHub with its own group**
8. **A workspace**
9. **The app uses the library**
10. **A build of both packages**
11. **A range of versions for the library**

Some sections run commands that the whole tutorial does not. They change `.venv`, and no file that git tracks. The
`$ just setup` at the top of the next section makes `.venv` match the lockfile again.

Where the whole tutorial makes changes that this one leaves out, the next section says what they did, and begins
from their code.

**What uv does in this project**

| Idea | What it means here | Sections |
|---|---|---|
| `pyproject.toml` and `uv.lock` | `pyproject.toml` gives the range of versions of each package. `uv.lock` gives the exact version that uv chose | 1 and 2 |
| `uv sync` | Makes `.venv` match the lockfile and the groups it installs. It installs what is missing, and removes every other package | 1 and 3 |
| `uv run` | Syncs first, then runs a command in `.venv`. The sync installs what is missing, and removes nothing. `--no-sync` skips the sync | 3 |
| `--locked` and `UV_LOCKED` | Refuse a lockfile that is out of date with `pyproject.toml` | 1 and 4 |
| `--frozen` | Uses the lockfile as it is, and does not check it. The project never uses it | 4 |
| Dependency groups | `test`, `lint` and `docs`, for the people who work on the project. `default-groups = "all"` makes uv install every group | 3, 6 and 7 |
| `.python-version` and `requires-python` | The Python of `.venv`, and the oldest Python that the project accepts | 1 and 5 |
| Environments | `.venv`, a temporary one with `--isolated`, and the one of a tool that `uvx` runs | 1, 5 and 7 |
| A workspace | Several packages with one lockfile and one `.venv`. `--package` names one of them | 8 and 9 |
| `[tool.uv.sources]` | Where uv gets a package. Here the library comes from the workspace, not from PyPI | 9 and 11 |
| `uv build --all-packages` | Builds a wheel and a source archive of each package of the workspace | 10 and 11 |

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
echo 'packages/wikirandom/pyproject.toml diff=pyproject' >> .git/info/attributes
echo '/uv.lock diff=uvlock' >> .git/info/attributes
git config diff.pyproject.textconv 'uv run --quiet --no-config --no-project --python ">=3.11" python "$(git rev-parse --git-common-dir)/package_names.py" pyproject.toml'
git config diff.uvlock.textconv 'uv run --quiet --no-config --no-project --python ">=3.11" python "$(git rev-parse --git-common-dir)/package_names.py" uv.lock'
git config alias.check '!f() { i="$(git rev-parse --git-path check-index)" && { cp -p "$(git rev-parse --git-path index)" "$i" 2>/dev/null || rm -f "$i"; } && export GIT_INDEX_FILE="$i" && git add -A && git diff --cached "$1" -- ":/"; }; f'
```

<a id="step-00"></a>

## 0 The project, and its `.venv`

A project needs a Python and its packages in one place, apart from the rest of the machine. `uv init` made the
project, and `uv lock` wrote its lockfile.

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

The program `just` runs the tasks of the project, and the justfile contains them. A task is called a recipe. It
has a name, and the commands that it runs. `just` alone lists the tasks, and
`just --show setup` shows the recipe behind one task. `just help setup` shows the same recipe. Later sections add
recipes to the justfile.

```bash
just
just --show setup
just --show help
just help setup
```

`.venv` is the environment of the project. It has a Python, and every package that the lockfile names. `uv run`
runs a command with that Python. So `uv run wikiapp` works at once. Without uv, a person
first activates `.venv`, with a command that makes the shell use the Python of `.venv`.

Check your files against this part. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check ae86cb7d116c
```

If you are stuck, this command puts the files of this part in place of yours. A file that you made yourself stays:

```bash
git rm -rq --cached --ignore-unmatch -- :/ && git restore --source ae86cb7d116c --staged --worktree -- :/
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

[The code](https://github.com/rahuldave/smallwikiapp/tree/ae86cb7d116c4103832edf25ab3a7a9077583830).

<a id="step-01.1"></a>

## 1.1 Two dependencies, and the lockfile

```bash
just setup
```

The command needs two packages that Python does not have. `uv add` writes a package into `pyproject.toml`, and
syncs `.venv`. It also chooses one version of each package that fits every range of versions, and writes the
versions in `uv.lock`. uv calls this choice resolving.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/ae86cb7d116c4103832edf25ab3a7a9077583830). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/36d49582843a575d84ed178ad66157913be4c59c).

### 1.1 click and requests

The command needs two packages that Python does not have. click makes command lines, with options and help.
requests gets pages over HTTP. `uv add` puts both in the dependencies of wikiapp, and installs them in `.venv`. It
also chooses one version of each package that fits every range of versions, and writes the versions in the
lockfile, `uv.lock`. uv calls this choice resolving.

```bash
uv add click requests
```

```bash
uv tree --depth 1
```

`uv tree` shows the two packages under `wikiapp`. A newer version of a package can come out after these notes.

If your versions are newer, `uv add` writes them into `pyproject.toml` and `uv.lock`. Only those versions differ
from the ones here.

`pyproject.toml` asks for a range, such as `click>=8.5.0`. `uv.lock` names the one version that uv chose, and the
versions of every package that click and requests need. Two people with the same lockfile get the same packages.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 36d49582843a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source ae86cb7d116c --staged -- :/ && git restore --source 36d49582843a --staged --worktree -- :/
```

#### What changed

- <a id="step-01.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the dependencies of the package, which anyone who installs it gets. 4 lines added, 1 removed. It comes from `uv add click requests`. [The file](https://github.com/rahuldave/smallwikiapp/blob/36d49582843a575d84ed178ad66157913be4c59c/pyproject.toml).
  - look at `"click>=8.5.0",`
- <a id="step-01.1-uv.lock-8356d8"></a>`uv.lock`: the exact versions, for every platform. 176 lines added. It comes from `uv add click requests`. [The file](https://github.com/rahuldave/smallwikiapp/blob/36d49582843a575d84ed178ad66157913be4c59c/uv.lock).

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

<a id="step-02.1-to-step-02.3"></a>

## 2.1 to 2.3 A group for the tests, and when uv syncs

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 36d49582843a --staged -- :/ && git restore --source f05d3c31be2c --staged --worktree -- :/
```

```bash
just setup
```

The command now asks Wikipedia for a random page, and prints its title and summary. It sends a User-Agent, a line
that tells Wikipedia the name of the program that asks. `wikiapp --version` prints the version.

The tests need pytest, and a user of the command does not. A dependency group is a list of packages for the
people who work on the project. By default uv installs only a group named `dev`. The project first sets
`default-groups = "all"`, so that uv installs every group. Then the test tools, the linters and the docs tools can
each have a group of their own.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/f05d3c31be2cf640cc2aa4345658b8eebc394d60). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d92e2dec921d6322e2a356af20dafef3837c1849).

<a id="step-02.1"></a>

### 2.1 uv installs every dependency group

The tests need pytest, but the package does not. A person who installs wikiapp should not get pytest. So the tools
of the project go in dependency groups. A dependency group is a list of packages in `pyproject.toml` that the
project needs while we work on it. A user of the package never gets them. The test tools go in a group `test`, and
later the linters and the docs tools get groups of their own.

uv installs only the group `dev` by default. The setting `default-groups = "all"` makes `uv sync` and `uv run`
install every group. So each later `uv add --group` needs no other change to `pyproject.toml`. A patch adds the
table `[tool.uv]` with this setting.

Set the values that this change sets in [`pyproject.toml`](#step-02.1-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It sets each of these values as the project has it, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import pathlib, tomlkit
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# Each value that the change sets, by its keys
SET = [
    (('tool', 'uv'), {'default-groups': 'all'}),
]

def put(table, keys, value):   # make each table on the way; a table goes into the one there, key by key
    for key in keys[:-1]:
        if key not in table:
            table[key] = tomlkit.table(True)
        table = table[key]
    if isinstance(value, dict) and isinstance(table.get(keys[-1]), dict):
        for key, item in value.items():
            put(table[keys[-1]], [key], item)
    else:
        table[keys[-1]] = value

for keys, value in SET:
    put(doc, keys, value)
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

The patch adds the table `[tool.uv]` at the end of `pyproject.toml`, after the table `[build-system]`. It has a
comment and one setting.

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
git restore --source f05d3c31be2c --staged -- :/ && git restore --source 46dc20fb9092 --staged --worktree -- :/
```

#### What changed

- <a id="step-02.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the table `[tool.uv]`, so uv installs every dependency group. 4 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/46dc20fb9092170695699eaa052f4830563cb930/pyproject.toml).
  - look at `default-groups = "all"`

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

The test needs pytest. `uv add --group test` writes pytest into a new group `test` of `pyproject.toml`, adds its
exact version to `uv.lock`, and installs it.

```bash
uv add --group test pytest
```

```bash
uv run pytest
```

pytest finds `tests/test_console.py`, and prints `collected 1 item` and `1 passed`. The test asks the real
Wikipedia, so it needs the network.

Now `.venv` has pytest, from the group `test`. The commands below show when uv syncs `.venv`, and when it does
not.

```bash
uv sync --no-default-groups
uv run --no-sync python -m pytest --version
uv run python -m pytest --version
```

`uv sync --no-default-groups` leaves out every group, and so it uninstalls pytest and the 4 packages that pytest
needs.
`--no-sync` runs Python in `.venv` as it is, and the last line says `No module named pytest`. A plain `uv run`
syncs first. It installs the 5 packages again, and prints the version of pytest.

```bash
uv pip install six
uv run python -c "import six; print(six.__version__)"
uv sync
```

`uv pip install` puts six into `.venv`, and the lockfile does not name it. `uv run` leaves six in place, and prints
its version. `uv sync` uninstalls it, because a sync removes every package that the lockfile and the groups do not
name.

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

<a id="step-04.10"></a>

## 4.10 A lockfile that must be up to date

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source d92e2dec921d --staged -- :/ && git restore --source d8a9c8f71eb5 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has pytest-mock and pytest-cov, in the group `test`. The project now has tests that use a
mock, a stand-in that answers in place of Wikipedia with no network. It also has recipes in the justfile that run each tool with `uv run`. The code that asks Wikipedia is now a library
of its own, `src/wikiapp/wikipedia.py`. ruff and
validate-pyproject are in a new group `lint`. `just lint-config` runs `uv lock --check`,
which fails if the lockfile is out of date with `pyproject.toml`.

A recipe should fail when `pyproject.toml` changes and nobody runs `uv lock`. But with no option, `uv run` resolves
the lockfile again and prints no warning. The justfile now exports `UV_LOCKED`, which makes every `uv run` refuse a
lockfile that is out of date.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/d8a9c8f71eb58893025360c20b32c9078e5b0c3c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/b7469ee81a824a46e6799d60957ea09d7cf2eade).

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

uv has three ways to treat the lockfile. With no option, `uv run` and `uv sync` resolve it again and write it, if it
is out of date with `pyproject.toml`. `--locked`, or `UV_LOCKED`, refuses a lockfile that is out of date. `--frozen`
uses the lockfile as it is, and does not compare it with `pyproject.toml`.

The project uses `--locked`. So a change to the dependencies, the version or `requires-python` without `uv lock`
fails in every recipe that runs `uv run` or `uv sync`. `uv build` does not read the lockfile, so `just build`, from
section 10, still works.

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

<a id="step-06.3-to-step-06.4"></a>

## 6.3 to 6.4 The oldest Python, and other environments

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source b7469ee81a82 --staged -- :/ && git restore --source 307d4d7b36bb --staged --worktree -- :/
```

```bash
just setup
```

The code now also has `just check`, which runs every check, and a git hook runs it before each `git commit`.
`pre-commit` and ty, a type checker, are in the group `lint`, and `just check` runs ty. The tests that ask the real
Wikipedia run only on request.

The project runs on one Python, and its users may have an older one. `.python-version` says which Python `.venv`
has. `requires-python` says which versions of Python the project accepts.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/307d4d7b36bb9dc7bc8ad601c8275d5241283e35). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d8af75e8fd576ae8d09cb76ed960b1c4892e0a84).

<a id="step-06.3"></a>

### 6.3 Any Python from 3.11 on

The project asks for Python 3.13, and nothing in it needs more than 3.11. `uv init` wrote
`requires-python = ">=3.13"`, because the command that made the project asked for Python 3.13. Python 3.10 reached
its end of life on 1 October 2026, so 3.11 is now the oldest Python that still gets security fixes. The line in
`pyproject.toml` now says 3.11.

Set the values that this change sets in [`pyproject.toml`](#step-06.3-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It sets each of these values as the project has it, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import pathlib, tomlkit
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# Each value that the change sets, by its keys
SET = [
    (('project', 'requires-python'), '>=3.11'),
]

def put(table, keys, value):   # make each table on the way; a table goes into the one there, key by key
    for key in keys[:-1]:
        if key not in table:
            table[key] = tomlkit.table(True)
        table = table[key]
    if isinstance(value, dict) and isinstance(table.get(keys[-1]), dict):
        for key, item in value.items():
            put(table[keys[-1]], [key], item)
    else:
        table[keys[-1]] = value

for keys, value in SET:
    put(doc, keys, value)
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

The patch changes one line of `pyproject.toml`, line 9, `requires-python`.

The lockfile, `uv.lock`, was resolved for Python 3.13 and newer. It no longer matches `pyproject.toml`, and this
move leaves it so on purpose. Line 6 of the `justfile` sets `UV_LOCKED` to 1 for every recipe, so uv refuses a
lockfile that does not match. So `just setup`, `just test` and `just check` fail until the next move resolves the
lockfile again.

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

The first of these moves changes `requires-python` by hand, and the second runs `uv lock`. Between the two, the
lockfile is out of date with `pyproject.toml`, and every recipe that runs `uv run` refuses it.

The second of these moves runs the tests with `uv run --isolated --python 3.11`. `--isolated` makes a second
environment, and uv deletes it after the command. `uvx` makes a third kind, an
environment of its own for one tool.

```bash
uv run python -c "import sys; print(sys.prefix)"
uvx --from ruff python -c "import sys; print(sys.prefix)"
```

The first path ends in `.venv`. The second is a folder in the cache of uv, with ruff installed. `uvx ruff` picks a
ruff of its own, which need not be the version that the lockfile names. So the recipes run ruff with `uv run`, and
get the version of the lockfile.

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

## 6.5 Versions of Python and groups on GitHub

```bash
just setup
```

GitHub runs the tests on several versions of Python, and each job installs groups. This section shows which groups GitHub's
jobs install.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/d8af75e8fd576ae8d09cb76ed960b1c4892e0a84). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/20cf458261edc55b725da39a99c9b37ef5d24657).

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

The job `tests` runs `uv run --locked pytest`, and so it installs every group, with ruff, ty and `pre-commit`.
pytest needs none of them. A dry run shows what the job would leave out with the group `test` alone.

```bash
uv sync --locked --no-default-groups --group test --dry-run
```

uv would uninstall 14 packages, ruff, ty, `pre-commit` and validate-pyproject among them. The project makes this
change in the next section.

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

<a id="step-08b"></a>

## 8b Each job on GitHub with its own group

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source 20cf458261ed --staged -- :/ && git restore --source ce0734f1272c --staged --worktree -- :/
```

The code now also has pydantic in the dependencies, from `uv add pydantic`. The function `random_page`, which asks
Wikipedia for a page, now returns a `Page`. A `Page` is a pydantic model, a class that checks the type of each of
its fields. smalldocs is in a new group `docs`. `just docs` builds a site from the code,
and `just docs check` counts what has documentation.

```bash
just setup
```

Every job on GitHub installs every dependency group, with every tool of the project, though most jobs need only a
few. Also, the docs site exists only on the machine that builds it. So we make the job `tests` install the group `test`
alone. Then a new workflow builds the docs site with the group `docs` alone, and GitHub Pages publishes it.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/ce0734f1272cf16f4aadeaa6712e589010ccd69f). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/39a4b09f85638bbe8424b243c4ba4477070f2740).

<a id="step-08b.1"></a>

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

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 971e9d780fd5
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source ce0734f1272c --staged -- :/ && git restore --source 971e9d780fd5 --staged --worktree -- :/
```

#### What changed

- <a id="step-08b.1-.github-workflows-test.yaml-a60e23"></a>`.github/workflows/test.yaml`: the comment, and the command of the job `tests`. 2 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/971e9d780fd539d13f49af3fbb00c1145fd22aa0/.github/workflows/test.yaml).
  - look at `- run: uv run --locked --no-default-groups --group test pytest  # the package and its tests, no more`

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/971e9d780fd539d13f49af3fbb00c1145fd22aa0). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/971e9d780fd539d13f49af3fbb00c1145fd22aa0).

<a id="step-08b.2"></a>

### 8b.2 A workflow that publishes the docs

`just docs` builds the docs site on one machine, and nobody else can read it. A second workflow,
`.github/workflows/docs.yaml`, builds the site on GitHub on every push to main, and GitHub Pages publishes it.

The workflow has two jobs. The job `build`, from line 21, installs the package and the group `docs`, and runs
`smalldocs render docs`, the command behind `just docs`. It does not run `just docs`, because that recipe, at
line 85, runs `uv run` with no option, which installs every group. The job then gives the folder
`docs/_site` to Pages. The job `deploy`, from line 32, publishes it.

Lines 11 to 14, under `permissions`, let the workflow publish to Pages. Lines 16 to 18, under `concurrency`, stop
an older publish when a newer push starts one.

The file is new, and comes whole, as a patch.

Apply the patch to [`.github/workflows/docs.yaml`](#step-08b.2-.github-workflows-docs.yaml-ce7835), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/39a4b09f85638bbe8424b243c4ba4477070f2740.diff | git apply --include=.github/workflows/docs.yaml
```

Read the comment at the top, then the lines under `permissions`, `concurrency` and `jobs`.

The workflow runs only where two settings on GitHub allow it. The settings are not in any file of the project. Both
are on GitHub's website, and need no tool on your machine.

- **Actions.** GitHub turns off the workflows of a fork, until its owner turns them on, on the tab **Actions**.
- **Pages.** Under **Settings**, then **Pages**, the source of the site must be **GitHub Actions**.

GitHub then publishes the site at `https://OWNER.github.io/smallwikiapp/`, where OWNER is the name of the account
that owns the fork. The account rahuldave has a domain of its own. So the site of rahuldave/smallwikiapp is at
[rahuldave.com/smallwikiapp](https://rahuldave.com/smallwikiapp/).

In every fork, the links from the reference to the code go to rahuldave/smallwikiapp. Line 20 of
`docs/_smalldocs.yml` names that repository.

To publish the docs from your own fork of smallwikiapp, do these things on GitHub's website.

1. Fork https://github.com/rahuldave/smallwikiapp, if you have no fork of it yet.
2. In your fork, open the tab **Actions**, and turn the workflows on.
3. Open **Settings**, then **Pages**. Under **Source**, choose **GitHub Actions**.
4. Open **Actions**, and choose the workflow **Docs**. Press **Run workflow**, keep the branch `main`, and press the
   green **Run workflow** under it.
5. When the run ends, open `https://YOU.github.io/smallwikiapp/`, with the name of your account in place of YOU.

Your fork has the finished project, so the site shows its docs. The changes that you make in this tutorial stay
on your machine, and do not reach the fork. From then on, each push to the main branch of your fork builds the site
again.

```bash
uv run pre-commit run check-yaml --files .github/workflows/docs.yaml
uv run --isolated --locked --no-default-groups --group docs smalldocs render docs
```

The file is valid YAML. The second command builds the site as the job does, with the group `docs` alone, and
prints `wrote 3 page(s) to docs/_site`. git ignores `docs/_site`.

`--no-default-groups --group NAME` installs the package and one group. A person and the job `check` still install
every group, since they run every tool.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 39a4b09f8563
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 971e9d780fd5 --staged -- :/ && git restore --source 39a4b09f8563 --staged --worktree -- :/
```

#### What changed

- <a id="step-08b.2-.github-workflows-docs.yaml-ce7835"></a>`.github/workflows/docs.yaml`: the site, built with the group `docs` alone, then published. New, 40 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/39a4b09f85638bbe8424b243c4ba4477070f2740/.github/workflows/docs.yaml).
  - look at `- run: uv run --locked --no-default-groups --group docs smalldocs render docs`

<details open><summary>The patch to <code>.github/workflows/docs.yaml</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/39a4b09f85638bbe8424b243c4ba4477070f2740). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/39a4b09f85638bbe8424b243c4ba4477070f2740).

<a id="step-09.1-to-step-09.2"></a>

## 9.1 to 9.2 A workspace

```bash
just setup
```

The library and the app are in one package. So a program that needs only the library must install the app too. The library becomes a
second package of the project. The two packages form a workspace. The library also needs packages of its own.
`--package wikirandom` makes `uv add` change the library's `pyproject.toml`, and not the app's.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/39a4b09f85638bbe8424b243c4ba4477070f2740). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/c153cdfc43300110bd63502b3d53a85ab3aa79f1).

<a id="step-09.1"></a>

### 9.1 An empty library, wikirandom

A second package needs its own folder, its own `pyproject.toml` and its own code. uv can make it inside the
project. The two packages then form a *workspace*, which has one lockfile and one `.venv` for both. `uv init`
makes the library, and each option writes one thing:

- `--lib` makes a library, with its code under `src/`, and no script to run.
- `--author-from none` writes no `authors`, so no name or email from git goes into the library.
- `--no-pin-python` asks for no `.python-version` file of the library's own. The project's file stays the only
  one.
- `--python ">=3.11"` writes `requires-python = ">=3.11"`, the same range as the app. Without it, uv writes
  `">=3.13"`, from the project's `.python-version`.
- `--description` writes the library's `description`, in place of uv's "Add your description here".

```bash
uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom
```

uv makes the folder `packages/wikirandom/`, with what a library needs. It has its own `pyproject.toml`, an empty
README, and code with an example function, `hello`. An empty file, `py.typed`, tells a type checker that the
package has types.

In the project's `pyproject.toml`, uv adds the table `[tool.uv.workspace]`, at lines 27 to 30, with the library in
its list `members`.

Another version of uv writes another range for `uv_build` in line 10 of the library's `pyproject.toml`, so that
line can differ from the one here. If the line differs, the check of your files still passes, because it ignores
version numbers.

`uv init` does not change `uv.lock`, so the lockfile does not list the new member yet. Line 6 of the `justfile`
sets `UV_LOCKED`, so every recipe refuses a lockfile that is out of date. After this move, `just setup`,
`just test` and `just check` fail on purpose. Each prints an error that names `uv.lock`, and a hint to run
`uv lock`. The next move, `uv add`, resolves the lockfile again for the workspace.

```bash
uv lock --check
```

The command prints `Resolved 42 packages`, then an error that names `uv.lock`, and a hint to run `uv lock`. Its
exit code is 1. Before this move, the lockfile had 41 packages. The 42nd is `wikirandom`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 01364831243e
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 39a4b09f8563 --staged -- :/ && git restore --source 01364831243e --staged --worktree -- :/
```

#### What changed

- <a id="step-09.1-packages-wikirandom-README.md-105646"></a>`packages/wikirandom/README.md`: empty. New, 0 lines. It comes from `uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/01364831243e6c4c4f2fab3756eb1c633f6903c8/packages/wikirandom/README.md).
- <a id="step-09.1-packages-wikirandom-pyproject.toml-28d6f6"></a>`packages/wikirandom/pyproject.toml`: a package of its own, with its name, version, description, the versions of Python it accepts, and its build backend. New, 11 lines. It comes from `uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/01364831243e6c4c4f2fab3756eb1c633f6903c8/packages/wikirandom/pyproject.toml).
  - look at `name = "wikirandom"`
- <a id="step-09.1-packages-wikirandom-src-wikirandom-__init__.py-343c23"></a>`packages/wikirandom/src/wikirandom/__init__.py`: uv's example function. New, 2 lines. It comes from `uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/01364831243e6c4c4f2fab3756eb1c633f6903c8/packages/wikirandom/src/wikirandom/__init__.py).
  - look at `def hello() -> str:`
- <a id="step-09.1-packages-wikirandom-src-wikirandom-py.typed-072343"></a>`packages/wikirandom/src/wikirandom/py.typed`: an empty file, which tells a type checker that the package has types. New, 0 lines. It comes from `uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/01364831243e6c4c4f2fab3756eb1c633f6903c8/packages/wikirandom/src/wikirandom/py.typed).
- <a id="step-09.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the workspace, with one member. 5 lines added. It comes from `uv init --lib --author-from none --no-pin-python --python ">=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/01364831243e6c4c4f2fab3756eb1c633f6903c8/pyproject.toml).
  - look at `"packages/wikirandom",`

<details><summary>The diff that <code>uv init --lib --author-from none --no-pin-python --python "&gt;=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom</code> makes in <code>packages/wikirandom/pyproject.toml</code></summary>

```diff
@@ -0,0 +1,11 @@
+[project]
+name = "wikirandom"
+version = "0.1.0"
+description = "A random page of Wikipedia, in any language"
+readme = "README.md"
+requires-python = ">=3.11"
+dependencies = []
+
+[build-system]
+requires = ["uv_build>=0.12.13,<0.13.0"]
+build-backend = "uv_build"
```

</details>

<details><summary>The diff that <code>uv init --lib --author-from none --no-pin-python --python "&gt;=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom</code> makes in <code>packages/wikirandom/src/wikirandom/__init__.py</code></summary>

```diff
@@ -0,0 +1,2 @@
+def hello() -> str:
+    return "Hello from wikirandom!"
```

</details>

<details><summary>The diff that <code>uv init --lib --author-from none --no-pin-python --python "&gt;=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -24,6 +24,11 @@ build-backend = "uv_build"
 # uv sync and uv run install every dependency group, not only dev
 default-groups = "all"
 
+[tool.uv.workspace]
+members = [
+    "packages/wikirandom",
+]
+
 [dependency-groups]
 docs = [
     "smalldocs>=0.1.5",
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/01364831243e6c4c4f2fab3756eb1c633f6903c8). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/01364831243e6c4c4f2fab3756eb1c633f6903c8).

<a id="step-09.2"></a>

### 9.2 requests and pydantic, for the library

The library's code will be the code of `src/wikiapp/wikipedia.py`, which imports requests and pydantic. So they
become the library's dependencies. `--package wikirandom` makes `uv add` change the library's `pyproject.toml`,
and not the app's. uv also resolves the lockfile again, for the whole workspace, so the lockfile now lists the
library.

```bash
uv add --package wikirandom requests pydantic
```

```bash
uv lock --check
uv tree --package wikirandom
```

`uv lock --check` prints `Resolved 42 packages`, with no error, so `just setup`, `just test` and `just check`
pass again. `uv tree` shows `wikirandom v0.1.0`, with `pydantic v2.14.1` and `requests v2.34.2` under it.

A workspace member is a package that the root `pyproject.toml` names under `[tool.uv.workspace]`. With no
workspace, the app could name the library by its folder. In section 9, it would write the line below under
`[tool.uv.sources]`.

```toml
wikirandom = { path = "packages/wikirandom" }
```

Without a workspace:

- uv would copy the library into `.venv`. A plain sync does not see an edit to the library, so the edit would
  reach the app only after `uv sync --reinstall-package wikirandom`.
- The library would be a project of its own. `uv lock` in its folder would write a second lockfile.
- `uv run --package wikirandom` would fail, and `uv build --all-packages` would build only the app.

In the next section, the app comes to depend on the library. Because the library is a member of the workspace, uv
then installs it editable. An editable install points `.venv` at the library's code, in `packages/wikirandom/src`, so an edit to the library
reaches the app at once.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check c153cdfc4330
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 01364831243e --staged -- :/ && git restore --source c153cdfc4330 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.2-packages-wikirandom-pyproject.toml-28d6f6"></a>`packages/wikirandom/pyproject.toml`: its dependencies. 4 lines added, 1 removed. It comes from `uv add --package wikirandom requests pydantic`. [The file](https://github.com/rahuldave/smallwikiapp/blob/c153cdfc43300110bd63502b3d53a85ab3aa79f1/packages/wikirandom/pyproject.toml).
  - look at `"pydantic>=2.14.1",`
- <a id="step-09.2-uv.lock-8356d8"></a>`uv.lock`: the two members of the workspace, and the library with its dependencies. 21 lines added. It comes from `uv add --package wikirandom requests pydantic`. [The file](https://github.com/rahuldave/smallwikiapp/blob/c153cdfc43300110bd63502b3d53a85ab3aa79f1/uv.lock).

<details><summary>The diff that <code>uv add --package wikirandom requests pydantic</code> makes in <code>packages/wikirandom/pyproject.toml</code></summary>

```diff
@@ -4,7 +4,10 @@ version = "0.1.0"
 description = "A random page of Wikipedia, in any language"
 readme = "README.md"
 requires-python = ">=3.11"
-dependencies = []
+dependencies = [
+    "pydantic>=2.14.1",
+    "requests>=2.34.2",
+]
 
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/c153cdfc43300110bd63502b3d53a85ab3aa79f1). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/c153cdfc43300110bd63502b3d53a85ab3aa79f1).

<a id="step-09.6-to-step-09.8"></a>

## 9.6 to 9.8 The app uses the library

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source c153cdfc4330 --staged -- :/ && git restore --source 34f1041135a7 --staged --worktree -- :/
```

```bash
just setup
```

The code now also has a README of the library, and a copy of `wikipedia.py` as the library's code. The library has
its own docstring, and its User-Agent names `wikirandom`.

The app must get the library from the workspace, not from PyPI. The app's `pyproject.toml` names the library as a
dependency, and `[tool.uv.sources]` says where uv gets it.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/34f1041135a78b1015d73e8fcb2529102c5ccf9e). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/f2dd413c02c731553f8c103b0e6c892dac0fa2dc).

<a id="step-09.6"></a>

### 9.6 The app depends on wikirandom

The app and the library now each have a copy of the code that asks Wikipedia for a page. Before the app can import the library, the library must be
a dependency of the app.

```bash
uv add wikirandom
```

wikirandom is a member of the workspace, so `uv add` also writes `wikirandom = { workspace = true }` under
`[tool.uv.sources]`. uv then installs the library from `packages/wikirandom`, and not from PyPI. It installs it
editable. An editable install points `.venv` at the library's folder, so an edit to the library reaches the app at
once, with no new install.

```bash
uv run python -c "import wikirandom; print(wikirandom.__file__)"
```

`uv add` installed the library, and the app now depends on it, so Python finds it under a plain `uv run`. The
command prints a path that ends with
`packages/wikirandom/src/wikirandom/__init__.py`, the file in the repository, not a copy.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 854534692873
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 34f1041135a7 --staged -- :/ && git restore --source 854534692873 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.6-pyproject.toml-5d07e7"></a>`pyproject.toml`: the app depends on the library, from the workspace. 4 lines added. It comes from `uv add wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8545346928730b73e69a52a7652ff4fbf15a333c/pyproject.toml).
  - look at `wikirandom = { workspace = true }`
- <a id="step-09.6-uv.lock-8356d8"></a>`uv.lock`: the app's dependencies have wikirandom. 2 lines added. It comes from `uv add wikirandom`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8545346928730b73e69a52a7652ff4fbf15a333c/uv.lock).

<details><summary>The diff that <code>uv add wikirandom</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -11,6 +11,7 @@ dependencies = [
     "click>=8.5.0",
     "pydantic>=2.14.1",
     "requests>=2.34.2",
+    "wikirandom",
 ]
 
 [project.scripts]
@@ -29,6 +30,9 @@ members = [
     "packages/wikirandom",
 ]
 
+[tool.uv.sources]
+wikirandom = { workspace = true }
+
 [dependency-groups]
 docs = [
     "smalldocs>=0.1.5",
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/8545346928730b73e69a52a7652ff4fbf15a333c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/8545346928730b73e69a52a7652ff4fbf15a333c).

<a id="step-09.7"></a>

### 9.7 The app uses wikirandom

The app must use the library, and drop its own `src/wikiapp/wikipedia.py`. Its tests then test the library,
coverage measures both packages, and the README and the docs say that there are two packages. `rm` deletes the
app's file, and there is one patch for each of the six other files.

```bash
rm src/wikiapp/wikipedia.py
```

`src/wikiapp/console.py` imports from the library. The import goes with the installed packages, under
`import click`, so the lines are already in ruff's order. `tests/test_wikipedia.py` keeps its name for now, and
tests the library. Each `wikipedia.` becomes `wikirandom.`, and the file imports `wikirandom` under `import pytest`.
The host `es.wikipedia.org` in the first test stays as it was.

Coverage measured `wikiapp` alone, and must measure both packages. Last, three files must say that there are two
packages, and that the app uses the library. They are the README, the front page of the docs and the library's
README.

Apply the patch to [`src/wikiapp/console.py`](#step-09.7-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/78ab09579fdffcb2db04e83807817e2edba27ebe.diff | git apply --include=src/wikiapp/console.py
```

Apply the patch to [`tests/test_wikipedia.py`](#step-09.7-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/78ab09579fdffcb2db04e83807817e2edba27ebe.diff | git apply --include=tests/test_wikipedia.py
```

Set the values that this change sets in [`pyproject.toml`](#step-09.7-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It sets each of these values as the project has it, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import pathlib, tomlkit
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# Each value that the change sets, by its keys
SET = [
    (('tool', 'pytest', 'ini_options', 'addopts'),
     "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"),
]

def put(table, keys, value):   # make each table on the way; a table goes into the one there, key by key
    for key in keys[:-1]:
        if key not in table:
            table[key] = tomlkit.table(True)
        table = table[key]
    if isinstance(value, dict) and isinstance(table.get(keys[-1]), dict):
        for key, item in value.items():
            put(table[keys[-1]], [key], item)
    else:
        table[keys[-1]] = value

for keys, value in SET:
    put(doc, keys, value)
path.write_text(tomlkit.dumps(doc), encoding='utf-8')
PY
```

Apply the patch to [`README.md`](#step-09.7-README.md-8ec9a0), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/78ab09579fdffcb2db04e83807817e2edba27ebe.diff | git apply --include=README.md
```

Apply the patch to [`docs/index.qmd`](#step-09.7-docs-index.qmd-d6d880), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/78ab09579fdffcb2db04e83807817e2edba27ebe.diff | git apply --include=docs/index.qmd
```

Apply the patch to [`packages/wikirandom/README.md`](#step-09.7-packages-wikirandom-README.md-105646), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/78ab09579fdffcb2db04e83807817e2edba27ebe.diff | git apply --include=packages/wikirandom/README.md
```

In `src/wikiapp/console.py`, the patch deletes the import from `wikiapp.wikipedia`, and puts
`from wikirandom import WikipediaError, random_page` under `import click`, in line 6. In
`tests/test_wikipedia.py`, read the docstring in line 1, the import in line 6, and each call that now starts with
`wikirandom.`. In `pyproject.toml`, the patch changes the first line of the comment above `addopts`, and adds
`--cov=wikirandom` to the line `addopts`. In `README.md`, it puts two rows in place of the row of `src/wikiapp/` in
the table of folders. In `docs/index.qmd`, it rewrites the paragraph about the modules. In
`packages/wikirandom/README.md`, "will use" becomes "uses".

```bash
just test -q
uv tree --depth 2
just docs check
just docs
```

The tests print `7 passed, 2 deselected`, and the coverage table lists
`packages/wikirandom/src/wikirandom/__init__.py`, and no longer `src/wikiapp/wikipedia.py`. `uv tree` shows that
wikirandom needs pydantic and requests, and that wikiapp still lists them too, beside click and wikirandom. The
app no longer imports them, so the next move removes them. `just docs check` still counts the app and the tests
alone, 12 of 12. `just docs` writes 2 pages, the front page and the reference page of the app. The front page
names both packages, but `random_page` is not yet a link, because the settings of the site name only the app.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 78ab09579fdf
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 854534692873 --staged -- :/ && git restore --source 78ab09579fdf --staged --worktree -- :/
```

#### What changed

- <a id="step-09.7-README.md-8ec9a0"></a>`README.md`: one row more, and the `src/wikiapp/` row says the app. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/78ab09579fdffcb2db04e83807817e2edba27ebe/README.md).
  - look at `| The library the app uses: a random page of Wikipedia. A package of its own |`
- <a id="step-09.7-docs-index.qmd-d6d880"></a>`docs/index.qmd`: two packages. 8 lines added, 7 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/78ab09579fdffcb2db04e83807817e2edba27ebe/docs/index.qmd).
  - look at `The code has two packages, in one repository:`
- <a id="step-09.7-packages-wikirandom-README.md-105646"></a>`packages/wikirandom/README.md`: the library's README says that the app uses it. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/78ab09579fdffcb2db04e83807817e2edba27ebe/packages/wikirandom/README.md).
  - look at ``A random page of Wikipedia, in any language. The command `wikiapp` uses this library.``
- <a id="step-09.7-pyproject.toml-5d07e7"></a>`pyproject.toml`: coverage measures both packages. 2 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/78ab09579fdffcb2db04e83807817e2edba27ebe/pyproject.toml).
  - look at `addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"`
- <a id="step-09.7-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: one import. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/78ab09579fdffcb2db04e83807817e2edba27ebe/src/wikiapp/console.py).
  - look at `from wikirandom import WikipediaError, random_page`
- <a id="step-09.7-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: deleted. Its code is in the library. Deleted. It comes from `rm src/wikiapp/wikipedia.py`.
- <a id="step-09.7-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the same three tests, of the library. 7 lines added, 8 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/78ab09579fdffcb2db04e83807817e2edba27ebe/tests/test_wikipedia.py).
  - look at `wikirandom.random_page(language="es")`

<details open><summary>The patch to <code>README.md</code></summary>

```diff
@@ -30,7 +30,8 @@ Then `just setup`, and `uv run wikiapp`.
 | Path | What it is |
 |---|---|
 | `pyproject.toml`, `uv.lock` | The project: its name, its Python, its dependencies, and the exact versions installed |
-| `src/wikiapp/` | The code. `wikipedia.py` is the library, `console.py` the `wikiapp` command |
+| `src/wikiapp/` | The app. `console.py` is the `wikiapp` command |
+| `packages/wikirandom/` | The library the app uses: a random page of Wikipedia. A package of its own |
 | `tests/` | The tests. `just test` runs them |
 | `docs/` | The docs site. smalldocs makes its reference from the code |
 | `justfile` | Every task of the project, one recipe each. `just help VERB` explains one |
```

</details>

<details open><summary>The patch to <code>docs/index.qmd</code></summary>

````diff
@@ -16,13 +16,14 @@ Le Changement démocratique est un parti politique salvadorien fondé en
 2005.
 ```
 
-The code has two modules:
-
-- `wikiapp.wikipedia`, the library. `random_page` asks Wikipedia for a random page and returns a
-  `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a language
-  code, if the request fails, or if the answer is not a page. The library knows nothing of the command line.
-- `wikiapp.console`, the app. `main` is the command. It reads `--language`, calls `random_page`, and
-  prints the page, or the error.
+The code has two packages, in one repository:
+
+- `wikirandom`, the library, in `packages/wikirandom`. `random_page` asks Wikipedia for a random page
+  and returns a `Page`, with a title and an extract. It raises `WikipediaError` if the language is not a
+  language code, if the request fails, or if the answer is not a page. The library knows nothing of the
+  command line.
+- `wikiapp`, the app. `main`, in `wikiapp.console`, is the command. It reads `--language`, calls
+  `random_page`, and prints the page, or the error.
 
 Each build of the site makes the pages under Reference from the code. A page takes these parts from
 each function:
````

</details>

<details open><summary>The patch to <code>packages/wikirandom/README.md</code></summary>

```diff
@@ -1,3 +1,3 @@
 # wikirandom
 
-A random page of Wikipedia, in any language. The command `wikiapp` will use this library.
+A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```

</details>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -51,10 +51,10 @@ test = [
 
 [tool.pytest.ini_options]
 testpaths = ["tests"]
-# Every run measures how much of src/wikiapp the tests run, and lists the lines they do not. A test
+# Every run measures how much of the two packages the tests run, and lists the lines they do not. A test
 # marked e2e asks the real Wikipedia, so it needs the network, and runs only when asked for:
 # just test -m e2e
-addopts = "--cov=wikiapp --cov-report=term-missing -m 'not e2e'"
+addopts = "--cov=wikiapp --cov=wikirandom --cov-report=term-missing -m 'not e2e'"
 markers = ["e2e: end to end, against the real Wikipedia; run with -m e2e"]
 
 [tool.ruff]
```

</details>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

```diff
@@ -3,9 +3,9 @@
 import textwrap
 
 import click
+from wikirandom import WikipediaError, random_page
 
 from wikiapp import __version__
-from wikiapp.wikipedia import WikipediaError, random_page
 
 
 @click.command()
```

</details>

<details><summary>The diff that <code>rm src/wikiapp/wikipedia.py</code> makes in <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,41 +0,0 @@
-"""Wikipedia's REST API: a random page."""
-
-import re
-
-import requests
-from pydantic import BaseModel, ValidationError
-
-API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
-LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
-USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
-
-
-class WikipediaError(Exception):
-    """Wikipedia could not give a page."""
-
-
-class Page(BaseModel):
-    """A page of Wikipedia: its title and the summary of its text."""
-
-    title: str  # The title of the page
-    extract: str  # The summary: the first paragraph of the page, as plain text
-
-
-def random_page(
-    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
-) -> Page:  # A page chosen at random
-    """Get a random page from Wikipedia.
-
-    Raises WikipediaError when the language is not a language code, when the request fails, or
-    when the answer is not a page.
-    """
-    if not LANGUAGE.fullmatch(language):
-        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
-    try:
-        with requests.get(
-            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
-        ) as response:
-            response.raise_for_status()
-            return Page.model_validate(response.json())
-    except (requests.RequestException, ValidationError) as error:
-        raise WikipediaError(str(error)) from error
```

</details>

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -1,17 +1,16 @@
-"""Tests of the library, wikipedia.py."""
+"""Tests of the library, wikirandom."""
 
 from unittest.mock import Mock
 
 import pytest
-
-from wikiapp import wikipedia
+import wikirandom
 
 
 def test_random_page_uses_given_language(
     mock_requests_get: Mock,  # The mock of `requests.get`, from conftest.py
 ) -> None:
     """The language chooses the Wikipedia that is asked."""
-    wikipedia.random_page(language="es")
+    wikirandom.random_page(language="es")
     args, _ = mock_requests_get.call_args
     assert "es.wikipedia.org" in args[0]
 
@@ -19,8 +18,8 @@ def test_random_page_uses_given_language(
 @pytest.mark.e2e
 def test_random_page_returns_page_in_production() -> None:
     """The real Wikipedia's answer makes a Page."""
-    page = wikipedia.random_page()
-    assert isinstance(page, wikipedia.Page)
+    page = wikirandom.random_page()
+    assert isinstance(page, wikirandom.Page)
 
 
 def test_random_page_handles_validation_error(
@@ -28,5 +27,5 @@ def test_random_page_handles_validation_error(
 ) -> None:
     """An answer that is not a page raises WikipediaError."""
     mock_requests_get.return_value.__enter__.return_value.json.return_value = {}
-    with pytest.raises(wikipedia.WikipediaError):
-        wikipedia.random_page()
+    with pytest.raises(wikirandom.WikipediaError):
+        wikirandom.random_page()
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/78ab09579fdffcb2db04e83807817e2edba27ebe). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/78ab09579fdffcb2db04e83807817e2edba27ebe).

<a id="step-09.8"></a>

### 9.8 The app no longer needs requests and pydantic

The app no longer imports pydantic. Of its files, only `tests/test_console.py` imports requests, in line 6, and
requests now comes with wikirandom. So the two leave the app's dependencies. The library still depends on them, so
the lockfile keeps them.

```bash
uv remove requests pydantic
```

```bash
uv tree --invert --package requests
just test -q
```

`uv tree --invert` shows who needs requests. After uv's line `Resolved 42 packages`, it prints `requests v2.34.2`, then `wikirandom v0.1.0`
under it, and `wikiapp v0.1.0` under that. The app gets requests only through the library. The tests still print
`7 passed, 2 deselected`.

```bash
ls -a packages/wikirandom
```

The library's folder has its `pyproject.toml`, and no `uv.lock` or `.venv`. The workspace has one lockfile and one
`.venv`, at its root.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check f2dd413c02c7
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 78ab09579fdf --staged -- :/ && git restore --source f2dd413c02c7 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.8-pyproject.toml-5d07e7"></a>`pyproject.toml`: the app's dependencies are click and wikirandom. 0 lines added, 2 removed. It comes from `uv remove requests pydantic`. [The file](https://github.com/rahuldave/smallwikiapp/blob/f2dd413c02c731553f8c103b0e6c892dac0fa2dc/pyproject.toml).
- <a id="step-09.8-uv.lock-8356d8"></a>`uv.lock`: the app no longer depends on pydantic and requests by itself. 0 lines added, 4 removed. It comes from `uv remove requests pydantic`. [The file](https://github.com/rahuldave/smallwikiapp/blob/f2dd413c02c731553f8c103b0e6c892dac0fa2dc/uv.lock).

<details><summary>The diff that <code>uv remove requests pydantic</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -9,8 +9,6 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
-    "pydantic>=2.14.1",
-    "requests>=2.34.2",
     "wikirandom",
 ]
 
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/f2dd413c02c731553f8c103b0e6c892dac0fa2dc). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/f2dd413c02c731553f8c103b0e6c892dac0fa2dc).

<a id="step-10.1"></a>

## 10.1 A build of both packages

This part does not start where the part before it ends, because the walk skips some changes. This command puts the files that this part starts from in place of yours. Run it, and then go on:

```bash
git restore --source f2dd413c02c7 --staged -- :/ && git restore --source 259e6364a52f --staged --worktree -- :/
```

```bash
just setup
```

The code now also has a docs check that counts the library. The tests of the library are now in
`tests/test_wikirandom.py`.

A user installs a package from a wheel, and not from a copy of the repository. A wheel is one file that contains
the package, ready to install. `uv build` makes the wheel, and also a source archive of the code, with the build
backend that its `pyproject.toml` names, here `uv_build`. A build backend is the tool that packs the code into that file.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/259e6364a52f83993c797f66148281b04eb92060). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/7744a84a4715e6edb876e1c4f3255daf524dd07d).

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

<a id="step-10.2"></a>

## 10.2 A range of versions for the library

```bash
just setup
```

`uv build` copies each entry of `dependencies` into a line `Requires-Dist` in the wheel's metadata. `[tool.uv.sources]` does not
go into the wheel. The app names wikirandom with no range of versions, so a user who installs the app from PyPI
can get any version of wikirandom.

[The code before this part](https://github.com/rahuldave/smallwikiapp/tree/7744a84a4715e6edb876e1c4f3255daf524dd07d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/6e6d2844bc7a5b34605ad76b9e03e6631fa236be).

### 10.2 The app needs wikirandom 0.1

The app's wheel says that the app needs `wikirandom`, of any version. A later release that changes the library
could break the app. The app works with wikirandom 0.1.0, so its dependency gets the range
`>=0.1.0,<0.2`. `<0.2` keeps out 0.2 and later.

```bash
uv add "wikirandom>=0.1.0,<0.2"
```

The range changes only the metadata of the app's wheel, and uv installs the same code as before. In `pyproject.toml`,
the table `[tool.uv.sources]` tells uv to take wikirandom from the workspace. `[tool.uv.workspace]` names the folder `packages/wikirandom` as a member of the
workspace, so uv installs the library from that folder.

```bash
just build
unzip -p dist/wikiapp-0.1.0-py3-none-any.whl wikiapp-0.1.0.dist-info/METADATA
```

The metadata says `Requires-Dist: wikirandom>=0.1.0,<0.2`.

This tutorial ends here. After it, the whole tutorial changes the justfile, and gives the library a licence and an
author. Both packages get a link to the repository. The User-Agent says the installed version. The
[whole tutorial](https://rahuldave.com/smallwikiapp-walk/) has every change.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 6e6d2844bc7a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 7744a84a4715 --staged -- :/ && git restore --source 6e6d2844bc7a --staged --worktree -- :/
```

#### What changed

- <a id="step-10.2-pyproject.toml-5d07e7"></a>`pyproject.toml`: one line, the range of versions. 1 line added, 1 removed. It comes from `uv add "wikirandom>=0.1.0,<0.2"`. [The file](https://github.com/rahuldave/smallwikiapp/blob/6e6d2844bc7a5b34605ad76b9e03e6631fa236be/pyproject.toml).
  - look at `"wikirandom>=0.1.0,<0.2",`

<details><summary>The diff that <code>uv add "wikirandom&gt;=0.1.0,&lt;0.2"</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -9,7 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
-    "wikirandom",
+    "wikirandom>=0.1.0,<0.2",
 ]
 
 [project.scripts]
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6e6d2844bc7a5b34605ad76b9e03e6631fa236be). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/6e6d2844bc7a5b34605ad76b9e03e6631fa236be).
