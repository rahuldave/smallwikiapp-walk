<!-- Made by the walk skill's render.py from the facts of the walk. Do not edit it by hand: run just walk-update again. -->

# smallwikiapp

**Build it yourself.** Every command to run and every change to make by hand, to make the project yourself. [Read the tutorial](read.md) is the other way to read it.

Each part ends with a section called **What changed**. It lists every file that the part changes, with a link to the file, and then the whole diff of each file, folded. A lockfile and a binary file have a link alone. The text above it explains the change. What changed is what you check your files against.

In Build it yourself, a file that a command makes says which command. A diff that is open is a patch. Apply it with the command in the text, or make the same change in your editor.

We build `wikiapp`, a small command that prints the title and the summary of a random Wikipedia page. Around the
command we build the project. A tool called [uv](https://docs.astral.sh/uv/) installs the project's packages, which are code that other people wrote and
that the project uses. The project also gets tests, a library, a formatter for the layout of the code, and a linter
for likely mistakes. It gets a check that each value in the code is the kind of value that the code expects. It also gets checks on
GitHub, documentation made from the code, and a build.

We make the project in moves. A move is one small change, made by one patch or by one command. A patch is a list of
lines to add to a file and lines to take out of it. A command, such as `uv add`, changes its files by itself,
with no patch. In **Build it yourself**, you make each move by hand, and then a command compares your files with the project's. In **Read the
tutorial**, each move is already made, and the text explains what changed.

Each move first says what problem it solves. Then it gives the change, piece by piece, and a command that checks
the result. Each larger part of the tutorial starts with the command `just setup`. The tool [`just`](https://just.systems/) runs
short commands that the project names. `just setup` asks uv to install the packages that the code needs at that
point.

The project is a rebuild of [the original wikiapp](https://github.com/rahuldave/wikiapp), which its author wrote in
2024 with pixi, another tool that installs a project's packages. Where the text says "the original wikiapp", it means that project.

The code is on GitHub, at [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp). Its author kept
the history of the project with git, a tool that records each change. That history, each change of the whole
tutorial one after another, is on GitHub too. A tag is a name for
one point in that history. The tags `step-00` to `step-10`, with `step-08b`, name the code at the end of each part
of the whole tutorial.

At the end, the command is in `src/wikiapp/`. `wikirandom`, the library that asks Wikipedia for a
random page, has a folder of its own, `packages/wikirandom/`. The tests of both are in `tests/`. The project also has a website of
documentation, the docs site, and `docs/` has its front page and its settings.

GitHub can also run the tasks of the project on its own machines. Each file in `.github/workflows/` says which
tasks, and when. `main` is the main line of the history on GitHub. Each time the author adds
a change to it, GitHub runs the tests, and every check that `just check` runs. It does the same when someone proposes a change. It also builds the docs site and publishes it each time
a change reaches `main`.

Five shorter tutorials take parts of this one. Each has its own site, for
[testing](https://rahuldave.com/smallwikiapp-walk/testing/),
[linting](https://rahuldave.com/smallwikiapp-walk/linting/),
[docs](https://rahuldave.com/smallwikiapp-walk/docs/),
[just](https://rahuldave.com/smallwikiapp-walk/just/) and
[uv](https://rahuldave.com/smallwikiapp-walk/uv/).

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

## 0 The project

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part is where the project starts, at `step-00`. [The code of this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

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

## 1 A random page

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-00`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-00)

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

<a id="step-02"></a>

## 2 Tests, with mocks

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-01`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-01)

```bash
just setup
```

We cannot tell whether `wikiapp` still works after a change, unless we run it by hand and read what it prints.
Tests run it for us. [pytest](https://docs.pytest.org/) finds the tests and runs them, and a recipe `just test` runs pytest.

The command asks the real Wikipedia, and a test cannot know which page comes back. So a mock takes the place of
`requests.get`, and returns a page that the tests know. Last, coverage shows which lines of the code the tests run.
One test still asks the real Wikipedia, so the tests need the network for now.

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/45807a0ddd9f97798c3f86a82b19782d4df45837). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/45807a0ddd9f97798c3f86a82b19782d4df45837).

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/bfc38e738984492a5dbf6a1a6a0b6691baad4c34). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/bfc38e738984492a5dbf6a1a6a0b6691baad4c34).

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

<a id="step-03"></a>

## 3 A library and an app

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-02`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-02)

```bash
just setup
```

`main` asks Wikipedia for a page and prints it, all in one function. Other code cannot get a page without the
command line, and a test of the request must run the command. So the code that asks Wikipedia goes into a module of
its own, `wikipedia.py`. The module then gets a language, and an error of its own. The command, in `console.py`,
uses the module. So `wikipedia.py` is a library with no code for the command line, and `console.py` is the
app that uses it.

<a id="step-03.1"></a>

### 3.1 random_page goes to wikipedia.py

The request is inside `main`, so only the command can ask Wikipedia for a page. A new module,
`src/wikiapp/wikipedia.py`, gets the address, the User-Agent and a function, `random_page`, which returns the page.
`random_page` returns the answer from inside the `with` block. The original wikiapp set `data` there, and returned it
after the block. The result is the same.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-03.1-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch makes the file `src/wikiapp/wikipedia.py`. Read its two constants, and `random_page`.

The command keeps only what belongs to the command line, so it asks the library for the page.

Apply the patch to [`src/wikiapp/console.py`](#step-03.1-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205.diff | git apply --include=src/wikiapp/console.py
```

The patch takes `import requests` and the two constants out of `src/wikiapp/console.py`. It imports
`random_page`, and `main` calls it in place of the request.

```bash
just test
```

The result is `5 passed`, with no change to the tests. The mock replaces the function `get` in the module
`requests`. `wikipedia.py` calls the function through the module, as `requests.get`, so it gets the mock.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 3f6d8cf59ab3
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-02 --staged -- :/ && git restore --source 3f6d8cf59ab3 --staged --worktree -- :/
```

#### What changed

- <a id="step-03.1-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: only the command stays. 6 lines added, 10 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205/src/wikiapp/console.py).
  - look at `data = random_page()`
- <a id="step-03.1-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the code that talks to Wikipedia. New, 10 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205/src/wikiapp/wikipedia.py).
  - look at `def random_page():`

<a id="step-03.1-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

```diff
@@ -1,22 +1,18 @@
 import click
 from wikiapp import __version__
-import requests
 import textwrap
 
-API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
-USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+from wikiapp.wikipedia import random_page
 
 @click.command()
 @click.version_option(version=__version__)
 def main() -> None:
     """Print the title and summary of a random Wikipedia page."""
-    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
-        response.raise_for_status()
-        data = response.json()
-        title = data["title"]
-        extract = data["extract"]
-        click.secho(title, fg="green")
-        click.echo(textwrap.fill(extract))
+    data = random_page()
+    title = data["title"]
+    extract = data["extract"]
+    click.secho(title, fg="green")
+    click.echo(textwrap.fill(extract))
 
 if __name__=="__main__":
     main()
```

</details>

<a id="step-03.1-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -0,0 +1,10 @@
+import requests
+
+API_URL = "https://en.wikipedia.org/api/rest_v1/page/random/summary"
+USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+
+def random_page():
+    """Get a random page from Wikipedia."""
+    with requests.get(API_URL, headers={"User-Agent": USER_AGENT}) as response:
+        response.raise_for_status()
+        return response.json()
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/3f6d8cf59ab3fd59dc157e169a7c79aeb13aa205).

<a id="step-03.2"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/a65f7f11432be0a56de38e7d4babe10bda735c2c). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/a65f7f11432be0a56de38e7d4babe10bda735c2c).

<a id="step-03.3"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/d9d02ca26fd3c3633e5ce22b18ecb2198e28a520).

<a id="step-03.4"></a>

### 3.4 wikiapp --language

The library takes a language, but a person who runs the command cannot choose one. A new option, `--language` or
`-l`, gives the language to `main`, and `main` passes it on to `random_page`. click gives the value of the option
to the parameter with the same name.

Apply the patch to [`src/wikiapp/console.py`](#step-03.4-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/5705a559523968eeab5379a65e30bf4122ba578e.diff | git apply --include=src/wikiapp/console.py
```

In `src/wikiapp/console.py`, the patch puts `@click.option(` and its six arguments between the line
`@click.command()` and the line `@click.version_option(version=__version__)`. It also changes the first three
lines of `main`, from `def main() -> None:` to `data = random_page()`.

```bash
uv run wikiapp --language fr
uv run wikiapp --help
```

The first command prints a French page. `--help` lists the option, its short form and its default.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 5705a5595239
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source d9d02ca26fd3 --staged -- :/ && git restore --source 5705a5595239 --staged --worktree -- :/
```

#### What changed

- <a id="step-03.4-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the option, which `main` gives to `random_page`. 10 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5705a559523968eeab5379a65e30bf4122ba578e/src/wikiapp/console.py).
  - look at `data = random_page(language=language)`

<a id="step-03.4-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

```diff
@@ -5,10 +5,18 @@ import textwrap
 from wikiapp.wikipedia import random_page
 
 @click.command()
+@click.option(
+    "--language",
+    "-l",
+    default="en",
+    help="Gets random page from Wikipedia in given language",
+    metavar="LANG",
+    show_default=True,
+)
 @click.version_option(version=__version__)
-def main() -> None:
+def main(language) -> None:
     """Print the title and summary of a random Wikipedia page."""
-    data = random_page()
+    data = random_page(language=language)
     title = data["title"]
     extract = data["extract"]
     click.secho(title, fg="green")
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/5705a559523968eeab5379a65e30bf4122ba578e). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/5705a559523968eeab5379a65e30bf4122ba578e).

<a id="step-03.5"></a>

### 3.5 WikipediaError

If a request fails for any reason, requests raises a `RequestException`. Code that uses the library should not
need to know the exceptions of requests. So the library raises an exception of its own, `WikipediaError`. The
request goes in a `try` block, and a `RequestException` becomes a `WikipediaError`.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-03.5-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/a6f5ae9a475d916d4053315c9e6699f16951193f.diff | git apply --include=src/wikiapp/wikipedia.py
```

In `src/wikiapp/wikipedia.py`, the patch puts the class `WikipediaError` above `random_page`, and the request
inside a `try` block.

`from error` keeps the original exception, so a traceback shows both exceptions.

```bash
uv run wikiapp --language xx
```

There is no Wikipedia in the language `xx`, so no server has the name `xx.wikipedia.org`. The command ends in a
traceback, and the last line is the `WikipediaError`. No code catches the error yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check a6f5ae9a475d
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 5705a5595239 --staged -- :/ && git restore --source a6f5ae9a475d --staged --worktree -- :/
```

#### What changed

- <a id="step-03.5-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the exception, and the line that raises it. 9 lines added, 3 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/a6f5ae9a475d916d4053315c9e6699f16951193f/src/wikiapp/wikipedia.py).
  - look at `raise WikipediaError(str(error)) from error`

<a id="step-03.5-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -3,8 +3,14 @@ import requests
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
+class WikipediaError(Exception):
+    """Wikipedia could not give a page."""
+
 def random_page(language="en"):
     """Get a random page from Wikipedia."""
-    with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
-        response.raise_for_status()
-        return response.json()
+    try:
+        with requests.get(API_URL.format(language=language), headers={"User-Agent": USER_AGENT}) as response:
+            response.raise_for_status()
+            return response.json()
+    except requests.RequestException as error:
+        raise WikipediaError(str(error)) from error
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/a6f5ae9a475d916d4053315c9e6699f16951193f). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/a6f5ae9a475d916d4053315c9e6699f16951193f).

<a id="step-03.6"></a>

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

<a id="step-04"></a>

## 4 Format, lint, a hook

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-03`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-03)

```bash
just setup
```

The tests check what the code does, and nothing checks how it is written. The code mixes styles, and a request can
wait for ever with no test to notice. A formatter writes every file in one style. A linter reads the code and
reports mistakes that the tests do not find. Each tool first shows what it would change, and then it makes the
change. Then a recipe checks the configuration, another runs every check, and a git hook runs them all before git
records a change.

The tests still need the network. [`pre-commit`](https://pre-commit.com/) downloads its hooks from GitHub the first time it runs.

<a id="step-04.1"></a>

### 4.1 ruff, in the group lint

The code has no one style, so a later change can mix a fix with a change of blank lines and quotes. A formatter
changes how the code looks, and never what it does. A linter finds problems in the code, such as a variable that
is never used, and changes nothing unless it is asked to. [ruff](https://docs.astral.sh/ruff/) is both, in one program. It goes in a second group
of dependencies, `lint`, next to the group `test`.

ruff comes from Astral, as uv does, and is written in Rust. It does the work of
older tools, such as Black for the format, and flake8 and isort for the lint, much faster.

```bash
uv add --group lint ruff
```

```bash
uv run ruff --version
```

It prints `ruff 0.17.0`, or a newer version. uv installs every group, so ruff is in the environment of the project, and nothing has
used it yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 8f7b800001ee
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-03 --staged -- :/ && git restore --source 8f7b800001ee --staged --worktree -- :/
```

#### What changed

- <a id="step-04.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group `lint`, with ruff in it. 3 lines added. It comes from `uv add --group lint ruff`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8f7b800001ee35d8db80c47521b02777047c019d/pyproject.toml).
  - look at `"ruff>=0.17.0",`
- <a id="step-04.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of ruff. 29 lines added. It comes from `uv add --group lint ruff`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8f7b800001ee35d8db80c47521b02777047c019d/uv.lock).

<a id="step-04.1-pyproject.toml-5d07e7-diff"></a>

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

ruff needs its settings, in `pyproject.toml`. They allow lines of up to 100 characters, and write out
the defaults of the formatter, so that a reader sees them. A recipe `fmt` runs the formatter. The words after
`just fmt` go to `ruff format`.

Set the values that this change sets in [`pyproject.toml`](#step-04.2-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '314457433791:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'ruff'),
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

Apply the patch to [`justfile`](#step-04.2-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/31445743379186b800fd4c035c8f04eed7ad7f3d.diff | git apply --include=justfile
```

In `pyproject.toml`, the change adds the tables `[tool.ruff]` and `[tool.ruff.format]`. In the `justfile`, it
adds the recipe `fmt` at the end.

```bash
uv run ruff format --check
just --show fmt
just fmt --check
```

`--check` changes nothing. It shows what it would change in each file, and fails. It ends with `6 files would be
reformatted, 1 file already formatted`. It names the six files that it would
change. The recipe
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

<a id="step-04.2-justfile-424f0b-diff"></a>

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

<a id="step-04.2-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-04.3"></a>

### 4.3 The code, formatted

`just fmt --check` found six files that do not follow the style. The formatter rewrites them. It adds blank lines,
puts spaces around `==`, and splits the lines longer than 100 characters.

```bash
just fmt
```

```bash
just fmt --check
just test
```

The check prints `7 files already formatted`, and the tests pass as before, `7 passed`. One test asks the real Wikipedia, so the tests still need the network.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 6690eee9f7e1
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 314457433791 --staged -- :/ && git restore --source 6690eee9f7e1 --staged --worktree -- :/
```

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

<a id="step-04.3-src-wikiapp-__init__.py-682a01-diff"></a>

<details><summary>The diff that <code>just fmt</code> makes in <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -1,2 +1,3 @@
 import importlib.metadata
+
 __version__ = importlib.metadata.version(__name__ or __package__)
```

</details>

<a id="step-04.3-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff that <code>just fmt</code> makes in <code>src/wikiapp/console.py</code></summary>

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

<a id="step-04.3-src-wikiapp-wikipedia.py-258803-diff"></a>

<details><summary>The diff that <code>just fmt</code> makes in <code>src/wikiapp/wikipedia.py</code></summary>

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

<a id="step-04.3-tests-conftest.py-626af3-diff"></a>

<details><summary>The diff that <code>just fmt</code> makes in <code>tests/conftest.py</code></summary>

```diff
@@ -1,5 +1,6 @@
 import pytest
 
+
 @pytest.fixture
 def mock_requests_get(mocker):
     mock = mocker.patch("requests.get")
```

</details>

<a id="step-04.3-tests-test_console.py-9442ee-diff"></a>

<details><summary>The diff that <code>just fmt</code> makes in <code>tests/test_console.py</code></summary>

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

<a id="step-04.3-tests-test_wikipedia.py-2f4413-diff"></a>

<details><summary>The diff that <code>just fmt</code> makes in <code>tests/test_wikipedia.py</code></summary>

```diff
@@ -1,5 +1,6 @@
 from wikiapp import wikipedia
 
+
 def test_random_page_uses_given_language(mock_requests_get):
     wikipedia.random_page(language="es")
     args, _ = mock_requests_get.call_args
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6690eee9f7e177a6df2ea5e1821b8f581948bc85). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/6690eee9f7e177a6df2ea5e1821b8f581948bc85).

<a id="step-04.4"></a>

### 4.4 The linter's rules, and the recipe lint

The linter checks the code against rules, and it needs to know which. A table in `pyproject.toml`
chooses the families of rules. Each family is on a line of its own, with a comment that says why it is on. The
tests may use `assert`. The rest of the code may not, because Python skips every `assert` when it runs with `-O`.

A recipe `lint` runs the linter. The words after `just lint` go to `ruff check`.

Set the values that this change sets in [`pyproject.toml`](#step-04.4-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '589f2f691557:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'ruff', 'lint'),
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

Apply the patch to [`justfile`](#step-04.4-justfile-424f0b), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/589f2f691557470eac084858d430a302c98390ce.diff | git apply --include=justfile
```

In `pyproject.toml`, the change adds the tables `[tool.ruff.lint]` and `[tool.ruff.lint.per-file-ignores]`.
Read the comment beside each family of rules. In the `justfile`, it adds the recipe `lint` at the end.

```bash
uv run ruff check --statistics
just --show lint
just lint --statistics
```

The linter finds five problems, and fails. Each problem has its code.

- `I001`: imports are out of order.
- `E402`: an import comes below code.
- `F841`, twice: a variable is assigned and never used.
- `S113`: a request has no timeout.

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

<a id="step-04.4-justfile-424f0b-diff"></a>

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

<a id="step-04.4-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-04.5"></a>

### 4.5 The tests' imports at the top, and no unused variables

Three of the five problems are in `tests/test_console.py`. The import of `console` comes below the fixture, where a
reader does not look for it. Two tests assign `result` and never read it. ruff has no fix for the import below the
code, and its fix for the unused variables is unsafe. So a person makes these fixes.

The import goes up, under `import requests`. wikiapp's own imports are a block of their own, after the installed
packages, which is the order that the rule `I001` asks for. The tests `test_main_invokes_requests_get` and
`test_main_uses_correct_url` check the mock, and not the result, so they need no `result =`.

Apply the patch to [`tests/test_console.py`](#step-04.5-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/2ec7932b37e21c1533f319c03e0533bc755f6da7.diff | git apply --include=tests/test_console.py
```

In `tests/test_console.py`, the patch moves `from wikiapp import console` up, under `import requests`, after a
blank line. In the two tests, it takes `result =` off the line `result = runner.invoke(console.main)`.

```bash
just lint --statistics
just fmt --check
```

Two problems are left, `S113` and `I001`, and the linter still fails. The format is unchanged, and the check prints
`7 files already formatted`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 2ec7932b37e2
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 589f2f691557 --staged -- :/ && git restore --source 2ec7932b37e2 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.5-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the import goes up, and two lines lose `result =`. 4 lines added, 5 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/2ec7932b37e21c1533f319c03e0533bc755f6da7/tests/test_console.py).
  - look at `from wikiapp import console`

<a id="step-04.5-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

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

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-04.6-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/0fb4985582732edf7372a4b90659d703db138446.diff | git apply --include=src/wikiapp/wikipedia.py
```

In `src/wikiapp/wikipedia.py`, the patch adds `timeout=10` at the end of the arguments of `requests.get(...)`.

If the server does not answer within 10 seconds, the request now raises an exception. `random_page` turns it
into a WikipediaError, as it does with every other error of requests.

```bash
just lint --statistics
```

One problem is left, `I001`, so the linter still fails. Its `[*]` says that ruff can fix it.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 0fb498558273
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 2ec7932b37e2 --staged -- :/ && git restore --source 0fb498558273 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.6-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: one more argument. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/0fb4985582732edf7372a4b90659d703db138446/src/wikiapp/wikipedia.py).
  - look at `timeout=10`

<a id="step-04.6-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

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

```bash
just lint --fix
```

```bash
just lint
```

`just lint --fix` reported `Found 1 error (1 fixed, 0 remaining).`, and exited with 0. Now `just lint` prints `All checks passed!`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check a57134d1cef6
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 0fb498558273 --staged -- :/ && git restore --source a57134d1cef6 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.7-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the imports, sorted. 3 lines added, 2 removed. It comes from `just lint --fix`. [The file](https://github.com/rahuldave/smallwikiapp/blob/a57134d1cef6ff24803235ace966e5870046fbd9/src/wikiapp/console.py).
  - look at `from wikiapp import __version__`

<a id="step-04.7-src-wikiapp-console.py-d9ae67-diff"></a>

<details><summary>The diff that <code>just lint --fix</code> makes in <code>src/wikiapp/console.py</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/a57134d1cef6ff24803235ace966e5870046fbd9). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/a57134d1cef6ff24803235ace966e5870046fbd9).

<a id="step-04.8"></a>

### 4.8 validate-pyproject, in the group lint

The tests and the linter check the code, and not the configuration. So an error in `pyproject.toml`, in the
lockfile or in the `justfile` passes them all. [validate-pyproject](https://validate-pyproject.readthedocs.io/) checks `pyproject.toml` against the standard for
it. It goes in the group `lint`.

validate-pyproject checks `pyproject.toml` against JSON schemas of
the standards that define the file.

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

<a id="step-04.8-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-04.9-justfile-424f0b-diff"></a>

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

<a id="step-04.10-justfile-424f0b-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/1f73d6af30cce37adbe58a2ebfd6e80c00e4c543).

<a id="step-04.12"></a>

### 4.12 `pre-commit`, in the group lint

`just check` runs every check, but a person must remember to run it. A [`pre-commit`](https://pre-commit.com/) hook is a program that git runs
before it records a change. If the program fails, git does not record the change. `pre-commit` installs such a hook, and
runs the checks that the file `.pre-commit-config.yaml` names. It goes in the group `lint`.

pre-commit manages git hooks. A file lists the hooks, and `pre-commit` installs each in
an environment of its own, and runs them on the files of a change.

```bash
uv add --group lint pre-commit
```

```bash
uv run pre-commit --version
```

It prints `pre-commit 4.7.0`, or a newer version. No hook is installed yet.

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

<a id="step-04.12-pyproject.toml-5d07e7-diff"></a>

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

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 6860da13f0fd
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 29291b3575f2 --staged -- :/ && git restore --source step-04 --staged --worktree -- :/
```

#### What changed

- <a id="step-04.13-.pre-commit-config.yaml-e7d14d"></a>`.pre-commit-config.yaml`: three hooks from `pre-commit`'s collection, then `just check`. New, 20 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/6860da13f0fdf9595f32390f2fa70fe0976159b1/.pre-commit-config.yaml).
  - look at `entry: just check`
- <a id="step-04.13-justfile-424f0b"></a>`justfile`: the recipe `hook`. 5 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/6860da13f0fdf9595f32390f2fa70fe0976159b1/justfile).
  - look at `@{{ if args == "help" { "just help hook" } else { "uv run pre-commit install" } }}`

<a id="step-04.13-.pre-commit-config.yaml-e7d14d-diff"></a>

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

<a id="step-04.13-justfile-424f0b-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/6860da13f0fdf9595f32390f2fa70fe0976159b1).

This part ends at the code at `step-04`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-04)

<a id="step-05"></a>

## 5 Types

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-04`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-04)

```bash
just setup
```

The tests run the code with the values that they choose, and Python checks no type before it runs a line. A call
with the wrong kind of value fails only when it runs. A type checker reads the code without running it, and finds
such calls. We add one, and fix the one problem that it finds. Then we write a type on every parameter and return,
so that it has something to check.

<a id="step-05.1"></a>

### 5.1 ty, in the group lint

Nothing checks the types of the code yet. [ty](https://docs.astral.sh/ty/) is a type checker. It reads the code without running it, and finds
calls whose arguments cannot have the types that the function asks for.
`uv add` puts ty in the group `lint`, with the other tools that check the code.

ty is Astral's type checker, written in Rust, like uv and ruff. It is new, and does
the work of older checkers such as mypy and pyright.

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
git fetch --quiet --tags --force origin; git restore --source step-04 --staged -- :/ && git restore --source 56a11f0bb31a --staged --worktree -- :/
```

#### What changed

- <a id="step-05.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: ty in the group `lint`. 1 line added. It comes from `uv add --group lint ty`. [The file](https://github.com/rahuldave/smallwikiapp/blob/56a11f0bb31a607e6c5ff37454c7915f2eddd86d/pyproject.toml).
  - look at `"ty>=0.0.87",`
- <a id="step-05.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of ty. 27 lines added. It comes from `uv add --group lint ty`. [The file](https://github.com/rahuldave/smallwikiapp/blob/56a11f0bb31a607e6c5ff37454c7915f2eddd86d/uv.lock).

<a id="step-05.1-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-05.2-justfile-424f0b-diff"></a>

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

<a id="step-05.3"></a>

### 5.3 The version of "wikiapp", by name

The name of the installed package is `wikiapp`, from `pyproject.toml`. The string `"wikiapp"` is never None, so
it can replace `__name__ or __package__`.

Apply the patch to [`src/wikiapp/__init__.py`](#step-05.3-src-wikiapp-__init__.py-682a01), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/b7a3e6d212b439920f62f0a023554b86d14ebd4e.diff | git apply --include=src/wikiapp/__init__.py
```

The patch changes the last line of `src/wikiapp/__init__.py`. It gives `importlib.metadata.version` the name
`"wikiapp"`.

```bash
just types
```

ty prints `All checks passed!`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check b7a3e6d212b4
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 2a5904d01d95 --staged -- :/ && git restore --source b7a3e6d212b4 --staged --worktree -- :/
```

#### What changed

- <a id="step-05.3-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: a string that is never None. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/b7a3e6d212b439920f62f0a023554b86d14ebd4e/src/wikiapp/__init__.py).
  - look at `__version__ = importlib.metadata.version("wikiapp")`

<a id="step-05.3-src-wikiapp-__init__.py-682a01-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -1,3 +1,3 @@
 import importlib.metadata
 
-__version__ = importlib.metadata.version(__name__ or __package__)
+__version__ = importlib.metadata.version("wikiapp")
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/b7a3e6d212b439920f62f0a023554b86d14ebd4e). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/b7a3e6d212b439920f62f0a023554b86d14ebd4e).

<a id="step-05.4"></a>

### 5.4 A type on every parameter and return

ty checks the types that the code states, and the code states almost none. ruff's rules `ANN` report each
parameter and each return without a type. So the linter checks that a type is written, and the type checker
checks that the type is right. The rules go in the list `select` in `pyproject.toml`.

Set the values that this change sets in [`pyproject.toml`](#step-05.4-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '06613b9b25a8:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'ruff', 'lint', 'select'),
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

The patch adds the line `"ANN"` to the list `select`, after the line with `"N"`.

```bash
just lint --statistics
```

The linter finds 25 missing types, in the code and in the tests. They are 15 parameters (`ANN001`) and 10
returns (`ANN201`). The next two moves add them, in the code and then in the tests.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 06613b9b25a8
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source b7a3e6d212b4 --staged -- :/ && git restore --source 06613b9b25a8 --staged --worktree -- :/
```

#### What changed

- <a id="step-05.4-pyproject.toml-5d07e7"></a>`pyproject.toml`: one line. 1 line added. [The file](https://github.com/rahuldave/smallwikiapp/blob/06613b9b25a8f16c7e60cf52803b2e471161d854/pyproject.toml).
  - look at `"ANN", # annotations: every parameter and every return value has a type`

<a id="step-05.4-pyproject.toml-5d07e7-diff"></a>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

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

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-05.5-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/643f65323fd11c5c6f518c59431b13867e155952.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch adds `from typing import Any` and a blank line above `import requests`. It also gives the line
`def random_page(language="en"):` its types.

`main` takes the language as a string. Its return type, None, was already there.

Apply the patch to [`src/wikiapp/console.py`](#step-05.5-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/643f65323fd11c5c6f518c59431b13867e155952.diff | git apply --include=src/wikiapp/console.py
```

The patch changes one line of `src/wikiapp/console.py`, the `def` line of `main`.

```bash
just lint --statistics
```

22 problems are left, 13 parameters and 9 returns. The next move gives the tests their types.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 643f65323fd1
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 06613b9b25a8 --staged -- :/ && git restore --source 643f65323fd1 --staged --worktree -- :/
```

#### What changed

- <a id="step-05.5-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the parameter. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/643f65323fd11c5c6f518c59431b13867e155952/src/wikiapp/console.py).
  - look at `def main(language: str) -> None:`
- <a id="step-05.5-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the parameter and the return. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/643f65323fd11c5c6f518c59431b13867e155952/src/wikiapp/wikipedia.py).
  - look at `def random_page(language: str = "en") -> dict[str, Any]:`

<a id="step-05.5-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

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

<a id="step-05.5-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

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
[pytest-mock](https://pytest-mock.readthedocs.io/)'s `MockerFixture`. The original wikiapp used its older name, `MockFixture`. So
`tests/conftest.py` imports `Mock` and `MockerFixture`, and its fixture states both types.

Apply the patch to [`tests/conftest.py`](#step-05.6-tests-conftest.py-626af3), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/5873353449adaf1734a9cb14d13262486b1fb5d5.diff | git apply --include=tests/conftest.py
```

The patch puts `from unittest.mock import Mock` at the top of `tests/conftest.py`, and
`from pytest_mock import MockerFixture` under `import pytest`. It also gives the `def` line of the fixture its types.

The tests of the command need the same types. `tests/test_console.py` imports `Mock` and `CliRunner` by name,
in place of `import click.testing`. The fixture `runner` returns `CliRunner()`, so its return type is
`CliRunner`. In every test, `runner` is a `CliRunner`, `mock_requests_get` is a `Mock`, and the test returns
`None`.

Apply the patch to [`tests/test_console.py`](#step-05.6-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/5873353449adaf1734a9cb14d13262486b1fb5d5.diff | git apply --include=tests/test_console.py
```

The patch changes the imports at the top of `tests/test_console.py`, and the `def` line of the fixture and of every test.
The bodies stay as they were, apart from `CliRunner()` in the fixture.

The test of the library gets its types the same way.

Apply the patch to [`tests/test_wikipedia.py`](#step-05.6-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/5873353449adaf1734a9cb14d13262486b1fb5d5.diff | git apply --include=tests/test_wikipedia.py
```

The patch adds `from unittest.mock import Mock` and a blank line at the top of `tests/test_wikipedia.py`, and gives
the `def` line of its test the types.

```bash
just lint
just types
```

Both commands print `All checks passed!`.

```bash
just check
```

`just check` passes. pytest prints `7 passed`, and a coverage of 96.88%, above the floor of 90%.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 5873353449ad
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 643f65323fd1 --staged -- :/ && git restore --source 5873353449ad --staged --worktree -- :/
```

#### What changed

- <a id="step-05.6-tests-conftest.py-626af3"></a>`tests/conftest.py`: the fixture returns a Mock. 4 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5873353449adaf1734a9cb14d13262486b1fb5d5/tests/conftest.py).
  - look at `def mock_requests_get(mocker: MockerFixture) -> Mock:`
- <a id="step-05.6-tests-test_console.py-9442ee"></a>`tests/test_console.py`: the runner is a CliRunner, and every test has its types. 11 lines added, 9 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5873353449adaf1734a9cb14d13262486b1fb5d5/tests/test_console.py).
  - look at `def runner() -> CliRunner:`
- <a id="step-05.6-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: the import of `Mock`, and the types of one test. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/5873353449adaf1734a9cb14d13262486b1fb5d5/tests/test_wikipedia.py).
  - look at `def test_random_page_uses_given_language(mock_requests_get: Mock) -> None:`

<a id="step-05.6-tests-conftest.py-626af3-diff"></a>

<details open><summary>The patch to <code>tests/conftest.py</code></summary>

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

<a id="step-05.6-tests-test_console.py-9442ee-diff"></a>

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

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

<a id="step-05.6-tests-test_wikipedia.py-2f4413-diff"></a>

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/5873353449adaf1734a9cb14d13262486b1fb5d5). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/5873353449adaf1734a9cb14d13262486b1fb5d5).

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

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 701783af434e
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 5873353449ad --staged -- :/ && git restore --source step-05 --staged --worktree -- :/
```

#### What changed

- <a id="step-05.7-justfile-424f0b"></a>`justfile`: the comment, and one line in check. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/701783af434e19b17e38a10898a39adc1dc5dae9/justfile).
  - look at `just types`

<a id="step-05.7-justfile-424f0b-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/701783af434e19b17e38a10898a39adc1dc5dae9).

This part ends at the code at `step-05`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-05)

<a id="step-06"></a>

## 6 End to end, and CI

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-05`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-05)

```bash
just setup
```

One test asks the real Wikipedia, so the tests fail without a network, and can fail when Wikipedia changes. We
run such tests only on request. Then the project accepts every version of Python from 3.11 on. GitHub
then runs the tests on three systems and four versions of Python after each push.

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/307d4d7b36bb9dc7bc8ad601c8275d5241283e35). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/307d4d7b36bb9dc7bc8ad601c8275d5241283e35).

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

<a id="step-07"></a>

## 7 A page with a shape

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-06`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-06)

```bash
just setup
```

`random_page` returns the dictionary that Wikipedia sends, and the code uses its title and its extract.
Nothing checks that the dictionary has them. We give a page a shape, with a [pydantic](https://docs.pydantic.dev/) model. `random_page` returns a page of that shape, and an
answer that is not a page becomes an error like any other. Last, the code checks that the language is a language
code before it puts it into the address.

<a id="step-07.1"></a>

### 7.1 pydantic

The command uses two of the many keys that Wikipedia sends. The code expects them to be there, with strings as
values, but nothing checks it. [pydantic](https://docs.pydantic.dev/) is a library that checks data against a model, and a model states the two
keys and their types in code. pydantic is a dependency of the package, as click and requests are, so `uv add` puts
it in `dependencies`.

pydantic is a widely used Python library. When the code makes a page from the data,
pydantic checks each value against the type that the model gives it. A value that does not fit raises an error.

```bash
uv add pydantic
```

`uv add` installs pydantic and the four packages that it needs, among them pydantic-core and annotated-types. If a newer pydantic is out, `uv add` writes its version as the lower bound. That line then
differs from the one here, and so does `uv.lock`. `git diff` shows those two files, and only the versions in
them differ.

```bash
uv run python -c "import pydantic; print(pydantic.VERSION)"
just test -q
```

The first command prints `2.14.1`. The tests print `6 passed, 2 deselected`, as before, because no code uses
pydantic yet.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 47fc24f56c91
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-06 --staged -- :/ && git restore --source 47fc24f56c91 --staged --worktree -- :/
```

#### What changed

- <a id="step-07.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: pydantic, a dependency of the package. 1 line added. It comes from `uv add pydantic`. [The file](https://github.com/rahuldave/smallwikiapp/blob/47fc24f56c9129f7c17f1c26092a6cfaffa3bf10/pyproject.toml).
  - look at `"pydantic>=2.14.1",`
- <a id="step-07.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of pydantic, and of what it needs. 180 lines added. It comes from `uv add pydantic`. [The file](https://github.com/rahuldave/smallwikiapp/blob/47fc24f56c9129f7c17f1c26092a6cfaffa3bf10/uv.lock).

<a id="step-07.1-pyproject.toml-5d07e7-diff"></a>

<details><summary>The diff that <code>uv add pydantic</code> makes in <code>pyproject.toml</code></summary>

```diff
@@ -9,6 +9,7 @@ authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "click>=8.5.0",
+    "pydantic>=2.14.1",
     "requests>=2.34.2",
 ]
 
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/47fc24f56c9129f7c17f1c26092a6cfaffa3bf10). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/47fc24f56c9129f7c17f1c26092a6cfaffa3bf10).

<a id="step-07.2"></a>

### 7.2 The model Page

The model `Page` is a class that inherits from pydantic's `BaseModel`. It has a title and an extract, both strings,
the two keys that the command uses. A `Page` made from a dictionary checks the two keys, and keeps only them.
Nothing uses `Page` yet.

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-07.2-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/1baf0602c1d1cec79277c2faec438b76a9a8c768.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch adds the import of `BaseModel` under the line `import requests`. It puts the class `Page` after the class
`WikipediaError`.

```bash
uv run python -c "from wikiapp.wikipedia import Page; print(Page.model_validate({'title': 'A', 'extract': 'B', 'lang': 'en'}))"
uv run python -c "from wikiapp.wikipedia import Page; Page.model_validate({'title': 'A'})"
```

The first command prints `title='A' extract='B'`. The model drops the other key. The second command fails with
`1 validation error for Page`, and names the field `extract` with `Field required`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 1baf0602c1d1
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 47fc24f56c91 --staged -- :/ && git restore --source 1baf0602c1d1 --staged --worktree -- :/
```

#### What changed

- <a id="step-07.2-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the model. 8 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/1baf0602c1d1cec79277c2faec438b76a9a8c768/src/wikiapp/wikipedia.py).
  - look at `class Page(BaseModel):`

<a id="step-07.2-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

```diff
@@ -1,6 +1,7 @@
 from typing import Any
 
 import requests
+from pydantic import BaseModel
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
@@ -10,6 +11,13 @@ class WikipediaError(Exception):
     """Wikipedia could not give a page."""
 
 
+class Page(BaseModel):
+    """A page of Wikipedia: its title and the summary of its text."""
+
+    title: str
+    extract: str
+
+
 def random_page(language: str = "en") -> dict[str, Any]:
     """Get a random page from Wikipedia."""
     try:
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/1baf0602c1d1cec79277c2faec438b76a9a8c768). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/1baf0602c1d1cec79277c2faec438b76a9a8c768).

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/06ff2caa1958318b960fa9b9c84b32b3a23ae18d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/06ff2caa1958318b960fa9b9c84b32b3a23ae18d).

<a id="step-07.5"></a>

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

<a id="step-08"></a>

## 8 Docs from the code

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-07`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-07)

```bash
just setup
```

A person who calls `random_page` must read its code to learn what it takes, what it returns and when it fails. We
document the code, and let a tool, [smalldocs](https://docs.smallish.dev/), write the reference from it. smalldocs also lists what has no
documentation, so `just check` can fail when a function has none. We document the library, the command and the tests. Then we
build a site with a front page, and name the tests and the docs in the README.

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

The first command prints `smalldocs 0.1.5`, or a newer version. `uv tree` prints smalldocs `(group: docs)`, and under it fastcore,
markdown-it-py, mdit-py-plugins, pygments and pyyaml.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 71726f393670
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-07 --staged -- :/ && git restore --source 71726f393670 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.1-pyproject.toml-5d07e7"></a>`pyproject.toml`: the group. 3 lines added. It comes from `uv add --group docs smalldocs`. [The file](https://github.com/rahuldave/smallwikiapp/blob/71726f393670206ea480aaa2edc03ddeeeebc1fe/pyproject.toml).
  - look at `docs = [`
- <a id="step-08.1-uv.lock-8356d8"></a>`uv.lock`: the exact version of smalldocs, and of the packages that it needs. 62 lines added. It comes from `uv add --group docs smalldocs`. [The file](https://github.com/rahuldave/smallwikiapp/blob/71726f393670206ea480aaa2edc03ddeeeebc1fe/uv.lock).

<a id="step-08.1-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-08.2-docs-_smalldocs.yml-4b0b48-diff"></a>

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

<a id="step-08.2-justfile-424f0b-diff"></a>

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

<a id="step-08.3"></a>

### 8.3 The library documented

The reference of `wikipedia.py` has empty descriptions, because the library has no docments and short
docstrings. We document it in four places:

- a docstring at the top of the module
- a docment beside each field of Page
- a docment on the parameter and on the return of `random_page`
- a longer docstring of `random_page`, which says when it raises an error

Apply the patch to [`src/wikiapp/wikipedia.py`](#step-08.3-src-wikiapp-wikipedia.py-258803), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/66a702fe4a01d424177085b9ef056dd8d8d11cc8.diff | git apply --include=src/wikiapp/wikipedia.py
```

The patch adds the docstring of the module above the line `import re`. It puts a comment beside each field of `Page`.
It writes `random_page` again from its `def` line to the end of its docstring, with one parameter to a line.

A pydantic field can also take its description as `Field(description="...")`. pydantic keeps that description
in the schema of the model, which other programs read. smalldocs uses the description when a field has one, and
the comment beside the field when it has none. `Page` only parses the answer of Wikipedia, so the comment is
enough.

```bash
just docs module wikipedia
```

The tables now have their descriptions.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 66a702fe4a01
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 40d4293f5902 --staged -- :/ && git restore --source 66a702fe4a01 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.3-src-wikiapp-wikipedia.py-258803"></a>`src/wikiapp/wikipedia.py`: the comments are the documentation. 12 lines added, 4 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/66a702fe4a01d424177085b9ef056dd8d8d11cc8/src/wikiapp/wikipedia.py).
  - look at `) -> Page:  # A page chosen at random`

<a id="step-08.3-src-wikiapp-wikipedia.py-258803-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/wikipedia.py</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/66a702fe4a01d424177085b9ef056dd8d8d11cc8). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/66a702fe4a01d424177085b9ef056dd8d8d11cc8).

<a id="step-08.4"></a>

### 8.4 The command documented

The two other modules, `src/wikiapp/__init__.py` and `src/wikiapp/console.py`, have no docstring, and `main` has
no docment. `wikiapp --help` prints the docstring of `main` and the help of each option, so those are
documentation too.

Each of the two modules gets a docstring at the top, which says what the module is.

Apply the patch to [`src/wikiapp/__init__.py`](#step-08.4-src-wikiapp-__init__.py-682a01), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/bb648b91f4aba037eac04caa5cd7b41095e7c388.diff | git apply --include=src/wikiapp/__init__.py
```

The patch adds the docstring at the top of `src/wikiapp/__init__.py`, with a blank line under it.

`check` does not ask for the docstring of `__init__.py`, because that file defines no public function or class.
Python still shows it, in `help(wikiapp)`.

The help of `--language` now says what a language is. It replaces the help of the original wikiapp, "Gets random
page from Wikipedia in given language". `main` has one parameter to a line, with its docment, and a docstring that
says what `main` prints. A function that returns None needs no docment for its return.

Apply the patch to [`src/wikiapp/console.py`](#step-08.4-src-wikiapp-console.py-d9ae67), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/bb648b91f4aba037eac04caa5cd7b41095e7c388.diff | git apply --include=src/wikiapp/console.py
```

The patch adds the docstring of the module at the top of `src/wikiapp/console.py`. It changes the line `help=...` of
the option `--language`. It writes the line `def main(...)` again, and the docstring under it.

```bash
just docs module console
uv run wikiapp --help
```

`main` is a click command, and smalldocs documents it like a function, with one more table. The table of
options shows the new help of `--language`, the same help that `--help` prints.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check bb648b91f4ab
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 66a702fe4a01 --staged -- :/ && git restore --source bb648b91f4ab --staged --worktree -- :/
```

#### What changed

- <a id="step-08.4-src-wikiapp-__init__.py-682a01"></a>`src/wikiapp/__init__.py`: a docstring, which `help(wikiapp)` shows. 2 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/bb648b91f4aba037eac04caa5cd7b41095e7c388/src/wikiapp/__init__.py).
  - look at `"""wikiapp: the title and summary of a random Wikipedia page."""`
- <a id="step-08.4-src-wikiapp-console.py-d9ae67"></a>`src/wikiapp/console.py`: the docment, the docstring and the help. 10 lines added, 3 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/bb648b91f4aba037eac04caa5cd7b41095e7c388/src/wikiapp/console.py).
  - look at `language: str,  # The language of the Wikipedia to ask, from --language`

<a id="step-08.4-src-wikiapp-__init__.py-682a01-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/__init__.py</code></summary>

```diff
@@ -1,3 +1,5 @@
+"""wikiapp: the title and summary of a random Wikipedia page."""
+
 import importlib.metadata
 
 __version__ = importlib.metadata.version("wikiapp")
```

</details>

<a id="step-08.4-src-wikiapp-console.py-d9ae67-diff"></a>

<details open><summary>The patch to <code>src/wikiapp/console.py</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/bb648b91f4aba037eac04caa5cd7b41095e7c388). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/bb648b91f4aba037eac04caa5cd7b41095e7c388).

<a id="step-08.5"></a>

### 8.5 The tests documented

`just docs check` still finds gaps in the tests. Each test file must say what it tests, and each fixture what it
returns. Each test says in one line what it checks. The docstring says in words what the asserts say in code. Each
parameter of a test has a docment, one parameter to a line.

Tests documented this way are documentation too. A reader learns from them what the code must do.

The fixture in `tests/conftest.py` gets a docstring for the file, a docment for its parameter and its return, and a
docstring of its own.

Apply the patch to [`tests/conftest.py`](#step-08.5-tests-conftest.py-626af3), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/7a0e5094887304538655b706752de99408df2d97.diff | git apply --include=tests/conftest.py
```

The patch adds the docstring of the file at the top. It writes the line `def mock_requests_get(...)` again, with one
parameter to a line, and adds the docstring of the fixture.

`tests/test_console.py` has a fixture and six tests, and each gets the same pattern.

Apply the patch to [`tests/test_console.py`](#step-08.5-tests-test_console.py-9442ee), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/7a0e5094887304538655b706752de99408df2d97.diff | git apply --include=tests/test_console.py
```

The patch adds a docstring at the top of the file. Each test gets a docment on each parameter, one to a line, and a
docstring of one line. Read `test_main_prints_title` first. Its docstring is "The command prints the title of the
page." The fixture `runner` gets a docstring, and a docment beside its return type on its `def`
line.

The three tests of `tests/test_wikipedia.py` get the same pattern.

Apply the patch to [`tests/test_wikipedia.py`](#step-08.5-tests-test_wikipedia.py-2f4413), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/7a0e5094887304538655b706752de99408df2d97.diff | git apply --include=tests/test_wikipedia.py
```

The patch adds the docstring of the file at the top. The two tests that take the mock get one parameter to a line,
with its docment. Each of the three tests gets a docstring of one line, under its `def`.

```bash
just docs check
```

`check` prints a line for each module and each test file, all complete, and then `15 of 15 functions, methods
and classes are typed and documented`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 7a0e50948873
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source bb648b91f4ab --staged -- :/ && git restore --source 7a0e50948873 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.5-tests-conftest.py-626af3"></a>`tests/conftest.py`: the fixture, documented. 6 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/7a0e5094887304538655b706752de99408df2d97/tests/conftest.py).
  - look at `mocker: MockerFixture,  # pytest-mock's fixture, which undoes every patch after the test`
- <a id="step-08.5-tests-test_console.py-9442ee"></a>`tests/test_console.py`: seven functions. 33 lines added, 7 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/7a0e5094887304538655b706752de99408df2d97/tests/test_console.py).
  - look at `"""The command prints the title of the page."""`
- <a id="step-08.5-tests-test_wikipedia.py-2f4413"></a>`tests/test_wikipedia.py`: three tests. 11 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/7a0e5094887304538655b706752de99408df2d97/tests/test_wikipedia.py).
  - look at `"""The language chooses the Wikipedia that is asked."""`

<a id="step-08.5-tests-conftest.py-626af3-diff"></a>

<details open><summary>The patch to <code>tests/conftest.py</code></summary>

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

<details open><summary>The patch to <code>tests/test_console.py</code></summary>

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

<details open><summary>The patch to <code>tests/test_wikipedia.py</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/7a0e5094887304538655b706752de99408df2d97). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/7a0e5094887304538655b706752de99408df2d97).

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
grep -o 'href="api/wikipedia.html#random_page"' docs/_site/index.html | head -n 1
```

smalldocs prints `wrote 3 page(s) to docs/_site`. The front page of the site is `docs/_site/index.html`, for a
browser. grep searches a file for a piece of text, and `-o` prints only the text that it finds. Here it finds the
link from `random_page` on the front page to its entry in `api/wikipedia.html`. The `|` passes what grep prints to
`head -n 1`, which keeps the first line, so the link prints once. Each build makes the site and the reference pages, and git ignores them.

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

<a id="step-08.6-docs-_smalldocs.yml-4b0b48-diff"></a>

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

<a id="step-08.6-docs-index.qmd-d6d880-diff"></a>

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

<a id="step-08.6-justfile-424f0b-diff"></a>

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

<a id="step-08.7"></a>

### 8.7 The README names the tests and the docs

The README is the first page that a reader sees on GitHub. Its table of folders says where each part of the
project is, and it lists neither the tests nor the docs. The table gets rows for `tests/` and `docs/`. The row of
`src/wikiapp/` also says that `wikipedia.py` is the library and `console.py` the command.

Apply the patch to [`README.md`](#step-08.7-README.md-8ec9a0), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/79c80120fc8fc12ec7b38474294b422e86619362.diff | git apply --include=README.md
```

The patch puts three rows in place of the row of `src/wikiapp/`, in the table of folders.

```bash
grep -n -E 'tests/|docs/' README.md
```

`grep` prints the two new rows of the table.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 79c80120fc8f
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source e99ed4f3ab32 --staged -- :/ && git restore --source 79c80120fc8f --staged --worktree -- :/
```

#### What changed

- <a id="step-08.7-README.md-8ec9a0"></a>`README.md`: the folders. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/79c80120fc8fc12ec7b38474294b422e86619362/README.md).
  - look at `| The docs site. smalldocs makes its reference from the code |`

<a id="step-08.7-README.md-8ec9a0-diff"></a>

<details open><summary>The patch to <code>README.md</code></summary>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/79c80120fc8fc12ec7b38474294b422e86619362). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/79c80120fc8fc12ec7b38474294b422e86619362).

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
git fetch --quiet --tags --force origin; git restore --source 79c80120fc8f --staged -- :/ && git restore --source step-08 --staged --worktree -- :/
```

#### What changed

- <a id="step-08.8-justfile-424f0b"></a>`justfile`: the comment, and one line in `check`. 2 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/ce0734f1272cf16f4aadeaa6712e589010ccd69f/justfile).
  - look at `just docs check`

<a id="step-08.8-justfile-424f0b-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/ce0734f1272cf16f4aadeaa6712e589010ccd69f).

This part ends at the code at `step-08`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-08)

<a id="step-08b"></a>

## 8b The docs on GitHub Pages

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-08`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-08)

```bash
just setup
```

Every job on GitHub installs every dependency group, with every tool of the project, though most jobs need only a
few. Also, the docs site exists only on the machine that builds it. So we make the job `tests` install the group `test`
alone. Then a new workflow builds the docs site with the group `docs` alone, and [GitHub Pages](https://docs.github.com/en/pages) publishes it.

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/971e9d780fd539d13f49af3fbb00c1145fd22aa0). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/971e9d780fd539d13f49af3fbb00c1145fd22aa0).

<a id="step-08b.2"></a>

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

The first command runs one check of [`pre-commit`](https://pre-commit.com/), `check-yaml`, on the new file. The file
is valid YAML. The second command builds the site as the job does, with the group `docs` alone, and
prints `wrote 3 page(s) to docs/_site`. git ignores `docs/_site`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 39a4b09f8563
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 971e9d780fd5 --staged -- :/ && git restore --source step-08b --staged --worktree -- :/
```

#### What changed

- <a id="step-08b.2-.github-workflows-docs.yaml-ce7835"></a>`.github/workflows/docs.yaml`: the site, built with the group `docs` alone, then published. New, 40 lines. [The file](https://github.com/rahuldave/smallwikiapp/blob/39a4b09f85638bbe8424b243c4ba4477070f2740/.github/workflows/docs.yaml).
  - look at `- run: uv run --locked --no-default-groups --group docs smalldocs render docs`

<a id="step-08b.2-.github-workflows-docs.yaml-ce7835-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/39a4b09f85638bbe8424b243c4ba4477070f2740).

This part ends at the code at `step-08b`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-08b)

<a id="step-09"></a>

## 9 The library as a package

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-08b`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-08b)

```bash
just setup
```

The code that asks Wikipedia has no code for the command line, but another program can get it only by installing
wikiapp, with click. So we make it a package of its own, `wikirandom`, in the same repository. First comes an empty
package, with its dependencies and its README, then its code. Then the app uses the library, and drops requests
and pydantic, which it no longer imports. Last, the docs check counts the library too.

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
sets `UV_LOCKED`, so after this move each recipe that runs uv refuses the lockfile, on purpose. The next move, `uv add`, resolves the lockfile again for the workspace.

```bash
uv lock --check
```

The command prints `Resolved 42 packages`, then an error that names `uv.lock`, and a hint to run `uv lock`. Its
exit code is 1. Before this move, the lockfile had 41 packages. The 42nd is `wikirandom`.

```bash
just test
```

`just test` prints its command, `uv run pytest`, then an error of uv that names `uv.lock` and `UV_LOCKED`, and the
hint to run `uv lock`. pytest does not run.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 01364831243e
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source step-08b --staged -- :/ && git restore --source 01364831243e --staged --worktree -- :/
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

<a id="step-09.1-packages-wikirandom-pyproject.toml-28d6f6-diff"></a>

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

<a id="step-09.1-packages-wikirandom-src-wikirandom-__init__.py-343c23-diff"></a>

<details><summary>The diff that <code>uv init --lib --author-from none --no-pin-python --python "&gt;=3.11" --description "A random page of Wikipedia, in any language" packages/wikirandom</code> makes in <code>packages/wikirandom/src/wikirandom/__init__.py</code></summary>

```diff
@@ -0,0 +1,2 @@
+def hello() -> str:
+    return "Hello from wikirandom!"
```

</details>

<a id="step-09.1-pyproject.toml-5d07e7-diff"></a>

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

`uv lock --check` prints `Resolved 42 packages`, with no error, so the lockfile matches the project again. `uv tree` shows `wikirandom v0.1.0`, with `pydantic v2.14.1` and `requests v2.34.2` under it.

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

<a id="step-09.2-packages-wikirandom-pyproject.toml-28d6f6-diff"></a>

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

<a id="step-09.3"></a>

### 9.3 The library's README

uv wrote an empty `README.md` for the library. It gets a heading, and a line that says what the library is. The
line also says that the command `wikiapp` will use it.

Apply the patch to [`packages/wikirandom/README.md`](#step-09.3-packages-wikirandom-README.md-105646), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/dab89136e205c1102c10ce98dd9b4bd9c3814543.diff | git apply --include=packages/wikirandom/README.md
```

The patch fills the empty file with the heading `# wikirandom`, a blank line, and the line of text.

```bash
cat packages/wikirandom/README.md
```

The command prints the heading, and
``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check dab89136e205
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source c153cdfc4330 --staged -- :/ && git restore --source dab89136e205 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.3-packages-wikirandom-README.md-105646"></a>`packages/wikirandom/README.md`: a heading, and what the library is. 3 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/dab89136e205c1102c10ce98dd9b4bd9c3814543/packages/wikirandom/README.md).
  - look at ``A random page of Wikipedia, in any language. The command `wikiapp` will use this library.``

<a id="step-09.3-packages-wikirandom-README.md-105646-diff"></a>

<details open><summary>The patch to <code>packages/wikirandom/README.md</code></summary>

```diff
@@ -0,0 +1,3 @@
+# wikirandom
+
+A random page of Wikipedia, in any language. The command `wikiapp` will use this library.
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/dab89136e205c1102c10ce98dd9b4bd9c3814543). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/dab89136e205c1102c10ce98dd9b4bd9c3814543).

<a id="step-09.4"></a>

### 9.4 The library gets a copy of wikipedia.py

The library has only uv's example function. Its code is the code of `src/wikiapp/wikipedia.py`. `cp` puts a copy
of that file in place of the example. The app does not use the library yet, and still has its own `wikipedia.py`.

```bash
cp src/wikiapp/wikipedia.py packages/wikirandom/src/wikirandom/__init__.py
```

```bash
diff src/wikiapp/wikipedia.py packages/wikirandom/src/wikirandom/__init__.py
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.USER_AGENT)"
```

`diff` prints nothing, because the two files are the same. The second command prints
`wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)`. The library still names the app in each request it
makes. `--package wikirandom` installs the library into the shared `.venv`, and runs the command there. The app
does not depend on the library yet, so a plain `uv run` would not install it.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 8e526cfa908b
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source dab89136e205 --staged -- :/ && git restore --source 8e526cfa908b --staged --worktree -- :/
```

#### What changed

- <a id="step-09.4-packages-wikirandom-src-wikirandom-__init__.py-343c23"></a>`packages/wikirandom/src/wikirandom/__init__.py`: the code of `wikipedia.py`, in place of `hello`. 41 lines added, 2 removed. It comes from `cp src/wikiapp/wikipedia.py packages/wikirandom/src/wikirandom/__init__.py`. [The file](https://github.com/rahuldave/smallwikiapp/blob/8e526cfa908bef1fff32429f795882eb734a103b/packages/wikirandom/src/wikirandom/__init__.py).
  - look at `def random_page(`

<a id="step-09.4-packages-wikirandom-src-wikirandom-__init__.py-343c23-diff"></a>

<details><summary>The diff that <code>cp src/wikiapp/wikipedia.py packages/wikirandom/src/wikirandom/__init__.py</code> makes in <code>packages/wikirandom/src/wikirandom/__init__.py</code></summary>

```diff
@@ -1,2 +1,41 @@
-def hello() -> str:
-    return "Hello from wikirandom!"
+"""Wikipedia's REST API: a random page."""
+
+import re
+
+import requests
+from pydantic import BaseModel, ValidationError
+
+API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
+LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
+USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+
+
+class WikipediaError(Exception):
+    """Wikipedia could not give a page."""
+
+
+class Page(BaseModel):
+    """A page of Wikipedia: its title and the summary of its text."""
+
+    title: str  # The title of the page
+    extract: str  # The summary: the first paragraph of the page, as plain text
+
+
+def random_page(
+    language: str = "en",  # The language of the Wikipedia to ask, as its code: en, fr, es
+) -> Page:  # A page chosen at random
+    """Get a random page from Wikipedia.
+
+    Raises WikipediaError when the language is not a language code, when the request fails, or
+    when the answer is not a page.
+    """
+    if not LANGUAGE.fullmatch(language):
+        raise WikipediaError(f"{language!r} is not a language code, such as en, fr or zh-yue")
+    try:
+        with requests.get(
+            API_URL.format(language=language), headers={"User-Agent": USER_AGENT}, timeout=10
+        ) as response:
+            response.raise_for_status()
+            return Page.model_validate(response.json())
+    except (requests.RequestException, ValidationError) as error:
+        raise WikipediaError(str(error)) from error
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/8e526cfa908bef1fff32429f795882eb734a103b). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/8e526cfa908bef1fff32429f795882eb734a103b).

<a id="step-09.5"></a>

### 9.5 The library's docstring and User-Agent

The copy still describes the app. Its docstring says only "Wikipedia's REST API", and its User-Agent names
`wikiapp`. The docstring now says what the package is, and the User-Agent names `wikirandom`, the program that now
makes the request.

Apply the patch to [`packages/wikirandom/src/wikirandom/__init__.py`](#step-09.5-packages-wikirandom-src-wikirandom-__init__.py-343c23), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/34f1041135a78b1015d73e8fcb2529102c5ccf9e.diff | git apply --include=packages/wikirandom/src/wikirandom/__init__.py
```

The patch changes two lines, the docstring in line 1 and the line `USER_AGENT = ...` in line 10. Every other line
stays as `cp` left it.

```bash
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.USER_AGENT)"
uv run --package wikirandom python -c "import wikirandom; print(wikirandom.random_page('fr').title)"
```

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`. The second asks the
real Wikipedia, and prints the title of a French page, another one on each run.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 34f1041135a7
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 8e526cfa908b --staged -- :/ && git restore --source 34f1041135a7 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.5-packages-wikirandom-src-wikirandom-__init__.py-343c23"></a>`packages/wikirandom/src/wikirandom/__init__.py`: the docstring, and the User-Agent. 2 lines added, 2 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/34f1041135a78b1015d73e8fcb2529102c5ccf9e/packages/wikirandom/src/wikirandom/__init__.py).
  - look at `USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"`

<a id="step-09.5-packages-wikirandom-src-wikirandom-__init__.py-343c23-diff"></a>

<details open><summary>The patch to <code>packages/wikirandom/src/wikirandom/__init__.py</code></summary>

```diff
@@ -1,4 +1,4 @@
-"""Wikipedia's REST API: a random page."""
+"""wikirandom: a random page of Wikipedia, in any language, from its REST API."""
 
 import re
 
@@ -7,7 +7,7 @@ from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
-USER_AGENT = "wikiapp/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
 
 
 class WikipediaError(Exception):
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/34f1041135a78b1015d73e8fcb2529102c5ccf9e). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/34f1041135a78b1015d73e8fcb2529102c5ccf9e).

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

<a id="step-09.6-pyproject.toml-5d07e7-diff"></a>

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

Set the values that this change sets in [`pyproject.toml`](#step-09.7-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '78ab09579fdf:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('tool', 'pytest', 'ini_options', 'addopts'),
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
alone, 12 of 12. `just docs` writes 2 pages, the front page and the reference page of the app, because the
settings of the site name only the app.

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

<a id="step-09.7-README.md-8ec9a0-diff"></a>

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

<a id="step-09.7-docs-index.qmd-d6d880-diff"></a>

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

<a id="step-09.7-packages-wikirandom-README.md-105646-diff"></a>

<details open><summary>The patch to <code>packages/wikirandom/README.md</code></summary>

```diff
@@ -1,3 +1,3 @@
 # wikirandom
 
-A random page of Wikipedia, in any language. The command `wikiapp` will use this library.
+A random page of Wikipedia, in any language. The command `wikiapp` uses this library.
```

</details>

<a id="step-09.7-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-09.7-src-wikiapp-console.py-d9ae67-diff"></a>

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

<a id="step-09.7-src-wikiapp-wikipedia.py-258803-diff"></a>

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

<a id="step-09.7-tests-test_wikipedia.py-2f4413-diff"></a>

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

<a id="step-09.8-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-09.9"></a>

### 9.9 The tests of the library are named for it

`tests/test_wikipedia.py` tests wikirandom, and its name should say so. `mv` renames the file, and changes none of
its lines.

```bash
mv tests/test_wikipedia.py tests/test_wikirandom.py
```

```bash
just docs check
```

The docs check lists the file under its new name, `tests/test_wikirandom.py   3 of   3`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 008e616610b0
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source f2dd413c02c7 --staged -- :/ && git restore --source 008e616610b0 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.9-tests-test_wikirandom.py-6f8588"></a>`tests/test_wikirandom.py`: the tests of the library, under their new name. No line changes. Renamed from `tests/test_wikipedia.py`. It comes from `mv tests/test_wikipedia.py tests/test_wikirandom.py`. [The file](https://github.com/rahuldave/smallwikiapp/blob/008e616610b0829196a2f61182e45255015b95c1/tests/test_wikirandom.py).

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/008e616610b0829196a2f61182e45255015b95c1). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/008e616610b0829196a2f61182e45255015b95c1).

<a id="step-09.10"></a>

### 9.10 The docs check counts the library

The settings of the site, `docs/_smalldocs.yml`, name only `wikiapp`, so the docs and their check leave out the
library. The line `packages:` in the section `api` must name both.

Apply the patch to [`docs/_smalldocs.yml`](#step-09.10-docs-_smalldocs.yml-4b0b48), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/259e6364a52f83993c797f66148281b04eb92060.diff | git apply --include=docs/_smalldocs.yml
```

The patch changes one line, `packages:` in the section `api`, in line 19.

```bash
just docs check
just docs
grep -o 'href="api/wikirandom.html#random_page"' docs/_site/index.html | head -n 1
just check
```

The docs check has a line for `wikirandom`, `3 of 3`, and prints `15 of 15` in all. `just docs` writes 3
pages, and grep finds the link from `random_page` on the front page to its entry in `api/wikirandom.html`.
`just check` passes.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 259e6364a52f
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 008e616610b0 --staged -- :/ && git restore --source step-09 --staged --worktree -- :/
```

#### What changed

- <a id="step-09.10-docs-_smalldocs.yml-4b0b48"></a>`docs/_smalldocs.yml`: the list of packages. 1 line added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/259e6364a52f83993c797f66148281b04eb92060/docs/_smalldocs.yml).
  - look at `packages: [wikiapp, wikirandom]  # the app, and the library in packages/wikirandom`

<a id="step-09.10-docs-_smalldocs.yml-4b0b48-diff"></a>

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

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/259e6364a52f83993c797f66148281b04eb92060).

This part ends at the code at `step-09`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-09)

<a id="step-10"></a>

## 10 Build

This walk goes through [rahuldave/smallwikiapp](https://github.com/rahuldave/smallwikiapp) on GitHub. This part starts from the code at `step-09`. [The code before this part](https://github.com/rahuldave/smallwikiapp/tree/step-09)

```bash
just setup
```

Nobody can install the two packages without this repository, because nothing builds them into the files that pip
and uv install. So we build each package into a wheel and a source archive, and read what the wheels say. Then the
app says which versions of the library it accepts, and `just lint-config` checks the library's `pyproject.toml`
too. Both packages say their licence and where their source is. Last, the library's User-Agent says the version
that is installed.

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
git fetch --quiet --tags --force origin; git restore --source step-09 --staged -- :/ && git restore --source 7744a84a4715 --staged --worktree -- :/
```

#### What changed

- <a id="step-10.1-justfile-424f0b"></a>`justfile`: the recipe `build`. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/7744a84a4715e6edb876e1c4f3255daf524dd07d/justfile).
  - look at `build *args:`

<a id="step-10.1-justfile-424f0b-diff"></a>

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

<a id="step-10.2-pyproject.toml-5d07e7-diff"></a>

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

<a id="step-10.3-justfile-424f0b-diff"></a>

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

<a id="step-10.4"></a>

### 10.4 A licence for the library, and a repository link for both

The library's wheel has no licence and no author, and neither package says where its source is. PyPI shows all
three on the page of a package. The library gets a copy of the project's `LICENSE`.

```bash
cp LICENSE packages/wikirandom/LICENSE
```

Its `pyproject.toml` gives the licence and the author in `[project]`, as the app's `pyproject.toml` does. Both
`pyproject.toml` files name the repository, in a table `[project.urls]`.

Set the values that this change sets in [`packages/wikirandom/pyproject.toml`](#step-10.4-packages-wikirandom-pyproject.toml-28d6f6). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('packages/wikirandom/pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '2c03603dc72a:packages/wikirandom/pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('project', 'license'),
    ('project', 'license-files'),
    ('project', 'authors'),
    ('project', 'urls'),
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

Set the values that this change sets in [`pyproject.toml`](#step-10.4-pyproject.toml-5d07e7). Run this command from the top of the project. It reads your file with tomlkit, a library for TOML files. It copies each of these tables and values from the project's file after this change, with their comments, and keeps the rest of your file:

```bash
uv run --quiet --no-config --no-project --with tomlkit python - <<'PY'
import copy, pathlib, subprocess, tomlkit
from tomlkit.items import Comment, Table, Whitespace
path = pathlib.Path('pyproject.toml')
doc = tomlkit.parse(path.read_text(encoding='utf-8')) if path.exists() else tomlkit.document()
# The project's file after this change, from your clone
project = tomlkit.parse(subprocess.run(['git', 'show', '2c03603dc72a:pyproject.toml'], capture_output=True, text=True,
                                        check=True).stdout)
# Each table and value that the change sets, by its keys: each comes from the project's file with its comments
COPY = [
    ('project', 'urls'),
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

In `packages/wikirandom/pyproject.toml`, the change adds the licence, its file and the author to `[project]`, and
the table `[project.urls]`. The app's `pyproject.toml` gets the same table.

```bash
just build
unzip -p dist/wikirandom-0.1.0-py3-none-any.whl wikirandom-0.1.0.dist-info/METADATA
```

The library's metadata has `License-Expression: Apache-2.0`,
`License-File: LICENSE` and `Project-URL: Repository, https://github.com/rahuldave/smallwikiapp`.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 2c03603dc72a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git restore --source 522bcb941336 --staged -- :/ && git restore --source 2c03603dc72a --staged --worktree -- :/
```

#### What changed

- <a id="step-10.4-packages-wikirandom-LICENSE-56404f"></a>`packages/wikirandom/LICENSE`: the same Apache-2.0 licence as the app's. New, 202 lines. It comes from `cp LICENSE packages/wikirandom/LICENSE`. [The file](https://github.com/rahuldave/smallwikiapp/blob/2c03603dc72a212f1575459528b3d269bb52be0d/packages/wikirandom/LICENSE).
  - look at `Apache License`
- <a id="step-10.4-packages-wikirandom-pyproject.toml-28d6f6"></a>`packages/wikirandom/pyproject.toml`: what PyPI would show. 6 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/2c03603dc72a212f1575459528b3d269bb52be0d/packages/wikirandom/pyproject.toml).
  - look at `license = "Apache-2.0"`
- <a id="step-10.4-pyproject.toml-5d07e7"></a>`pyproject.toml`: the app's repository. 3 lines added. [The file](https://github.com/rahuldave/smallwikiapp/blob/2c03603dc72a212f1575459528b3d269bb52be0d/pyproject.toml).
  - look at `[project.urls]`

<a id="step-10.4-packages-wikirandom-LICENSE-56404f-diff"></a>

<details><summary>The diff that <code>cp LICENSE packages/wikirandom/LICENSE</code> makes in <code>packages/wikirandom/LICENSE</code></summary>

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

<a id="step-10.4-packages-wikirandom-pyproject.toml-28d6f6-diff"></a>

<details open><summary>The patch to <code>packages/wikirandom/pyproject.toml</code></summary>

```diff
@@ -3,12 +3,18 @@ name = "wikirandom"
 version = "0.1.0"
 description = "A random page of Wikipedia, in any language"
 readme = "README.md"
+license = "Apache-2.0"
+license-files = ["LICENSE"]
+authors = [{ name = "Rahul Dave" }]
 requires-python = ">=3.11"
 dependencies = [
     "pydantic>=2.14.1",
     "requests>=2.34.2",
 ]
 
+[project.urls]
+Repository = "https://github.com/rahuldave/smallwikiapp"
+
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
```

</details>

<a id="step-10.4-pyproject.toml-5d07e7-diff"></a>

<details open><summary>The patch to <code>pyproject.toml</code></summary>

```diff
@@ -15,6 +15,9 @@ dependencies = [
 [project.scripts]
 wikiapp = "wikiapp.console:main"
 
+[project.urls]
+Repository = "https://github.com/rahuldave/smallwikiapp"
+
 [build-system]
 requires = ["uv_build>=0.12.13,<0.13.0"]
 build-backend = "uv_build"
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/2c03603dc72a212f1575459528b3d269bb52be0d). [The code after it](https://github.com/rahuldave/smallwikiapp/tree/2c03603dc72a212f1575459528b3d269bb52be0d).

<a id="step-10.5"></a>

### 10.5 The User-Agent says the installed version

The library's User-Agent says `0.1.0`, written by hand. After a change of the version in
`packages/wikirandom/pyproject.toml`, it would still say `0.1.0`. So the library reads its version from the
installed package, as `wikiapp --version` does. `VERSION` is the installed version, and `USER_AGENT` contains it.

Apply the patch to [`packages/wikirandom/src/wikirandom/__init__.py`](#step-10.5-packages-wikirandom-src-wikirandom-__init__.py-343c23), from the top of the project:

```bash
curl -fsSL https://github.com/rahuldave/smallwikiapp/commit/73fc4e12cc7a5831163e61fc01a3699355f95d52.diff | git apply --include=packages/wikirandom/src/wikirandom/__init__.py
```

The patch adds `import importlib.metadata` above `import re`, and puts two lines, `VERSION = ...` and
`USER_AGENT = ...`, in place of the old `USER_AGENT = ...`.

```bash
uv run python -c "import wikirandom; print(wikirandom.USER_AGENT)"
just check
```

The first command prints `wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)`, and `just check` passes.

Check your files against this move. The command prints nothing when they match, and otherwise shows what differs:

```bash
git check 73fc4e12cc7a
```

If you are stuck, this command puts the files of this move in place of yours. A file that you made yourself stays:

```bash
git fetch --quiet --tags --force origin; git restore --source 2c03603dc72a --staged -- :/ && git restore --source step-10 --staged --worktree -- :/
```

#### What changed

- <a id="step-10.5-packages-wikirandom-src-wikirandom-__init__.py-343c23"></a>`packages/wikirandom/src/wikirandom/__init__.py`: the version now comes from one place, the library's `pyproject.toml`. 3 lines added, 1 removed. [The file](https://github.com/rahuldave/smallwikiapp/blob/73fc4e12cc7a5831163e61fc01a3699355f95d52/packages/wikirandom/src/wikirandom/__init__.py).
  - look at `VERSION = importlib.metadata.version("wikirandom")`

<a id="step-10.5-packages-wikirandom-src-wikirandom-__init__.py-343c23-diff"></a>

<details open><summary>The patch to <code>packages/wikirandom/src/wikirandom/__init__.py</code></summary>

```diff
@@ -1,5 +1,6 @@
 """wikirandom: a random page of Wikipedia, in any language, from its REST API."""
 
+import importlib.metadata
 import re
 
 import requests
@@ -7,7 +8,8 @@ from pydantic import BaseModel, ValidationError
 
 API_URL = "https://{language}.wikipedia.org/api/rest_v1/page/random/summary"
 LANGUAGE = re.compile(r"[a-z]+(-[a-z]+)*")  # en, fr, simple, zh-yue: letters and hyphens
-USER_AGENT = "wikirandom/0.1.0 (https://github.com/rahuldave/smallwikiapp)"
+VERSION = importlib.metadata.version("wikirandom")
+USER_AGENT = f"wikirandom/{VERSION} (https://github.com/rahuldave/smallwikiapp)"
 
 
 class WikipediaError(Exception):
```

</details>

[This change on GitHub](https://github.com/rahuldave/smallwikiapp/commit/73fc4e12cc7a5831163e61fc01a3699355f95d52).

This part ends at the code at `step-10`. [The code after this part](https://github.com/rahuldave/smallwikiapp/tree/step-10)
